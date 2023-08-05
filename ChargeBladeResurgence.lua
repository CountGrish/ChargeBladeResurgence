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
            readyStanceToCondensedSlashCharge = {
                status = true,
                description = "Charge Condensed Element/Spinning Slash after Ready Stance",
            },
            readyStanceAnimationCancels = {
                status = true,
                description = "Cancel attacks with Ready Stance",
            },
            readyStanceGuardHitSmallToCondensedSlash = {
                status = true,
                description = "Instant Condensed Element/Spinning Slash on successful Ready Stance",
            },
            readyStanceToDashSlam = {
                status = true,
                description = "Dash Slam after Ready Stance",
            },
            readyStanceGuardHitWireUp = {
                status = true,
                description = "Morphing Advance/Air Dash on successful Ready Stance",
            },
            guardHitSmallToCondensedSlash = {
                status = true,
                description = "Instant Condensed Element/Spinning Slash on successful block",
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
        if not CounterPeakBlockAfter then
            CounterPeakBlockAfter = {}
        end
        local blockAfterParryCondition = bhtToolkit:getConditionObj(7346)
        CounterPeakBlockAfter[1] = bhtToolkit:setField(blockAfterParryCondition, "StartFrame", 10)
    else
        if CounterPeakBlockAfter then
            for _, change in ipairs(CounterPeakBlockAfter) do
                change.reset()
            end
        end
    end

    if config.userOptions.counterPeakDodgeAfter.status then
        if not CounterPeakDodgeAfter then
            CounterPeakDodgeAfter = {}
        end
        local dodgeConditionID = 7494
        local dodgeCondition = bhtToolkit:getConditionObj(dodgeConditionID)
        CounterPeakDodgeAfter[1] = bhtToolkit:setField(dodgeCondition, "StartFrame", 10)
        CounterPeakDodgeAfter[2] =
            bhtToolkit:addConditionPairs(counterPeakIndex, dodgeConditionID, swordDodgeTransitionID, true)
    else
        if CounterPeakDodgeAfter then
            for _, change in ipairs(CounterPeakDodgeAfter) do
                change.reset()
            end
        end
    end

    local morphAdvanceTransitionID = 4295
    local morphAdvanceConditionID = 6971
    local morphAdvanceEventID = 4041

    local airDashTransitionID = 4640
    local airDashConditionID = 6972
    local airDashEventID = 4042
    if config.userOptions.counterPeakWireUp.status then
        if not CounterPeakWireUp then
            CounterPeakWireUp = {}
        end
        CounterPeakWireUp[1] =
            bhtToolkit:addConditionPairs(counterPeakIndex, morphAdvanceConditionID, morphAdvanceTransitionID, true)
        CounterPeakWireUp[2] =
            bhtToolkit:addConditionPairs(counterPeakIndex, airDashConditionID, airDashTransitionID, true)
        CounterPeakWireUp[3] =
            bhtToolkit:addTransitionEvent(counterPeakIndex, morphAdvanceConditionID, morphAdvanceEventID)
        CounterPeakWireUp[4] = bhtToolkit:addTransitionEvent(counterPeakIndex, airDashConditionID, airDashEventID)
    else
        if CounterPeakWireUp then
            for _, change in ipairs(CounterPeakWireUp) do
                change.reset()
            end
        end
    end

    local hopSaedIndex = 2766799031
    local saedIndex = 464731314
    local aedIndex = 562795953
    local haedIndex = 3652067243
    if config.userOptions.saedFasterDodge.status then
        if not SaedFasterDodge then
            SaedFasterDodge = {}
        end
        local axeDodgeConditionID = 7401
        local axeDodgeTransitionID = 3993
        local swordDodgeConditionID = 7261
        -- saedSwordDodge
        local swordDodgeCondition = bhtToolkit:getConditionObj(swordDodgeConditionID)
        SaedFasterDodge[1] = bhtToolkit:setField(swordDodgeCondition, "StartFrame", 50)
        -- saedAxeInstaDodge
        local axeDodgeCondition = bhtToolkit:getConditionObj(axeDodgeConditionID)
        SaedFasterDodge[2] = bhtToolkit:setField(axeDodgeCondition, "StartFrame", 0)
        SaedFasterDodge[3] = bhtToolkit:addConditionPairs(saedIndex, axeDodgeConditionID, axeDodgeTransitionID, true)
        -- hopSAED
        SaedFasterDodge[5] = bhtToolkit:replaceCondition(hopSaedIndex, axeDodgeConditionID, swordDodgeConditionID)
        --|Must be in reversed order
        SaedFasterDodge[4] = bhtToolkit:addConditionPairs(hopSaedIndex, axeDodgeConditionID, axeDodgeTransitionID, true)
        -- AED
        SaedFasterDodge[6] = bhtToolkit:addConditionPairs(aedIndex, swordDodgeConditionID, swordDodgeTransitionID, true)
        SaedFasterDodge[7] = bhtToolkit:addConditionPairs(aedIndex, axeDodgeConditionID, axeDodgeTransitionID, true)
        -- hopAED
        local haedDodgeConditionID = 7387
        SaedFasterDodge[9] = bhtToolkit:replaceCondition(haedIndex, haedDodgeConditionID, swordDodgeConditionID)
        --Must be in reversed order
        SaedFasterDodge[8] = bhtToolkit:addConditionPairs(haedIndex, axeDodgeConditionID, axeDodgeTransitionID, true)
    else
        if SaedFasterDodge then
            for _, change in ipairs(SaedFasterDodge) do
                change.reset()
            end
        end
    end

    if config.userOptions.saedFasterBlock.status then
        if not SaedFasterBlock then
            SaedFasterBlock = {}
        end
        local morphConditionID = 6458
        local morphTransitionID = 4017
        SaedFasterBlock[1] = bhtToolkit:addConditionPairs(saedIndex, morphConditionID, morphTransitionID, true)
        SaedFasterBlock[2] = bhtToolkit:addConditionPairs(hopSaedIndex, morphConditionID, morphTransitionID, true)
        SaedFasterBlock[3] = bhtToolkit:addConditionPairs(aedIndex, morphConditionID, morphTransitionID, true)
        SaedFasterBlock[4] = bhtToolkit:addConditionPairs(haedIndex, morphConditionID, morphTransitionID, true)
    else
        if SaedFasterBlock then
            for _, change in ipairs(SaedFasterBlock) do
                change.reset()
            end
        end
    end

    if config.userOptions.saedUnlockAngle.status then
        if not SaedUnlockAngle then
            SaedUnlockAngle = {}
        end
        local saedStartEventID = 4376
        local saedStartEvent = bhtToolkit:getEventObject(saedStartEventID)
        SaedUnlockAngle[1] = bhtToolkit:setField(saedStartEvent, "_LimitAngle", 0)
        SaedUnlockAngle[2] = bhtToolkit:setField(saedStartEvent, "_AngleSetType", 1)
        SaedUnlockAngle[3] = bhtToolkit:addTransitionEvent(4286945847, 7237, saedStartEventID) --4527
    else
        if SaedUnlockAngle then
            for _, change in ipairs(SaedUnlockAngle) do
                change.reset()
            end
        end
    end

    if config.userOptions.readyStanceAnimationCancels.status then
        if not ReadyStanceAnimationCancels then
            ReadyStanceAnimationCancels = {}
        end

        if readyStanceConditions == nil then
            readyStanceConditions = bhtToolkit:getAllConditions_SpecificState({ 4043, 4616 })
        end
        if readyStanceConditions ~= nil then
            local index = 1
            for _, conditionsInStates in pairs(readyStanceConditions) do
                for _, condition in pairs(conditionsInStates) do
                    ReadyStanceAnimationCancels[index] = bhtToolkit:setField(condition, "StartFrame", 0, index)
                    index = index + 1
                end
            end
        end
    else
        if ReadyStanceAnimationCancels then
            for _, change in ipairs(ReadyStanceAnimationCancels) do
                change.reset()
            end
        end
    end

    local readyStanceGuardHitSmallIndex1 = 4213486657
    local readyStanceGuardHitSmallIndex2 = 1277383964
    if config.userOptions.readyStanceToSAED.status then
        if not ReadyStanceToSAED then
            ReadyStanceToSAED = {}
        end
        local saedFromGuardHitTransitionID = 4044 --//2522966112 | 4235
        local saedFromGuardHitConditionID = 504 --//2522966112 | 4235
        local oFromGuardHitConditionID = 7504 --// 4621
        local tFromGuardHitConditionID = 7506 --// 4621
        local oFromGuardHitCondition2ID = 7497 --// 4622
        local tFromGuardHitCondition2ID = 7499 --// 4622
        local oFromGuardHitCondition = bhtToolkit:getConditionObj(oFromGuardHitConditionID)
        local tFromGuardHitCondition = bhtToolkit:getConditionObj(tFromGuardHitConditionID)
        local oFromGuardHitCondition2 = bhtToolkit:getConditionObj(oFromGuardHitCondition2ID)
        local tFromGuardHitCondition2 = bhtToolkit:getConditionObj(tFromGuardHitCondition2ID)
        local saedFromGuardHitCondition = bhtToolkit:getConditionObj(saedFromGuardHitConditionID)
        ReadyStanceToSAED[1] =
            bhtToolkit:setField(oFromGuardHitCondition, "CmdType", bhtToolkit.CommandFsm.AtkAwithoutX)
        ReadyStanceToSAED[2] =
            bhtToolkit:setField(tFromGuardHitCondition, "CmdType", bhtToolkit.CommandFsm.AtkXwithoutA)
        ReadyStanceToSAED[3] =
            bhtToolkit:setField(oFromGuardHitCondition2, "CmdType", bhtToolkit.CommandFsm.AtkAwithoutX)
        ReadyStanceToSAED[4] =
            bhtToolkit:setField(tFromGuardHitCondition2, "CmdType", bhtToolkit.CommandFsm.AtkXwithoutA)
        ReadyStanceToSAED[5] = bhtToolkit:setField(saedFromGuardHitCondition, "StartFrame", 0)

        ReadyStanceToSAED[6] = bhtToolkit:addConditionPairs(
            readyStanceGuardHitSmallIndex1,
            saedFromGuardHitConditionID,
            saedFromGuardHitTransitionID,
            true
        )
        ReadyStanceToSAED[7] = bhtToolkit:addConditionPairs(
            readyStanceGuardHitSmallIndex2,
            saedFromGuardHitConditionID,
            saedFromGuardHitTransitionID,
            true
        )
    else
        if ReadyStanceToSAED then
            for _, change in ipairs(ReadyStanceToSAED) do
                change.reset()
            end
        end
    end

    local readyStanceIndex1 = 726343640
    local readyStanceIndex2 = 3934364626
    if config.userOptions.readyStanceToCondensedSlashCharge.status then
        if not ReadyStanceToCondensedSlashCharge then
            ReadyStanceToCondensedSlashCharge = {}
        end
        -- local charginCondensedSpinningSlashTransitionID = 4301 -- Charging Chainsaw;Unused
        local charginCondensedSpinningSlashTransitionID = 4155 -- Charging Chainsaw/Slash
        ReadyStanceToCondensedSlashCharge[1] =
            bhtToolkit:replaceTransition(726343640, 7490, charginCondensedSpinningSlashTransitionID)
        ReadyStanceToCondensedSlashCharge[2] =
            bhtToolkit:replaceTransition(3934364626, 7518, charginCondensedSpinningSlashTransitionID)
    else
        if ReadyStanceToCondensedSlashCharge then
            for _, change in ipairs(ReadyStanceToCondensedSlashCharge) do
                change.reset()
            end
        end
    end

    if config.userOptions.readyStanceToDashSlam.status then
        if not ReadyStanceToDashSlam then
            ReadyStanceToDashSlam = {}
        end
        local dashSlamTransitionID = 4384
        ReadyStanceToDashSlam[1] = bhtToolkit:replaceTransition(readyStanceIndex1, 7489, dashSlamTransitionID)
        ReadyStanceToDashSlam[2] = bhtToolkit:replaceTransition(readyStanceIndex2, 7517, dashSlamTransitionID)
        ReadyStanceToDashSlam[3] =
            bhtToolkit:replaceTransition(readyStanceGuardHitSmallIndex1, 7498, dashSlamTransitionID)
        ReadyStanceToDashSlam[4] =
            bhtToolkit:replaceTransition(readyStanceGuardHitSmallIndex2, 7505, dashSlamTransitionID)
    else
        if ReadyStanceToDashSlam then
            for _, change in ipairs(ReadyStanceToDashSlam) do
                change.reset()
            end
        end
    end

    -- local condensedSpinningSlashTransitionID = 4411 -- Instant Chainsaw; Unused
    local condensedSpinningSlashTransitionID = 4319 -- Instant Chainsaw/Slash
    local condensedSpinningSlashEventID = 4315 -- Instant Chainsaw/Slash
    if config.userOptions.readyStanceGuardHitSmallToCondensedSlash.status then
        if not ReadyStanceGuardHitSmallToCondensedSlash then
            ReadyStanceGuardHitSmallToCondensedSlash = {}
        end
        ReadyStanceGuardHitSmallToCondensedSlash[1] =
            bhtToolkit:addTransitionEvent(readyStanceGuardHitSmallIndex2, 7506, condensedSpinningSlashEventID)
        ReadyStanceGuardHitSmallToCondensedSlash[2] =
            bhtToolkit:replaceTransition(readyStanceGuardHitSmallIndex2, 7506, condensedSpinningSlashTransitionID)

        ReadyStanceGuardHitSmallToCondensedSlash[3] =
            bhtToolkit:addTransitionEvent(readyStanceGuardHitSmallIndex1, 7499, condensedSpinningSlashEventID)
        ReadyStanceGuardHitSmallToCondensedSlash[4] =
            bhtToolkit:replaceTransition(readyStanceGuardHitSmallIndex1, 7499, condensedSpinningSlashTransitionID)
    else
        if ReadyStanceGuardHitSmallToCondensedSlash then
            for _, change in ipairs(ReadyStanceGuardHitSmallToCondensedSlash) do
                change.reset()
            end
        end
    end

    if config.userOptions.readyStanceGuardHitWireUp.status then
        if not ReadyStanceGuardHitWireUp then
            ReadyStanceGuardHitWireUp = {}
        end
        local index = 0
        for _, readyStanceSmallHitIndex in pairs({ readyStanceGuardHitSmallIndex1, readyStanceGuardHitSmallIndex2 }) do
            ReadyStanceGuardHitWireUp[1 + index] = bhtToolkit:addConditionPairs(
                readyStanceSmallHitIndex,
                morphAdvanceConditionID,
                morphAdvanceTransitionID,
                true
            )
            ReadyStanceGuardHitWireUp[2 + index] =
                bhtToolkit:addConditionPairs(readyStanceSmallHitIndex, airDashConditionID, airDashTransitionID, true)
            ReadyStanceGuardHitWireUp[3 + index] =
                bhtToolkit:addTransitionEvent(readyStanceSmallHitIndex, morphAdvanceConditionID, morphAdvanceEventID)
            ReadyStanceGuardHitWireUp[4 + index] =
                bhtToolkit:addTransitionEvent(readyStanceSmallHitIndex, airDashConditionID, airDashEventID)
            index = 4
        end
    else
        if ReadyStanceGuardHitWireUp then
            for _, change in ipairs(ReadyStanceGuardHitWireUp) do
                change.reset()
            end
        end
    end

    if config.userOptions.guardHitSmallToCondensedSlash.status then
        if not GuardHitSmallToCondensedSlash then
            GuardHitSmallToCondensedSlash = {}
        end
        local guardHitSmallIndex = 1412529222
        GuardHitSmallToCondensedSlash[1] =
            bhtToolkit:replaceTransition(guardHitSmallIndex, 495, condensedSpinningSlashTransitionID)
        GuardHitSmallToCondensedSlash[2] =
            bhtToolkit:addTransitionEvent(guardHitSmallIndex, 495, condensedSpinningSlashEventID)
    else
        if GuardHitSmallToCondensedSlash then
            for _, change in ipairs(GuardHitSmallToCondensedSlash) do
                change.reset()
            end
        end
    end

    if config.userOptions.airDashToSAED.status then
        if not AirDashToSAED then
            AirDashToSAED = {}
        end
        local airDashIndex = 1120569797
        local airDashEarlyIndex = 612282475

        local airSaedID = 4019
        local airSaedConditionID = 7350
        local airSaedEventID = 4323

        local airAedID = 4018
        local airAedConditionID = 7351
        local airAedEventID = 4324
        local index = 0
        for _, adIndex in pairs({ airDashIndex, airDashEarlyIndex }) do
            AirDashToSAED[1 + index] = bhtToolkit:addConditionPairs(adIndex, airSaedConditionID, airSaedID, true)
            AirDashToSAED[2 + index] = bhtToolkit:addConditionPairs(adIndex, airAedConditionID, airAedID, true)
            AirDashToSAED[3 + index] = bhtToolkit:addTransitionEvent(adIndex, airSaedConditionID, airSaedEventID)
            AirDashToSAED[4 + index] = bhtToolkit:addTransitionEvent(adIndex, airAedConditionID, airAedEventID)
            index = index + 4
        end

        local oFromAirDashConditionID = 7548
        local oFromAirDashLateConditionID = 7534
        local tFromAirDashConditionID = 7550
        local oFromAirDashCondition = bhtToolkit:getConditionObj(oFromAirDashConditionID)
        local oFromAirDashLateCondition = bhtToolkit:getConditionObj(oFromAirDashLateConditionID)
        local tFromAirDashCondition = bhtToolkit:getConditionObj(tFromAirDashConditionID)
        bhtToolkit:setField(oFromAirDashCondition, "CmdType", bhtToolkit.CommandFsm.AtkAwithoutX, 1)
        bhtToolkit:setField(oFromAirDashLateCondition, "CmdType", bhtToolkit.CommandFsm.AtkAwithoutX, 2)
        bhtToolkit:setField(tFromAirDashCondition, "CmdType", bhtToolkit.CommandFsm.AtkXwithoutA, 3)
    else
        if AirDashToSAED then
            for _, change in ipairs(AirDashToSAED) do
                change.reset()
            end
        end
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
        isUpdated[9], uo.guardHitSmallToCondensedSlash.status = createCheckbox(uo.guardHitSmallToCondensedSlash)
        imgui.text("---Ready Stance---")
        isUpdated[10], uo.readyStanceToSAED.status = createCheckbox(uo.readyStanceToSAED)
        isUpdated[11], uo.readyStanceToCondensedSlashCharge.status = createCheckbox(uo.readyStanceToCondensedSlashCharge)
        isUpdated[12], uo.readyStanceGuardHitSmallToCondensedSlash.status =
            createCheckbox(uo.readyStanceGuardHitSmallToCondensedSlash)
        isUpdated[13], uo.readyStanceToDashSlam.status = createCheckbox(uo.readyStanceToDashSlam)
        isUpdated[14], uo.readyStanceAnimationCancels.status = createCheckbox(uo.readyStanceAnimationCancels)
        isUpdated[15], uo.readyStanceGuardHitWireUp.status = createCheckbox(uo.readyStanceGuardHitWireUp)
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
