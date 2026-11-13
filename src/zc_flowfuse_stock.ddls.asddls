@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FlowFuse Stock Consumption View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_FLOWFUSE_STOCK
  provider contract transactional_query
  as projection on ZI_FLOWFUSE_STOCK
{
  key StockId,
      MaterialId,
      LocationId,
      UnitField,

      @Semantics.quantity.unitOfMeasure: 'UnitField'
      AvailableQty,

      @Semantics.quantity.unitOfMeasure: 'UnitField'
      SafetyQty,

      LastChangedAt,
      LocalLastChangedAt
}
