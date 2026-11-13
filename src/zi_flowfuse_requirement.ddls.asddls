@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FlowFuse Requirement Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_FLOWFUSE_REQUIREMENT
  as select from zyff_requirement
{
  key requirement_id as RequirementId,
      material_id    as MaterialId,
      location_id    as LocationId,
      unit_field     as UnitField,

      @Semantics.quantity.unitOfMeasure: 'UnitField'
      required_qty   as RequiredQty,

      @Semantics.quantity.unitOfMeasure: 'UnitField'
      available_qty  as AvailableQty,

      urgency        as Urgency,
      status         as Status,

      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}
