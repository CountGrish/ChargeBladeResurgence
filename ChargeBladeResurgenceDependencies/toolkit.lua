local behaviorTreeToolKit = require("./ChargeBladeResurgenceDependencies/behaviorTreeToolKit/toolkits")

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
