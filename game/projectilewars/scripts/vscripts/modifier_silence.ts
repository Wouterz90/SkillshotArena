class modifier_silence_basic extends CDOTA_Modifier_Lua {

  IsHidden() {return false}
  IsPurgable() {return true}
  GetAttributes() { return DOTAModifierAttribute_t.MODIFIER_ATTRIBUTE_MULTIPLE}
  OnCreated(kv:{silenceIndices:number[]}) {
    if (IsServer()) {
      let parent = this.GetParent()
      let silenceIndices = kv.silenceIndices && kv.silenceIndices.length < 1 ? kv.silenceIndices : [1,2,3,4,5,6]
      let abil = this.GetCaster().GetCurrentActiveAbility() as base_ability
      // Interrupt
      if (abil.CanBeSilenced() && silenceIndices.indexOf(abil.GetAbilityIndex()) != -1) {
        this.GetParent().Interrupt()
      }
      //Activate overlay
      let silencableAbilities = []
      for (let i = 0;i <8;i++) {
        let ability = this.GetParent().GetAbilityByIndex(i) as base_ability
        if (ability && ability.CanBeSilenced() && silenceIndices.indexOf(i) != -1) {
          ability.SetSilenceEndTime(this.GetRemainingTime())
          silencableAbilities.push(i)
        }
      }
      CustomGameEventManager.Send_ServerToPlayer(this.GetParent().GetPlayerOwner(),"hero_silence_created",{silenceIndex:silencableAbilities})
    } 
  }

  OnDestroy() {
    if (IsServer()) {
      let parent = this.GetParent()
      let silenceIndices = []
      for (let i=0;i< 8;i++) {
        let ability = parent.GetAbilityByIndex(i) as base_ability
        if (ability && !ability.IsSilenced()) {
          silenceIndices.push(i)
        }
      }
      //Remove overlay
      CustomGameEventManager.Send_ServerToPlayer(this.GetCaster().GetPlayerOwner(),"hero_silence_removed",{unsilenceIndex:silenceIndices})
    }
  }

  //IsSilenceDebuff:true

  GetEffectName() {
    return "particles/generic_gameplay/generic_silenced.vpcf"
  }
  GetEffectAttachType() {
    return ParticleAttachment_t.PATTACH_OVERHEAD_FOLLOW
  }

}
