local skynet = require "skynet"
require "skynet.manager"
--local util = require "util"
local constant = require "config_constant"

local command = {}

-- 获取key
local function getPlayerInfoKey(player_key) return "player_info_" .. player_key end
local function getLastSubmitKey(player_key) return "last_submit_" .. player_key end
local function getTopListKey(toplist_key) return "toplist_" .. toplist_key end

function command.updatePlayerInfo(data)
  --[[
      同步玩家的信息
      [唯一ID, 详细信息]
  --]]
  local player_id, player_info = table.unpack(data)
  local player_info_key = getPlayerInfoKey(player_id)
  skynet.call("centerdb", "lua", "set", player_info_key, player_info)

  -- 不需要回包
  return nil
end

function command.submitScore(data)
  --[[
      玩家提交积分
      [playerID, score]
  --]]
  local player_id, score = table.unpack(data)
  local last_tick = os.time();
  local toplist_key = getTopListKey(1)
  skynet.call("centerdb", "lua", "zadd", toplist_key, score, player_id)

  local last_submit_key = getLastSubmitKey(player_id)
  skynet.call("centerdb", "lua", "set", last_submit_key, last_tick)
  
  -- 不需要回包
  return nil
end

local function topSort(top_a, top_b)
  -- 排序比较函数
  if top_a[2] == top_b[2] then
    return top_a[4] < top_b[4]
  else
    return top_a[2] > top_b[2]
  end
end

local function sortTopList(fans_top, min, max)
  --[[
      将相同排名的粉丝排名，按照最后贡献时间重新排序
  --]]
  --按最后提交成绩时间排序
  table.sort(fans_top, topSort)

  local rank = 1 + min
  
  for rank, fans_info in ipairs(fans_top) do
    if rank + min > max + 1 then
      break
    end
    --加入排名
    table.insert(fans_info, 1, rank + min)
    --删除时间戳
    table.remove(fans_info, 5)
  end

  --return fans_top
end

function command.getTopList(data)
  --[[
      获取排行榜
      { sort_by_time, min, max }
      { mod, action, {{top_info}} }
      top_info : [rank, player_key, socre, fans_info]
  --]]
  local res_table = {}
  local sort_by_time, min, max = table.unpack(data)
  if sort_by_time == 0 then -- 不需要按时间排序
    local toplist_key = getTopListKey(1)
    local top_list = skynet.call("centerdb", "lua", "ZREVRANGE", toplist_key, min, max, "WITHSCORES")

    local rank = 1 + min
    for i = 1, #top_list, 2 do
      local player_key = top_list[i]
      local sorce = top_list[i+1]
      local player_info_key = getPlayerInfoKey(player_key)
      local player_info = skynet.call("centerdb", "lua", "get", player_info_key)
      if player_info == nil then
        player_info = ''
      end
      local top_info = {rank, player_key, tonumber(sorce), player_info}
      table.insert(res_table, top_info)
      rank = rank + 1
    end
  else -- 相同积分按时间排序
    local toplist_key = getTopListKey(1)
    local min_sorce_player = skynet.call("centerdb", "lua", "ZREVRANGE", toplist_key, max, max, "WITHSCORES")
    local max_sorce_player = skynet.call("centerdb", "lua", "ZREVRANGE", toplist_key, min, min, "WITHSCORES")
    if #max_sorce_player ~= 2 then
      --查询区间内没有符合的玩家
      return {10, 81, {res_table}}
    end
    local max_sorce = max_sorce_player[2]
    local top_list = {}
    if #min_sorce_player == 2 then
      local min_sorce = min_sorce_player[2]
      top_list = skynet.call("centerdb", "lua", "ZREVRANGEBYSCORE", toplist_key, max_sorce, min_sorce, "WITHSCORES")
    else
      top_list = skynet.call("centerdb", "lua", "ZREVRANGE", toplist_key, min, max, "WITHSCORES")
    end

    for i = 1, #top_list, 2 do
      local player_key = top_list[i]
      local sorce = top_list[i+1]
      local player_info_key = getPlayerInfoKey(player_key)
      local player_info = skynet.call("centerdb", "lua", "get", player_info_key)
      if player_info == nil then
        player_info = ''
      end
      local last_submit_key = getLastSubmitKey(player_key)
      local last_submit = skynet.call("centerdb", "lua", "get", last_submit_key)
      if last_submit == nil then
        last_submit = 0
      end
      local top_info = {player_key, tonumber(sorce), fans_info, tonumber(last_submit)}
      table.insert(res_table, top_info)
    end

    sortTopList(res_table, min, max)
  end
  
  -- 回包
  return {10, 81, {res_table}}
end

function command.getPlayerInfoById(data)
  --[[
      10-88 根据ID获取玩家信息
      { player_key }
  --]]
  local player_key = table.unpack(data)
  local player_info_key = getFansInfoKey(player_key)
  local player_info = skynet.call("centerdb", "lua", "get", player_info_key)
  if player_info == nil then
    player_info = ''
  end

  -- 回包
  return {10, 88, {self_sid, self_pid, player_key, player_info}}
end

skynet.start(function()
	skynet.dispatch("lua", function(session, address, cmd, ...)
		local f = command[cmd]
		if f then
			skynet.ret(skynet.pack(f(...)))
		else
			print("wrong command in toplist:",cmd)
		end
	end)
	skynet.register ".toplist"
	
end)
