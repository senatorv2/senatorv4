sudo = {170146015,204507468,196568905,}
--CerNerTm
bot = dofile('utils.lua')
json = dofile('json.lua')
URL = require "socket.url"
serpent = require("serpent")
http = require "socket.http"
https = require "ssl.https"
redis = require('redis')
db = redis.connect('127.0.0.1', 6379)
bot_id = db:get('bot_id')
function vardump(value)
  print(serpent.block(value, {comment=false}))
end
function dl_cb(arg, data)
 -- isdade
  --ads
end

function is_sudo(msg)
  local var = false
  for v,user in pairs(sudo) do
    if user == msg.sender_user_id_ then
      var = true
    end
  end
  return var
end

function is_owner(msg) 
  local hash = db:sismember('owners:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_sudo(msg) then
return true
else
return false
end
end
function is_mod(msg) 
  local hash = db:sismember('mods:'..msg.chat_id_,msg.sender_user_id_)
if hash or is_sudo(msg) or is_owner(msg) then
return true
else
return false
end
end
function is_banned(chat,user)
   local hash =  db:sismember('banned'..chat,user)
  if hash then
    return true
    else
    return false
    end
  end
function is_filter(msg,value)
 local list = db:smembers('filters:'..msg.chat_id_)
 var = false
  for i=1, #list do
    if value:match(list[i]) then
      var = true
    end
    end
    return var
  end
function is_muted(chat,user)
   local hash =  db:sismember('mutes'..chat,user)
  if hash then
    return true
    else
    return false
    end
  end
function priv(chat,user)
  local ohash = db:sismember('owners:'..chat,user)
  local mhash = db:sismember('mods:'..chat,user)
 if tonumber(SUDO) == tonumber(user) or mhash or ohash then
   return true
    else
    return false
    end
  end
function kick(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, "\n<b>You Can't Kick Admins/Mod/Sudo/Owner,</b>", 'html')
    else
  bot.changeChatMemberStatus(chat, user, "Kicked")
    end
  end
function ban(msg,chat,user)
  if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, "\n<b>You Can't Ban Admins/Mod/Sudo/Owner,</b>", 'html')
    else
  bot.changeChatMemberStatus(chat, user, "Kicked")
  db:sadd('banned'..chat,user)
  local t = 'User (<code>'..user..'</code>)Has Been Banned!'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t, 1, 'html')
  end
  end
function mute(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
  if priv(chat,user) then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, "\n<b>You Can't Mute Admins/Mod/Sudo/Owner,</b>", 'html')
    else
  db:sadd('mutes'..chat,user)
  local t = '<b>User</b> (<code>'..user..'</code>) <b>Has Been Muted!</b>'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'html')
  end
  end
function unban(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   db:srem('banned'..chat,user)
  local t = '<b>User</b> (<code>'..user..'</code>) <b>Has Been UnBaned!</b>'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'html')
  end
function unmute(msg,chat,user)
    if tonumber(user) == tonumber(bot_id) then
    return false
    end
   db:srem('mutes'..chat,user)
  local t = '<b>User</b> (<code>'..user..'</code>) <b>Has Been UnMuted!!</b>'
  bot.sendMessage(msg.chat_id_, msg.id_, 1, t,1, 'html')
  end
 function delete_msg(chatid,mid)
  tdcli_function ({ID="DeleteMessages", chat_id_=chatid, message_ids_=mid}, dl_cb, nil)
end

function settings(msg,value,lock) 
local hash = 'settings:'..msg.chat_id_..':'..value
  if value == 'file' then
      text = 'File'
   elseif value == 'keysh' then
    text = 'keysh'
  elseif value == 'links' then
    text = 'Links'
  elseif value == 'game' then
    text = 'Game'
    elseif value == 'tag' then
    text = 'Tag(@)'
    elseif value == 'hashtag' then
    text = 'Hashtag(#)'
   elseif value == 'pin' then
    text = 'Pin'
    elseif value == 'photo' then
    text = 'Photo'
    elseif value == 'gif' then
    text = 'Gifs'
    elseif value == 'video' then
    text = 'Videos'
    elseif value == 'voice' then
    text = 'Voice'
    elseif value == 'music' then
    text = 'Music'
    elseif value == 'text' then
    text = 'Text'
    elseif value == 'sticker' then
    text = 'Stickers'
    elseif value == 'contact' then
    text = 'Contact'
    elseif value == 'forward' then
    text = 'Fwd'
    elseif value == 'persian' then
    text = 'Persian'
    elseif value == 'english' then
    text = 'English'
    elseif value == 'bot' then
    text = 'Bots'
    elseif value == 'edit' then
    text = 'Edit'   
    elseif value == 'tgservice' then
    text = 'Tg Service'
    else return false
    end
  if lock then
db:set(hash,true)
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<i>✽'..text..'✽</i>  <b>Has Been locked</b>',1,'html')
    else
  db:del(hash)
bot.sendMessage(msg.chat_id_, msg.id_, 1, '<i>✽'..text..'✽</i>  <b>Has Been Disabled In The Group</b>',1,'html')
end
end
function is_lock(msg,value)
local hash = 'settings:'..msg.chat_id_..':'..value
 if db:get(hash) then
    return true 
    else
    return false
    end
  end

function trigger_anti_spam(msg,type)
  if type == 'kick' then
    bot.sendMessage(msg.chat_id_, msg.id_, 1, '\n<b>»Flooding Is Not Allowed Here«</b>\n<b>»ID User:</b> <code>['..msg.sender_user_id_..']</code>\n<b>»Status: User Kicked«</b>', 1,'md')
    kick(msg,msg.chat_id_,msg.sender_user_id_)
    end
  if type == 'ban' then
    if is_banned(msg.chat_id_,msg.sender_user_id_) then else
bot.sendMessage(msg.chat_id_, msg.id_, 1, '\n<b>»Flooding Is Not Allowed Here«</b>\n<b>»ID User:</b> <code>['..msg.sender_user_id_..']</code>\n<b>»Status: User Baned«</b>', 1,'md')
      end
