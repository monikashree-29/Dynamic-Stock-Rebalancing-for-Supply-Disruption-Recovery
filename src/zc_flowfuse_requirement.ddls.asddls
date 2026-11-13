@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FlowFuse Requirement Consumption View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_FLOWFUSE_REQUIREMENT
  provider contract transactional_query
  as projection on ZI_FLOWFUSE_REQUIREMENT
{
  key RequirementId,
      MaterialId,
      LocationId,
      UnitField,

      @Semantics.quantity.unitOfMeasure: 'UnitField'
      RequiredQty,

      @Semantics.quantity.unitOfMeasure: 'UnitField'
      AvailableQty,

      Urgency,
      Status,
      LastChangedAt,
      LocalLastChangedAt
}
