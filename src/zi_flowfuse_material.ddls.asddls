@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FlowFuse Material Interface View'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_FLOWFUSE_MATERIAL
  as select from zyff_material
{
  key material_id  as MaterialId,

      material_name as MaterialName,
      base_unit     as BaseUnit,
      criticality   as Criticality
}
