local addon = CreateFrame('Frame')
addon.completedQuests = {}
addon.incompleteQuests = {}

function addon:canAutomate ()
  if IsShiftKeyDown()
    return true
  else
    return false
  end
end

function addon:stripText (text)
  if not text then return end
  text = text:gsub('|c%x%x%x%x%x%x%x%x(.-)|r','%1')
  text = text:gsub('%[.*%]%s*','')
  text = text:gsub('(.+) %(.+%)', '%1')
  text = text:trim()
  return text
end

function addon:QUEST_AUTOCOMPLETE (event, questId)
  for i = 0, 6 do
    local id = GetQuestIndexForWatch(i)
    if id then
      ShowQuestComplete(id)
    end
  end
end

function addon:QUEST_COMPLETE (event)
  if not self:canAutomate() then return end
  if GetNumQuestChoices() <= 1 then
    QuestFrameCompleteQuestButton:Click()
  end
end

function addon:QUEST_PROGRESS ()
  if not self:canAutomate() then return end
  if IsQuestCompletable() then
    CompleteQuest()
  end
end

function addon:QUEST_LOG_UPDATE ()
  if not self:canAutomate() then return end
  local startEntry = GetQuestLogSelection()
  local numEntries = GetNumQuestLogEntries()
  local title
  local isComplete
  local noObjectives
  local _

  self.completedQuests = {}
  self.incompleteQuests = {}

  if numEntries > 0 then
    for i = 1, numEntries do
      SelectQuestLogEntry(i)
      title, _, _, _, _, _, isComplete = GetQuestLogTitle(i)
      noObjectives = GetNumQuestLeaderBoards(i) == 0
      if title then
        if isComplete or noObjectives then
          self.completedQuests[title] = true
        else
          self.incompleteQuests[title] = true
        end
      end
    end
  end

  SelectQuestLogEntry(startEntry)
end

function addon:GOSSIP_SHOW ()
  if not self:canAutomate() then return end

  local button
  local text

  for i = 1, 32 do
    button = _G['GossipTitleButton' .. i]
    if button:IsVisible() then
      text = self:stripText(button:GetText())
      if button.type == 'Available' then
        button:Click()
      elseif button.type == 'Active' then
        if self.completedQuests[text] then
          button:Click()
        end
      end
    end
  end
end

function addon:QUEST_GREETING (...)
  if not self:canAutomate() then return end

  local button
  local text

  for i = 1, 32 do
    button = _G['QuestTitleButton' .. i]
    if button:IsVisible() then
      text = self:stripText(button:GetText())
      if self.completedQuests[text] then
        button:Click()
      elseif not self.incompleteQuests[text] then
        button:Click()
      end
    end
  end
end

function addon:QUEST_DETAIL ()
  if not self:canAutomate() then return end
  AcceptQuest()
end

function addon.onevent (self, event, ...)
  if self[event] then
    self[event](self, ...)
  end
end

addon:SetScript('OnEvent', addon.onevent)
addon:RegisterEvent('GOSSIP_SHOW')
addon:RegisterEvent('QUEST_AUTOCOMPLETE')
addon:RegisterEvent('QUEST_COMPLETE')
addon:RegisterEvent('QUEST_DETAIL')
addon:RegisterEvent('QUEST_FINISHED')
addon:RegisterEvent('QUEST_GREETING')
addon:RegisterEvent('QUEST_LOG_UPDATE')
addon:RegisterEvent('QUEST_PROGRESS')
