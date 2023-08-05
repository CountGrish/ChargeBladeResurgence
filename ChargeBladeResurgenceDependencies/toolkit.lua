local behaviorTreeToolKit = require("./ChargeBladeResurgenceDependencies/behaviorTreeToolKit/toolkits")

behaviorTreeToolKit.__savedChanges = {}

---@param paramIndex table
---@return string
local function createTableKey(paramIndex)
    local key = ""
    for _, value in ipairs(paramIndex) do
        key = key .. tostring(value) .. "_"
    end
    return key:sub(1, -2)
end

---@param funcIndex function
---@param paramIndex table
---@param resetFunc function
---@param isInvalid boolean | nil
---@return table
function behaviorTreeToolKit:addFunction(funcIndex, paramIndex, resetFunc, isInvalid)
    isInvalid = isInvalid or false
    local paramIndexKey = createTableKey(paramIndex)
    if self:contains(funcIndex, paramIndex) and not self.__savedChanges[funcIndex][paramIndexKey].isInvalid then
        self.__savedChanges[funcIndex][paramIndexKey].isReset = false
        return self.__savedChanges[funcIndex][paramIndexKey]
    end
    if self.__savedChanges[funcIndex] == nil then
        self.__savedChanges[funcIndex] = {}
    end
    self.__savedChanges[funcIndex][paramIndexKey] = {
        isReset = false,
        isInvalid = isInvalid,
        reset = function()
            self:reset(self.__savedChanges[funcIndex][paramIndexKey], resetFunc)
        end,
    }
    return self.__savedChanges[funcIndex][paramIndexKey]
end

---@param funcIndex function
---@param paramIndex table
function behaviorTreeToolKit:contains(funcIndex, paramIndex)
    local paramIndexKey = createTableKey(paramIndex)
    if self.__savedChanges[paramIndexKey] == nil then
        return false
    end
    return self.__savedChanges[funcIndex][paramIndexKey] ~= nil
end

---@param functionTable table
---@param resetFunc function
function behaviorTreeToolKit:reset(functionTable, resetFunc)
    if not functionTable.isReset and not functionTable.isInvalid then
        resetFunc()
        functionTable.isReset = true
    end
end

function behaviorTreeToolKit.addTransitionEvent(self, NodeID, ConditionID, EventIndex)
    local treeObj = self:getTreeComponentCore()
    local node_data = treeObj:get_node_by_id(NodeID):get_data()
    local Conditions = node_data:get_transition_conditions()
    local TransitionEvents = node_data:get_transition_events()
    local matched = false
    local resetFunc = self:addFunction(self.addTransitionEvent, { NodeID, ConditionID, EventIndex }, function()
        self:eraseTransitionEvent(NodeID, ConditionID, EventIndex)
    end)
    if Conditions == nil then
        return resetFunc
    end
    local matchedConditionIndex
    for index = 0, Conditions:get_size() do
        if tonumber(Conditions[index]) == ConditionID then
            matchedConditionIndex = index
            matched = true
        end
    end
    if matched then
        local Target = TransitionEvents[matchedConditionIndex]
        if not (Target == nil) then
            if Target:get_size() == 0 then
                Target:push_back(tonumber(EventIndex))
            else
                local isCollision = false
                for i = 0, Target:get_size() - 1 do
                    if tonumber(Target[i]) == EventIndex then
                        isCollision = true
                    end
                end
                if isCollision == false then
                    Target:push_back(tonumber(EventIndex))
                end
            end
        end
    end
    return resetFunc
end

function behaviorTreeToolKit.addConditionPairs(self, NodeID, ConditionID, transitionStateIndex, whetherAddDefaultEvent)
    local layer
    local tree
    local playercomp = (self:getMasterPlayerUtils()).playerGameObj
    local motion_fsm2 = playercomp:call("getComponent(System.Type)", sdk.typeof("via.motion.MotionFsm2"))

    if playercomp == nil then
        return
    end
    if motion_fsm2 == nil then
        return
    end

    layer = motion_fsm2:call("getLayer", 0)
    if layer == nil then
        return
    end

    tree = layer:get_tree_object()
    if tree == nil then
        return
    end

    local condition = tree:get_condition(ConditionID)
    if condition == nil then
        return
    end

    local node = tree:get_node_by_id(NodeID)
    if node == nil then
        return
    end

    local node_data = node:get_data()
    local transition_array = node_data:get_transition_conditions()

    local resetFunc = self:addFunction(
        self.addConditionPairs,
        { NodeID, ConditionID, transitionStateIndex, whetherAddDefaultEvent },
        function()
            self:eraseConditionPairs(NodeID, ConditionID, whetherAddDefaultEvent)
        end
    )

    for i = 0, transition_array:get_size() - 1 do
        if tonumber(transition_array[i]) == ConditionID then
            return resetFunc
        end
    end

    transition_array:push_back(tonumber(ConditionID))
    node_data:get_states():push_back(tonumber(transitionStateIndex))

    if not whetherAddDefaultEvent then
        return resetFunc
    end
    local events = node_data:get_transition_events()
    local tmpNode = tree:get_nodes()[1]
    local tmpEvent = tmpNode:get_data():get_transition_events()
    events:push_back(tmpEvent[0])

    return resetFunc
end

