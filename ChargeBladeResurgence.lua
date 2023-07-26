local bhtToolkit = require("./ChargeBladeResurgenceDependencies/toolkit")
local configFile = "ChargeBladeResurgence.json"
local allowMovesetModify = false
local playerManager
local readyStanceConditions

---@return table
local function loadConfig()
    local loadedConfig = json.load_file(configFile) or nil
    local defaultValues = {
        localOptions = {
            enabled = true,
        },
        userOptions = {
            counterPeakBlockAfter = {
                status = true,
                description = "Block on successful Counter Peak",
            },
            counterPeakDodgeAfter = {
                status = true,
                description = "Dodge on successful Counter Peak",
            },
            counterPeakWireUp = {
                status = true,
                description = "Morphing Advance/Air Dash on successful Counter Peak",
            },
            saedFasterDodge = {
                status = true,
                description = "Dodge after AED/UED",
            },
            saedFasterBlock = {
                status = true,
                description = "Morph slash after AED/UED",
            },
            saedUnlockAngle = {
                status = true,
                description = "Unlock AED/UED turn angle",
            },
            readyStanceToSAED = {
                status = true,
                description = "AED/UED on successful Ready Stance",
            },
            readyStanceToSavageAxeCharge = {
                status = true,
                description = "Charge Savage Axe after Ready Stance",
            },
            readyStanceAnimationCancels = {
                status = true,
                description = "Cancel attacks with Ready Stance",
            },
            readyStanceGuardHitSmallToSavageAxe = {
                status = true,
                description = "Instant Savage Axe on successful Ready Stance",
            },
            readyStanceGuardHitWireUp = {
                status = true,
                description = "Morphing Advance/Air Dash on successful Ready Stance",
            },
            guardHitSmallToSavageAxe = {
                status = true,
                description = "Instant Savage axe on successful block",
            },
            airDashToSAED = {
                status = true,
                description = "Air Dash into AED/UED",
            },
        },
    }

    if loadedConfig == nil then
        return defaultValues
    end

    for key, defaultOption in pairs(defaultValues.localOptions) do
        if loadedConfig.localOptions[key] == nil then
            loadedConfig.localOptions[key] = defaultOption
        end
    end

    for key, defaultOption in pairs(defaultValues.userOptions) do
        if loadedConfig.userOptions[key] == nil then
            loadedConfig.userOptions[key] = defaultOption
        end
    end

    return loadedConfig
end

local config = loadConfig()

re.on_config_save(function()
    json.dump_file(configFile, config)
end)

