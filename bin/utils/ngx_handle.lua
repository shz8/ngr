local logger = require("bin.utils.logger")
local pairs = pairs
local os = os
local error = error
local string_format = string.format
local setmetatable =  setmetatable

local function create_dirs(necessary_dirs)
    if necessary_dirs then
        for _, dir in pairs(necessary_dirs) do
            os.execute("mkdir -p " .. dir .. " > /dev/null")
        end
    end
end

local function ngx_command(args)
    if not args then 
        error("error args to execute nginx command.") 
        os.exit(1)
    end

    local prefix, ngx_conf, ngx_signal =  "", "", ""
    local logger_info = ""
    if args.ngr_conf ~= nil and args.ngx_signal ~= "reload" and args.ngx_signal ~= "stop" then
        logger_info = logger_info .. "CONF=" .. args.ngr_conf .. " "
    end
    if args.prefix then
        prefix = "-p " .. args.prefix
        logger_info = logger_info .. "PREFIX=" .. args.prefix
    end
    if args.ngx_conf then
        ngx_conf = "-c " .. args.ngx_conf
    end
    -- ngx master signal
    if args.ngx_signal then
        ngx_signal = "-s " .. args.ngx_signal
    end


    local cmd = string_format("nginx %s %s %s", prefix, ngx_conf, ngx_signal)
    local execute_logger = string_format("Using Parameters: %s", logger_info)
    logger:info(execute_logger)
    return os.execute(cmd)
end


local _M = {}

function _M:new(args)
    local instance = {
        ngr_conf = args.ngr_conf,
        prefix = args.prefix,
        ngx_conf = args.ngx_conf,
        necessary_dirs = args.necessary_dirs
    }

    setmetatable(instance, { __index = self })
    return instance
end

-- start nginx
function _M:start()
    logger:info("Starting NgrRouter......")
    create_dirs(self.necessary_dirs)

    return ngx_command({
        ngr_conf = self.ngr_conf or nil,
        prefix = self.prefix or nil,
        ngx_conf = self.ngx_conf,
        ngx_signal = nil
    })
end

-- execute nginx stop signal
function _M:stop()
    logger:info("Stopping NgrRouter......")
    return ngx_command({
        ngr_conf = self.ngr_conf or nil,
        prefix = self.prefix or nil,
        ngx_conf = self.ngx_conf,
        ngx_signal = "stop"
    })
end

-- execute nginx reload signal
function _M:reload()
    logger:info("Reloading NgrRouter.......")
    create_dirs(self.necessary_dirs)
    return ngx_command({
        ngr_conf = self.ngr_conf or nil,
        prefix = self.prefix or nil,
        ngx_conf = self.ngx_conf,
        ngx_signal = "reload"
    })
end

return _M
