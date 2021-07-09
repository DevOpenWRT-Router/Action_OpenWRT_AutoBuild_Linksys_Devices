module("luci.pb.checker", package.seeall)

function index ()
end

function ip (ipaddr, options)
	if not ipaddr then return nil end
	if options.mode == "4" then
		return ipv4(ipaddr)
	elseif options.mode == "6" then
		return ipv6(ipaddr)
	else
		return ipv4(ipaddr)
	end
	return nil
end

function ipv4 (ipaddr)
	if not ipaddr then return nil end
	if not ipaddr:match("%.") then
		return nil
	end

	local b1, b2, b3, b4 = ipaddr:match("^(%d+)%.(%d+)%.(%d+)%.(%d+)$")
	if b1 then b1 = number(b1) else return nil end
	if b2 then b2 = number(b2) else return nil end
	if b3 then b3 = number(b3) else return nil end
	if b4 then b4 = number(b4) else return nil end
	if b1 and b1 >= 0 and b1 <= 255 and
		b2 and b2 >= 0 and b2 <= 255 and
		b3 and b3 >= 0 and b3 <= 255 and
		b4 and b4 >= 0 and b4 <= 255 then
		return ipaddr
	else
		return nil
	end
	return nil
end

function ipv6 (ipaddr)
	if not ipaddr then return nil end
	-- @TODO Check IPv6
	return ipaddr
end

function mac (macaddr)
	if not macaddr then return nil end
	local b1, b2, b3, b4, b5, b6 =
		macaddr:match("^([%da-fA-F]+)%:([%da-fA-F]+)%:([%da-fA-F]+)%:([%da-fA-F]+)%:([%da-fA-F]+)%:([%da-fA-F]+)$")
	if b1 and string.len(b1) == 2 and
		b2 and string.len(b2) == 2 and
		b3 and string.len(b3) == 2 and
		b4 and string.len(b4) == 2 and
		b5 and string.len(b5) == 2 and
		b6 and string.len(b6) == 2 then
		return macaddr
	else
		return nil
	end
	return nil
end

function number (num)
	if not num then return nil end
	if type(num) == "string" then
		num = num:match("%d+")
	end
	if num then
		return tonumber(num)
	else
		return nil
	end
end
