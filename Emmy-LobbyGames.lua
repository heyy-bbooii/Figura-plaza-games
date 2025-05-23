-- Keybind to tag someone
local tagKey = keybinds:newKeybind("Tag Player", "key.mouse.left")
local HostTarget = world.getEntity("ab8b0d8f-0e4b-47d4-b0a7-b7aae86eff94")
local target
local tagData
local lastTagged = nil
avatar:store("lobbyGames", true)
-- === Tagging Functions === --
-- Try tagging the target
function tryTag()
    target = player:getTargetedEntity(4)
    if target and target:getName() ~= player:getName() and tagData and tagData["tagged"] == player:getName() and target:getVariable("lobbyGames") == true then
        pings.taggedSomeone(target:getName())
    elseif target and tagData and tagData["tagged"] == player:getName() and ((target:getVariable("lobbyGames") == false or not target:getVariable("lobbyGames")))then
        host:setActionbar(target:getName().. "Isnt Playing Tag TwT")
    end
end

-- Store attempted tag to host
function pings.taggedSomeone(name)
    avatar:store("playertag", name)
    if host:isHost() then
        avatar:store("playertag", name)
        host:setActionbar("You tagged " .. name .. "!")
    end
end

-- Clear current target and playertag
function pings.cleartag()
    target = nil
    avatar:store("playertag", nil)
end

-- Detect and respond to changes in who is IT
function updateTagStatus()
    tagData = HostTarget and HostTarget:isLoaded() and HostTarget:getVariable("tagData")
    if tagData and tagData["tagged"] and tagData["tagged"] == player:getName() then
        host:setActionbar("You are IT!")
    end
    if tagData and tagData["tagged"] ~= lastTagged then
        lastTagged = tagData["tagged"]
        if lastTagged ~= nil then
            if lastTagged == player:getName() then
                host:setActionbar("You are now IT!")
            else
                host:setActionbar(lastTagged .. " is now IT!")
            end
        end
    end
end

-- Automatically clear local tag if host updates
function checkTagMatch()
    if target and tagData and tagData["tagged"] == target:getName() then
        pings.cleartag()
    end
end

-- Show current IT player on "whos it" message
function handleWhosItCommand(msg)
    if msg == "whos it" or msg == "who's it" or msg:find("whos it") then
        if tagData and tagData["tagged"] then
            host:setActionbar(tagData["tagged"] .. " is now IT!")
        else
            host:setActionbar("Nobody is IT.")
        end
    else 
        return msg
    end
end

-- === Event Bindings === --

tagKey.press = tryTag

function events.tick()
    updateTagStatus()
    checkTagMatch()
end

-- function events.chat_send_message(msg)
--     return handleWhosItCommand(msg)
-- end