function behaviorTreeToolKit.eraseConditionPairs(self, NodeID, ConditionID, whetherAddDefaultEvent)
    local layer
    local tree
    local playercomp = (self:getMasterPlayerUtils()).playerGameObj
    local motion_fsm2 = playercomp:call("getComponent(System.Type)", sdk.typeof("via.motion.MotionFsm2"))

    if playercomp == nil then
        return
    end

    if motion_fsm2 == nil then
        return
    end

    layer = motion_fsm2:call("getLayer", 0)
    if layer == nil then
        return
    end

    tree = layer:get_tree_object()
    if tree == nil then
        return
    end

    local node = tree:get_node_by_id(NodeID)
    if node == nil then
        return
    end

    local node_data = node:get_data()
    local transition_array = node_data:get_transition_conditions()
    for i = 0, transition_array:get_size() - 1 do
        if tonumber(transition_array[i]) == ConditionID then
            transition_array:erase(i)
            node_data:get_states():erase(i)
            if whetherAddDefaultEvent then
                node_data:get_transition_events():erase(i)
            end
        end
    end
end

---@param conditionOrEvent table
---@param field string
---@param value number|string|boolean
---@param extraIdentifier number | string | nil
---@return table
function behaviorTreeToolKit:setField(conditionOrEvent, field, value, extraIdentifier)
    extraIdentifier = extraIdentifier or ""
    local oldValue = conditionOrEvent:get_field(field)
    conditionOrEvent:set_field(field, value)
    return self:addFunction(
        self.setField,
        { conditionOrEvent:get_type_definition():get_name(), field, value, extraIdentifier },
        function()
            self:setField(conditionOrEvent, field, oldValue)
        end
    )
end

function behaviorTreeToolKit.replaceCondition(self, NodeID, OriginalConditionID, ReplacedConditionID)
    local layer
    local tree
    local playercomp = (module.getMasterPlayerUtils()).playerGameObj
    local motion_fsm2 = playercomp:call("getComponent(System.Type)", sdk.typeof("via.motion.MotionFsm2"))
    local resetFunc = self:addFunction(
        self.replaceCondition,
        { NodeID, OriginalConditionID, ReplacedConditionID },
        function()
            self:replaceCondition(NodeID, ReplacedConditionID, OriginalConditionID)
        end,
        true
    )
    if playercomp ~= nil then
        if motion_fsm2 ~= nil then
            layer = motion_fsm2:call("getLayer", 0)
            if layer ~= nil then
                tree = layer:get_tree_object()
                if tree == nil then
                    return resetFunc
                end
                local node = tree:get_node_by_id(NodeID)
                if node == nil then
                    return resetFunc
                end
                local node_data = node:get_data()
                local transition_array = node_data:get_transition_conditions()
                for index = 0, transition_array:size() - 1 do
                    if tonumber(transition_array[index]) == ReplacedConditionID then
                        return resetFunc
                    end
                end
                for index = 0, transition_array:size() - 1 do
                    if transition_array[index] == OriginalConditionID then
                        transition_array[index] = tonumber(ReplacedConditionID)
                        resetFunc = self:addFunction(
                            self.replaceCondition,
                            { NodeID, OriginalConditionID, ReplacedConditionID },
                            function()
                                self:replaceCondition(NodeID, ReplacedConditionID, OriginalConditionID)
                            end
                        )
                    end
                end
            end
        end
    end
    return resetFunc
end

function behaviorTreeToolKit.replaceTransition(self, NodeID, ConditionID, ReplacedStateIndex)
    local layer
    local tree
    local playercomp = (module.getMasterPlayerUtils()).playerGameObj
    local motion_fsm2 = playercomp:call("getComponent(System.Type)", sdk.typeof("via.motion.MotionFsm2"))
    local resetFunc = self:addFunction(self.replaceTransition, { NodeID, ConditionID, ReplacedStateIndex }, function()
        self:replaceTransition(NodeID, ConditionID, ReplacedStateIndex)
    end, true)
    if playercomp ~= nil then
        if motion_fsm2 ~= nil then
            layer = motion_fsm2:call("getLayer", 0)
            if layer ~= nil then
                tree = layer:get_tree_object()
                if tree == nil then
                    return resetFunc
                end
                local node = tree:get_node_by_id(NodeID)
                if node == nil then
                    return resetFunc
                end
                local node_data = node:get_data()
                local transition_array = node_data:get_transition_conditions()
                local node_array = node_data:get_states()

                for index = 0, node_array:size() - 1 do
                    if tonumber(node_array[index]) == ReplacedStateIndex then
                        if transition_array[index] == ConditionID then
                            return resetFunc
                        end
                    end
                end

                for i = 0, transition_array:size() - 1 do
                    if transition_array[i] == ConditionID then
                        local originalTransition = node_array[i]
                        resetFunc = self:addFunction(
                            self.replaceTransition,
                            { NodeID, ConditionID, ReplacedStateIndex },
                            function()
                                self:replaceTransition(NodeID, ConditionID, originalTransition)
                            end
                        )
                        node_array[i] = tonumber(ReplacedStateIndex)
                        return resetFunc
                    end
                end
            end
        end
    end
end

---@return table|nil
---@param statesIndex table
function behaviorTreeToolKit.getAllConditions_SpecificState(self, statesIndex)
    local stateIndexSet = {}
    local tbl = {}
    for _, value in pairs(statesIndex) do
        stateIndexSet[value] = true
        tbl[value] = {}
    end
    local found = false
    local tree = behaviorTreeToolKit:getTreeComponentCore()
    local nodes = tree:get_nodes()
    local condition_array = tree:get_conditions()
    for i = 0, nodes:size() - 1 do
        local node_data = nodes[i]:get_data()
        local states = node_data:get_states()
        local conditions = node_data:get_transition_conditions()
        for j = 0, states:size() - 1 do
            if stateIndexSet[tonumber(states[j])] then
                local conditionIndex = tonumber(conditions[j])
                table.insert(tbl[tonumber(states[j])], condition_array[conditionIndex])
                found = true
            end
        end
    end
    if found then
        return tbl
    end
    return nil
end

return behaviorTreeToolKit
