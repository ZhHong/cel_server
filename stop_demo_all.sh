if [ "`ps -ef|grep './skynet'|grep -v grep|awk '{print $2}'`" != "" ]; then
        ps -ef|grep './skynet'|grep -v grep|awk '{print $2}'|xargs kill
fi

