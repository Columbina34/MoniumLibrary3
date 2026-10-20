local Monium = {
    Name    = "Monium Library",
    Version = "1.0.0",
    Build   = tostring(os.time()) .. "-" .. tostring(math.random(100000, 999999)),
}

local ENV = {}
do
    ENV.newcclosure     = newcclosure or function(f) return f end
    ENV.checkcaller     = checkcaller or function() return true end
    ENV.hookfunction    = hookfunction or replaceclosure or function() end
    ENV.getrawmeta      = getrawmetatable or function() return nil end
    ENV.setreadonly     = setreadonly
    ENV.isreadonly      = isreadonly
    ENV.identify        = identifyexecutor or getexecutorname or function() return "Unknown" end
    ENV.getgc           = getgc or function() return {} end
    ENV.getgenv         = getgenv or function() return _G end
    ENV.getreg          = getreg or debug.getregistry
    ENV.getupvalue      = debug.getupvalue
    ENV.getlocal        = debug.getlocal
    ENV.setupvalue      = debug.setupvalue
    ENV.traceback       = debug.traceback
    ENV.info            = debug.info
    ENV.getcallingscript = getcallingscript
    ENV.loadstring      = loadstring or load
    ENV.setfenv         = setfenv
    ENV.getfenv         = getfenv
    ENV.writefile       = writefile
    ENV.readfile        = readfile
    ENV.isfile          = isfile
    ENV.makefolder      = makefolder
    ENV.isfolder        = isfolder
    ENV.appendfile      = appendfile
    ENV.delfile         = delfile
    ENV.listfiles       = listfiles
    ENV.setclipboard    = setclipboard or toclipboard
    ENV.getclipboard    = getclipboard
    ENV.gethui          = gethui
    ENV.httpget         = httpget or syn and syn.request or http and http.request
    ENV.request         = request or http_request or syn and syn.request
    ENV.bit32           = bit32 or bit
    ENV.os_clock        = os.clock
    ENV.os_time         = os.time
    ENV.os_date         = os.date
    ENV.table_freeze    = table.freeze or function(t) return t end
    ENV.table_isfrozen  = table.isfrozen or function() return false end
    ENV.table_clone     = table.clone or function(t)
        local c = {}
        for k, v in pairs(t) do c[k] = v end
        return c
    end
    ENV.cloneref        = cloneref or function(o) return o end
    ENV.task_wait       = task.wait
    ENV.task_spawn      = task.spawn
    ENV.task_delay      = task.delay
    ENV.task_defer      = task.defer
    ENV.string_byte     = string.byte
    ENV.string_char     = string.char
    ENV.string_format   = string.format
    ENV.string_gsub     = string.gsub
    ENV.string_match    = string.match
    ENV.string_sub      = string.sub
    ENV.string_rep      = string.rep
    ENV.math_floor      = math.floor
    ENV.math_random     = math.random
    ENV.math_max        = math.max
    ENV.math_min        = math.min
    ENV.select          = select
    ENV.pcall           = pcall
    ENV.xpcall          = xpcall
    ENV.type            = type
    ENV.tostring        = tostring
    ENV.tonumber        = tonumber
    ENV.rawget          = rawget
    ENV.rawset          = rawset
    ENV.rawequal        = rawequal
    ENV.rawlen          = rawlen
    ENV.unpack          = table.unpack or unpack
    ENV.pack            = table.pack or function(...) return {n = select("#", ...), ...} end
end

ENV.has_unc      = type(newcclosure) == "function" and type(checkcaller) == "function"
ENV.has_file_io  = type(writefile) == "function" and type(readfile) == "function"
ENV.has_http     = type(request) == "function" or type(http_request) == "function"
ENV.has_clip     = type(setclipboard) == "function" or type(toclipboard) == "function"
ENV.has_hui      = type(gethui) == "function"

local Services = {}
do
    local ok, svc = pcall(function()
        return {
            Players      = ENV.cloneref(game:GetService("Players")),
            TweenService = ENV.cloneref(game:GetService("TweenService")),
            UIS          = ENV.cloneref(game:GetService("UserInputService")),
            Lighting     = ENV.cloneref(game:GetService("Lighting")),
            RunService   = ENV.cloneref(game:GetService("RunService")),
            CoreGui      = ENV.cloneref(game:GetService("CoreGui")),
            HttpService  = ENV.cloneref(game:GetService("HttpService")),
            Teleport     = ENV.cloneref(game:GetService("TeleportService")),
            StarterGui   = ENV.cloneref(game:GetService("StarterGui")),
            ReplicatedStorage = ENV.cloneref(game:GetService("ReplicatedStorage")),
        }
    end)
    if ok and svc then
        Services = svc
    end
end
Monium.Services = Services

local LocalPlayer
do
    local ok, lp = pcall(function() return Services.Players.LocalPlayer end)
    if ok then LocalPlayer = lp end
end

local function get_gui_parent()
    if ENV.gethui then
        local ok, hui = pcall(ENV.gethui)
        if ok and hui then return hui end
    end
    if Services.CoreGui then
        local ok, cg = pcall(function() return Services.CoreGui end)
        if ok and cg then return cg end
    end
    if LocalPlayer then
        return LocalPlayer:WaitForChild("PlayerGui")
    end
    return game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local Logger = {}
do
    local entries = {}
    local MAX = 500
    local tag = "[Monium] "
    local enabled = true

    local LEVELS = { INFO = 1, WARN = 2, ERROR = 3, DEBUG = 0 }

    local function push(level, msg)
        if not enabled then return end
        if #entries >= MAX then
            table.remove(entries, 1)
        end
        table.insert(entries, {
            lvl = level,
            msg = tostring(msg),
            t   = ENV.os_clock(),
        })
    end

    function Logger.info(msg)
        push("INFO", msg)
        print(tag .. msg)
    end
    function Logger.warn(msg)
        push("WARN", msg)
        warn(tag .. msg)
    end
    function Logger.error(msg)
        push("ERROR", msg)
        warn(tag .. "ERROR: " .. msg)
    end
    function Logger.debug(msg)
        push("DEBUG", msg)
        if Monium._debug then print(tag .. "DEBUG: " .. msg) end
    end
    function Logger.get()
        local copy = {}
        for i, e in ipairs(entries) do
            copy[i] = { lvl = e.lvl, msg = e.msg, t = e.t }
        end
        return copy
    end
    function Logger.clear()
        table.clear(entries)
    end
    function Logger.setEnabled(v) enabled = v end
    function Logger.isEnabled() return enabled end
end
Monium.Logger = Logger

local Encoding = {}

