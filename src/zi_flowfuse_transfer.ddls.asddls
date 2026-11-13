@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FlowFuse Transfer Interface View'
@Metadata.ignorePropagatedAnnotations: true

define root view entity ZI_FLOWFUSE_TRANSFER
  as select from zyff_transfer
{
  key transfer_id         as TransferId,

      requirement_id      as RequirementId,
      material_id         as MaterialId,
      source_location     as SourceLocation,
      target_location     as TargetLocation,

      unit_field          as UnitField,

      @Semantics.quantity.unitOfMeasure: 'UnitField'
      transfer_qty        as TransferQty,

      recovery_score      as RecoveryScore,
      status              as Status,
      escalation_required as EscalationRequired,
      explanation         as Explanation,
      last_changed_at       as LastChangedAt,
      local_last_changed_at as LocalLastChangedAt
}
