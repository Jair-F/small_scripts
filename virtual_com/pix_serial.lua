
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
    local packed_msg = string.pack('<HBBBc128',
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

    -- FIND THE PAYLOAD START
    -- The Message ID for TUNNEL (385) in hex is 0x000181
    -- In the wire stream, this appears as 81 01 00
    local start_idx = raw_string:find("\129\1\0") 

    if not start_idx then
        return nil -- Message ID not found in this packet
    end

    -- The payload starts 3 bytes after the start of the Message ID
    local message_payload = raw_string:sub(start_idx + 3)

    -- EXACT LAYOUT FROM YOUR DOCS:
    -- B (uint8):  target_system
    -- B (uint8):  target_component
    -- H (uint16): payload_type
    -- B (uint8):  payload_length
    -- c128 (bytes): payload
    local target_sys, target_comp, p_type, p_len, p_buffer = string.unpack("<BBHBc128", message_payload)

    -- Extract valid data
    local actual_payload = p_buffer
    -- local actual_payload = string.sub(p_buffer, 1, p_len)

    return p_type, actual_payload, p_len, target_sys, target_comp
end

local function update()
    gcs:send_text('7', "trying to receive mavlink msg")
    local raw_data, chan, recv_time = mavlink:receive_chan()
    gcs:send_text('7', 'chan:' .. tostring(chan))
    send_tunnel_msg(chan, string.pack("<ff", 12.34, 56.78))

    if raw_data == nil then
        gcs:send_text('7', "msg is nil")
        return update, 1000
    end

    local p_type, actual_payload, p_len, target_sys, target_comp = extract_tunnel_data(raw_data)

    if p_type then
        gcs:send_text(7, "payload_type: " .. tostring(p_type))
        gcs:send_text(7, "payload len: " .. tostring(p_len))

        local status, b1, b2, b3, b4, b5, b6, b7 = pcall(string.unpack, "<BBBBBBB", actual_payload)

        if status then
            -- This prints a single clean string to the GCS
            gcs:send_text(6, string.format("Hex: %02X %02X %02X %02X %02X %02X %02X", b1, b2, b3, b4, b5, b6, b7))
        else
            gcs:send_text(7, "Unpack failed - payload too short?")
        end
    end

    -- if msg.msgid == MAV_TUNNEL_ID then
    --     gcs:send_text("7", 'got tunnel message from mav')
    --     if msg.payload_type == PAYLOAD_CUSTOM_ID then
    --         gcs:send_text("7", "got message with matching paylod type!")
    
    --         local len = msg:get_field('payload_length')
    --         local data = msg:get_field('payload')

    --         gcs:send_text(6, string.format("Received tunnel length: %d", len))

    --         local hex_str = ""
    --         for i = 1, len do
    --             hex_str = hex_str .. string.format("%02X ", data[i])
    --         end
    --         gcs:send_text(6, "Bytes: " .. hex_str)
    --     end
    -- end
    return update, 1000
end

gcs:send_text('7', "startup")
mavlink:init(10, 1)
mavlink:register_rx_msgid(MAV_TUNNEL_ID)
return update()