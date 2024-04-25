local bhtToolkit = require("./ChargeBladeResurgenceDependencies/toolkit")
local configFile = "ChargeBladeResurgence.json"
local allowMovesetModify = false
local playerManager
local readyStanceConditions
local isChainsawToggled = false

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
            keepChainsawBuff = {
                status = true,
                description = "Maintain Savage Axe buff through morphing (Requires shield buff)",
            },
            guardCounterBuff = {
                status = true,
                description = "Extend shield buff on guard point/Ready Stance block (Requires shield buff)",
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
    local isEnabled = config.localOptions.enabled
    local swordDodgeTransitionID = 246
    local counterPeakIndex = 2912959963

    if config.userOptions.counterPeakBlockAfter.status and isEnabled then
        if not CounterPeakBlockAfter then
            CounterPeakBlockAfter = {}
        end
        local blockAfterParryCondition = bhtToolkit:getConditionObj(7346)
        CounterPeakBlockAfter[1] =
            bhtToolkit:setField(blockAfterParryCondition, "StartFrame", 10, "counterPeakBlockAfter")
    else
        if CounterPeakBlockAfter then
            for _, change in ipairs(CounterPeakBlockAfter) do
                change.reset()
            end
        end
    end

    if config.userOptions.counterPeakDodgeAfter.status and isEnabled then
        if not CounterPeakDodgeAfter then
            CounterPeakDodgeAfter = {}
        end
        local dodgeConditionID = 7494
        local dodgeCondition = bhtToolkit:getConditionObj(dodgeConditionID)
        CounterPeakDodgeAfter[1] = bhtToolkit:setField(dodgeCondition, "StartFrame", 10, "counterPeakDodgeAfter")
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
    if config.userOptions.counterPeakWireUp.status and isEnabled then
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
    if config.userOptions.saedFasterDodge.status and isEnabled then
        if not SaedFasterDodge then
            SaedFasterDodge = {}
        end
        local axeDodgeConditionID = 7401
        local axeDodgeTransitionID = 3993
        local swordDodgeConditionID = 7261
        -- saedSwordDodge
        local swordDodgeCondition = bhtToolkit:getConditionObj(swordDodgeConditionID)
        SaedFasterDodge[1] = bhtToolkit:setField(swordDodgeCondition, "StartFrame", 50, "saedFasterDodge1")
        -- saedAxeInstaDodge
        local axeDodgeCondition = bhtToolkit:getConditionObj(axeDodgeConditionID)
        SaedFasterDodge[2] = bhtToolkit:setField(axeDodgeCondition, "StartFrame", 0, "saedFasterDodge2")
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

    if config.userOptions.saedFasterBlock.status and isEnabled then
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

    if config.userOptions.saedUnlockAngle.status and isEnabled then
        if not SaedUnlockAngle then
            SaedUnlockAngle = {}
        end
        local saedStartEventID = 4376
        local saedStartEvent = bhtToolkit:getEventObject(saedStartEventID)
        SaedUnlockAngle[1] = bhtToolkit:setField(saedStartEvent, "_LimitAngle", 0, "saedUnlockAngle1")
        SaedUnlockAngle[2] = bhtToolkit:setField(saedStartEvent, "_AngleSetType", 1, "saedUnlockAngle2")
        SaedUnlockAngle[3] = bhtToolkit:addTransitionEvent(4286945847, 7237, saedStartEventID) --4527
        local SaedCancelCondition = bhtToolkit:getConditionObj(7269) --4276
        SaedUnlockAngle[4] =
            bhtToolkit:setField(SaedCancelCondition, "CmdType", bhtToolkit.CommandFsm.AtkX, "saedCancel")
        local SaedCancelConditionNoPhials = bhtToolkit:getConditionObj(7272) --4277
        SaedUnlockAngle[5] = bhtToolkit:setField(
            SaedCancelConditionNoPhials,
            "CmdType",
            bhtToolkit.CommandFsm.AtkX,
            "saedCancelNoPhials"
        )
        --medium block saed cancel
        local SaedCancelConditionBlock = bhtToolkit:getConditionObj(7275) --4279
        SaedUnlockAngle[6] =
            bhtToolkit:setField(SaedCancelConditionBlock, "CmdType", bhtToolkit.CommandFsm.AtkX, "saedCancelBlockM")
        local SaedCancelConditionBlockNoPhials = bhtToolkit:getConditionObj(7279) --4281
        SaedUnlockAngle[7] = bhtToolkit:setField(
            SaedCancelConditionBlockNoPhials,
            "CmdType",
            bhtToolkit.CommandFsm.AtkX,
            "saedCancelBlockMNoPhials"
        )
    else
        if SaedUnlockAngle then
            for _, change in ipairs(SaedUnlockAngle) do
                change.reset()
            end
        end
    end

    if config.userOptions.readyStanceAnimationCancels.status and isEnabled then
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
                    ReadyStanceAnimationCancels[index] =
                        bhtToolkit:setField(condition, "StartFrame", 0, "readyStanceAnimationCancels")
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

    if config.userOptions.readyStanceToSAED.status and isEnabled then
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
        ReadyStanceToSAED[1] = bhtToolkit:setField(
            oFromGuardHitCondition,
            "CmdType",
            bhtToolkit.CommandFsm.AtkAwithoutX,
            "readyStanceToSAED1"
        )
        ReadyStanceToSAED[2] = bhtToolkit:setField(
            tFromGuardHitCondition,
            "CmdType",
            bhtToolkit.CommandFsm.AtkXwithoutA,
            "readyStanceToSAED2"
        )
        ReadyStanceToSAED[3] = bhtToolkit:setField(
            oFromGuardHitCondition2,
            "CmdType",
            bhtToolkit.CommandFsm.AtkAwithoutX,
            "readyStanceToSAED3"
        )
        ReadyStanceToSAED[4] = bhtToolkit:setField(
            tFromGuardHitCondition2,
            "CmdType",
            bhtToolkit.CommandFsm.AtkXwithoutA,
            "readyStanceToSAED4"
        )
        ReadyStanceToSAED[5] = bhtToolkit:setField(saedFromGuardHitCondition, "StartFrame", 0, "readyStanceToSAED5")

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
    if config.userOptions.readyStanceToCondensedSlashCharge.status and isEnabled then
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

    if config.userOptions.readyStanceToDashSlam.status and isEnabled then
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
    if config.userOptions.readyStanceGuardHitSmallToCondensedSlash.status and isEnabled then
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

    if config.userOptions.readyStanceGuardHitWireUp.status and isEnabled then
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

    if config.userOptions.guardHitSmallToCondensedSlash.status and isEnabled then
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

    if config.userOptions.airDashToSAED.status and isEnabled then
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
        AirDashToSAED[1 + index] =
            bhtToolkit:setField(oFromAirDashCondition, "CmdType", bhtToolkit.CommandFsm.AtkAwithoutX, "airDashToSAED1")
        AirDashToSAED[2 + index] = bhtToolkit:setField(
            oFromAirDashLateCondition,
            "CmdType",
            bhtToolkit.CommandFsm.AtkAwithoutX,
            "airDashToSAED2"
        )
        AirDashToSAED[3 + index] =
            bhtToolkit:setField(tFromAirDashCondition, "CmdType", bhtToolkit.CommandFsm.AtkXwithoutA, "airDashToSAED3")
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
        isUpdated[10], uo.guardCounterBuff.status = createCheckbox(uo.guardCounterBuff)
        imgui.text("---Ready Stance---")
        isUpdated[11], uo.readyStanceToSAED.status = createCheckbox(uo.readyStanceToSAED)
        isUpdated[12], uo.readyStanceToCondensedSlashCharge.status =
            createCheckbox(uo.readyStanceToCondensedSlashCharge)
        isUpdated[13], uo.readyStanceGuardHitSmallToCondensedSlash.status =
            createCheckbox(uo.readyStanceGuardHitSmallToCondensedSlash)
        isUpdated[14], uo.readyStanceToDashSlam.status = createCheckbox(uo.readyStanceToDashSlam)
        isUpdated[15], uo.readyStanceAnimationCancels.status = createCheckbox(uo.readyStanceAnimationCancels)
        isUpdated[16], uo.readyStanceGuardHitWireUp.status = createCheckbox(uo.readyStanceGuardHitWireUp)
        imgui.text("---Savage Axe---")
        isUpdated[17], uo.keepChainsawBuff.status = createCheckbox(uo.keepChainsawBuff)
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
        if not config.localOptions.enabled then
            modifyMoveset()
        else
            allowMovesetModify = true
        end
    end
end)