local function modifyMoveset()
    if config.localOptions.enabled == false then
        return
    end

    local swordDodgeTransitionID = 246
    local counterPeakIndex = 2912959963
    if config.userOptions.counterPeakBlockAfter.status then
        local blockAfterParryCondition = bhtToolkit:getConditionObj(7346)
        blockAfterParryCondition:set_field("StartFrame", 10)
    end

    if config.userOptions.counterPeakDodgeAfter.status then
        local dodgeCondition = 7494
        bhtToolkit:getConditionObj(dodgeCondition):set_field("StartFrame", 10)
        bhtToolkit:addConditionPairs(counterPeakIndex, dodgeCondition, swordDodgeTransitionID, true)
    end

    local morphAdvanceTransitionID = 4295
    local morphAdvanceConditionID = 6971
    local morphAdvanceEventID = 4041

    local airDashTransitionID = 4640
    local airDashConditionID = 6972
    local airDashEventID = 4042
    if config.userOptions.counterPeakWireUp.status then
        bhtToolkit:addConditionPairs(counterPeakIndex, morphAdvanceConditionID, morphAdvanceTransitionID, true)
        bhtToolkit:addConditionPairs(counterPeakIndex, airDashConditionID, airDashTransitionID, true)
        bhtToolkit:addTransitionEvent(counterPeakIndex, morphAdvanceConditionID, morphAdvanceEventID)
        bhtToolkit:addTransitionEvent(counterPeakIndex, airDashConditionID, airDashEventID)
    end

    local hopSaedIndex = 2766799031
    local saedIndex = 464731314
    local aedIndex = 562795953
    local haedIndex = 3652067243
    if config.userOptions.saedFasterDodge.status then
        local axeDodgeConditionID = 7401
        local axeDodgeTransitionID = 3993
        local swordDodgeConditionID = 7261
        -- saedSwordDodge
        local swordDodgeCondition = bhtToolkit:getConditionObj(swordDodgeConditionID)
        swordDodgeCondition:set_field("StartFrame", 50)
        -- saedAxeInstaDodge
        local axeDodgeCondition = bhtToolkit:getConditionObj(axeDodgeConditionID)
        axeDodgeCondition:set_field("StartFrame", 0)
        bhtToolkit:addConditionPairs(saedIndex, axeDodgeConditionID, axeDodgeTransitionID, true)
        -- hopSAED
        bhtToolkit:replaceCondition(hopSaedIndex, axeDodgeConditionID, swordDodgeConditionID)
        bhtToolkit:addConditionPairs(hopSaedIndex, axeDodgeConditionID, axeDodgeTransitionID, true)
        -- AED
        bhtToolkit:addConditionPairs(aedIndex, swordDodgeConditionID, swordDodgeTransitionID, true)
        bhtToolkit:addConditionPairs(aedIndex, axeDodgeConditionID, axeDodgeTransitionID, true)
        -- hopAED
        local haedDodgeConditionID = 7387
        bhtToolkit:replaceCondition(haedIndex, haedDodgeConditionID, swordDodgeConditionID)
        bhtToolkit:addConditionPairs(haedIndex, axeDodgeConditionID, axeDodgeTransitionID, true)
    end

    if config.userOptions.saedFasterBlock.status then
        local morphConditionID = 6458
        local morphTransitionID = 4017
        bhtToolkit:addConditionPairs(saedIndex, morphConditionID, morphTransitionID, true)
        bhtToolkit:addConditionPairs(hopSaedIndex, morphConditionID, morphTransitionID, true)
        bhtToolkit:addConditionPairs(aedIndex, morphConditionID, morphTransitionID, true)
        bhtToolkit:addConditionPairs(haedIndex, morphConditionID, morphTransitionID, true)
    end

    if config.userOptions.saedUnlockAngle.status then
        local saedStartEventID = 4376
        local saedStartEvent = bhtToolkit:getEventObject(saedStartEventID)
        saedStartEvent:set_field("_LimitAngle", 0)
        saedStartEvent:set_field("_AngleSetType", 1)
        bhtToolkit:addTransitionEvent(4286945847, 7237, saedStartEventID) --4527
    end

    if config.userOptions.readyStanceAnimationCancels then
        if readyStanceConditions == nil then
            readyStanceConditions = bhtToolkit:getAllConditions_SpecificState({ 4043, 4616 })
        end
        if readyStanceConditions ~= nil then
            for _, conditionsInStates in pairs(readyStanceConditions) do
                for _, condition in pairs(conditionsInStates) do
                    condition:set_field("StartFrame", 0)
                end
            end
        end
    end

    local readyStanceGuardHitSmallIndex1 = 4213486657
    local readyStanceGuardHitSmallIndex2 = 1277383964
    if config.userOptions.readyStanceToSAED.status then
        local saedFromGuardHit = 4044 --//2522966112 | 4235
        local saedFromGuardHitCondition = 504 --//2522966112 | 4235
        local oFromGuardHitCondition = 7504 --// 4621
        local tFromGuardHitCondition = 7506 --// 4621
        local oFromGuardHitCondition2 = 7497 --// 4622
        local tFromGuardHitCondition2 = 7499 --// 4622
        bhtToolkit:getConditionObj(oFromGuardHitCondition):set_field("CmdType", bhtToolkit.CommandFsm.AtkAwithoutX)
        bhtToolkit:getConditionObj(tFromGuardHitCondition):set_field("CmdType", bhtToolkit.CommandFsm.AtkXwithoutA)
        bhtToolkit:getConditionObj(oFromGuardHitCondition2):set_field("CmdType", bhtToolkit.CommandFsm.AtkAwithoutX)
        bhtToolkit:getConditionObj(tFromGuardHitCondition2):set_field("CmdType", bhtToolkit.CommandFsm.AtkXwithoutA)
        bhtToolkit:getConditionObj(saedFromGuardHitCondition):set_field("StartFrame", 0)

        bhtToolkit:addConditionPairs(readyStanceGuardHitSmallIndex1, saedFromGuardHitCondition, saedFromGuardHit, true)
        bhtToolkit:addConditionPairs(readyStanceGuardHitSmallIndex2, saedFromGuardHitCondition, saedFromGuardHit, true)
    end

    if config.userOptions.readyStanceToSavageAxeCharge.status then
        bhtToolkit:replaceTransition(726343640, 7490, 4301)
        bhtToolkit:replaceTransition(3934364626, 7518, 4301)
    end

    local condensedSpinningSlashTransitionID = 4411
    if config.userOptions.readyStanceGuardHitSmallToSavageAxe.status then
        bhtToolkit:replaceTransition(readyStanceGuardHitSmallIndex2, 7506, condensedSpinningSlashTransitionID)
        bhtToolkit:replaceTransition(readyStanceGuardHitSmallIndex1, 7499, condensedSpinningSlashTransitionID)
    end

    if config.userOptions.readyStanceGuardHitWireUp.status then
        for _, readyStanceIndex in pairs({ readyStanceGuardHitSmallIndex1, readyStanceGuardHitSmallIndex2 }) do
            bhtToolkit:addConditionPairs(readyStanceIndex, morphAdvanceConditionID, morphAdvanceTransitionID, true)
            bhtToolkit:addConditionPairs(readyStanceIndex, airDashConditionID, airDashTransitionID, true)

            bhtToolkit:addTransitionEvent(readyStanceIndex, morphAdvanceConditionID, morphAdvanceEventID)
            bhtToolkit:addTransitionEvent(readyStanceIndex, airDashConditionID, airDashEventID)
        end
    end

    if config.userOptions.guardHitSmallToSavageAxe.status then
        local guardHitSmallIndex = 1412529222
        bhtToolkit:replaceTransition(guardHitSmallIndex, 495, condensedSpinningSlashTransitionID)
    end

    if config.userOptions.airDashToSAED.status then
        local airDashIndex = 1120569797
        local airDashEarlyIndex = 612282475

        local airSaedID = 4019
        local airSaedConditionID = 7350
        local airSaedEventID = 4323

        local airAedID = 4018
        local airAedConditionID = 7351
        local airAedEventID = 4324
        for _, adIndex in pairs({ airDashIndex, airDashEarlyIndex }) do
            bhtToolkit:addConditionPairs(adIndex, airSaedConditionID, airSaedID, true)
            bhtToolkit:addConditionPairs(adIndex, airAedConditionID, airAedID, true)
            bhtToolkit:addTransitionEvent(adIndex, airSaedConditionID, airSaedEventID)
            bhtToolkit:addTransitionEvent(adIndex, airAedConditionID, airAedEventID)
        end

        local oFromAirDashConditionID = 7548
        local oFromAirDashLateConditionID = 7534
        local tFromAirDashConditionID = 7550
        bhtToolkit:getConditionObj(oFromAirDashConditionID):set_field("CmdType", bhtToolkit.CommandFsm.AtkAwithoutX)
        bhtToolkit:getConditionObj(oFromAirDashLateConditionID):set_field("CmdType", bhtToolkit.CommandFsm.AtkAwithoutX)
        bhtToolkit:getConditionObj(tFromAirDashConditionID):set_field("CmdType", bhtToolkit.CommandFsm.AtkXwithoutA)
    end