-- Base64
do
    local B64C = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local B64D = {}
    for i = 1, #B64C do B64D[B64C:sub(i, i)] = i - 1 end

    function Encoding.base64_encode(s)
        return ((s:gsub('.', function(x)
            local r, b = '', x:byte()
            for i = 8, 1, -1 do r = r .. (b % 2^i - b % 2^(i-1) > 0 and '1' or '0') end
            return r
        end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
            if #x < 6 then return '' end
            local c = 0
            for i = 1, 6 do c = c + (x:sub(i, i) == '1' and 2^(6-i) or 0) end
            return B64C:sub(c+1, c+1)
        end) .. ({'', '==', '='})[#s % 3 + 1])
    end

    function Encoding.base64_decode(s)
        s = s:gsub('[^' .. B64C:gsub('%+', '%%+') .. '=]', '')
        return (s:gsub('.', function(x)
            if x == '=' then return '' end
            local r, f = '', (B64D[x] or 0)
            for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0') end
            return r
        end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
            if #x ~= 8 then return '' end
            local c = 0
            for i = 1, 8 do c = c + (x:sub(i, i) == '1' and 2^(8-i) or 0) end
            return string.char(c)
        end))
    end
end

do
    function Encoding.hex_encode(s)
        return (s:gsub('.', function(c)
            return string.format("%02x", c:byte())
        end))
    end

    function Encoding.hex_decode(s)
        return (s:gsub("%x%x", function(cc)
            return string.char(tonumber(cc, 16))
        end))
    end
end

do
    function Encoding.xor_string(s, key)
        if #key == 0 then return s end
        local out = {}
        for i = 1, #s do
            local k = key:byte(((i - 1) % #key) + 1)
            out[i] = string.char(bit32 and bit32.bxor(s:byte(i), k) or (s:byte(i) ~ k))
        end
        return table.concat(out)
    end

    function Encoding.xor_bytes(bytes, key)
        local out = {}
        for i, b in ipairs(bytes) do
            local k = key:byte(((i - 1) % #key) + 1)
            out[i] = bit32 and bit32.bxor(b, k) or (b ~ k)
        end
        return out
    end
end

do
    local URL_SAFE = "^[%w%-%._~]$"
    function Encoding.url_encode(s)
        return (s:gsub("([^%w%-%._~])", function(c)
            return string.format("%%%02X", c:byte())
        end))
    end
    function Encoding.url_decode(s)
        return (s:gsub("%%(%x%x)", function(h)
            return string.char(tonumber(h, 16))
        end))
    end
end

Monium.Encoding = Encoding

local StringPool = {}
do
    local POOL_KEY = "\x4D\x6F\x6E\x69\x75\x6D\x2D\x53\x74\x72\x50\x6F\x6F\x6C\x2D\x76\x34" 
    local pool = {}
    local counter = 0

    local function scramble(s)
        local xored = Encoding.xor_string(s, POOL_KEY)
        return Encoding.base64_encode(xored)
    end

    local function unscramble(s)
        local decoded = Encoding.base64_decode(s)
        return Encoding.xor_string(decoded, POOL_KEY)
    end

    function StringPool.register(plain)
        counter = counter + 1
        local id = "__sp" .. counter
        pool[id] = scramble(plain)
        return id
    end

    function StringPool.resolve(id)
        return unscramble(pool[id] or "")
    end

    local SENSITIVE = {
        "getStatus", "destroy", "verify", "challenge", "respond",
        "selfTest", "getLog", "register", "unregister",
        "auth", "fingerprint", "master", "internal", "protected",
    }
    local REGISTRY = {}
    for _, s in ipairs(SENSITIVE) do
        REGISTRY[s] = StringPool.register(s)
    end
    StringPool.ids = REGISTRY
end
Monium.StringPool = StringPool

local Hash = {}
do
    local b32 = ENV.bit32 or {
        bxor = function(a, b) return (a ~ b) % 4294967296 end,
        band = function(a, b) return (a & b) % 4294967296 end,
        rshift = function(a, n) return math.floor(a / 2^n) % 4294967296 end,
        lshift = function(a, n) return (a * 2^n) % 4294967296 end,
    }

    function Hash.fnv1a(s, seed)
        local h = seed or 2166136261
        for i = 1, #s do
            h = b32.bxor(h, s:byte(i))
            h = math.floor((h * 16777619) % 4294967296)
        end
        return h
    end

    function Hash.djb2(s, seed)
        local h = seed or 5381
        for i = 1, #s do
            h = math.floor((h * 33 + s:byte(i)) % 4294967296)
        end
        return h
    end

    function Hash.sdbm(s, seed)
        local h = seed or 0
        for i = 1, #s do
            h = math.floor((s:byte(i) + (h * 65599)) % 4294967296)
        end
        return h
    end

    function Hash.jenkins_one_at_a_time(s, seed)
        local h = seed or 0
        for i = 1, #s do
            h = (h + s:byte(i)) % 4294967296
            h = (h + b32.lshift(h, 10)) % 4294967296
            h = b32.bxor(h, b32.rshift(h, 6))
        end
        h = (h + b32.lshift(h, 3)) % 4294967296
        h = b32.bxor(h, b32.rshift(h, 11))
        h = (h + b32.lshift(h, 15)) % 4294967296
        return h
    end

    function Hash.murmur_lite(s, seed)
        local h = seed or 0x9747b28c
        for i = 1, #s do
            local k = s:byte(i) * 0xcc9e2d51
            k = math.floor(k % 4294967296)
            k = b32.bxor(k, b32.rshift(k, 15))
            k = math.floor((k * 0x1b873593) % 4294967296)
            h = b32.bxor(h, k)
            h = math.floor((h * 5 + 0xe6546b64) % 4294967296)
            h = b32.bxor(h, b32.rshift(h, 16))
        end
        h = b32.bxor(h, #s)
        h = b32.bxor(h, b32.rshift(h, 16))
        h = math.floor((h * 0x85ebca6b) % 4294967296)
        h = b32.bxor(h, b32.rshift(h, 13))
        h = math.floor((h * 0xc2b2ae35) % 4294967296)
        h = b32.bxor(h, b32.rshift(h, 16))
        return h
    end

    function Hash.composite(s)
        local a = Hash.fnv1a(s)
        local b = Hash.djb2(s)
        local c = Hash.jenkins_one_at_a_time(s)
        local d = Hash.murmur_lite(s)
        return string.format("%08x%08x%08x%08x", a, b, c, d)
    end

    function Hash.mix(s, seed)
        local h = Hash.fnv1a(s, seed or 0x5bd1e995)
        h = b32.bxor(h, b32.rshift(h, 16))
        h = math.floor((h * 0x85ebca6b) % 4294967296)
        h = b32.bxor(h, b32.rshift(h, 13))
        h = math.floor((h * 0xc2b2ae35) % 4294967296)
        h = b32.bxor(h, b32.rshift(h, 16))
        return h
    end
end
Monium.Hash = Hash

local Crypto = {}
do
    function Crypto.entropy_pool()
        return table.concat({
            tostring(ENV.os_clock()),
            tostring(ENV.os_time()),
            tostring(ENV.math_random(1, 2^30)),
            tostring(ENV.tostring(Monium):gsub("table: ", "")),
            tostring(ENV.tostring({}):gsub("table: ", "")),
            tostring(ENV.tostring(function() end)),
            tostring(ENV.identify()),
            tostring(ENV.math_random(2^15, 2^30)),
            tostring(ENV.os_clock() * 1000),
        }, "|")
    end

    function Crypto.derive(parent, purpose)
        local h = Hash.mix(parent .. "||" .. purpose, 0x5bd1e995)
        local parts = {}
        for r = 1, 8 do
            h = Hash.mix(tostring(h) .. purpose .. r, h)
            parts[r] = string.format("%08x", h)
        end
        return table.concat(parts)
    end

    function Crypto.hmac(key, msg)
        local ipad = Crypto.derive(key, "ipad")
        local opad = Crypto.derive(key, "opad")
        local inner = Hash.mix(ipad .. "||" .. msg, 0)
        local outer = Hash.mix(opad .. "||" .. tostring(inner), 0)
        return string.format("%08x%08x", inner, outer)
    end

    function Crypto.nonce()
        local raw = table.concat({
            tostring(ENV.os_clock()),
            tostring(ENV.math_random(2^30)),
            tostring(ENV.math_random(2^30)),
        }, "~")
        return Encoding.base64_encode(raw)
    end

    function Crypto.random_id(len)
        local chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        local out = {}
        for i = 1, (len or 16) do
            local idx = ENV.math_random(1, #chars)
            out[i] = chars:sub(idx, idx)
        end
        return table.concat(out)
    end
end
Monium.Crypto = Crypto

local Protection = {}
do
    local protected = {}
    local signatures = {}

    function Protection.protect(fn, name)
        if type(fn) ~= "function" then return fn end
        protected[fn] = true
        if name then signatures[name] = fn end
        return fn
    end

    function Protection.isProtected(fn)
        return protected[fn] == true
    end

    function Protection.register(name, fn)
        signatures[name] = fn
        protected[fn] = true
    end

    function Protection.checkIntegrity()
        for name, expected in pairs(signatures) do
        end
        return true
    end

    function Protection.verifySignature(name, current)
        local expected = signatures[name]
        if expected == nil then return false, "unknown" end
        return expected == current, expected == current and "ok" or "mismatch"
    end
end
Monium.Protection = Protection

local AntiDebug = {}
do
    local installed = false
    local detections = {}

    function AntiDebug.install()
        if installed then return end
        installed = true

        if ENV.getupvalue and ENV.hookfunction then
            local orig = ENV.getupvalue
            local hooked = ENV.newcclosure(function(f, idx, ...)
                if Protection.isProtected(f) then
                    return nil
                end
                return orig(f, idx, ...)
            end)
            Protection.protect(hooked)
            pcall(ENV.hookfunction, orig, hooked)
        end

        if ENV.getlocal and ENV.hookfunction then
            local orig = ENV.getlocal
            local hooked = ENV.newcclosure(function(f, idx, ...)
                if Protection.isProtected(f) then
                    return nil
                end
                return orig(f, idx, ...)
            end)
            Protection.protect(hooked)
            pcall(ENV.hookfunction, orig, hooked)
        end

        if ENV.setupvalue and ENV.hookfunction then
            local orig = ENV.setupvalue
            local hooked = ENV.newcclosure(function(f, idx, val)
                if Protection.isProtected(f) then
                    detections[#detections+1] = { t = ENV.os_clock(), kind = "setupvalue" }
                    return nil
                end
                return orig(f, idx, val)
            end)
            Protection.protect(hooked)
            pcall(ENV.hookfunction, orig, hooked)
        end
    end

    function AntiDebug.getDetections()
        local copy = {}
        for i, d in ipairs(detections) do copy[i] = { t = d.t, kind = d.kind } end
        return copy
    end

    function AntiDebug.clearDetections() table.clear(detections) end
end
Monium.AntiDebug = AntiDebug


local AntiHook = {}
do
    local watched = {}

    function AntiHook.watch(name, fn)
        watched[name] = { ref = fn, hash = Hash.composite(tostring(fn)) }
    end

    function AntiHook.verify()
        local issues = {}
        for name, rec in pairs(watched) do
            local current = rec.ref
            if type(current) ~= "function" then
                issues[#issues+1] = { name = name, kind = "missing" }
            end
        end
        return #issues == 0, issues
    end
end
Monium.AntiHook = AntiHook

local Timing = {}
do
    local sample_count = 0
    local total_time = 0
    local baseline = 0.00001

    function Timing.baseline(fn, iterations)
        iterations = iterations or 100
        local t0 = ENV.os_clock()
        for i = 1, iterations do
            pcall(fn)
        end
        local dt = ENV.os_clock() - t0
        baseline = dt / iterations
        return baseline
    end

    function Timing.check(fn, tolerance)
        tolerance = tolerance or 5
        local t0 = ENV.os_clock()
        pcall(fn)
        local dt = ENV.os_clock() - t0
        if baseline > 0 and dt > baseline * tolerance then
            return false, dt
        end
        return true, dt
    end
end
Monium.Timing = Timing

local Decoy = {}
do
    local alert_cb = nil
    local alerts = {}

    function Decoy.setAlert(cb) alert_cb = cb end
    function Decoy.getAlerts() return alerts end

    function Decoy.create(purpose)
        return setmetatable({}, {
            __index = function(_, k)
                local a = { t = ENV.os_clock(), purpose = purpose or "?", key = tostring(k), mode = "r" }
                alerts[#alerts+1] = a
                if alert_cb then pcall(alert_cb, a) end
                return nil
            end,
            __newindex = function(t, k, v)
                local a = { t = ENV.os_clock(), purpose = purpose or "?", key = tostring(k), mode = "w" }
                alerts[#alerts+1] = a
                if alert_cb then pcall(alert_cb, a) end
                ENV.rawset(t, k, v)
            end,
        })
    end
end
Monium.Decoy = Decoy

local Config = {}
do
    local ROOT = "Monium"
    local function ensure()
        if not ENV.has_file_io then return false end
        pcall(function()
            if ENV.makefolder and ENV.isfolder and not ENV.isfolder(ROOT) then
                ENV.makefolder(ROOT)
            end
        end)
        return true
    end

    local function serialize(v, depth)
        depth = depth or 0
        if depth > 10 then return "nil" end
        local t = type(v)
        if t == "string" then return string.format("%q", v) end
        if t == "number" then return tostring(v) end
        if t == "boolean" then return tostring(v) end
        if t == "nil" then return "nil" end
        if t == "table" then
            local parts = {}
            for k, val in pairs(v) do
                parts[#parts+1] = "[" .. serialize(k, depth+1) .. "]=" .. serialize(val, depth+1)
            end
            return "{" .. table.concat(parts, ",") .. "}"
        end
        return "nil"
    end

    function Config.new(scope)
        local path = ROOT .. "/" .. scope .. ".cfg"
        local data = {}
        local api = {}

        function api.set(k, v)
            data[k] = v
            if ENV.has_file_io and ENV.writefile then
                pcall(ENV.writefile, path, serialize(data))
            end
            return v
        end

        function api.get(k, d)
            if data[k] == nil then return d end
            return data[k]
        end

        function api.remove(k)
            data[k] = nil
            if ENV.has_file_io and ENV.writefile then
                pcall(ENV.writefile, path, serialize(data))
            end
        end

        function api.load()
            if not ENV.has_file_io then return false end
            if not (ENV.isfile and ENV.isfile(path)) then return false end
            local ok, content = pcall(ENV.readfile, path)
            if not ok or not content then return false end
            local chunk = ENV.loadstring("return " .. content)
            if not chunk then return false end
            local ok2, res = pcall(chunk)
            if not ok2 or type(res) ~= "table" then return false end
            for k, v in pairs(res) do data[k] = v end
            return true
        end

        function api.save()
            if not ENV.has_file_io or not ENV.writefile then return false end
            ensure()
            return pcall(ENV.writefile, path, serialize(data))
        end

        function api.all()
            local c = {}
            for k, v in pairs(data) do c[k] = v end
            return c
        end

        function api.clear()
            table.clear(data)
            if ENV.has_file_io and ENV.writefile then
                pcall(ENV.writefile, path, "{}")
            end
        end

        return api
    end
end
Monium.Config = Config

local function makeEvents()
    local subs = {}
    local api = {}

    function api.on(event, cb)
        if type(event) ~= "string" then error("event: string", 2) end
        if type(cb) ~= "function" then error("cb: function", 2) end
        subs[event] = subs[event] or {}
        table.insert(subs[event], cb)
        return function()
            local b = subs[event]
            if not b then return end
            for i = #b, 1, -1 do
                if b[i] == cb then table.remove(b, i); return end
            end
        end
    end

    function api.once(event, cb)
        local unsub
        unsub = api.on(event, function(...)
            if unsub then unsub() end
            cb(...)
        end)
        return unsub
    end

    function api.emit(event, ...)
        local b = subs[event]
        if not b then return end
        for i = 1, #b do
            local ok, err = pcall(b[i], ...)
            if not ok then Logger.warn("event " .. event .. ": " .. tostring(err)) end
        end
    end

    function api.clear(event)
        if event then subs[event] = nil else table.clear(subs) end
    end

    function api.count(event)
        return subs[event] and #subs[event] or 0
    end

    return api
end
Monium.Events = makeEvents()


local KeySystem = {}
do
    local KEY_FILE = "Monium/key.txt"
    local HASH_FILE = "Monium/key.hash"

    local VALID = {
        ["MONIUM-2025-FREE-KEY1"] = { tier = "free",    expires = nil },
        ["MONIUM-TEST-KEY0-0001"] = { tier = "premium", expires = nil },
        ["MONIUM-DEMO-KEYS-VALID"] = { tier = "admin",   expires = nil },
    }

    local used = {}

    local function ensure_dir()
        if not ENV.has_file_io then return end
        pcall(function()
            if ENV.makefolder and ENV.isfolder and not ENV.isfolder("Monium") then
                ENV.makefolder("Monium")
            end
        end)
    end

    local function normalize(k)
        if type(k) ~= "string" then return "" end
        k = k:upper():gsub("%s+", "")
        k = k:gsub("^%s*(.-)%s*$", "%1")
        return k
    end

    local function hash_key(k)
        return Hash.composite(k .. "|" .. Monium.Build)
    end

    function KeySystem.validate(raw)
        local k = normalize(raw)
        if #k < 8 then return false, "Key too short", nil end
        if not k:match("^MONIUM%-") then
            return false, "Invalid format (MONIUM-XXXX-XXXX-XXXX)", nil
        end
        local entry = VALID[k]
        if not entry then
            return false, "Key not recognized", nil
        end
        if used[k] then
            return false, "Key already used in this session", nil
        end
        if entry.expires and entry.expires < ENV.os_time() then
            return false, "Key expired", nil
        end
        used[k] = true
        return true, "OK", entry.tier
    end

    function KeySystem.save(k)
        ensure_dir()
        if ENV.writefile then
            local nk = normalize(k)
            pcall(ENV.writefile, KEY_FILE, nk)
            pcall(ENV.writefile, HASH_FILE, hash_key(nk))
        end
    end

    function KeySystem.load()
        if not ENV.has_file_io then return nil end
        local ok, k = pcall(function()
            if ENV.isfile and ENV.isfile(KEY_FILE) then return ENV.readfile(KEY_FILE) end
        end)
        if not ok or not k then return nil end
        return normalize(k)
    end

    function KeySystem.verify_saved()
        local k = KeySystem.load()
        if not k then return false end
        local ok, h = pcall(function()
            if ENV.isfile and ENV.isfile(HASH_FILE) then return ENV.readfile(HASH_FILE) end
        end)
        if not ok or not h then return false end
        if h ~= hash_key(k) then return false end
        return true, k
    end

    function KeySystem.clear()
        if ENV.writefile then
            pcall(ENV.writefile, KEY_FILE, "")
            pcall(ENV.writefile, HASH_FILE, "")
        end
    end

    function KeySystem.getTier(k)
        local entry = VALID[normalize(k)]
        return entry and entry.tier or nil
    end

    function KeySystem.listKeys()
        local out = {}
        for k, v in pairs(VALID) do out[#out+1] = { key = k, tier = v.tier } end
        return out
    end
end
Monium.Keys = KeySystem

local Sandbox = {}
do
    local BLOCKED = {
        "debug", "getfenv", "setfenv", "getmetatable", "setmetatable",
        "rawget", "rawset", "rawequal", "rawlen",
        "loadstring", "load", "require",
        "hookfunction", "hookmetamethod",
        "getrawmetatable", "setreadonly", "isreadonly",
        "getgc", "getgenv", "getreg", "getrenv",
    }

    function Sandbox.create(extra)
        local env = {}
        local safe_globals = {
            print = print,
            warn = warn,
            error = error,
            assert = assert,
            pcall = pcall,
            xpcall = xpcall,
            select = select,
            type = type,
            tostring = tostring,
            tonumber = tonumber,
            next = next,
            pairs = pairs,
            ipairs = ipairs,
            unpack = ENV.unpack,
            table = table,
            string = string,
            math = math,
            os = { time = os.time, clock = os.clock, date = os.date, difftime = os.difftime },
            task = task,
            tick = tick,
            wait = wait,
            spawn = spawn,
            delay = delay,
            Instance = Instance,
            Vector3 = Vector3,
            Vector2 = Vector2,
            CFrame = CFrame,
            Color3 = Color3,
            UDim = UDim,
            UDim2 = UDim2,
            Enum = Enum,
            game = game,
            workspace = workspace,
            script = script,
        }

        for k, v in pairs(safe_globals) do env[k] = v end
        if extra then
            for k, v in pairs(extra) do env[k] = v end
        end

        setmetatable(env, {
            __index = function(_, k)
                if BLOCKED[k] then
                    error("blocked global: " .. tostring(k), 2)
                end
                return nil
            end,
        })

        return env
    end
end
Monium.Sandbox = Sandbox

local Theme = {
    Accent   = Color3.fromRGB(125, 92, 255),
    Accent2  = Color3.fromRGB(90, 200, 255),
    Bg       = Color3.fromRGB(18, 18, 24),
    Bg2      = Color3.fromRGB(26, 26, 34),
    Bg3      = Color3.fromRGB(36, 36, 46),
    Bg4      = Color3.fromRGB(46, 46, 58),
    Text     = Color3.fromRGB(238, 238, 245),
    TextDim  = Color3.fromRGB(150, 150, 162),
    Success  = Color3.fromRGB(84, 222, 132),
    Warn     = Color3.fromRGB(250, 192, 84),
    Error    = Color3.fromRGB(255, 96, 96),
    Font     = Enum.Font.GothamMedium,
    FontBold = Enum.Font.GothamBold,
    CornerSm = UDim.new(0, 6),
    CornerMd = UDim.new(0, 10),
    CornerLg = UDim.new(0, 14),
}
Monium.Theme = Theme

local function create(class, props, children)
    local inst = Instance.new(class)
    local parent = props and props.Parent
    if props then
        for k, v in pairs(props) do
            if k ~= "Parent" then inst[k] = v end
        end
    end
    for _, c in ipairs(children or {}) do c.Parent = inst end
    if parent then inst.Parent = parent end
    return inst
end

local function tween(inst, props, dur, style, dir)
    local ti = Services.TweenService:Create(inst, TweenInfo.new(
        dur or 0.22, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out
    ), props)
    ti:Play()
    return ti
end

local function corner(r) return create("UICorner", { CornerRadius = r or Theme.CornerSm }) end
local function stroke(c, t)
    return create("UIStroke", {
        Color = c or Theme.Accent, Thickness = t or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end
local function grad(c1, c2, rot)
    return create("UIGradient", {
        Color = ColorSequence.new(c1, c2), Rotation = rot or 90,
    })
end
local function padding(t, b, l, r)
    return create("UIPadding", {
        PaddingTop = UDim.new(0, t or 0),
        PaddingBottom = UDim.new(0, b or 0),
        PaddingLeft = UDim.new(0, l or 0),
        PaddingRight = UDim.new(0, r or 0),
    })
end
local function listLayout(p, sort)
    return create("UIListLayout", {
        Padding = UDim.new(0, p or 6),
        SortOrder = sort or Enum.SortOrder.LayoutOrder,
    })
end

local Notifier = {}
do
    local gui, holder, enabled = nil, nil, true

    local function ensure()
        if gui and gui.Parent then return end
        gui = create("ScreenGui", {
            Name = "MoniumNotify",
            ResetOnSpawn = false,
            ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
            DisplayOrder = 9999,
            Parent = get_gui_parent(),
        })
        holder = create("Frame", {
            Size = UDim2.new(0, 320, 1, 0),
            Position = UDim2.new(1, -340, 0, 20),
            BackgroundTransparency = 1,
            Parent = gui,
        }, { listLayout(8) })
    end

    function Notifier.push(title, message, kind, dur)
        if not enabled then return end
        ensure()
        kind = kind or "info"
        dur = dur or 4

        local color = ({
            info    = Theme.Accent,
            success = Theme.Success,
            warn    = Theme.Warn,
            error   = Theme.Error,
        })[kind] or Theme.Accent

        local frame = create("Frame", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundColor3 = Theme.Bg2,
            BackgroundTransparency = 1,
            ClipsDescendants = true,
            Position = UDim2.new(1, 60, 0, 0),
            Parent = holder,
        }, { corner(Theme.CornerMd), stroke(Theme.Bg4, 1) })

        local bar = create("Frame", {
            Size = UDim2.new(0, 3, 1, 0),
            BackgroundColor3 = color,
            BorderSizePixel = 0,
            BackgroundTransparency = 1,
            Parent = frame,
        }, { corner(UDim.new(1, 0)) })

        local body = create("Frame", {
            Size = UDim2.new(1, -20, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            Position = UDim2.new(0, 12, 0, 8),
            BackgroundTransparency = 1,
            Parent = frame,
        }, { listLayout(3), padding(0, 8, 0, 0) })

        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 18),
            BackgroundTransparency = 1,
            Text = title,
            TextColor3 = Theme.Text,
            Font = Theme.FontBold,
            TextSize = 14,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = body,
        })
        create("TextLabel", {
            Size = UDim2.new(1, 0, 0, 0),
            AutomaticSize = Enum.AutomaticSize.Y,
            BackgroundTransparency = 1,
            Text = message,
            TextColor3 = Theme.TextDim,
            Font = Theme.Font,
            TextSize = 12,
            TextWrapped = true,
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = body,
        })

        tween(frame, { BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0) }, 0.3)
        tween(bar, { BackgroundTransparency = 0 }, 0.3)

        ENV.task_delay(dur, function()
            tween(frame, { BackgroundTransparency = 1, Position = UDim2.new(1, 60, 0, 0) }, 0.3)
            ENV.task_wait(0.4)
            frame:Destroy()
        end)
    end

    function Notifier.setEnabled(v) enabled = v end
    function Notifier.isEnabled() return enabled end
    function Notifier.clear()
        if holder then
            for _, c in ipairs(holder:GetChildren()) do
                if c:IsA("Frame") then c:Destroy() end
            end
        end
    end
end
Monium.Notify = Notifier

local function showSplash()
    local gui = create("ScreenGui", {
        Name = "MoniumSplash",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 10000,
        Parent = get_gui_parent(),
    })

    local bg = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0,
        Parent = gui,
    })
    grad(Theme.Bg, Theme.Bg3, 45).Parent = bg

    local holder = create("Frame", {
        Size = UDim2.new(0, 460, 0, 300),
        Position = UDim2.new(0.5, -230, 0.5, -150),
        BackgroundTransparency = 1,
        Parent = gui,
    }, {
        listLayout(10),
        create("UIListLayout", {
            Padding = UDim.new(0, 10),
            SortOrder = Enum.SortOrder.LayoutOrder,
            HorizontalAlignment = Enum.HorizontalAlignment.Center,
        }),
    })

    local logo = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 72),
        BackgroundTransparency = 1,
        Text = "MONIUM",
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 60,
        TextTransparency = 1,
        Parent = holder,
    })
    grad(Theme.Accent, Theme.Accent2, 45).Parent = logo

    local sub = create("TextLabel", {
        Size = UDim2.new(1, 0, 0, 22),
        BackgroundTransparency = 1,
        Text = "LIBRARY · " .. Monium.Version,
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 14,
        TextTransparency = 1,
        Parent = holder,
    })

    local bar = create("Frame", {
        Size = UDim2.new(0, 320, 0, 5),
        Position = UDim2.new(0.5, -160, 0.72, 0),
        BackgroundColor3 = Theme.Bg3,
        BorderSizePixel = 0,
        Parent = gui,
    }, { corner(UDim.new(1, 0)) })

    local fill = create("Frame", {
        Size = UDim2.new(0, 0, 1, 0),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = bar,
    }, { corner(UDim.new(1, 0)) })
    grad(Theme.Accent, Theme.Accent2, 90).Parent = fill

    local status = create("TextLabel", {
        Size = UDim2.new(0, 320, 0, 18),
        Position = UDim2.new(0.5, -160, 0.72, 14),
        BackgroundTransparency = 1,
        Text = "Initializing...",
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 11,
        TextTransparency = 1,
        Parent = gui,
    })

    tween(logo, { TextTransparency = 0 }, 0.5)
    tween(sub, { TextTransparency = 0 }, 0.5)
    ENV.task_wait(0.25)
    tween(status, { TextTransparency = 0 }, 0.3)

    local steps = {
        { 0.15, "Loading environment..." },
        { 0.30, "Snapshotting services..." },
        { 0.45, "Installing anti-debug hooks..." },
        { 0.60, "Loading string pool..." },
        { 0.75, "Checking integrity..." },
        { 0.88, "Preparing interface..." },
        { 1.00, "Ready." },
    }
    for _, s in ipairs(steps) do
        status.Text = s[2]
        tween(fill, { Size = UDim2.new(s[1], 0, 1, 0) }, 0.35)
        ENV.task_wait(0.36)
    end
    ENV.task_wait(0.2)

    tween(bg, { BackgroundTransparency = 1 }, 0.5)
    for _, obj in ipairs({ logo, sub, status }) do
        tween(obj, { TextTransparency = 1 }, 0.3)
    end
    tween(bar, { BackgroundTransparency = 1 }, 0.3)
    tween(fill, { BackgroundTransparency = 1 }, 0.3)
    ENV.task_wait(0.55)
    gui:Destroy()
end

local function showKeyScreen(onValid)
    local gui = create("ScreenGui", {
        Name = "MoniumKey",
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        DisplayOrder = 9500,
        Parent = get_gui_parent(),
    })

    local bg = create("Frame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0,
        Parent = gui,
    })
    grad(Theme.Bg, Theme.Bg3, 45).Parent = bg

    local card = create("Frame", {
        Size = UDim2.new(0, 460, 0, 380),
        Position = UDim2.new(0.5, -230, 0.5, -190),
        BackgroundColor3 = Theme.Bg2,
        BorderSizePixel = 0,
        Parent = gui,
    }, { corner(Theme.CornerLg), stroke(Theme.Accent, 1) })

    local header = create("Frame", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = Theme.Bg3,
        BorderSizePixel = 0,
        Parent = card,
    }, { corner(Theme.CornerLg) })
    create("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 1, -22),
        BackgroundColor3 = Theme.Bg3,
        BorderSizePixel = 0,
        Parent = header,
    })
    create("Frame", {
        Size = UDim2.new(0, 4, 0, 30),
        Position = UDim2.new(0, 20, 0.5, -15),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = header,
    }, { corner(UDim.new(1, 0)) })

    create("TextLabel", {
        Size = UDim2.new(0, 300, 0, 20),
        Position = UDim2.new(0, 36, 0, 14),
        BackgroundTransparency = 1,
        Text = "MONIUM LIBRARY",
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })
    create("TextLabel", {
        Size = UDim2.new(0, 300, 0, 18),
        Position = UDim2.new(0, 36, 0, 36),
        BackgroundTransparency = 1,
        Text = "Enter your access key to continue",
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })

    create("TextLabel", {
        Size = UDim2.new(1, -48, 0, 16),
        Position = UDim2.new(0, 24, 0, 84),
        BackgroundTransparency = 1,
        Text = "ACCESS KEY",
        TextColor3 = Theme.TextDim,
        Font = Theme.FontBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    local input = create("TextBox", {
        Size = UDim2.new(1, -48, 0, 44),
        Position = UDim2.new(0, 24, 0, 104),
        BackgroundColor3 = Theme.Bg3,
        BorderSizePixel = 0,
        Text = "",
        PlaceholderText = "MONIUM-XXXX-XXXX-XXXX",
        PlaceholderColor3 = Theme.TextDim,
        TextColor3 = Theme.Text,
        Font = Theme.Font,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        ClearTextOnFocus = false,
        Parent = card,
    }, { corner(Theme.CornerSm), padding(0, 0, 12, 0) })

    local statusLbl = create("TextLabel", {
        Size = UDim2.new(1, -48, 0, 20),
        Position = UDim2.new(0, 24, 0, 154),
        BackgroundTransparency = 1,
        Text = "",
        TextColor3 = Theme.Error,
        Font = Theme.Font,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = card,
    })

    local verifyBtn = create("TextButton", {
        Size = UDim2.new(1, -48, 0, 44),
        Position = UDim2.new(0, 24, 0, 180),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Text = "VERIFY KEY",
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 14,
        AutoButtonColor = false,
        Parent = card,
    }, { corner(Theme.CornerSm) })

    local info_row = create("Frame", {
        Size = UDim2.new(1, -48, 0, 40),
        Position = UDim2.new(0, 24, 0, 236),
        BackgroundTransparency = 1,
        Parent = card,
    }, { listLayout(8) })
    create("UIListLayout", {
        Padding = UDim.new(0, 8),
        FillDirection = Enum.FillDirection.Horizontal,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = info_row,
    })

    local function miniBtn(text, cb)
        local b = create("TextButton", {
            Size = UDim2.new(0, 140, 1, 0),
            BackgroundColor3 = Theme.Bg3,
            BorderSizePixel = 0,
            Text = text,
            TextColor3 = Theme.TextDim,
            Font = Theme.Font,
            TextSize = 12,
            AutoButtonColor = false,
            Parent = info_row,
        }, { corner(Theme.CornerSm) })
        b.MouseEnter:Connect(function()
            tween(b, { BackgroundColor3 = Theme.Accent, TextColor3 = Theme.Text }, 0.15)
        end)
        b.MouseLeave:Connect(function()
            tween(b, { BackgroundColor3 = Theme.Bg3, TextColor3 = Theme.TextDim }, 0.15)
        end)
        b.MouseButton1Click:Connect(cb)
        return b
    end

    miniBtn("Get key", function()
        if ENV.setclipboard then
            ENV.setclipboard("https://discord.gg/your-server")
            Notifier.push("Copied", "Discord link copied", "success")
        end
    end)

    miniBtn("Paste", function()
        if ENV.getclipboard then
            local ok, clip = pcall(ENV.getclipboard)
            if ok and clip and #clip > 0 then
                input.Text = clip
                statusLbl.TextColor3 = Theme.TextDim
                statusLbl.Text = "Pasted from clipboard"
            end
        end
    end)

    create("TextLabel", {
        Size = UDim2.new(1, -48, 0, 30),
        Position = UDim2.new(0, 24, 1, -50),
        BackgroundTransparency = 1,
        Text = "Executor: " .. ENV.identify() .. "  ·  Build: " .. Monium.Build,
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Center,
        Parent = card,
    })

    local busy = false
    local function attempt()
        if busy then return end
        busy = true
        verifyBtn.Text = "CHECKING..."
        local ok, msg, tier = KeySystem.validate(input.Text)
        ENV.task_wait(0.3)
        if ok then
            statusLbl.TextColor3 = Theme.Success
            statusLbl.Text = "✓ Key valid — tier: " .. tostring(tier)
            verifyBtn.BackgroundColor3 = Theme.Success
            KeySystem.save(input.Text)
            ENV.task_wait(0.6)
            tween(bg, { BackgroundTransparency = 1 }, 0.4)
            tween(card, { BackgroundTransparency = 1, Position = UDim2.new(0.5, -230, 0.5, -160) }, 0.4)
            for _, c in ipairs(card:GetDescendants()) do
                if c:IsA("TextLabel") or c:IsA("TextButton") or c:IsA("TextBox") then
                    tween(c, { TextTransparency = 1 }, 0.3)
                elseif c:IsA("Frame") then
                    tween(c, { BackgroundTransparency = 1 }, 0.3)
                end
            end
            ENV.task_wait(0.5)
            gui:Destroy()
            onValid(tier)
        else
            statusLbl.TextColor3 = Theme.Error
            statusLbl.Text = "✗ " .. msg
            verifyBtn.BackgroundColor3 = Theme.Error
            tween(card, { Position = UDim2.new(0.5, -220, 0.5, -190) }, 0.08)
            ENV.task_wait(0.08)
            tween(card, { Position = UDim2.new(0.5, -240, 0.5, -190) }, 0.08)
            ENV.task_wait(0.08)
            tween(card, { Position = UDim2.new(0.5, -230, 0.5, -190) }, 0.08)
            ENV.task_wait(0.5)
            verifyBtn.BackgroundColor3 = Theme.Accent
            verifyBtn.Text = "VERIFY KEY"
            busy = false
        end
    end

    verifyBtn.MouseButton1Click:Connect(attempt)
    input.FocusLost:Connect(function(enter) if enter then attempt() end end)
    ENV.task_defer(function() pcall(function() input:CaptureFocus() end) end)
end

local function buildMenu()
    local gui = create("ScreenGui", {
        Name = "MoniumMenu",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 9000,
        Parent = get_gui_parent(),
    })

    local win = create("Frame", {
        Size = UDim2.new(0, 680, 0, 480),
        Position = UDim2.new(0.5, -340, 0.5, -240),
        BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0,
        Parent = gui,
    }, { corner(Theme.CornerLg), stroke(Theme.Accent, 1) })

    local header = create("Frame", {
        Size = UDim2.new(1, 0, 0, 48),
        BackgroundColor3 = Theme.Bg2,
        BorderSizePixel = 0,
        Parent = win,
    }, { corner(Theme.CornerLg) })
    create("Frame", {
        Size = UDim2.new(1, 0, 0, 22),
        Position = UDim2.new(0, 0, 1, -22),
        BackgroundColor3 = Theme.Bg2,
        BorderSizePixel = 0,
        Parent = header,
    })
    create("Frame", {
        Size = UDim2.new(0, 4, 0, 26),
        Position = UDim2.new(0, 16, 0.5, -13),
        BackgroundColor3 = Theme.Accent,
        BorderSizePixel = 0,
        Parent = header,
    }, { corner(UDim.new(1, 0)) })

    local title = create("TextLabel", {
        Size = UDim2.new(0, 250, 0, 20),
        Position = UDim2.new(0, 32, 0, 13),
        BackgroundTransparency = 1,
        Text = "MONIUM",
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })
    grad(Theme.Accent, Theme.Accent2, 45).Parent = title

    create("TextLabel", {
        Size = UDim2.new(0, 300, 0, 14),
        Position = UDim2.new(0, 32, 0, 29),
        BackgroundTransparency = 1,
        Text = "v" .. Monium.Version .. " · " .. ENV.identify(),
        TextColor3 = Theme.TextDim,
        Font = Theme.Font,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = header,
    })

    local closeBtn = create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -38, 0.5, -14),
        BackgroundColor3 = Theme.Error,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 18,
        AutoButtonColor = false,
        Parent = header,
    }, { corner(Theme.CornerSm) })

    local minBtn = create("TextButton", {
        Size = UDim2.new(0, 28, 0, 28),
        Position = UDim2.new(1, -72, 0.5, -14),
        BackgroundColor3 = Theme.Bg3,
        BorderSizePixel = 0,
        Text = "−",
        TextColor3 = Theme.Text,
        Font = Theme.FontBold,
        TextSize = 18,
        AutoButtonColor = false,
        Parent = header,
    }, { corner(Theme.CornerSm) })

    local sidebar = create("Frame", {
        Size = UDim2.new(0, 160, 1, -48),
        Position = UDim2.new(0, 0, 0, 48),
        BackgroundColor3 = Theme.Bg,
        BorderSizePixel = 0,
        Parent = win,
    }, { listLayout(4), padding(8, 8, 8, 8) })

    local content = create("Frame", {
        Size = UDim2.new(1, -160, 1, -48),
        Position = UDim2.new(0, 160, 0, 48),
        BackgroundColor3 = Theme.Bg2,
        BorderSizePixel = 0,
        Parent = win,
    }, { padding(12, 12, 12, 12) })

    local dragging, dragStart, startPos
    header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = win.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    Services.UIS.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            win.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    local minimized = false
    local savedSize = win.Size

    closeBtn.MouseButton1Click:Connect(function()
        tween(win, { Size = UDim2.new(0, 680, 0, 0), BackgroundTransparency = 1 }, 0.3)
        ENV.task_wait(0.35)
        gui:Destroy()
        Notifier.push("Menu closed", "Goodbye", "info")
    end)

    minBtn.MouseButton1Click:Connect(function()
        minimized = not minimized
        if minimized then
            savedSize = win.Size
            tween(win, { Size = UDim2.new(0, 680, 0, 48) }, 0.3)
            minBtn.Text = "□"
        else
            tween(win, { Size = savedSize }, 0.3)
            minBtn.Text = "−"
        end
    end)

    local MenuAPI = {}
    local tabButtons, tabFrames = {}, {}
    local currentTab

    function MenuAPI.addTab(name)
        local btn = create("TextButton", {
            Size = UDim2.new(1, 0, 0, 32),
            BackgroundColor3 = Theme.Bg2,
            BorderSizePixel = 0,
            Text = "  " .. name,
            TextColor3 = Theme.TextDim,
            Font = Theme.Font,
            TextSize = 13,
            TextXAlignment = Enum.TextXAlignment.Left,
            AutoButtonColor = false,
            Parent = sidebar,
        }, { corner(Theme.CornerSm) })

        local frame = create("ScrollingFrame", {
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            AutomaticCanvasSize = Enum.AutomaticSize.Y,
            Visible = false,
            Parent = content,
        }, { listLayout(10) })

        tabButtons[name] = btn
        tabFrames[name] = frame

        btn.MouseButton1Click:Connect(function()
            for n, b in pairs(tabButtons) do
                local active = (n == name)
                tween(b, {
                    BackgroundColor3 = active and Theme.Accent or Theme.Bg2,
                    TextColor3 = active and Theme.Text or Theme.TextDim,
                }, 0.15)
                tabFrames[n].Visible = active
            end
            currentTab = name
            Monium.Events.emit("tab:changed", name)
        end)

        btn.MouseEnter:Connect(function()
            if currentTab ~= name then
                tween(btn, { BackgroundColor3 = Theme.Bg3 }, 0.15)
            end
        end)
        btn.MouseLeave:Connect(function()
            if currentTab ~= name then
                tween(btn, { BackgroundColor3 = Theme.Bg2 }, 0.15)
            end
        end)

        if not currentTab then
            currentTab = name
            btn.BackgroundColor3 = Theme.Accent
            btn.TextColor3 = Theme.Text
            frame.Visible = true
        end

        return MenuAPI._makeTabAPI(frame)
    end

    function MenuAPI._makeTabAPI(parent)
        local TAB = {}

        function TAB.addSection(title)
            local sec = create("Frame", {
                Size = UDim2.new(1, 0, 0, 0),
                AutomaticSize = Enum.AutomaticSize.Y,
                BackgroundColor3 = Theme.Bg3,
                BorderSizePixel = 0,
                Parent = parent,
            }, { corner(Theme.CornerMd), listLayout(6), padding(10, 10, 12, 12) })

            if title and title ~= "" then
                create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 18),
                    BackgroundTransparency = 1,
                    Text = title:upper(),
                    TextColor3 = Theme.Accent,
                    Font = Theme.FontBold,
                    TextSize = 11,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sec,
                })
            end

            local SEC = {}

            function SEC.addButton(text, cb)
                local b = create("TextButton", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = Theme.Bg2,
                    BorderSizePixel = 0,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Theme.Font,
                    TextSize = 13,
                    AutoButtonColor = false,
                    Parent = sec,
                }, { corner(Theme.CornerSm) })
                b.MouseEnter:Connect(function()
                    tween(b, { BackgroundColor3 = Theme.Accent }, 0.15)
                end)
                b.MouseLeave:Connect(function()
                    tween(b, { BackgroundColor3 = Theme.Bg2 }, 0.15)
                end)
                b.MouseButton1Click:Connect(function()
                    if cb then pcall(cb) end
                end)
                return b
            end

            function SEC.addToggle(text, default, cb)
                default = default or false
                local state = default

                local f = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 36),
                    BackgroundColor3 = Theme.Bg2,
                    BorderSizePixel = 0,
                    Parent = sec,
                }, { corner(Theme.CornerSm) })

                create("TextLabel", {
                    Size = UDim2.new(1, -70, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Theme.Font,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = f,
                })

                local pill = create("Frame", {
                    Size = UDim2.new(0, 42, 0, 22),
                    Position = UDim2.new(1, -54, 0.5, -11),
                    BackgroundColor3 = state and Theme.Accent or Theme.Bg4,
                    BorderSizePixel = 0,
                    Parent = f,
                }, { corner(UDim.new(1, 0)) })

                local knob = create("Frame", {
                    Size = UDim2.new(0, 16, 0, 16),
                    Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8),
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    Parent = pill,
                }, { corner(UDim.new(1, 0)) })

                local btn = create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = f,
                })

                local toggle
                toggle = {
                    get = function() return state end,
                    set = function(v, silent)
                        state = v
                        tween(pill, { BackgroundColor3 = state and Theme.Accent or Theme.Bg4 }, 0.2)
                        tween(knob, {
                            Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
                        }, 0.2)
                        if not silent and cb then pcall(cb, state) end
                    end,
                }

                btn.MouseButton1Click:Connect(function()
                    toggle.set(not state)
                end)

                return toggle
            end

            function SEC.addSlider(text, min, max, default, cb)
                min = min or 0
                max = max or 100
                default = default or min
                local value = default

                local f = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 52),
                    BackgroundColor3 = Theme.Bg2,
                    BorderSizePixel = 0,
                    Parent = sec,
                }, { corner(Theme.CornerSm) })

                local lbl = create("TextLabel", {
                    Size = UDim2.new(1, -30, 0, 20),
                    Position = UDim2.new(0, 12, 0, 6),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = Theme.Text,
                    Font = Theme.Font,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = f,
                })

                local val_lbl = create("TextLabel", {
                    Size = UDim2.new(0, 50, 0, 20),
                    Position = UDim2.new(1, -62, 0, 6),
                    BackgroundTransparency = 1,
                    Text = tostring(value),
                    TextColor3 = Theme.Accent,
                    Font = Theme.FontBold,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = f,
                })

                local bar = create("Frame", {
                    Size = UDim2.new(1, -24, 0, 6),
                    Position = UDim2.new(0, 12, 1, -16),
                    BackgroundColor3 = Theme.Bg4,
                    BorderSizePixel = 0,
                    Parent = f,
                }, { corner(UDim.new(1, 0)) })

                local fill = create("Frame", {
                    Size = UDim2.new((value - min) / (max - min), 0, 1, 0),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Parent = bar,
                }, { corner(UDim.new(1, 0)) })

                local hitbox = create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundTransparency = 1,
                    Text = "",
                    Parent = bar,
                })

                local slider
                local function set(v, silent)
                    v = math.max(min, math.min(max, v))
                    value = v
                    val_lbl.Text = tostring(v)
                    tween(fill, { Size = UDim2.new((v - min) / (max - min), 0, 1, 0) }, 0.1)
                    if not silent and cb then pcall(cb, v) end
                end

                hitbox.MouseButton1Down:Connect(function()
                    local moving = true
                    local conn
                    conn = Services.UIS.InputChanged:Connect(function(input)
                        if moving and (input.UserInputType == Enum.UserInputType.MouseMovement
                        or input.UserInputType == Enum.UserInputType.Touch) then
                            local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
                            set(min + (max - min) * rel)
                        end
                    end)
                    Services.UIS.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1
                        or input.UserInputType == Enum.UserInputType.Touch then
                            moving = false
                            if conn then conn:Disconnect() end
                        end
                    end)
                end)

                slider = {
                    get = function() return value end,
                    set = set,
                }
                return slider
            end

            function SEC.addInput(placeholder, cb)
                local box = create("TextBox", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = Theme.Bg2,
                    BorderSizePixel = 0,
                    Text = "",
                    PlaceholderText = placeholder or "Type here...",
                    PlaceholderColor3 = Theme.TextDim,
                    TextColor3 = Theme.Text,
                    Font = Theme.Font,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    ClearTextOnFocus = false,
                    Parent = sec,
                }, { corner(Theme.CornerSm), padding(0, 0, 12, 0) })
                box.FocusLost:Connect(function(enter)
                    if enter and cb then pcall(cb, box.Text) end
                end)
                return box
            end

            function SEC.addDropdown(text, options, cb)
                options = options or {}
                local selected = nil
                local open = false

                local f = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 34),
                    BackgroundColor3 = Theme.Bg2,
                    BorderSizePixel = 0,
                    Parent = sec,
                }, { corner(Theme.CornerSm) })

                local btn = create("TextButton", {
                    Size = UDim2.new(1, 0, 1, 0),
                    BackgroundColor3 = Theme.Bg2,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    Parent = f,
                }, { corner(Theme.CornerSm) })

                local lbl = create("TextLabel", {
                    Size = UDim2.new(1, -40, 1, 0),
                    Position = UDim2.new(0, 12, 0, 0),
                    BackgroundTransparency = 1,
                    Text = text .. " — none",
                    TextColor3 = Theme.Text,
                    Font = Theme.Font,
                    TextSize = 13,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = f,
                })

                create("TextLabel", {
                    Size = UDim2.new(0, 20, 1, 0),
                    Position = UDim2.new(1, -28, 0, 0),
                    BackgroundTransparency = 1,
                    Text = "▾",
                    TextColor3 = Theme.TextDim,
                    Font = Theme.FontBold,
                    TextSize = 14,
                    Parent = f,
                })

                local drop = create("Frame", {
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    Position = UDim2.new(0, 0, 1, 4),
                    BackgroundColor3 = Theme.Bg3,
                    Visible = false,
                    ZIndex = 10,
                    Parent = f,
                }, { corner(Theme.CornerSm), stroke(Theme.Bg4, 1), listLayout(2), padding(4, 4, 4, 4) })

                for _, opt in ipairs(options) do
                    local ob = create("TextButton", {
                        Size = UDim2.new(1, 0, 0, 28),
                        BackgroundColor3 = Theme.Bg2,
                        BorderSizePixel = 0,
                        Text = tostring(opt),
                        TextColor3 = Theme.Text,
                        Font = Theme.Font,
                        TextSize = 12,
                        TextXAlignment = Enum.TextXAlignment.Left,
                        AutoButtonColor = false,
                        ZIndex = 11,
                        Parent = drop,
                    }, { corner(Theme.CornerSm) })
                    ob.MouseEnter:Connect(function()
                        tween(ob, { BackgroundColor3 = Theme.Accent }, 0.1)
                    end)
                    ob.MouseLeave:Connect(function()
                        tween(ob, { BackgroundColor3 = Theme.Bg2 }, 0.1)
                    end)
                    ob.MouseButton1Click:Connect(function()
                        selected = opt
                        lbl.Text = text .. " — " .. tostring(opt)
                        drop.Visible = false
                        open = false
                        if cb then pcall(cb, opt) end
                    end)
                end

                btn.MouseButton1Click:Connect(function()
                    open = not open
                    drop.Visible = open
                end)

                return {
                    get = function() return selected end,
                    set = function(v)
                        selected = v
                        lbl.Text = text .. " — " .. tostring(v)
                    end,
                }
            end

            function SEC.addLabel(text, color)
                return create("TextLabel", {
                    Size = UDim2.new(1, 0, 0, 20),
                    BackgroundTransparency = 1,
                    Text = text,
                    TextColor3 = color or Theme.TextDim,
                    Font = Theme.Font,
                    TextSize = 12,
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = sec,
                })
            end

            function SEC.addDivider()
                return create("Frame", {
                    Size = UDim2.new(1, 0, 0, 1),
                    BackgroundColor3 = Theme.Bg4,
                    BorderSizePixel = 0,
                    Parent = sec,
                })
            end

            return SEC
        end

        return TAB
    end

    return MenuAPI, gui