bot.changeChatMemberStatus(msg.chat_id_, msg.sender_user_id_, "Kicked")
  db:sadd('banned'..msg.chat_id_,msg.sender_user_id_)
  end
  if type == 'mute' then
    if is_muted(msg.chat_id_,msg.sender_user_id_) then else
bot.sendMessage(msg.chat_id_, msg.id_, 1, '\n<b>»Flooding Is Not Allowed Here«</b>\n<b>»ID User:</b> <code>['..msg.sender_user_id_..']</code>\n<b>»Status: User Muted«</b>', 1,'md')
      end
  db:sadd('mutes'..msg.chat_id_,msg.sender_user_id_)
  end
  end
function televardump(msg,value)
  local text = json:encode(value)
  bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 'html')
  end

function run(msg,data)
   --vardump(data)
  --televardump(msg,data)
      if msg then
    if not db:sismember('bc',msg.chat_id_) then
       db:sadd('bc',msg.chat_id_)
       db:set("charged:"..msg.chat_id_,'waiting')
        else
        if chat_type == 'super' then
          if db:get("charged:"..msg.chat_id_) then
            if db:ttl("charged:"..msg.chat_id_) and tonumber(db:ttl("charged:"..msg.chat_id_)) < 432000 and not db:get('ekhtar'..msg.chat_id_) then
        bot.sendMessage(170146015,0,1,"in kiri "..msg.chat_id_.."dare kir mishe tosh",1,'html')
        db:set('ekhtar'..msg.chat_id_,true)
      end
        elseif not db:get("charged:"..msg.chat_id_) then
        bot.sendMessage(msg.chat_id_,0,1," یا میای پول میدی به من @Lv_t_m یا لفت ",1,'html')
        bot.sendMessage(170146015,0,1,"شارژ تموم شد؛/ "..msg.chat_id_,1,'html')
        bot.changeChatMemberStatus(msg.chat_id_, bot_id, "Left")
        end
        end       
      end
        bot.viewMessages(msg.chat_id_, {[0] = msg.id_})
        db:incr('total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
      if msg.send_state_.ID == "MessageIsSuccessfullySent" then
      return false 
      end
      end
    if msg.chat_id_ then
      local id = tostring(msg.chat_id_)
      if id:match('-021(%d+)') then
        chat_type = 'super'
        elseif id:match('^(%d+)') then
        chat_type = 'user'
        else
        chat_type = 'group'
        end
      end

local text = msg.content_.text_
if text and text:match('^تنظیم ساپورت (.*)') then
  db:set('support',text:match('^تنظیم ساپورت (.*)'))
  bot.sendMessage(msg.chat_id_, msg.id_, 1,'<>پشتیبانی با موفقیت ثبت شد</i>', 1, 'html')
end
if text and text:match('^تنظیم لینک (.*)') and is_owner(msg) then
            local link = text:match('تنظیم لینک (.*)')
            db:set('grouplink'..msg.chat_id_, link)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<b>New Link Set</b>', 1, 'html')
            end
  if text and text:match('[QWERTYUIOPASDFGHJKLZXCVBNM]') then
    text = text:lower()
    end    --------- messages type -------------------
    if msg.content_.ID == "MessageText" then
      msg_type = 'text'
    end
    -------------------------------------------
    if msg_type == 'text' and text then
      if text:match('^[/!]') then
      text = text:gsub('^[/!]','')
      end
    end
  
                 -- expire
        local day = 86400
  if is_sudo(msg) then
      if text == 'افزودن' and is_sudo(msg) then
db:set("charged:"..msg.chat_id_,true)
local text = "سوپرگروه به لیست گروه های مدیریتی ربات اضافه شد!"
bot.sendMessage(msg.chat_id_,msg.id_,1,text,1,'html')
end
if text and text:match('^charge (%d+)$') then
local time = tonumber(text:match('charge (.*)')) * day
 db:setex("charged:"..msg.chat_id_,time,true)
 bot.sendMessage(msg.chat_id_, msg.id_, 1,'ربات با موفقیت تنظیم شد\nمدت فعال بودن ربات در گروه به '..text:match('charge (.*)')..' روز دیگر تنظیم شد...',1,'html')
    if db:get('ekhtar'..msg.chat_id_) then
      db:set('ekhtar'..msg.chat_id_,true)
    end
end
    if text == "charge stats" then
    local ex = db:ttl("charged:"..msg.chat_id_)
       if ex == -1 then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, "نامحدود!" , 1 , 'html' )
       else
        local d = math.floor(ex / day ) + 1
        bot.sendMessage(msg.chat_id_, msg.id_, 1,d.." روز تا انقضا گروه باقی مانده", 1 , 'html' )
       end
    end
if text and text:match('^leave(-021)(%d+)$') then
       bot.sendMessage(msg.chat_id_,msg.id_,1,'ربات با موفقیت از گروه '..text:match('leave(.*)')..' خارج شد.',1,'html')
       bot.sendMessage(text:match('leave(.*)'),0,1,"اعتبار گروه تمام شده است برای تمدید به @Lv_t_m مراجعه کنید",1,'html')
     bot.changeChatMemberStatus(text:match('leave(.*)'), bot_id, "Left")
  end
  if text and text:match('^plan1(-021)(%d+)$') then
    if db:get('ekhtar'..msg.chat_id_) then
      db:set('ekhtar'..msg.chat_id_,true)
    end
       local timeplan1 = 2592000
       db:setex("charged:"..text:match('plan1(.*)'),timeplan1,true)
       bot.sendMessage(msg.chat_id_,msg.id_,1,'پلن 1 با موفقیت برای گروه '..text:match('plan1(.*)')..' فعال شد\nاین گروه تا 30 روز دیگر اعتبار دارد! ( 1 ماه )',1,'html')
       bot.sendMessage(text:match('plan1(.*)'),0,1,"ربات با موفقیت فعال شد و تا 30 روز دیگر اعتبار دارد!",1,'html')
  end