end

---@param option table
---@return boolean, boolean
local function createCheckbox(option)
    return imgui.checkbox(option.description, option.status)
end

local function createUI()
    local isUpdated = {}
    if imgui.tree_node("Charge Blade: Resurgence") then
        local uo = config.userOptions
        isUpdated[1], config.localOptions.enabled = imgui.checkbox("Enabled", config.localOptions.enabled)
        imgui.text("---AED/UED---")
        isUpdated[2], uo.saedUnlockAngle.status = createCheckbox(uo.saedUnlockAngle)
        isUpdated[3], uo.saedFasterDodge.status = createCheckbox(uo.saedFasterDodge)
        isUpdated[4], uo.saedFasterBlock.status = createCheckbox(uo.saedFasterBlock)
        imgui.text("---Air Dash---")
        isUpdated[5], uo.airDashToSAED.status = createCheckbox(uo.airDashToSAED)
        imgui.text("---Counter Peak Block---")
        isUpdated[6], uo.counterPeakBlockAfter.status = createCheckbox(uo.counterPeakBlockAfter)
        isUpdated[7], uo.counterPeakDodgeAfter.status = createCheckbox(uo.counterPeakDodgeAfter)
        isUpdated[8], uo.counterPeakWireUp.status = createCheckbox(uo.counterPeakWireUp)
        imgui.text("---Guard Hit---")
        isUpdated[9], uo.guardHitSmallToSavageAxe.status = createCheckbox(uo.guardHitSmallToSavageAxe)
        imgui.text("---Ready Stance---")
        isUpdated[10], uo.readyStanceToSAED.status = createCheckbox(uo.readyStanceToSAED)
        isUpdated[11], uo.readyStanceToSavageAxeCharge.status = createCheckbox(uo.readyStanceToSavageAxeCharge)
        isUpdated[12], uo.readyStanceGuardHitSmallToSavageAxe.status = createCheckbox(uo.readyStanceGuardHitSmallToSavageAxe)
        isUpdated[13], uo.readyStanceAnimationCancels.status = createCheckbox(uo.readyStanceAnimationCancels)
        isUpdated[14], uo.readyStanceGuardHitWireUp.status = createCheckbox(uo.readyStanceGuardHitWireUp)
        imgui.tree_pop()
    end
    for _, value in ipairs(isUpdated) do
        if value then
            return true
        end
    end
    return false
