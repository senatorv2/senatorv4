package.path = package.path .. ';.luarocks/share/lua/5.2/?.lua'
.. ';.luarocks/share/lua/5.2/?/init.lua'
package.cpath = package.cpath .. ';.luarocks/lib/lua/5.2/?.so'

-- @Senator_tea
http = require("socket.http")
https = require("ssl.https")
http.TIMEOUT = 10
JSON = require('dkjson')
-------@Senator_tea
tdcli = dofile('tdcli.lua')
redis = (loadfile "./libs/redis.lua")()
serpent = require('serpent')
serp = require 'serpent'.block
sudo_users = {
  170146015,
  204507468,
  196568905
}

function string:split(sep)
  local sep, fields = sep or ":", {}
  local pattern = string.format("([^%s]+)", sep)
  self:gsub(pattern, function(c)
    fields[#fields + 1] = c
  end)
  return fields
end

function is_sudo(msg)
  local var = false
  for v,user in pairs(sudo_users) do
    if user == msg.sender_user_id_ then
      var = true
    end
  end
  return var
end

function is_normal(msg)
  local chat_id = msg.chat_id_
  local user_id = msg.sender_user_id_
  local mutel = redis:sismember('muteusers:'..chat_id,user_id)
  if mutel then
    return true
  end
  if not mutel then
    return false
  end
end
-- function owner
function is_owner(msg)
  local var = false
  local chat_id = msg.chat_id_
  local user_id = msg.sender_user_id_
  local group_mods = redis:get('owners:'..chat_id)
  if group_mods == tostring(user_id) then
    var = true
  end
  for v, user in pairs(sudo_users) do
    if user == user_id then
      var = true
    end
  end
  return var
end
--- function promote
function is_mod(msg)
  local var = false
  local chat_id = msg.chat_id_
  local user_id = msg.sender_user_id_
  if redis:sismember('mods:'..chat_id,user_id) then
    var = true
  end
  if  redis:get('owners:'..chat_id) == tostring(user_id) then
    var = true
  end
  for v, user in pairs(sudo_users) do
    if user == user_id then
      var = true
    end
  end
  return var
end
-- Print message format. Use serpent for prettier result.
function vardump(value, depth, key)
  local linePrefix = ''
  local spaces = ''

  if key ~= nil then
    linePrefix = key .. ' = '
  end

  if depth == nil then
    depth = 0
  else
    depth = depth + 1
    for i=1, depth do
      spaces = spaces .. '  '
    end
  end

  if type(value) == 'table' then
    mTable = getmetatable(value)
    if mTable == nil then
      print(spaces .. linePrefix .. '(table) ')
    else
      print(spaces .. '(metatable) ')
      value = mTable
    end
    for tableKey, tableValue in pairs(value) do
      vardump(tableValue, depth, tableKey)
    end
  elseif type(value)  == 'function' or
    type(value) == 'thread' or
    type(value) == 'userdata' or
    value == nil then --@Senator_tea
    print(spaces .. tostring(value))
  elseif type(value)  == 'string' then
    print(spaces .. linePrefix .. '"' .. tostring(value) .. '",')
  else
    print(spaces .. linePrefix .. tostring(value) .. ',')
  end
end

-- Print callback
function dl_cb(arg, data)
end


local function setowner_reply(extra, result, success)
  t = vardump(result)
  local msg_id = result.id_
  local user = result.sender_user_id_
  local ch = result.chat_id_
  redis:del('owners:'..ch)
  redis:set('owners:'..ch,user)
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '*🚀 #تایید شد \nیوزر '..user..' *مالک گروه شد*\nکانال:  @Senator_tea*', 1, 'md')
  print(user)
end

local function deowner_reply(extra, result, success)
  t = vardump(result)
  local msg_id = result.id_
  local user = result.sender_user_id_
  local ch = result.chat_id_
  redis:del('owners:'..ch)
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '*🚀 #تایید شد\nیوزر '..user..' *از مالک گروه حذف شد*\nکانال:  @Senator_tea*', 1, 'md')
  print(user)
end

local database = 'http://vip.opload.ir/vipdl/94/11/amirhmz/'
local function setmod_reply(extra, result, success)
vardump(result)
local msg = result.id_
local user = result.sender_user_id_
local chat = result.chat_id_
redis:sadd('mods:'..chat,user)
tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '* 🚀 #تایید شد\nیوزر '..user..' *به لیست مدیران اضافه شد*\nکانال:  @Senator_tea*', 1, 'md')
end

local function remmod_reply(extra, result, success)
vardump(result)
local msg = result.id_
local user = result.sender_user_id_
local chat = result.chat_id_
redis:srem('mods:'..chat,user)
tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '* 🚀 #تایید شد\nیوزر '..user..' *از لیست مدیران حذف شد*\nکانال:  @Senator_tea*', 1, 'md')
end

function kick_reply(extra, result, success)
  b = vardump(result)
  tdcli.changeChatMemberStatus(result.chat_id_, result.sender_user_id_, 'Kicked')
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '*#تایید شد\n🔹یوزر '..result.sender_user_id_..' *کیک شد*\nکانال:  @Senator_tea*', 1, 'md')
end

function ban_reply(extra, result, success)
  b = vardump(result)
  tdcli.changeChatMemberStatus(result.chat_id_, result.sender_user_id_, 'Banned')
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '*#تایید شد\n🔹یوزر '..result.sender_user_id_..' *بن شد*\nکانال:  @Senator_tea*', 1, 'md')
end


local function setmute_reply(extra, result, success)
  vardump(result)
  redis:sadd('muteusers:'..result.chat_id_,result.sender_user_id_)
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '*یوزر '..result.sender_user_id_..' به لیست سایت اضافه شد \nکانال:  @Senator_tea*',  1,'md')
end