sdk.hook(sdk.find_type_definition("snow.player.ChargeAxe"):get_method("update"), function(args)
    if not config.localOptions.enabled or not config.userOptions.keepChainsawBuff.status then
        return
    end
    local chargeAxe = sdk.to_managed_object(args[2])
    local isChainsawStyleOn = chargeAxe:isChainsawType()
    if not isChainsawStyleOn then
        chargeAxe:set_field("_IsChainsawBuff", false)
        isChainsawToggled = false
        return
    end
    isChainsawToggled = chargeAxe:get_field("_IsChainsawBuff") or isChainsawToggled
    if isChainsawToggled and chargeAxe:get_field("_ShieldBuffTimer") > 0 then
        chargeAxe:set_field("_IsChainsawBuff", true)
        return
    end
    isChainsawToggled = false
end)

sdk.hook(sdk.find_type_definition("snow.player.ChargeAxe"):get_method("createGuardCounterShell"), function(args)
    if not config.localOptions.enabled or not config.userOptions.guardCounterBuff.status then
        return
    end
    local chargeAxe = sdk.to_managed_object(args[2])
    local additionalTime = 5 * 60
    local currentShieldBuffTime = chargeAxe:get_field("_ShieldBuffTimer")
    chargeAxe:set_field("_ShieldBuffTimer", currentShieldBuffTime + additionalTime)
end)

--[[
--Reload on training area load \\Is called many times
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
--]]
--Reload on CB ctor
sdk.hook(sdk.find_type_definition("snow.player.ChargeAxe"):get_method("resetStatusWorkWeapon"), nil, function()
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
