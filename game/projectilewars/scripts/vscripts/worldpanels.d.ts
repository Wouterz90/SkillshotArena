declare interface WorldPanels {
    CreateWorldPanel(playerID:PlayerID, configTable:WorldPanelTable):wp
    CreateWorldPanelForTeam(teamID:DOTATeam_t, configTable:WorldPanelTable):wp
    CreateWorldPanelForAll(configTable:WorldPanelTable):wp
}

declare interface WorldPanelTable {
  layout:string,
  position?:Vec ,
  entity?:number, 
  offsetX?:number,
  offsetY?:number,
  horizontalAlign?: "center" | "left" | "right",
  verticalAlign?: "center" | "bottom" | "top",
  entityHeight?: number,
  edgePadding?: number,
  duration?: number,
  data?:{key:any},
  ability?:string,
  item?:string

}
declare const WorldPanels: WorldPanels;

declare interface wp {
  SetPosition(position:Vec)
  SetEntity(entity:number)
  SetHorizontalAlign(hAlign:"center" | "left" | "right")
  SetVerticalAlign(vAlign:"center" | "bottom" | "top")
  SetOffsetX(offsetX:number)
  SetOffsetY(offsetY:number)
  SetEdgePadding(edge:number)
  SetEntityHeight(entityHeight:number)
  SetData(data:{key:any})
  Delete()
}

declare const wp:wp