end

re.on_draw_ui(function()
    local isUpdated = createUI()
    if isUpdated then
        json.dump_file(configFile, config)
        allowMovesetModify = true
    end
end)

--Reload on training area load
sdk.hook(
    sdk.find_type_definition("snow.data.EquipDataManager"):get_method("addLvBuffCountOnTrainingArea"),
    nil,
    function()
        allowMovesetModify = true
    end
)

--Reload on quest start
sdk.hook(sdk.find_type_definition("snow.stage.StageManager"):get_method("onQuestStart"), nil, function()
    allowMovesetModify = true
end)

--Reload on tent exit
sdk.hook(sdk.find_type_definition("snow.stage.StageManager"):get_method("setTentFlag"), nil, function()
    allowMovesetModify = true
end)

re.on_frame(function()
    if not allowMovesetModify then
        return
    end
    if not config.localOptions.enabled then
        allowMovesetModify = false
        return
    end
    if not playerManager then
        playerManager = bhtToolkit:getMasterPlayerUtils()
    end
    if playerManager.playerWeaponType ~= bhtToolkit.playerWeaponTypeIndex.ChargeAxe then
        allowMovesetModify = false
        return
    end
    --If user option changed not in field
    if not bhtToolkit:checkInMainField() then
        allowMovesetModify = false
        return
    end
    modifyMoveset()
    allowMovesetModify = false
end)