local function demute_reply(extra, result, success)
  vardump(result)
  redis:srem('muteusers:'..result.chat_id_,result.sender_user_id_)
  tdcli.sendText(result.chat_id_, 0, 0, 1, nil, '*یوزر '..result.sender_user_id_..' از لیست سایلنت حذف شد\nکانال:  @Senator_tea*', 1, 'md')
end



function tdcli_update_callback(data)
  vardump(data)

  if (data.ID == "UpdateNewMessage") then
    local msg = data.message_
    local input = msg.content_.text_
    local chat_id = msg.chat_id_
    local user_id = msg.sender_user_id_
    local reply_id = msg.reply_to_message_id_
    vardump(msg)
    if msg.content_.ID == "MessageText" then
      if input == "ping" then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '`pong`', 1, 'md')

      end
      if input == "PING" then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>PONG</b>', 1, 'html')
      end
      if input:match("^ایدی$") then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>ایدی سوپرگروه : </b><code>'..string.sub(chat_id, 5,14)..'</code>\n<b>ایدی یوزر: </b><code>'..user_id..'</code>\n<b>کانال : </b>@Senator_tea', 1, 'html')
      end

      if input:match("^سنجاق$") and reply_id and is_owner(msg) then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>سنجاق شد✅</b>*', 1, 'html')
        tdcli.pinChannelMessage(chat_id, reply_id, 1)
      end

      if input:match("^حذف سنجاق$") and reply_id and is_owner(msg) then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<b>سنجاق حذف شد✅</b>*', 1, 'html')
        tdcli.unpinChannelMessage(chat_id, reply_id, 1)
      end


      -----------------------------------------------------------------------------------------------------------------------------
      if input:match('^تنظیم مالک$') and is_owner(msg) and msg.reply_to_message_id_ then
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,setowner_reply,nil)
      end
      if input == "/delowner" and is_sudo(msg) and msg.reply_to_message_id_ then
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,deowner_reply,nil)
      end

      if input:match('^مالک$') then
        local hash = 'owners:'..chat_id
        local owner = redis:get(hash)
        if owner == nil then
          tdcli.sendText(chat_id, 0, 0, 1, nil, '*🔸گروه مالک ندارد\nکانال:  @Senator_tea *', 1, 'md')
        end
        local owner_list = redis:get('owners:'..chat_id)
        text85 = '👤*Group Owner :*\n\n '..owner_list
        tdcli.sendText(chat_id, 0, 0, 1, nil, text85, 1, 'md')
      end
      if input:match('^[/!#]setowner (.*)') and not input:find('@') and is_sudo(msg) then
        redis:del('owners:'..chat_id)
        redis:set('owners:'..chat_id,input:match('^تنظیم مالک(.*)'))
        tdcli.sendText(chat_id, 0, 0, 1, nil, 'user '..input:match('^تنظیم مالک(.*)')..' *<🚏>مالک گروه شد</🚏>*\nکانال:  @Senator_tea*', 1, 'md')
      end

      if input:match('^[/!#]setowner (.*)') and input:find('@') and is_owner(msg) then
        function Inline_Callback_(arg, data)
          redis:del('owners:'..chat_id)
          redis:set('owners:'..chat_id,input:match('^تنظیم مالک(.*)'))
          tdcli.sendText(chat_id, 0, 0, 1, nil, 'یوزر '..input:match('^تنظیم مالک(.*)')..' *<🚏>مالک گروه شد</🚏>\nکانال:  @Senator_tea*', 1, 'md')
        end
        tdcli_function ({ID = "SearchPublicChat",username_ =input:match('^تنظیم مالک(.*)')}, Inline_Callback_, nil)
      end


      if input:match('^عزل مالک(.*)') and is_sudo(msg) then
        redis:del('owners:'..chat_id)
        tdcli.sendText(chat_id, 0, 0, 1, nil, 'user '..input:match('^عزل مالک(.*)')..'*<b>از لیست مالک حذف شد</b>\nکانال:  @Senator_tea*', 1, 'md')
      end
      -----------------------------------------------------------------------------------------------------------------------
      if input:match('^تنظیم مدیر') and is_sudo(msg) and msg.reply_to_message_id_ then
tdcli.getMessage(chat_id,msg.reply_to_message_id_,setmod_reply,nil)
end
if input:match('^عزل مدیر') and is_sudo(msg) and msg.reply_to_message_id_ then
tdcli.getMessage(chat_id,msg.reply_to_message_id_,remmod_reply,nil)
end
			
			sm = input:match('^تنظیم مدیر(.*)')
if sm and is_sudo(msg) then
  redis:sadd('mods:'..chat_id,sm)
  tdcli.sendText(chat_id, 0, 0, 1, nil, '*🚀 #تایید شد\nیوزر '..sm..'*<🚏>به لیست مدیران اضافه شد<🚏>*\nکانال:  @Senator_tea*', 1, 'md')
end

dm = input:match('^عزل مدیر(.*)')
if dm and is_sudo(msg) then
  redis:srem('mods:'..chat_id,dm)
  tdcli.sendText(chat_id, 0, 0, 1, nil, '*🚀 #تایید شد\nیوزر'..dm..'*<🚏>از لیست مدیران حذف شد<🚏>*\nکانال:  @Senator_tea*', 1, 'md')
end

if input:match('^لیست مدیران') then
if redis:scard('mods:'..chat_id) == 0 then
tdcli.sendText(chat_id, 0, 0, 1, nil, '*<🚏>لیست مدیران خالی است<🚏>\nکانال:  @Senator_tea*', 1, 'md')
end
local text = "<🚏>لیست مدیران<🚏> : \n"
for k,v in pairs(redis:smembers('mods:'..chat_id)) do
text = text.."_"..k.."_ - *"..v.."*\n"
end
tdcli.sendText(chat_id, 0, 0, 1, nil, text, 1, 'md')
end
						--------------------------------------------------------
			if input:match('^تنظیم لینک(.*)') and is_owner(msg) then