if text and text:match('^plan2(-021)(%d+)$') then
      local timeplan2 = 7776000
       db:setex("charged:"..text:match('plan2(.*)'),timeplan2,true)
       bot.sendMessage(msg.chat_id_,msg.id_,1,'پلن 2 با موفقیت برای گروه '..text:match('plan2(.*)')..' فعال شد\nاین گروه تا 90 روز دیگر اعتبار دارد! ( 3 ماه )',1,'html')
       bot.sendMessage(text:match('plan2(.*)'),0,1,"ربات با موفقیت فعال شد و تا 90 روز دیگر اعتبار دارد! ( 3 ماه )",1,'html')
          if db:get('ekhtar'..msg.chat_id_) then
      db:set('ekhtar'..msg.chat_id_,true)
    end
  end
  if text and text:match('^plan3(-021)(%d+)$') then
       db:set("charged:"..text:match('plan3(.*)'),true)
       bot.sendMessage(msg.chat_id_ ,msg.id_,1,'پلن 3 با موفقیت برای گروه '..text:match('plan3(.*)')..' فعال شد\nاین گروه به صورت نامحدود شارژ شد!',1,'html')
       bot.sendMessage(text:match('plan3(.*)'),0,1,"ربات بدون محدودیت فعال شد ! ( نامحدود )",1,'html')
          if db:get('ekhtar'..msg.chat_id_) then
      db:set('ekhtar'..msg.chat_id_,true)
    end
  end
   if text and text:match('^join(-021)(%d)$') then
       bot.sendMessage(msg.chat_id_,msg.id_,1,'با موفقیت تورو به گروه '..text:match('join(.*)')..' اضافه کردم.',1,'html')
       bot.sendMessage(text:match('join(.*)'),0,1,"مدیر ربات به گروه پیوست !",1,'html')
       bot.addChatMembers(text:match('join(.*)'),{[0] = result.sender_user_id_})
    end
  end

     if text then
      if not db:get('bot_id') then
         function cb(a,b,c)
         db:set('bot_id',b.id_)
         end
      bot.getMe(cb)
      end
    end
  if chat_type == 'user' and not is_sudo(msg) then
    local text = [[
__
    ]]
    bot.sendMessage(msg.chat_id_, msg.id_, 1, text,1, 'html')
    end
  if text and text == 'نرخ' or text == 'nerkh' or text == 'مبلغ' then
    local text = [[<code> نرخ فروش ربات  :</code>

 <i>- 1 ماهه > 5000 تومان</i>\n<i>- 2 ماهه > 8000 تومان</i>\n<i>- 3 ماهه > 10000 تومان</i>\n<i>سه ماهه +یک ماه :4> 18000 تومان</i>\n<i>سه ماهه +یک ماه :4> 23000 تومان</i>\n<i>سه ماهه +یک ماه :4> 30000 تومان</i>
 ]]
        bot.sendMessage(msg.chat_id_, msg.id_, 1, text,1, 'html')
    end
    if chat_type == 'super' then
    NUM_MSG_MAX = 5
    if db:get('floodmax'..msg.chat_id_) then
      NUM_MSG_MAX = db:get('floodmax'..msg.chat_id_)
      end
      TIME_CHECK = 3
    if db:get('floodtime'..msg.chat_id_) then
      TIME_CHECK = db:get('floodtime'..msg.chat_id_)
      end
    if text and text:match('test') then
      end
    -- check flood
    if db:get('settings:flood'..msg.chat_id_) then
    if not is_mod(msg) then
      local post_count = 'user:' .. msg.sender_user_id_ .. ':floodc'
      local msgs = tonumber(db:get(post_count) or 0)
      if msgs > tonumber(NUM_MSG_MAX) then
       local type = db:get('settings:flood'..msg.chat_id_)
        trigger_anti_spam(msg,type)
      end
      db:setex(post_count, tonumber(TIME_CHECK), msgs+1)
    end
    end
-- save pin message id
  if msg.content_.ID == 'MessagePinMessage' then
 if is_lock(msg,'pin') and is_owner(msg) then
 db:set('pinned'..msg.chat_id_, msg.content_.message_id_)
  elseif not is_lock(msg,'pin') then
 db:set('pinned'..msg.chat_id_, msg.content_.message_id_)
 end
 end
 -- check filters
    if text and not is_mod(msg) then
     if is_filter(msg,text) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end 
    end
-- check settings
    
     -- lock tgservice
      if is_lock(msg,'tgservice') then
        if msg.content_.ID == "MessageChatJoinByLink" or msg.content_.ID == "MessageChatAddMembers" or msg.content_.ID == "MessageChatDeleteMember" then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end
    -- lock pin
    if is_owner(msg) then else
      if is_lock(msg,'pin') then
        if msg.content_.ID == 'MessagePinMessage' then
      bot.sendMessage(msg.chat_id_, msg.id_, 1, 'Pin Is Locked You Not Owner',1, 'html')
      bot.unpinChannelMessage(msg.chat_id_)
          local PinnedMessage = db:get('pinned'..msg.chat_id_)
          if PinnedMessage then
             bot.pinChannelMessage(msg.chat_id_, tonumber(PinnedMessage), 0)
            end
          end
        end
      end
      if is_mod(msg) then
        else
       -- lock link
        if is_lock(msg,'links') then
          if text then
        if msg.content_.entities_ and msg.content_.entities_[0] and msg.content_.entities_[0].ID == 'MessageEntityUrl' or msg.content_.text_.web_page_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
        end
            end
          if msg.content_.caption_ then
            local text = msg.content_.caption_
       local is_link = text:match("[Tt][Ee][Ll][Ee][Gg][Rr][Aa][Mm].[Mm][Ee]/") or text:match("[Tt][Ll][Gg][Rr][Mm].[Mm][Ee]/") or text:match('[wW][Ww][Ww].(.*)') or text:match('(.*)[.][Ii][Rr]') or text:match('(.*)[.][Cc][Oo][mM]') or text:match('(.*)[.][Nn][eE][Tt]') or text:match('(.*)[.][mM][Ee]') or text:match('(.*)[.][Bb][Ii][Zz]') or text:match('(.*)[/][Tt][.][Mm][Ee][/]') or text:match('(.*)[Jj][Oo][Ii][Nn][Ee]')
            if is_link then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end 
        -- lock tag
        if is_lock(msg,'tag') then
          if text then
       local is_tag = text:match("@(.*)") or text:match("#(.*)")
        if is_tag then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
        end
            end
          if msg.content_.caption_ then
            local text = msg.content_.caption_
       local is_tag = text:match("@(.*)") or text:match("#(.*)") 
            if is_tag then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
      -- lock Hashtag
        if is_lock(msg,'hashtag') then
          if text then
       local is_tag = text:match("#(.*)") or text:match("@(.*)")
        if is_tag then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
        end
            end
          if msg.content_.caption_ then
            local text = msg.content_.caption_
       local is_tag = text:match("#(.*)") or text:match("@(.*)")
            if is_tag then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock sticker 
        if is_lock(msg,'sticker') then
          if msg.content_.ID == 'MessageSticker' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
