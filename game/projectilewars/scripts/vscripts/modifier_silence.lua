require("typescript_lualib")
modifier_silence_basic = {}
modifier_silence_basic.__index = modifier_silence_basic
function modifier_silence_basic.new(construct, ...)
    local instance = setmetatable({}, modifier_silence_basic)
    if construct and modifier_silence_basic.constructor then modifier_silence_basic.constructor(instance, ...) end
    return instance
end
function modifier_silence_basic.IsHidden(self)
    return false
end
function modifier_silence_basic.IsPurgable(self)
    return true
end
function modifier_silence_basic.GetAttributes(self)
    return MODIFIER_ATTRIBUTE_MULTIPLE
end
function modifier_silence_basic.OnCreated(self,kv)
    if IsServer() then
        local parent = CDOTA_Buff.GetParent(self)

        local silenceIndices = TS_ITE(kv.silenceIndices and (#kv.silenceIndices<1),function() return kv.silenceIndices end,function() return {1,2,3,4,5,6} end)

        local abil = CDOTA_BaseNPC.GetCurrentActiveAbility(CDOTA_Buff.GetCaster(self))

        if base_ability.CanBeSilenced(abil) and (TS_indexOf(silenceIndices, CDOTABaseAbility.GetAbilityIndex(abil))~=-1) then
            CDOTA_BaseNPC.Interrupt(CDOTA_Buff.GetParent(self))
        end
        local silencableAbilities = {}

        for i=0,8-1,1 do
            local ability = CDOTA_BaseNPC.GetAbilityByIndex(CDOTA_Buff.GetParent(self),i)

            if (ability and base_ability.CanBeSilenced(ability)) and (TS_indexOf(silenceIndices, i)~=-1) then
                base_ability.SetSilenceEndTime(ability,CDOTA_Buff.GetRemainingTime(self))
                table.insert(silencableAbilities, i)
            end
        end
        CCustomGameEventManager.Send_ServerToPlayer(CustomGameEventManager,CDOTA_BaseNPC.GetPlayerOwner(CDOTA_Buff.GetParent(self)),"hero_silence_created",{silenceIndex=silencableAbilities})
    end
end
function modifier_silence_basic.OnDestroy(self)
    if IsServer() then
        local parent = CDOTA_Buff.GetParent(self)

        local silenceIndices = {}

        for i=0,8-1,1 do
            local ability = CDOTA_BaseNPC.GetAbilityByIndex(parent,i)

            if ability and not base_ability.IsSilenced(ability) then
                table.insert(silenceIndices, i)
            end
        end
        CCustomGameEventManager.Send_ServerToPlayer(CustomGameEventManager,CDOTA_BaseNPC.GetPlayerOwner(CDOTA_Buff.GetCaster(self)),"hero_silence_removed",{unsilenceIndex=silenceIndices})
    end
end
function modifier_silence_basic.GetEffectName(self)
    return "particles/generic_gameplay/generic_silenced.vpcf"
end
function modifier_silence_basic.GetEffectAttachType(self)
    return PATTACH_OVERHEAD_FOLLOW
end