end


function Monium.Execute(source, name)
    name = name or "MoniumScript"
    if type(source) ~= "string" then
        Notifier.push("Execute", "source must be a string", "error")
        return false
    end
    local fn, err = ENV.loadstring(source, "=" .. name)
    if not fn then
        Notifier.push("Compile error", tostring(err), "error", 6)
        return false
    end
    local ok, runErr = pcall(fn)
    if not ok then
        Notifier.push("Runtime error", tostring(runErr), "error", 6)
        return false
    end
    Notifier.push("Loaded", name .. " ran successfully", "success")
    return true
end

function Monium.ExecuteUrl(url, name)
    if not ENV.httpget and not game.HttpGet then
        Notifier.push("Execute", "No HttpGet available", "error")
        return false
    end
    local ok, source = pcall(function()
        if game.HttpGet then return game:HttpGet(url) end
        if ENV.httpget then
            local res = ENV.httpget(url)
            return res and (res.Body or res) or nil
        end
    end)
    if not ok or not source then
        Notifier.push("HttpGet failed", tostring(source), "error")
        return false
    end
    return Monium.Execute(source, name or url:match("([^/]+)%.lua$") or "remote")
end

function Monium.ExecuteSandboxed(source, name, extra_env)
    name = name or "SandboxedScript"
    if type(source) ~= "string" then return false end
    local fn, err = ENV.loadstring(source, "=" .. name)
    if not fn then
        Notifier.push("Compile error", tostring(err), "error")
        return false
    end
    if ENV.setfenv then
        ENV.setfenv(fn, Sandbox.create(extra_env))
    end
    local ok, runErr = pcall(fn)
    if not ok then
        Notifier.push("Sandbox error", tostring(runErr), "error")
        return false
    end
    return true
