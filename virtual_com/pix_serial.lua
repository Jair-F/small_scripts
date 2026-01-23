
local PAYLOAD_CUSTOM_ID = 40002
local TARGET_SYSTEM = param:get("MAV_GCS_SYSID") -- gcs Station
local TARGET_COMPONENT = param:get("MAV_SYSID") -- autopilot
local MAV_TUNNEL_ID = 385 -- https://mavlink.io/en/messages/common.html#TUNNEL


local function send_tunnel_msg(mav_channel, payload_binary)
    if mav_channel == nil then
       return 
    end

    local MAV_TUNNEL_ID = 385 -- https://mavlink.io/en/messages/common.html#TUNNEL
    local target_system = TARGET_SYSTEM
    local target_component = TARGET_COMPONENT
    local payload_type = PAYLOAD_CUSTOM_ID

    local payload_len = #payload_binary

    -- 3. Pad to exactly 128 bytes (MAVLink Tunnel requirement)
    -- filling up remaining junk data
    local full_payload = payload_binary .. string.rep(string.char(0), 128 - payload_len)

    -- 3. Pack the message fields into a MAVLink binary string
    -- Format string "<HBBBc128" means:
    -- <    : Little-endian
    -- H    : uint16 (payload_type)
    -- B    : uint8  (target_system)
    -- B    : uint8  (target_component)
    -- B    : uint8  (payload_length)
    -- c128 : 128 fixed-length characters (the payload)
    local format = '<HBBBc' .. tostring(#full_payload)
    local packed_msg = string.pack(format,
        payload_type,
        target_system,
        target_component,
        payload_len,
        full_payload
    )

    mavlink:send_chan(mav_channel, MAV_TUNNEL_ID, packed_msg)
end

local function extract_tunnel_data(raw_string)
    if not raw_string or #raw_string < 15 then return nil end

    local tunnel_id_bin = string.pack("<I3", MAV_TUNNEL_ID) -- little endian 3byte(24 bit integer)
    -- FIND THE PAYLOAD START
    local start_idx = raw_string:find(tunnel_id_bin)

    if not start_idx then
        return nil -- not a tunnel msg
    end

    -- The payload starts 3 bytes after the start of the Message ID
    local message_payload = raw_string:sub(start_idx + 3)

    -- EXACT LAYOUT FROM YOUR DOCS:
    -- B (uint8):  target_system
    -- B (uint8):  target_component
    -- H (uint16): payload_type
    -- B (uint8):  payload_length
    -- c128 (bytes): payload
    local target_system, target_component, payload_type, payload_length,
        payload_buffer = string.unpack("<BBHBc128", message_payload)

    -- payload_buffer = string.sub(payload_buffer, 1, payload_length) -- convert to valid string

    return payload_type, payload_buffer, payload_length, target_system, target_component
end

local function handle_tunnel_msg(payload_type, payload_buffer, payload_length, target_system, target_component)
    if payload_type == nil then
        gcs:send_text('7', 'recvd empty tunnel payload')
    end

    gcs:send_text('7', 'type: ' .. tostring(payload_type))
    gcs:send_text('7', 'length: ' .. tostring(payload_length))
    gcs:send_text('7', 'target_system: ' .. tostring(target_system))
    gcs:send_text('7', 'target_component: ' .. tostring(target_component))
    if payload_type == PAYLOAD_CUSTOM_ID then
        gcs:send_text(7, "payload len: " .. tostring(payload_length))

        local status, b1, b2, b3, b4, b5, b6, b7, next_pos = pcall(string.unpack, "<BBBBBBB", payload_buffer)

        if status then
            gcs:send_text(6, string.format("Hex: %02X %02X %02X %02X %02X %02X %02X", b1, b2, b3, b4, b5, b6, b7))
        else
            gcs:send_text(7, "Unpack failed - payload too short?")
        end
    else
        gcs:send_text('7', 'recvd tunnel but not with our payload_type: ' .. tostring(payload_type))
    end
end

local function loop()
    gcs:send_text('7', "getting mavlink channel")
    local byte_data, chan, recv_time = mavlink:receive_chan()

    local data_buffer = string.pack("<ff", 12.34, 56.78)
    send_tunnel_msg(chan, data_buffer)

    if byte_data == nil then
        gcs:send_text('7', "failed to recv msg")
        return loop, 1000
    end

    handle_tunnel_msg(extract_tunnel_data(byte_data))

    return loop, 1000
end

local function startup()
    gcs:send_text('7', "startup")
    mavlink:init(10, 1)
    mavlink:register_rx_msgid(MAV_TUNNEL_ID)
    return loop()
end

return startup()