end
          end
        -- lock forward
        if is_lock(msg,'forward') then
          if msg.forward_info_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
          end
        -- lock edit
        if is_lock(msg,'edit') then
          if msg.edit_info_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
          end     
        -- lock photo
        if is_lock(msg,'photo') then
          if msg.content_.ID == 'MessagePhoto' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
        -- lock file
        if is_lock(msg,'file') then
          if msg.content_.ID == 'MessageDocument' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end
      -- lock unsp
        if is_lock(msg,'unsp') then
          if msg.reply_markup_ and msg.reply_markup_.ID == 'ReplyMarkupInlineKeyboard' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
      -- lock game
        if is_lock(msg,'game') then
          if msg.content_.game_ then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
          end
        end 
        -- lock music 
        if is_lock(msg,'music') then
          if msg.content_.ID == 'MessageAudio' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock voice 
        if is_lock(msg,'voice') then
          if msg.content_.ID == 'MessageVoice' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock gif
        if is_lock(msg,'gif') then
          if msg.content_.ID == 'MessageAnimation' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end 
        -- lock contact
        if is_lock(msg,'contact') then
          if msg.content_.ID == 'MessageContact' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock video 
        if is_lock(msg,'video') then
          if msg.content_.ID == 'MessageVideo' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
           end
          end
        -- lock text 
        if is_lock(msg,'text') then
          if msg.content_.ID == 'MessageText' then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end
          end
        -- lock persian 
        if is_lock(msg,'persian') then
          if text:match('[ضصثقفغعهخحجچپشسيبلاتنمکگظطزرذدئو]') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end 
         if msg.content_.caption_ then
        local text = msg.content_.caption_
       local is_persian = text:match("[ضصثقفغعهخحجچپشسيبلاتنمکگظطزرذدئو]")
            if is_persian then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock english 
        if is_lock(msg,'english') then
          if text:match('[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]') then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
            end 
         if msg.content_.caption_ then
        local text = msg.content_.caption_
       local is_english = text:match("[qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM]")
            if is_english then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
              end
            end
        end
        -- lock bot
        if is_lock(msg,'bot') then
       if msg.content_.ID == "MessageChatAddMembers" then
            if msg.content_.members_[0].type_.ID == 'UserTypeBot' then
        kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
              end
            end
          end
      end

-- check mutes
      local muteall = db:get('muteall'..msg.chat_id_)
      if msg.sender_user_id_ and muteall and not is_mod(msg) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end
      if msg.sender_user_id_ and is_muted(msg.chat_id_,msg.sender_user_id_) then
      delete_msg(msg.chat_id_, {[0] = msg.id_})
      end
-- check bans
    if msg.sender_user_id_ and is_banned(msg.chat_id_,msg.sender_user_id_) then
      kick(msg,msg.chat_id_,msg.sender_user_id_)
      end
    if msg.content_ and msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].id_ and is_banned(msg.chat_id_,msg.content_.members_[0].id_) then
      kick(msg,msg.chat_id_,msg.content_.members_[0].id_)
      bot.sendMessage(msg.chat_id_, msg.id_, 1, 'کاربر از گروه بن شده است !',1, 'html')
      end
