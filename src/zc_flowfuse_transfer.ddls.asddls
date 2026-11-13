@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FlowFuse Transfer Consumption View'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_FLOWFUSE_TRANSFER
  provider contract transactional_query
  as projection on ZI_FLOWFUSE_TRANSFER
{
  key TransferId,
      RequirementId,
      MaterialId,
      SourceLocation,
      TargetLocation,
      UnitField,
       @Semantics.quantity.unitOfMeasure: 'UnitField'
      TransferQty,
      RecoveryScore,
      Status,
      EscalationRequired,
      Explanation,
      LastChangedAt,
      LocalLastChangedAt
      
}