end

local function populateMenu(menu)

    local home = menu.addTab("Home")
    local welcome = home.addSection("Welcome")
    welcome.addLabel("Welcome to " .. Monium.Name)
    welcome.addLabel("Version: " .. Monium.Version)
    welcome.addLabel("Build: " .. Monium.Build)
    welcome.addLabel("Executor: " .. ENV.identify())
    if LocalPlayer then welcome.addLabel("User: " .. LocalPlayer.Name) end
    welcome.addLabel("Time: " .. ENV.os_date("%H:%M:%S"))

    local quick = home.addSection("Quick actions")
    quick.addButton("Copy Discord link", function()
        if ENV.setclipboard then
            ENV.setclipboard("https://discord.gg/your-server")
            Notifier.push("Copied", "Discord link in clipboard", "success")
        end
    end)
    quick.addButton("Copy saved key", function()
        local k = KeySystem.load()
        if k and ENV.setclipboard then
            ENV.setclipboard(k)
            Notifier.push("Copied", "Key in clipboard", "success")
        else
            Notifier.push("Empty", "No saved key", "warn")
        end
    end)
    quick.addButton("Clear saved key", function()
        KeySystem.clear()
        Notifier.push("Done", "Key cleared", "info")
    end)

    local scripts = menu.addTab("Scripts")
    local popular = scripts.addSection("Popular")
    popular.addButton("Infinite Yield", function()
        Notifier.push("Loading", "Fetching IY...", "info")
        Monium.ExecuteUrl("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source", "IY")
    end)
    popular.addButton("Rejoin server", function()
        if Services.Teleport and LocalPlayer then
            Services.Teleport:Teleport(game.PlaceId, LocalPlayer)
        end
    end)
    popular.addButton("Server hop", function()
        Notifier.push("Info", "Add your own server-hop logic", "info")
    end)

    local custom = scripts.addSection("Execute custom")
    local input = custom.addInput("Paste script or URL here...", function(text)
        if text:match("^https?://") then
            Monium.ExecuteUrl(text, "custom")
        else
            Monium.Execute(text, "custom")
        end
    end)
    custom.addButton("Execute from input", function()
        local text = input.Text
        if #text == 0 then
            Notifier.push("Empty", "Input is empty", "warn")
            return
        end
        if text:match("^https?://") then
            Monium.ExecuteUrl(text, "custom")
        else
            Monium.Execute(text, "custom")
        end
    end)
    custom.addButton("Execute sandboxed", function()
        Monium.ExecuteSandboxed(input.Text, "sandboxed")
    end)


    local settings = menu.addTab("Settings")
    local ui = settings.addSection("Interface")
    ui.addToggle("Enable notifications", true, function(v)
        Notifier.setEnabled(v)
        if v then Notifier.push("Enabled", "Notifications on", "success") end
    end)
    ui.addToggle("Debug mode", false, function(v)
        Monium._debug = v
    end)

    local perf = settings.addSection("Performance")
    perf.addToggle("Low graphics mode", false, function(v)
        if v and Services.Lighting then
            Services.Lighting.GlobalShadows = false
            Services.Lighting.FogEnd = 9e9
            pcall(function() settings().Rendering.QualityLevel = 1 end)
            Notifier.push("Graphics", "Low graphics enabled", "success")
        elseif Services.Lighting then
            Services.Lighting.GlobalShadows = true
            pcall(function() settings().Rendering.QualityLevel = 21 end)
            Notifier.push("Graphics", "High graphics enabled", "info")
        end
    end)
    perf.addSlider("Field of view", 50, 120, 70, function(v)
        if workspace and workspace.CurrentCamera then
            workspace.CurrentCamera.FieldOfView = v
        end
    end)

    local security = settings.addSection("Security")
    security.addLabel("Anti-debug detections: " .. #AntiDebug.getDetections())
    security.addButton("Show detections", function()
        local dets = AntiDebug.getDetections()
        if #dets == 0 then
            Notifier.push("Clean", "No detections", "success")
        else
            for i, d in ipairs(dets) do
                if i <= 3 then Notifier.push("Detection #" .. i, d.kind .. " at " .. tostring(d.t), "warn", 6) end
            end
        end
    end)
    security.addButton("View audit log", function()
        local log = Logger.get()
        if #log == 0 then
            Notifier.push("Log", "Empty", "info")
        else
            for i = #log, math.max(1, #log - 3), -1 do
                Notifier.push("[" .. log[i].lvl .. "]", log[i].msg, "info", 6)
            end
        end
    end)
    security.addButton("Run self-test", function()
        local pass, issues = AntiHook.verify()
        if pass then
            Notifier.push("Self-test", "All checks passed", "success")
        else
            for _, i in ipairs(issues) do
                Notifier.push("FAIL", i.name .. " (" .. i.kind .. ")", "error", 6)
            end
        end
    end)

    local danger = settings.addSection("Danger zone")
    danger.addButton("Clear all saved data", function()
        KeySystem.clear()
        Notifier.push("Cleared", "All saved data removed", "warn")
    end)

    local about = menu.addTab("About")
    local info = about.addSection("Monium Library")
    info.addLabel("Name: " .. Monium.Name)
    info.addLabel("Version: " .. Monium.Version)
    info.addLabel("Build: " .. Monium.Build)
    info.addLabel("Executor: " .. ENV.identify())
    info.addLabel("UNC support: " .. tostring(ENV.has_unc))
    info.addLabel("File IO: " .. tostring(ENV.has_file_io))
    info.addLabel("HTTP: " .. tostring(ENV.has_http))
    info.addLabel("")
    info.addLabel("Protection layers active:")
    info.addLabel("  · String pool")
    info.addLabel("  · Anti-debug hooks")
    info.addLabel("  · Integrity signatures")
    info.addLabel("  · Decoy traps")
    info.addLabel("  · Sandbox isolation")
    info.addLabel("")
    info.addLabel("Made with ♥")

    local credits = about.addSection("Credits")
    credits.addLabel("UI: MoniumLibrary v1")
    credits.addLabel("Script executor: built-in")
    credits.addButton("Copy Discord", function()
        if ENV.setclipboard then
            ENV.setclipboard("https://discord.gg/your-server")
            Notifier.push("Copied", "Discord link copied", "success")
        end
    end)
end


local function launchMenu(tier)
    local menu, gui = buildMenu()
    populateMenu(menu)
    Monium.Menu = menu
    Monium.Gui  = gui
    Monium.Tier = tier

    Notifier.push("Welcome", "Monium loaded (tier: " .. tostring(tier) .. ")", "success", 5)
    Monium.Events.emit("menu:ready", menu)
end

local function init()
    pcall(AntiDebug.install)

    showSplash()

    local ok, savedKey = KeySystem.verify_saved()
    if ok and savedKey then
        local valid, _, tier = KeySystem.validate(savedKey)
        if valid then
            Notifier.push("Auto-login", "Saved key accepted", "success")
            ENV.task_wait(0.4)
            launchMenu(tier)
            return
        end
    end

    showKeyScreen(function(tier)
        Notifier.push("Access granted", "Tier: " .. tostring(tier), "success")
        ENV.task_wait(0.4)
        launchMenu(tier)
    end)
end


Monium.Execute          = Monium.Execute
Monium.ExecuteUrl       = Monium.ExecuteUrl
Monium.ExecuteSandboxed = Monium.ExecuteSandboxed
Monium.Theme            = Theme
Monium.Notifier         = Notifier

-- Freeze module metadata (lo mínimo, no todo)
local moduleMeta = {
    __metatable = "Monium:Module:" .. Monium.Version,
    __index = function(t, k)
        error("Monium: field '" .. tostring(k) .. "' does not exist", 2)
    end,
}
setmetatable(Monium, moduleMeta)

init()

return Monium
