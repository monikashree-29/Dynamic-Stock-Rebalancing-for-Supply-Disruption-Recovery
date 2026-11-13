@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FlowFuse Stock Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_FLOWFUSE_STOCK
  as select from zyff_stock
{
     key stock_id      as StockId,

      material_id   as MaterialId,
      location_id   as LocationId,

      unit_field    as UnitField,

      @Semantics.quantity.unitOfMeasure: 'UnitField'
      available_qty as AvailableQty,

      @Semantics.quantity.unitOfMeasure: 'UnitField'
      safety_qty    as SafetyQty,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}
