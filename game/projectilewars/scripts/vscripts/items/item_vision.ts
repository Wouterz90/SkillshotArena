require('items/base_item')

class item_rune_vision extends item_base_rune {
}

LinkLuaModifier("modifier_rune_vision","items/item_vision.lua",LuaModifierType.LUA_MODIFIER_MOTION_NONE)

class modifier_rune_vision extends CDOTA_Modifier_Lua {
  vision:number
  DeclareFunctions() {
    return [
      modifierfunction.MODIFIER_PROPERTY_BONUS_DAY_VISION,
      modifierfunction.MODIFIER_PROPERTY_BONUS_NIGHT_VISION,
    ]
  }

  OnCreated() {
    this.vision = this.GetAbility().GetSpecialValueFor( "bonus_vision")
  }

  GetBonusDayVision() {
    return this.vision
  } 
  GetBonusNightVision() {
    return this.vision
  }   
}