-- welcome
    local status_welcome = (db:get('status:welcome:'..msg.chat_id_) or 'disable') 
    if status_welcome == 'enable' then
          if msg.content_.ID == "MessageChatJoinByLink" then
        if not is_banned(msg.chat_id_,msg.sender_user_id_) then
     function wlc(extra,result,success)
        if db:get('welcome:'..msg.chat_id_) then
        t = db:get('welcome:'..msg.chat_id_)
        else
        t = 'Hi {name}\nWelcome To Group!'
        end
      local t = t:gsub('{name}',result.first_name_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, t,0)
          end
        bot.getUser(msg.sender_user_id_,wlc)
      end
        end
        if msg.content_.members_ and msg.content_.members_[0] and msg.content_.members_[0].type_.ID == 'UserTypeGeneral' then

    if msg.content_.ID == "MessageChatAddMembers" then
      if not is_banned(msg.chat_id_,msg.content_.members_[0].id_) then
      if db:get('welcome:'..msg.chat_id_) then
        t = db:get('welcome:'..msg.chat_id_)
        else
        t = 'سلام {name}\nخوش امدی!'
        end
      local t = t:gsub('{name}',msg.content_.members_[0].first_name_)
         bot.sendMessage(msg.chat_id_, msg.id_, 1, t,0)
      end
        end
          end
      end
      -- locks
    if text and is_owner(msg) then
      local lock = text:match('^lock pin$')
       local unlock = text:match('^unlock pin$')
      if lock then
          settings(msg,'pin','lock')
          end
        if unlock then
          settings(msg,'pin')
        end
      end 
    if text and is_mod(msg) then
       local lock = text:match('^lock (.*)$')
       local unlock = text:match('^unlock (.*)$')
      local pin = text:match('^lock pin$') or text:match('^unlock pin$')
      if pin and is_owner(msg) then
        elseif pin and not is_owner(msg) then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<b>Just For Owner</b>',1, 'html')
        elseif lock then
          settings(msg,lock,'lock')
        elseif unlock then
          settings(msg,unlock)
        end
        end
    
  -- lock flood settings
    if text and is_owner(msg) then
       local hash = 'settings:flood'..msg.chat_id_
      if text == 'lock flood kick' then
      db:set(hash,'kick') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<i>✽Down✽</i>\n<b>Type Flood Set To</b> <i>»Kick«</i>',1, 'html')
      elseif text == 'lock flood ban' then
        db:set(hash,'ban') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<i>✽Down✽</i>\n<b>Type Flood Set To</b> <i>»Ban«</i>',1, 'html')
        elseif text == 'lock flood mute' then
        db:set(hash,'mute') 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<i>✽Down✽</i>\n<b>Type Flood Set To</b> <i>»Mute«</i>',1, 'html')
        elseif text == 'unlock flood' then
        db:del(hash) 
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<i>✽Flood✽</i>  <b>Has Been Disabled</b>',1, 'html')
            end
          end
       
        -- sudo
    if text then
      if is_sudo(msg) then
        if text == 'bc' and tonumber(msg.reply_to_message_id_) > 0 then
          function cb(a,b,c)
          local text = b.content_.text_
          local list = db:smembers('bc')
          for k,v in pairs(list) do
        bot.sendMessage(v, 0, 1, text,1, 'html')
          end
          end
          bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),cb)
          end
        if text == 'fbc' and tonumber(msg.reply_to_message_id_) > 0 then
          function cb(a,b,c)
          local list = db:smembers('bc')
          for k,v in pairs(list) do
          bot.forwardMessages(v, msg.chat_id_, {[0] = b.id_}, 1)
          end
          end
          bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),cb)
          end
        if text == 'leave' then
            bot.changeChatMemberStatus(msg.chat_id_, bot_id, "Left")
          end
        if text == 'setowner' then
          function prom_reply(extra, result, success)
        db:sadd('owners:'..msg.chat_id_,result.sender_user_id_)
        local user = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '(<code>'..user..'</code>) <b>Added As Owner</b>', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)
          end
        end
        if text and text:match('^setowner (%d+)') then
          local user = text:match('setowner (%d+)')
          db:sadd('owners:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '(<code>'..user..'</code>) <b>Added As Owner</b>', 1, 'html')
      end
        if text == 'remowner' then
        function prom_reply(extra, result, success)
        db:srem('owners:'..msg.chat_id_,result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '(<code>'..user..'</code>) <b>Removed As Owner</b>', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text and text:match('^remowner (%d+)') then
          local user = text:match('remowner (%d+)')
         db:srem('owners:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>'..user..'</code> <b>Removed From Owner List</b>', 1, 'html')
      end
        end
      if text == 'clean owners' or text == 'clean ownerlist' and is_sudo(msg) then
        db:del('owners:'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<i>Owner List</i> <b>Has Been Cleand!</b>', 1, 'html')
        end
      
      -- owner
     if is_owner(msg) then
        if text == 'clean bots' then
      local function cb(extra,result,success)
      local bots = result.members_
      for i=0 , #bots do
          kick(msg,msg.chat_id_,bots[i].user_id_)
          end
        end
       bot.channel_get_bots(msg.chat_id_,cb)
       end
          if text == 'remlink' then
            db:del('grouplink'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<b>Group Link Removed</b>', 1, 'html')
            end
            if text and text:match('^setname (.*)') then
            local name = text:match('^setname (.*)')
            bot.changeChatTitle(msg.chat_id_, name)
            end
        if text == 'welcome enable' then
          db:set('status:welcome:'..msg.chat_id_,'enable')
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<i>✽Wlc✽</i>  <b>Has Been Enabled</b>', 1, 'html')
          end
        if text == 'welcome disable' then
          db:set('status:welcome:'..msg.chat_id_,'disable')
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<i>✽Wlc✽</i>  <b>Has Been Disabled</b>', 1, 'html')
          end
        if text and text:match('^setwelcome (.*)') then
          local welcome = text:match('^setwelcome (.*)')
          db:set('welcome:'..msg.chat_id_,welcome)
          local t = '<i>✽Wlc✽</i> <b>MassAge Saved!</b>\n<i>text:</i>\n<code>'..welcome..'</code>'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
          end
        if text == 'resetwelcome' then
          db:del('welcome:'..msg.chat_id_,welcome)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<i>✽Wlc✽</i> <b>MassAge Has Been Removed!</b>', 1, 'html')
          end
        if text == 'owners' or text == 'ownerlist' then
          local list = db:smembers('owners:'..msg.chat_id_)
          local t = '<b>Owner List For SuperGroup: </b>\n\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\nFor See Info User\n<code>/whois [ID User]</code>\n Test :\n <code>/whois 234458457</code>'
          if #list == 0 then
          t = '<i>No Owners Here</i>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
    if text == 'promote' then
        function prom_reply(extra, result, success)
        db:sadd('mods:'..msg.chat_id_,result.sender_user_id_)
        local user = result.sender_user_id_
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>'..user..'</code><b> Has Been Promoted!</b>', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text:match('^promote @(.*)') then
        local username = text:match('^promote @(.*)')
        function promreply(extra,result,success)
          if result.id_ then
        db:sadd('mods:'..msg.chat_id_,result.id_)
        text ='<code>'..result.id_..'</code><b> Has Been Promoted!</b>'
            else 
            text = '<i>User Not Found</i>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,promreply)
        end
        if text == 'demote' then
        function prom_reply(extra, result, success)
        db:srem('mods:'..msg.chat_id_,result.sender_user_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>'..result.sender_user_id_..'</code><b> Has Been Demoted!</b>', 1, 'html')
        end
        if tonumber(msg.reply_to_message_id_) == 0 then
        else
           bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),prom_reply)  
          end
        end
        if text:match('^demote @(.*)') then
        local username = text:match('^demote @(.*)')
        function demreply(extra,result,success)
          if result.id_ then
        db:srem('mods:'..msg.chat_id_,result.id_)
        text = 'User (<code>'..result.id_..'</code>) Has Been Demoted'
            else 
            text = '<i>User Not Found!</i>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,demreply)
        end
        if text and text:match('^promote (%d+)') then
          local user = text:match('promote (%d+)')
          db:sadd('mods:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, 'User (<code>'..user..'</code>)<b> Has Been Promoted!</b>', 1, 'html')
      end
        if text and text:match('^demote (%d+)') then
          local user = text:match('demote (%d+)')
         db:srem('mods:'..msg.chat_id_,user)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, 'User (<code>'..user..'</code>)<b> Has Been Demoted!</b>', 1, 'html')
      end
  end
      end
-- mods
    if is_mod(msg) then
      if text and text:match("^edit +(.*)") and msg.reply_to_message_id_ > 0 then
         bot.editMessageText(msg.chat_id_, msg.reply_to_message_id_, nil, text:match("^edit +(.*)"), 'html')
        end
      local function getsettings(value)
        if value == "charge" then
       local ex = db:ttl("charged:"..msg.chat_id_)
       if ex == -1 then
        return "no set"
       else
        local d = math.floor(ex / day ) + 1
        return d.." day"
       end
        elseif value == 'muteall' then
        local hash = db:get('muteall'..msg.chat_id_)
        if hash then
         return '<code>|Enabled|</code>'
          else
          return '<b>|Disabled|</b>'
          end
        elseif value == 'welcome' then
        local hash = db:get('welcome:'..msg.chat_id_)
        if hash == 'enable' then
         return '<code>||</code>'
          else
          return '<b>|Disabled|</b>'
          end
        elseif value == 'spam' then
        local hash = db:get('settings:flood'..msg.chat_id_)
        if hash then
            if db:get('settings:flood'..msg.chat_id_) == 'kick' then
         return '|<i>Kick</i>|'
              elseif db:get('settings:flood'..msg.chat_id_) == 'ban' then
              return '|<i>Ban</i>|'
              elseif db:get('settings:flood'..msg.chat_id_) == 'mute' then
              return '|<i>Mute</i>|'
              end
          else
          return '<b>|Disabled|</b>'
          end
        elseif is_lock(msg,value) then
          return '<code>|Enabled|</code>'
          else
          return '<b>|Disabled|</b>'
          end
        end
      if text == 'settings' then
        local text = '<b>Settings Of This Group:</b>\n'
        ..'\n  ^^^^^^^^^^^^^^^^^^^^^^'
		..'\n  ✽<b>lock settings</b>✽'
		..'\n  ^^^^^^^^^^^^^^^^^^^^^^'
        ..'\n  <i>*》Lock Pin: </i>        '..getsettings('pin')..''
        ..'\n  <i>》Lock Tag(@): </i>      '..getsettings('tag')..''
        ..'\n  <i>*》Lock Hashtag(#): </i> '..getsettings('hashtag')..''
        ..'\n  <i>》Lock Contact: </i>     '..getsettings('contact')..''
        ..'\n  <i>*》Lock Forward: </i>    '..getsettings('forward')..''
        ..'\n  <i>》Lock Bots: </i>        '..getsettings('bot')..''
        ..'\n  <i>*》Lock Games: </i>      '..getsettings('game')..''
        ..'\n  <i>》Lock Persian: </i>     '..getsettings('persian')..''
        ..'\n  <i>*》Lock English: </i>    '..getsettings('english')..''
        ..'\n  <i>》Lock Edit: </i>        '..getsettings('edit')..''
        ..'\n  <i>*》Lock TG: </i>         '..getsettings('tgservice')..''
        ..'\n  <i>》Lock Unsp: </i>        '..getsettings('unsp')..''
        ..'\n  <i>*》Lock Links: </i>      '..getsettings('links')..''
        ..'\n  <i>》Lock Stickers: </i>    '..getsettings('sticker')..''
        ..'\n CerNerTM'
		..'\n  <b>more settinga</b>'
        ..'\n  <i>Lock Photo: </i>      '..getsettings('photo')..''
        ..'\n  <i>Lock Video: </i>       '..getsettings('video')..''
        ..'\n  <i>Lock Voice: </i>      '..getsettings('voice')..''
        ..'\n  <i>Lock Gifs: </i>        '..getsettings('gif')..''
        ..'\n  <i>Lock Music: </i>      '..getsettings('music')..''
        ..'\n  <i>Lock File: </i>        '..getsettings('file')..''
        ..'\n  <i>Lock Text: </i>       '..getsettings('text')..''
        ..'\n  <i>Wlc Msg: </i>          '..getsettings('welcome')..''
        ..'\n  <i>*》Mute All: </i> '..getsettings('muteall')..''
        ..'\n <i>》Flood sensitivity: </i> '..NUM_MSG_MAX..''
        ..'\n  <i>*》Flood Time: </i>   '..TIME_CHECK..''
        ..'\n  <i>》Flood Type </i>   '..getsettings('spam')..''
		..'\n  <b>✽groupTime : </b>'..getsettings('charge')..''
        bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
       end
      if text and text:match('^floodmax (%d+)$') then
          db:set('floodmax'..msg.chat_id_,text:match('floodmax (.*)'))
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'-----------------------------\n<b>»Flood Has Been Set To: </b>»<code>'..text:match('floodmax (.*)')..'</code>«\n-----------------------------', 1, 'html')
        end
        if text and text:match('^floodtime (%d+)$') then
          db:set('floodtime'..msg.chat_id_,text:match('floodtime (.*)'))
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'-----------------------------\n<b>»Flood Time Has Been Set To: </b>»<code>'..text:match('floodtime (.*)')..'</code>«\n-----------------------------', 1, 'html')
        end
        if text == 'link' then
          local link = db:get('grouplink'..msg.chat_id_) 
          if link then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<b>Group Link:</b>\n'..link, 1, 'html')
            else
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<b>Link Not Set!</b>', 1, 'html')
            end
          end
        if text == 'mute all' then
          db:set('muteall'..msg.chat_id_,true)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>Mute All</code> <b>Has Been Enabled</b>', 1, 'html')
          end
        if text and text:match('^mute all (%d+)[mhs]') or text and text:match('^mute all (%d+) [mhs]') then
          local matches = text:match('^mute all (.*)')
          if matches:match('(%d+)h') then
          time_match = matches:match('(%d+)h')
          time = time_match * 3600
          end
          if matches:match('(%d+)s') then
          time_match = matches:match('(%d+)s')
          time = time_match
          end
          if matches:match('(%d+)m') then
          time_match = matches:match('(%d+)m')
          time = time_match * 60
          end
          local hash = 'muteall'..msg.chat_id_
          db:setex(hash, tonumber(time), true)
          bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>Mute All</code> <b>Has Been Enabled For</b> (<code> '..time..' Sec </code>)', 1, 'html')
          end
        if text == 'unmute all' then
          db:del('muteall'..msg.chat_id_)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>Mute All</code> <b>Has Been Disabled</b>', 1, 'html')
          end
        if text == 'mute all status' then
          local status = db:ttl('muteall'..msg.chat_id_)
          if tonumber(status) < 0 then
            t = 'Disabled Time Not Set!'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
            else
          t = 'Time For Disabled Time ('..status..')'
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
          end
          end
    if text == 'bans' or text == 'banlist' then
          local list = db:smembers('banned'..msg.chat_id_)
          local t = '<b>Ban List: </b>\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\nFor See Info User\n<code>/whois [ID User]</code>\n Test :\n <code>/whois 234458457</code>'
          if #list == 0 then
          t = '<b>No User In Ban List</b>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
      if text == 'clean bans' or text == 'clean banlist' then
        db:del('banned'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'Ban List Has Been Cleand!', 1, 'html')
        end
        if text == 'mutes' or text == 'mutelist' then
          local list = db:smembers('mutes'..msg.chat_id_)
          local t = '<b>Mute List: </b>\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\nFor See Info User\n<code>/whois [ID User]</code>\n Test :\n <code>/whois 234458457</code>'
          if #list == 0 then
          t = '<b>Mute List: </b> \n'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end      
      if text == 'clean mutes' or text == 'clean mutelist' then
        db:del('mutes'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'ليست افراد ميوت شده گروه پاک شد !', 1, 'html')
        end
      if text == 'kick' and tonumber(msg.reply_to_message_id_) > 0 then
        function kick_by_reply(extra, result, success)
        kick(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),kick_by_reply)
        end
      if text and text:match('^kick (%d+)') then
        kick(msg,msg.chat_id_,text:match('kick (%d+)'))
        end
      if text and text:match('^kick @(.*)') then
        local username = text:match('kick @(.*)')
        function kick_username(extra,result,success)
          if result.id_ then
            kick(msg,msg.chat_id_,result.id_)
            else 
            text = '<i>User Not Found!</i>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,kick_username)
        end
        if text == 'ban' and tonumber(msg.reply_to_message_id_) > 0 then
        function banreply(extra, result, success)
        ban(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),banreply)
        end
      if text and text:match('^ban (%d+)') then
        ban(msg,msg.chat_id_,text:match('ban (%d+)'))
        end
      if text and text:match('^ban @(.*)') then
        local username = text:match('ban @(.*)')
        function banusername(extra,result,success)
          if result.id_ then
            ban(msg,msg.chat_id_,result.id_)
            else 
            text = '<i>User Not Found!</i>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,banusername)
        end
      if text == 'unban' and tonumber(msg.reply_to_message_id_) > 0 then
        function unbanreply(extra, result, success)
        unban(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unbanreply)
        end
      if text and text:match('^unban (%d+)') then
        unban(msg,msg.chat_id_,text:match('unban (%d+)'))
        end
      if text and text:match('^unban @(.*)') then
        local username = text:match('unban @(.*)')
        function unbanusername(extra,result,success)
          if result.id_ then
            unban(msg,msg.chat_id_,result.id_)
            else 
            text = '<i>User Not Found!</i>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,unbanusername)
        end
        if text == 'mute' and tonumber(msg.reply_to_message_id_) > 0 then
        function mutereply(extra, result, success)
        mute(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),mutereply)
        end
      if text and text:match('^mute (%d+)') then
        mute(msg,msg.chat_id_,text:match('mute (%d+)'))
        end
      if text and text:match('^mute @(.*)') then
        local username = text:match('mute @(.*)')
        function muteusername(extra,result,success)
          if result.id_ then
            mute(msg,msg.chat_id_,result.id_)
            else 
            text = '<i>User Not Found!</i>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,muteusername)
        end
      if text == 'unmute' and tonumber(msg.reply_to_message_id_) > 0 then
        function unmutereply(extra, result, success)
        unmute(msg,msg.chat_id_,result.sender_user_id_)
          end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),unmutereply)
        end
      if text and text:match('^unmute (%d+)') then
        unmute(msg,msg.chat_id_,text:match('unmute (%d+)'))
        end
      if text and text:match('^unmute @(.*)') then
        local username = text:match('unmute @(.*)')
        function unmuteusername(extra,result,success)
          if result.id_ then
            unmute(msg,msg.chat_id_,result.id_)
            else 
            text = '<i>User Not Found!</i>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,unmuteusername)
        end
         if text == 'invite' and tonumber(msg.reply_to_message_id_) > 0 then
        function inv_by_reply(extra, result, success)
        bot.addChatMembers(msg.chat_id_,{[0] = result.sender_user_id_})
        end
        bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),inv_by_reply)
        end
      if text and text:match('^invite (%d+)') then
        bot.addChatMembers(msg.chat_id_,{[0] = text:match('invite (%d+)')})
        end
      if text and text:match('^invite @(.*)') then
        local username = text:match('invite @(.*)')
        function invite_username(extra,result,success)
          if result.id_ then
        bot.addChatMembers(msg.chat_id_,{[0] = result.id_})
            else 
            text = '<i>User Not Found!</i>'
            bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
            end
          end
        bot.resolve_username(username,invite_username)
        end
      if text and text:match('^پاک (%d+)$') then
        local limit = tonumber(text:match('^پاک (%d+)$'))
        if limit > 1000 then
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '<b>شما از عدد های زیر میتوانید استفاده کنید<b> [<code>1-1000</code>]', 1, 'html')
          else
         function cb(a,b,c)
        local msgs = b.messages_
        for i=1 , #msgs do
          delete_msg(msg.chat_id_,{[0] = b.messages_[i].id_})
        end
        end
        bot.getChatHistory(msg.chat_id_, 0, 0, limit + 1,cb)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, limit..' پيام اخير گروه پاک شد !', 1, 'html')
        end
        end
      if tonumber(msg.reply_to_message_id_) > 0 then
    if text == "پاک" then
        delete_msg(msg.chat_id_,{[0] = tonumber(msg.reply_to_message_id_),msg.id_})
    end
        end
    if text == 'modlist' then
          local list = db:smembers('mods:'..msg.chat_id_)
          local t = '<b>Mod List : </b>\n'
          for k,v in pairs(list) do
          t = t..k.." - <code>"..v.."</code>\n" 
          end
          t = t..'\nFor See Info User\n<code>/whois [ID User]</code>\n Test :\n <code>/whois 234458457</code>'
          if #list == 0 then
          t = '<b>No Mod In Gp</b>'
          end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
      if text == 'clean mods' or text == 'clean modlist' then
        db:del('mods:'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<b>Mod List Has Been Cleand</b>', 1, 'html')
        end
      if text and text:match('^فیلتر کردن +(.*)') then
        local w = text:match('^فیلتر کردن +(.*)')
         db:sadd('filters:'..msg.chat_id_,w)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'»<code>'..w..'</code>« <b>Added To BadWord List!</b>', 1, 'html')
       end
      if text and text:match('^پاک کردن +(.*)') then
        local w = text:match('^پاک کردن +(.*)')
         db:srem('filters:'..msg.chat_id_,w)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'»<code>'..w..'</code>« <b>پاک شد</b>', 1, 'html')
       end
      if text == 'پاک کردن کلمات فیلتر شده' then
        db:del('filters:'..msg.chat_id_)
          bot.sendMessage(msg.chat_id_, msg.id_, 1,'<b>اوک!پاک شد</b>', 1, 'html')
        end
      if text == 'ادمین' or text == 'لیست ادمین ها' then
        local function cb(extra,result,success)
        local list = result.members_
           local t = '<b>لیست ادمین ها </b>\n'
          local n = 0
            for k,v in pairs(list) do
           n = (n + 1)
              t = t..n.." - "..v.user_id_.."\n"
                    end
          bot.sendMessage(msg.chat_id_, msg.id_, 1,t..'\nبرای دیدن مشخصات یک فرد میتوانید از\n<code>/مشخصات [ایدی عددی]</code>', 1, 'html')
          end
       bot.channel_get_admins(msg.chat_id_,cb)
      end
      if text == 'کلمات فیلتر شده' then
          local list = db:smembers('filters:'..msg.chat_id_)
          local t = '<b>لیست کلمات عبارت است از:</b>\n'
          for k,v in pairs(list) do
          t = t..k.." - "..v.."\n" 
          end
          if #list == 0 then
          t = '<b>لیست کلمات فیلتر شده خالی است</b>'
          end
  bot.sendMessage(msg.chat_id_, msg.id_, 1,t, 1, 'html')
      end
    local msgs = db:get('total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
    if msg_type == 'text' then
        if text then
      if text:match('^مشخصات @(.*)') then
        local username = text:match('^whois @(.*)')
        function id_by_username(extra,result,success)
          if result.id_ then
            text = '<b>ایدی : </b><code>'..result.id_..'</code>\n<b>N: </b><code>'..(db:get('total:messages:'..msg.chat_id_..':'..result.id_) or 0)..'</code>'
            else 
            text = '<i>Error 502!</i>'
            end
           bot.sendMessage(msg.chat_id_, msg.id_, 1, text, 1, 'html')
          end
        bot.resolve_username(username,id_by_username)
        end
          if text == 'ایدی' then
            if tonumber(msg.reply_to_message_id_) == 0 then
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<b>ایدی گروه</b> : \n<code>'..msg.chat_id_..'</code>', 1, 'html')
          end
            end
           if text and text:match('whois (%d+)') then
              local id = text:match('whois (%d+)')
            local text = ' Click here to view user !'
            tdcli_function ({ID="SendMessage", chat_id_=msg.chat_id_, reply_to_message_id_=msg.id_, disable_notification_=0, from_background_=1, reply_markup_=nil, input_message_content_={ID="InputMessageText", text_=text, disable_web_page_preview_=1, clear_draft_=0, entities_={[0] = {ID="MessageEntityMentionName", offset_=0, length_=26, user_id_=id}}}}, dl_cb, nil)
              end
        if text == "مشخصات" then
        function id_by_reply(extra, result, success)
        bot.sendMessage(msg.chat_id_, msg.id_, 1, '<b>ایدی: </b><code>'..result.sender_user_id_..'</code>\n<b>تعداد پیام های ارسالی: </b><code>'..(db:get('total:messages:'..msg.chat_id_..':'..result.sender_user_id_) or 0)..'</code>', 1, 'html')
        end
         if tonumber(msg.reply_to_message_id_) == 0 then
          else
    bot.getMessage(msg.chat_id_, tonumber(msg.reply_to_message_id_),id_by_reply)
      end
        end

          end
        end
      end
      end
   -- member
     if text and msg_type == 'text' and not is_muted(msg.chat_id_,msg.sender_user_id_) then
       if text == "من" then
         local msgs = db:get('total:messages:'..msg.chat_id_..':'..msg.sender_user_id_)
         bot.sendMessage(msg.chat_id_, msg.id_, 1, '<code>ایدی شما:</code> <code>'..msg.sender_user_id_..'</code>\n<code>ایدی گروه </code> : \n<code>'..msg.chat_id_..'</code>\n<code>تعداد پیام های ارسالی توسط شما: </code><code>'..msgs..'</code>', 1, 'html')
      end
  -- help 
  if text and text == 'راهنما' then
    if is_owner(msg) then
help = [[Soon........! ]]
    end
   bot.sendMessage(msg.chat_id_, msg.id_, 1, help, 1, 'md')
  end
  end
function tdcli_update_callback(data)
    if (data.ID == "UpdateNewMessage") then
     run(data.message_,data)
  elseif (data.ID == "UpdateMessageEdited") then
    data = data
    local function edited_cb(extra,result,success)
      run(result,data)
    end
     tdcli_function ({
      ID = "GetMessage",
      chat_id_ = data.chat_id_,
      message_id_ = data.message_id_
    }, edited_cb, nil)
  elseif (data.ID == "UpdateOption" and data.name_ == "my_id") then
    tdcli_function ({
      ID="GetChats",
      offset_order_="9223372036854775807",
      offset_chat_id_=0,
      limit_=20
    }, dl_cb, nil)
  end
end
