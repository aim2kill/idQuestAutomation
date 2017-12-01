local addon = CreateFrame('Frame')
addon.completedQuests = {}
addon.incompleteQuests = {}

function addon:canAutomate()
  if IsShiftKeyDown() then
    return false
  else
    return true
  end
end

function addon:stripText(text)
  if not text then return end
  text = string.gsub(text, '|c%x%x%x%x%x%x%x%x(.-)|r','%1')
  text = string.gsub(text, '%[.*%]%s*','')
  text = string.gsub(text, '(.+) %(.+%)', '%1')
  return text
end

function addon:GOSSIP_SHOW()
  -- ChatFrame1:AddMessage('GOSSIP_SHOW')

  if not addon:canAutomate() then return end

  local button
  local text

  for i = 1, 32 do
    button = getglobal('GossipTitleButton' .. i)
    if button:IsVisible() then
      text = addon:stripText(button:GetText())
      if button.type == 'Available' then
        button:Click()
      elseif button.type == 'Active' then
        if addon.completedQuests[text] then
          button:Click()
        end
      end
    end
  end
end

function addon:QUEST_COMPLETE(event)
  -- ChatFrame1:AddMessage('QUEST_COMPLETE')

  if not addon:canAutomate() then return end
  if GetNumQuestChoices() <= 1 then
    QuestFrameCompleteQuestButton:Click()
  end
end

function addon:QUEST_DETAIL()
  -- ChatFrame1:AddMessage('QUEST_DETAIL')

  if not addon:canAutomate() then return end

  AcceptQuest()
end

function addon:QUEST_GREETING()
  -- ChatFrame1:AddMessage('QUEST_GREETING')

  if not addon:canAutomate() then return end

  local button
  local text

  for i = 1, 32 do
    button = getglobal('QuestTitleButton' .. i)
    if button:IsVisible() then
      text = addon:stripText(button:GetText())
      if addon.completedQuests[text] then
        button:Click()
      elseif not addon.incompleteQuests[text] then
        button:Click()
      end
    end
  end
end

function addon:QUEST_LOG_UPDATE()
  -- ChatFrame1:AddMessage('QUEST_LOG_UPDATE')

  if not addon:canAutomate() then return end
  local startEntry = GetQuestLogSelection()
  local numEntries = GetNumQuestLogEntries()
  local title
  local isComplete
  local noObjectives
  local _

  addon.completedQuests = {}
  addon.incompleteQuests = {}

  if numEntries > 0 then
    for i = 1, numEntries do
      SelectQuestLogEntry(i)
      title, _, _, _, _, _, isComplete = GetQuestLogTitle(i)
      noObjectives = GetNumQuestLeaderBoards(i) == 0
      if title then
        if isComplete or noObjectives then
          addon.completedQuests[title] = true
        else
          addon.incompleteQuests[title] = true
        end
      end
    end
  end

  SelectQuestLogEntry(startEntry)
end

function addon:QUEST_PROGRESS()
  -- ChatFrame1:AddMessage('QUEST_PROGRESS')

  if not addon:canAutomate() then return end
  if IsQuestCompletable() then
    CompleteQuest()
  end
end

addon:SetScript('OnEvent', function()
  local handler = addon[event]
  if handler then
    handler(addon, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9)
  end
end)

addon:RegisterEvent('GOSSIP_SHOW')
addon:RegisterEvent('QUEST_COMPLETE')
addon:RegisterEvent('QUEST_DETAIL')
addon:RegisterEvent('QUEST_GREETING')
addon:RegisterEvent('QUEST_LOG_UPDATE')
addon:RegisterEvent('QUEST_PROGRESS')
