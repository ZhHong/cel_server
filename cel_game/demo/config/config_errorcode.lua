local errorcode = {
    SUCCESS = 0,
    ERROR = 1,
    PARAM_ERROR = 1001,
    FUNCTION_ERROR = 1002,

    --app server
    PLATFORM_NOT_FOUND = 30001,
    PLATFORM_CALL_FAILED = 30002,
    PLATFORM_UID_FAILED = 30003,
}
return errorcode