redis:set('link'..chat_id,input:match('^تنظیم لینک(.*)'))
tdcli.sendText(chat_id, 0, 0, 1, nil, '*<🚏>لینک ذخیره شد<🚏>*', 1, 'html')
end

if input:match('^لینک') and is_owner(msg) then
link = redis:get('link'..chat_id)
tdcli.sendText(chat_id, 0, 0, 1, nil, '*<🚏>لینک گروه<🚏>:\n'..link, 1, 'html')
end
		-------------------------------------------------------
		if input:match('^تنظیم قوانین(.*)') and is_owner(msg) then
redis:set('gprules'..chat_id,input:match('^تنظیم قوانین(.*)'))
tdcli.sendText(chat_id, 0, 0, 1, nil, '*<b>قوانین ذخیره شد</b>*', 1, 'html')
end

if input:match('^قوانین') then
rules = redis:get('gprules'..chat_id)
tdcli.sendText(chat_id, 0, 0, 1, nil, '*<🚏>قوانین گروه<🚏> :\n'..rules, 1, 'html')
end
--------------------------------------------------------------------------
local res = http.request(database.."joke.db")
	local joke = res:split(",")
 if input:match'[جوک)' then
 local run = joke[math.random(#joke)]
 tdcli.sendText(chat_id, msg.id_, 0, 1, nil, run..'*\n\nکانال:  @Senator_tea*', 1, 'md')
 end
      ---------------------------------------------------------------------------------------------------------------------------------
      if input:match("^اضافه$") and is_sudo(msg) then
        redis:sadd('groups',chat_id)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>به لیست گروه های ربات سناتور اضافه شد<🚏>\nکانال:  @Senator_tea `'..msg.sender_user_id_..'`*', 1, 'md')
      end
      -------------------------------------------------------------------------------------------------------------------------------------------
      if input:match("^حذف$") and is_sudo(msg) then
        redis:srem('groups',chat_id)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>از لیست گروهای ربات سناتور حذف شد<🚏>\nکانال:  @Senator_tea `'..msg.sender_user_id_..'`*', 1, 'md')
      end
      -----------------------------------------------------------------------------------------------------------------------------------------------
      -----------------------------------------------------------------------
      if input:match('^کیک$') and is_mod(msg) then
        tdcli.getMessage(chat_id,reply,kick_reply,nil)
      end

      if input:match('^کیک(.*)') and not input:find('@') and is_mod(msg) then
        tdcli.sendText(chat_id, 0, 0, 1, nil, 'یوزر '..input:match('^کیک(.*)')..'* <🚏>کیک شد<🚏>*', 1, 'md')
        tdcli.changeChatMemberStatus(chat_id, input:match('^کیک(.*)'), '<🚏>کیک شد<🚏>')
      end

      if input:match('^کیک(.*)') and input:find('@') and is_mod(msg) then
        function Inline_Callback_(arg, data)
          tdcli.sendText(chat_id, 0, 0, 1, nil, 'یوزر '..input:match('^کیک(.*)')..'* <🚏>کیک شد<🚏>*', 1, 'md')
          tdcli.changeChatMemberStatus(chat_id, data.id_, 'Kicked')
        end
        tdcli_function ({ID = "SearchPublicChat",username_ =input:match('^کیک(.*)')}, Inline_Callback_, nil)
      end
      --------------------------------------------------------
      ----------------------------------------------------------
      if input:match('^سایلنت') and is_mod(msg) and msg.reply_to_message_id_ then
        redis:set('tbt:'..chat_id,'yes')
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,setmute_reply,nil)
      end
      if input:match('^سایلنت') and is_mod(msg) and msg.reply_to_message_id_ then
        tdcli.getMessage(chat_id,msg.reply_to_message_id_,demute_reply,nil)
      end
      mu = input:match('^سایلنت(.*)')
      if mu and is_mod(msg) then
        redis:sadd('muteusers:'..chat_id,mu)
        redis:set('tbt:'..chat_id,'yes')
        tdcli.sendText(chat_id, 0, 0, 1, nil, '*یوزر '..mu..' <🚏>به لیست سایلنت ها اضافه شد<🚏>\nکانال:  @Senator_tea*', 1, 'md')
      end
      umu = input:match('^حذف سایلنت(.*)')
      if umu and is_mod(msg) then
        redis:srem('muteusers:'..chat_id,umu)
        tdcli.sendText(chat_id, 0, 0, 1, nil, '*یوزر '..umu..' <🚏>از لیست سایلنت ها حذف شد<🚏>\nکانال:  @Senator_tea *', 1, 'md')
      end

      if input:match('^لیست سایلنت ') then
        if redis:scard('muteusers:'..chat_id) == 0 then
          tdcli.sendText(chat_id, 0, 0, 1, nil, '*<🚏>لیست سایلنت خالی است<🚏>\nکانال:  @Senator_tea*', 1, 'md')
        end
        local text = "<🚏>لیست سایلنت ها<🚏>:\n"
        for k,v in pairs(redis:smembers('muteusers:'..chat_id)) do
          text = text.."<b>"..k.."</b> - <b>"..v.."</b>\n"
        end
        tdcli.sendText(chat_id, 0, 0, 1, nil, text, 1, 'html')
      end
      -------------------------------------------------------

      --lock links
      groups = redis:sismember('groups',chat_id)
      if input:match("^قفل لینک$") and is_mod(msg) and groups then
        if redis:get('lock_linkstg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال لینک از قبل قفل بود<🚏>*', 1, 'md')
        else
          redis:set('lock_linkstg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*#تایید شد\n<🚏>ارسال لینک قفل شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن لینک$")  and is_mod(msg) and groups then
        if not redis:get('lock_linkstg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال لینک از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('lock_linkstg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏ارسال لینک آزاد شد><🚏>*', 1, 'md')
        end
      end
      --lock username
      groups = redis:sismember('groups',chat_id)
      if input:match("^قفل یوزرنیم$") and is_mod(msg) and groups then
        if redis:get('usernametg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال یوزرنیم از قبل قفل بود<🚏>*', 1, 'md')
        else
          redis:set('usernametg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>ارسال یوزرنیم قفل شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن یوزرنیم$") and is_mod(msg) and groups then
        if not redis:get('usernametg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, ' *<🚏>ارسال یوزرنیم از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('usernametg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>ارسال یوزرنیم آزاد شد<🚏>*', 1, 'md')
        end
      end
      --lock tag
      groups = redis:sismember('groups',chat_id)
      if input:match("^قفل تگ$") and is_mod(msg) and groups then
        if redis:get('tagtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال تگ از قبل قفل بود<🚏>*', 1, 'md')
        else
          redis:set('tagtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil,  '*✅ #تایید شد\n<🚏>ارسال تگ قفل شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن تگ$") and is_mod(msg) and groups then
        if not redis:get('tagtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال تگ از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('tagtg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>ارسال تگ آزاد شد<🚏>*', 1, 'md')
        end
      end
      --lock forward
      groups = redis:sismember('groups',chat_id)
      if input:match("^قفل فروارد$") and is_mod(msg) and groups then
        if redis:get('forwardtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>فروارد کردن از قبل قفل بود<🚏>*', 1, 'md')
        else
          redis:set('forwardtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n:<🚏>فروارد کردن قفل شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازرکردن فروارد$") and is_mod(msg) and groups then
        if not redis:get('forwardtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>فروارد کردن از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('forwardtg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>فروارد کردن آزاد شد<🚏>*', 1, 'md')
        end
      end
      --arabic/persian
      groups = redis:sismember('groups',chat_id)
      if input:match("^قفل عربی$") and is_mod(msg) and groups then
        if redis:get('arabictg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>استفاده از کلمات عربی از قبل قفل بود<🚏>*', 1, 'md')
        else
          redis:set('arabictg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>استفاده از کلمات عربی قفل شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن عربی$") and is_mod(msg) and groups then
        if not redis:get('arabictg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>استفاده از کلمات عربی از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('arabictg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>استفاده ا کلمات عربی آزاد شد<🚏>*', 1, 'md')
        end
      end
      ---english
      groups = redis:sismember('groups',chat_id)
      if input:match("^قفل انگلیسی$") and is_mod(msg) and groups then
        if redis:get('engtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>استفاده از کلمات انگلیسی از قبل قفل بود<🚏>*', 1, 'md')
        else
          redis:set('engtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>استفاده از کلمات انگلیسی قفل شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن انگلیسی$") and is_mod(msg) and groups then
        if not redis:get('engtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil,  '*<🚏>استفاده از کلمات انگلیسی از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('engtg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil,  '*✅ #تایید شد\n<🚏>استفاده از کلمات انگلیسی آزاد شد<🚏>*', 1, 'md')
        end
      end
      --lock foshtg
      groups = redis:sismember('groups',chat_id)
      if input:match("^قفل کلمات زشت$") and is_mod(msg) and groups then
        if redis:get('badwordtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>استفاده از کلمات زشت از قبل قفل بود<🚏>*', 1, 'md')
        else
          redis:set('badwordtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>استفاده از کلمات زشت قفل شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن کلمات زشت$") and is_mod(msg) and groups then
        if not redis:get('badwordtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>استفاده از کلمات زشت از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('badwordtg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>استفاده از کلمات زشت آزاد شد<🚏>*', 1, 'md')
        end
      end
      --lock edit
      groups = redis:sismember('groups',chat_id)
      if input:match("^قفل ویرایش$") and is_mod(msg) and groups then
        if redis:get('edittg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ویرایش از قبل قفل بود<🚏>*', 1, 'md')
        else
          redis:set('edittg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n:<🚏>ویرایش قفل شد<🚏>*',1, 'md')
        end
      end
      if input:match("^بازکردن ویرایش$") and is_mod(msg) and groups then
        if not redis:get('edittg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ویرایش از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('edittg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>ویرایش آزاد شد<🚏>*', 1, 'md')
        end
      end
      --- lock Caption
      if input:match("^قفل عنوان$") and is_mod(msg) and groups then
        if redis:get('captg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال عنوان از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:set('captg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>ارسال عنوان قفل شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن عنوان$") and is_mod(msg) and groups then
        if not redis:get('captg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال عنوان از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('captg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>ارسال عنوان آزاد شد<🚏>*', 1, 'md')
        end
      end
      --lock emoji
      groups = redis:sismember('groups',chat_id)
      if input:match("^قفل ایموجی") and is_mod(msg) and groups then
        if redis:get('emojitg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال ایموجی از قیل قفل بود<🚏>*', 1, 'md')
        else
          redis:set('emojitg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>ارسال ایموجی قفل شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن ایموجی$") and is_mod(msg) and groups then
        if not redis:get('emojitg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ارسال ایموجی از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('emojitg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>ارسال ایموجی آزاد شد<🚏>*', 1, 'md')
        end
      end
      --- lock inline
      groups = redis:sismember('groups',chat_id)
      if input:match("^قفل اینلاین") and is_mod(msg) and groups then
        if redis:get('inlinetg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>اینلاین  از قبل قفل بود<🚏>*', 1, 'md')
        else
          redis:set('inlinetg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>اینلاین قفل شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن اینلاین$") and is_mod(msg) and groups then
        if not redis:get('inlinetg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>اینلاین از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('inlinetg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>اینلاین آزاد شد<🚏>*', 1, 'md')
        end
      end
      -- lock reply
      groups = redis:sismember('groups',chat_id)
      if input:match("^قفل ریپلای") and is_mod(msg) and groups then
        if redis:get('replytg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ریپلای کردن از قبل قفل بود<🚏>*', 1, 'md')
        else
          redis:set('replytg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>ریپلای کردن قفل شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن ریپلای$") and is_mod(msg) and groups then
        if not redis:get('replytg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ریپلای کردن از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('replytg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n:<🚏>ریپلای کردن آزاد شد<🚏>*', 1, 'md')
        end
      end
      --lock tgservice
      groups = redis:sismember('groups',chat_id)
      if input:match("^قفل سرویس$") and is_mod(msg) and groups then
        if redis:get('tgservice:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>سرویس تلگرام از قبل قفل شد<🚏>*', 1, 'md')
        else
          redis:set('tgservice:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>سرویس تلگرام قفل شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن سرویس$") and is_mod(msg) and groups then
        if not redis:get('tgservice:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>سرویس تلگرام از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('tgservice:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>سرویس تلگرام آزاد شد<🚏>*', 1, 'md')
        end
      end
      --lock flood (by @Flooding)
      groups = redis:sismember('groups',chat_id)
      if input:match("^قفل حساسیت") and is_mod(msg) and groups then
        if redis:get('floodtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>حساسیت تکرار از قبل فعال بود<🚏>*', 1, 'md')
        else
          redis:set('floodtg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>حساسیت تکرار فعال شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن حساسیت$") and is_mod(msg) and groups then
        if not redis:get('floodtg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>حساسیت به تکرار از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('flood:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*✅ #تایید شد\n<🚏>حساسیت تکرار  آزاد شد<🚏>*', 1, 'md')
        end
      end

      --------------------------------
      ---------------------------------------------------------------------------------
      local link = 'lock_linkstg:'..chat_id
      if redis:get(link) then
        link = "`✅`"
      else
        link = "`❎`"
      end

      local username = 'usernametg:'..chat_id
      if redis:get(username) then
        username = "`✅`"
      else
        username = "`❎`"
      end

      local tag = 'tagtg:'..chat_id
      if redis:get(tag) then
        tag = "`✅`"
      else
        tag = "`❎`"
      end

      local flood = 'flood:'..chat_id
      if redis:get(flood) then
        flood = "`✅`"
      else
        flood = "`❎`"
      end

      local forward = 'forwardtg:'..chat_id
      if redis:get(forward) then
        forward = "`✅`"
      else
        forward = "`❎`"
      end

      local arabic = 'arabictg:'..chat_id
      if redis:get(arabic) then
        arabic = "`✅`"
      else
        arabic = "`❎`"
      end

      local eng = 'engtg:'..chat_id
      if redis:get(eng) then
        eng = "`✅`"
      else
        eng = "`❎`"
      end

      local badword = 'badwordtg:'..chat_id
      if redis:get(badword) then
        badword = "`✅`"
      else
        badword = "`❎`"
      end

      local edit = 'edittg:'..chat_id
      if redis:get(edit) then
        edit = "`✅`"
      else
        edit = "`❎`"
      end

      local emoji = 'emojitg:'..chat_id
      if redis:get(emoji) then
        emoji = "`✅`"
      else
        emoji = "`❎`"
      end

      local caption = 'captg:'..chat_id
      if redis:get(caption) then
        caption = "`✅`"
      else
        caption = "`❎`"
      end

      local inline = 'inlinetg:'..chat_id
      if redis:get(inline) then
        inline = "`✅`"
      else
        inline = "`❎`"
      end

      local reply = 'replytg:'..chat_id
      if redis:get(reply) then
        reply = "`✅`"
      else
        reply = "`❎`"
      end
      ----------------------------
      --muteall
      groups = redis:sismember('groups',chat_id)
      if input:match("^ممنوعیت همه$") and is_mod(msg) and groups then
        if redis:get('mute_alltg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت همه از قبل فعال بود<🚏>*', 1, 'md')
        else
          redis:set('mute_alltg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت همه از فعال شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن همه$") and is_mod(msg) and groups then
        if not redis:get('mute_alltg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت همه از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('mute_alltg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت همه  آزاد شد<🚏>*', 1, 'md')
        end
      end

      --mute sticker
      groups = redis:sismember('groups',chat_id)
      if input:match("^ممنوعیت استیکر$") and is_mod(msg) and groups then
        if redis:get('mute_stickertg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت استیکر از قبل فعال بود<🚏>*', 1, 'md')
        else
          redis:set('mute_stickertg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت استیکر از فعال شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن استیکر$") and is_mod(msg) and groups then
        if not redis:get('mute_stickertg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil,'*<🚏>ممنوعیت استیکر از قبل آزاد بود<🚏>*', 1, 'md')

        else
          redis:del('mute_stickertg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت استیکر آزاد شد<🚏>*', 1, 'md')
        end
      end
      --mute gift
      groups = redis:sismember('groups',chat_id)
      if input:match("^ممنوعیت گیف$") and is_mod(msg) and groups then
        if redis:get('mute_gifttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil,  '*<🚏>ممنوعیت گیف از قبل فعال بود<🚏>*', 1, 'md')
        else
          redis:set('mute_gifttg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت گیف از فعال شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن گیف$") and is_mod(msg) and groups then
        if not redis:get('mute_gifttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت گیف از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('mute_gifttg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت گیف آزاد شد<🚏>*', 1, 'md')
        end
      end
      --mute contact
      groups = redis:sismember('groups',chat_id)
      if input:match("^ممنوعیت شماره$") and is_mod(msg) and groups then
        if redis:get('mute_contacttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت شماره از قبل فعال بود<🚏>*', 1, 'md')
        else
          redis:set('mute_contacttg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت شماره از فعال شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن شماره$") and is_mod(msg) and groups then
        if not redis:get('mute_contacttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت شماره از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('mute_contacttg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت شماره آزاد شد<🚏>*', 1, 'md')
        end
      end
      --mute photo
      groups = redis:sismember('groups',chat_id)
      if input:match("^ممنوعیت عکس$") and is_mod(msg) and groups then
        if redis:get('mute_phototg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت عکس از قبل فعال بود<🚏>*', 1, 'md')
        else
          redis:set('mute_phototg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت عکس از فعال شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن عکس$") and is_mod(msg) and groups then
        if not redis:get('mute_phototg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت عکس از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('mute_phototg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت عکس  آزاد شد<🚏>*', 1, 'md')
        end
      end
      --mute audio
      groups = redis:sismember('groups',chat_id)
      if input:match("^ممنوعیت آهنگ$") and is_mod(msg) and groups then
        if redis:get('mute_audiotg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت آهنگ از قبل فعال بود<🚏>*', 1, 'md')
        else
          redis:set('mute_audiotg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت آهنگ از فعال شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن آهنگ$") and is_mod(msg) and groups then
        if not redis:get('mute_audiotg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت آهنگ از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('mute_audiotg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت آهنگ  آزاد شد<🚏>*', 1, 'md')
        end
      end
      --mute voice
      groups = redis:sismember('groups',chat_id)
      if input:match("^ممنوعیت صدا$") and is_mod(msg) and groups then
        if redis:get('mute_voicetg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت صدا از قبل فعال بود<🚏>*', 1, 'md')
        else
          redis:set('mute_voicetg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت صدا از فعال شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن صدا$") and is_mod(msg) and groups then
        if not redis:get('mute_voicetg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت صدا از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('mute_voicetg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت صدا آزاد شد<🚏>*', 1, 'md')
        end
      end
      --mute video
      groups = redis:sismember('groups',chat_id)
      if input:match("^ممنوعیت فیلم$") and is_mod(msg) and groups then
        if redis:get('mute_videotg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت فیلم از قبل فعال بود<🚏>*', 1, 'md')
        else
          redis:set('mute_videotg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت فیلم از فعال شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن فیلم$") and is_mod(msg) and groups then
        if not redis:get('mute_videotg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت فیلم از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('mute_videotg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت فیلم آزاد شد<🚏>*', 1, 'md')
        end
      end
      --mute document
      groups = redis:sismember('groups',chat_id)
      if input:match("^ممنوعیت یاداشت$") and is_mod(msg) and groups then
        if redis:get('mute_documenttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت یاداشت از قبل فعال بود<🚏>*', 1, 'md')
        else
          redis:set('mute_documenttg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت یاداشت از فعال شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن یاداشت$") and is_mod(msg) and groups then
        if not redis:get('mute_documenttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت یاداشت از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('mute_documenttg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت یاداشت  آزاد شد<🚏>*', 1, 'md')
        end
      end
      --mute  text
      groups = redis:sismember('groups',chat_id)
      if input:match("^ممنوعیت متن$") and is_mod(msg) and groups then
        if redis:get('mute_texttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت متن از قبل فعال بود<🚏>*', 1, 'md')
        else
          redis:set('mute_texttg:'..chat_id, true)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت متن از فعال شد<🚏>*', 1, 'md')
        end
      end
      if input:match("^بازکردن متن$") and is_mod(msg) and groups then
        if not redis:get('mute_texttg:'..chat_id) then
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت متن از قبل آزاد بود<🚏>*', 1, 'md')
        else
          redis:del('mute_texttg:'..chat_id)
          tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '*<🚏>ممنوعیت متن  آزاد شد<🚏>*', 1, 'md')
        end
      end
      --settings
      local all = 'mute_alltg:'..chat_id
      if redis:get(all) then
        All = "`🔕`"
      else
        All = "`🔔`"
      end

      local sticker = 'mute_stickertg:'..chat_id
      if redis:get(sticker) then
        sticker = "`🔕`"
      else
        sticker = "`🔔`"
      end

      local gift = 'mute_gifttg:'..chat_id
      if redis:get(gift) then
        gift = "`🔕`"
      else
        gift = "`🔔`"
      end

      local contact = 'mute_contacttg:'..chat_id
      if redis:get(contact) then
        contact = "`🔕`"
      else
        contact = "`🔔`"
      end

      local photo = 'mute_phototg:'..chat_id
      if redis:get(photo) then
        photo = "`🔕`"
      else
        photo = "`🔔`"
      end

      local audio = 'mute_audiotg:'..chat_id
      if redis:get(audio) then
        audio = "`🔕`"
      else
        audio = "`🔔`"
      end

      local voice = 'mute_voicetg:'..chat_id
      if redis:get(voice) then
        voice = "`🔕`"
      else
        voice = "`🔔`"
      end

      local video = 'mute_videotg:'..chat_id
      if redis:get(video) then
        video = "`🔕`"
      else
        video = "`🔔`"
      end

      local document = 'mute_documenttg:'..chat_id
      if redis:get(document) then
        document = "`🔕`"
      else
        document = "`🔔`"
      end

      local text1 = 'mute_texttg:'..chat_id
      if redis:get(text1) then
        text1 = "`🔕`"
      else
        text1 = "`🔔`"
      end
      if input:match("^تنظیمات$") and is_mod(msg) then
        local text = "👥 SuperGroup Settings :".."\n"
        .."⚠*قفل حساسیت=> *".."`"..flood.."`".."\n"
        .."⚠*قفل لینک=> *".."`"..link.."`".."\n"
        .."⚠*قفل تگ=> *".."`"..tag.."`".."\n"
        .."⚠*قفل یوزرنیم=> *".."`"..username.."`".."\n"
        .."⚠*قفل فروارد=> *".."`"..forward.."`".."\n"
        .."⚠*قفل عربی=> *".."`"..arabic..'`'..'\n'
        .."⚠*قفل انگلیسی=> *".."`"..eng..'`'..'\n'
        .."⚠*قفل ریپلای=> *".."`"..reply..'`'..'\n'
        .."⚠*قفل فروارد=> *".."`"..badword..'`'..'\n'
        .."⚠*قفل ویرایش=> *".."`"..edit..'`'..'\n'
        .."⚠*قفل عنوان=> *".."`"..caption..'`'..'\n'
        .."⚠*قفل اینلاین=> *".."`"..inline..'`'..'\n'
        .."⚠*قفل ایموجی=> *".."`"..emoji..'`'..'\n'
        .."*➖➖➖➖➖➖➖➖➖*".."\n"
        .."🏮*💈لیست ممنوعیت ها💈 :".."\n"
        .."🏮*ممنوعیت همه: *".."`"..All.."`".."\n"
        .."🏮*ممنوعیت استیکر: *".."`"..sticker.."`".."\n"
        .."🏮*ممنوعیت گیف: *".."`"..gift.."`".."\n"
        .."🏮*ممنوعیت شماره: *".."`"..contact.."`".."\n"
        .."🏮*ممنوعیت عکس: *".."`"..photo.."`".."\n"
        .."🏮*ممنوعین آهنگ: *".."`"..audio.."`".."\n"
        .."🏮*ممنوعیت صدا: *".."`"..voice.."`".."\n"
        .."🏮*ممنوعیت فیلم: *".."`"..video.."`".."\n"
        .."🏮*ممنوعیت یاداشت: *".."`"..document.."`".."\n"
        .."🏮*ممنوعیت متن: *".."`"..text1.."`".."\n"
        .."🏮ورژن 4 سناتور  لینک کانال پشتیبانی :\nhttps://telegram.me/joinchat/AAAAAD_2f86VIMKHSEGOlQ"
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, text, 1, 'md')
      end
if input:match("^[#!/][Ss][Ee][Nn][Aa][Tt][Oo][Rr]$") and is_mod(msg) or input:match("^[Ss][Ee][Nn][Aa][Tt][Oo][Rr]$") and is_mod(msg) or input:match("^سناتور$") and is_mod(msg) then
        local text = "🔰 خداي سناتور ورژن 4: \n"
	.."🔰سناتور رباتي قدرتمند جهت مديريت سوپرگروه: \n"
        .."🏮 نوشته شده برپايه tdcli(New TG) \n"
        .."🏮 پشتيباني از قفل اديت وسنجاق \n"
        .."🏮 سرعت بالا بدون جاگذاشتن لينک \n"
        .."🏮 لانچ شدن خودکار هر 3دقيقه \n"
        .."🏮  ديباگ شده و قدرتمند \n"
        .."🏮  ويرايش و ارتقا: \n@Lv_t_m \n"       
        .."🏮 سرور: #المان \nhttps://telegram.me/joinchat/AAAAAD_2f86VIMKHSEGOlQ \n"
        .." ➖➖➖➖➖➖➖➖➖"
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, text, 1, 'md')
      end
      if input:match("^ارسال$") then
        tdcli.forwardMessages(chat_id, chat_id,{[0] = reply_id}, 0)
      end

      if input:match("یورزنیم") and is_sudo(msg) then
        tdcli.changeUsername(string.sub(input, 11))
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>یوزرنیم به</b>@'..string.sub(input, 11), 1, 'html')
      end

      if input:match("^[#!/][Ee]cho") then
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, string.sub(input, 7), 1, 'html')
      end

      if input:match("^تنظیم نام") and is_owner(msg) then
        tdcli.changeChatTitle(chat_id, string.sub(input, 10), 1)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>اسم سوپرگروه تغییر یافته به</b><code>'..string.sub(input, 10)..'</code>', 1, 'html')
      end
	  
      if input:match("^چک نام") and is_sudo(msg) then
        tdcli.changeName(string.sub(input, 13), nil, 1)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>اسم رباته تغییر یافته به</b><code>'..string.sub(input, 13)..'</code>', 1, 'html')
      end
	  
      if input:match("^چک یوزر") and is_sudo(msg) then
        tdcli.changeUsername(string.sub(input, 13), nil, 1)
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>وزرنیم رباته تغییر کرد به</b><code>'..string.sub(input, 13)..'</code>', 1, 'html')
      end
	  
      if input:match("^پاک کردن یوزر") and is_sudo(msg) then
        tdcli.changeUsername('')
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '#تایید شد\nیوزرنیم پاک شد', 1, 'html')
      end
	  
      if input:match("^ویرایش") and is_owner(msg) then
        tdcli.editMessageText(chat_id, reply_id, nil, string.sub(input, 7), 'html')
      end

      if input:match("^پاک کردن پرو") and is_sudo(msg) then
        tdcli.DeleteProfilePhoto(chat_id, {[0] = msg.id_})
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>#تایید شد\nپرو پاکوشد</b>', 1, 'html')
      end

      if input:match("^دعوت") and is_sudo(msg) then
        tdcli.addChatMember(chat_id, string.sub(input, 9), 20)
      end
	  
      if input:match("^[#!/][Cc]reatesuper") and is_sudo(msg) then
        tdcli.createNewChannelChat(string.sub(input, 14), 1, 'My Supergroup, my rules')
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>SuperGroup </b>'..string.sub(input, 14)..' <b>Created</b>', 1, 'html')
      end

      if input:match("^حذف") and is_mod(msg) and msg.reply_to_message_id_ ~= 0 then
        tdcli.deleteMessages(msg.chat_id_, {[0] = msg.reply_to_message_id_})
      end

      if input:match('^[#!/]tosuper') then
        local gpid = msg.chat_id_
        tdcli.migrateGroupChatToChannelChat(gpid)
      end

      if input:match("^هستی") then
        tdcli.viewMessages(chat_id, {[0] = msg.id_})
        tdcli.sendText(chat_id, msg.id_, 0, 1, nil, '<b>آره هستم</b>', 1, 'html')
      end
    end

    local input = msg.content_.text_
    if redis:get('mute_alltg:'..chat_id) and msg and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_stickertg:'..chat_id) and msg.content_.sticker_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_gifttg:'..chat_id) and msg.content_.animation_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_contacttg:'..chat_id) and msg.content_.contact_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_phototg:'..chat_id) and msg.content_.photo_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_audiotg:'..chat_id) and msg.content_.audio_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_voicetg:'..chat_id) and msg.content_.voice_  and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_videotg:'..chat_id) and msg.content_.video_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_documenttg:'..chat_id) and msg.content_.document_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('mute_texttg:'..chat_id) and msg.content_.text_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end
    if redis:get('forwardtg:'..chat_id) and msg.forward_info_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end
    local is_link_msg = input:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or input:match("[Tt].[Mm][Ee]/")
    if redis:get('lock_linkstg:'..chat_id) and is_link_msg and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('tagtg:'..chat_id) and input:match("#") and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('usernametg:'..chat_id) and input:match("@") and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('arabictg:'..chat_id) and input:match("[\216-\219][\128-\191]") and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    local is_english_msg = input:match("[a-z]") or input:match("[A-Z]")
    if redis:get('engtg:'..chat_id) and is_english_msg and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    local is_fosh_msg = input:match("کیر") or input:match("کس") or input:match("کون") or input:match("85") or input:match("جنده") or input:match("ننه") or input:match("ننت") or input:match("مادر") or input:match("قهبه") or input:match("گایی") or input:match("سکس") or input:match("kir") or input:match("kos") or input:match("kon") or input:match("nne") or input:match("nnt")
    if redis:get('badwordtg:'..chat_id) and is_fosh_msg and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    local is_emoji_msg = input:match("😀") or input:match("😬") or input:match("😁") or input:match("😂") or  input:match("😃") or input:match("😄") or input:match("😅") or input:match("☺️") or input:match("🙃") or input:match("🙂") or input:match("😊") or input:match("😉") or input:match("😇") or input:match("😆") or input:match("😋") or input:match("😌") or input:match("😍") or input:match("😘") or input:match("😗") or input:match("😙") or input:match("😚") or input:match("🤗") or input:match("😎") or input:match("🤓") or input:match("🤑") or input:match("😛") or input:match("😏") or input:match("😶") or input:match("😐") or input:match("😑") or input:match("😒") or input:match("🙄") or input:match("🤔") or input:match("😕") or input:match("😔") or input:match("😡") or input:match("😠") or input:match("😟") or input:match("😞") or input:match("😳") or input:match("🙁") or input:match("☹️") or input:match("😣") or input:match("😖") or input:match("😫") or input:match("😩") or input:match("😤") or input:match("😲") or input:match("😵") or input:match("😭") or input:match("😓") or input:match("😪") or input:match("😥") or input:match("😢") or input:match("🤐") or input:match("😷") or input:match("🤒") or input:match("🤕") or input:match("😴") or input:match("💋") or input:match("❤️")
    if redis:get('emojitg:'..chat_id) and is_emoji_msg and not is_mod(msg)  then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('captg:'..chat_id) and  msg.content_.caption_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('locatg:'..chat_id) and  msg.content_.location_ and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('inlinetg:'..chat_id) and  msg.via_bot_user_id_ ~= 0 and not is_mod(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('replytg:'..chat_id) and  msg.reply_to_message_id_ and not is_mod(msg) ~= 0 then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end

    if redis:get('tbt:'..chat_id) and is_normal(msg) then
      tdcli.deleteMessages(chat_id, {[0] = msg.id_})
    end
    -- AntiFlood --
    local floodMax = 5
    local floodTime = 2
    local hashflood = 'floodtg:'..msg.chat_id_
    if redis:get(hashflood) and not is_mod(msg) then
      local hash = 'flood:'..msg.sender_user_id_..':'..msg.chat_id_..':msg-num'
      local msgs = tonumber(redis:get(hash) or 0)
      if msgs > (floodMax - 1) then
        tdcli.changeChatMemberStatus(msg.chat_id_, msg.sender_user_id_, "Kicked")
        tdcli.sendText(msg.chat_id_, msg.id_, 1, 'User _'..msg.sender_user_id_..' has been kicked for #flooding !', 1, 'md')
        redis:setex(hash, floodTime, msgs+1)
      end
    end
    -- AntiFlood --
		elseif data.ID == "UpdateMessageEdited" then
if redis:get('edittg:'..data.chat_id_) then
  tdcli.deleteMessages(data.chat_id_, {[0] = tonumber(data.message_id_)})
end 
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
	
    -- @Senator_tea
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
  end
end
