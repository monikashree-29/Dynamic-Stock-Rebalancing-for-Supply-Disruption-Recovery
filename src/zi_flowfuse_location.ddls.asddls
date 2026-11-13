@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'FlowFuse Location Interface View'
@Metadata.ignorePropagatedAnnotations: true

define view entity ZI_FLOWFUSE_LOCATION
  as select from zyff_location
{
  key location_id    as LocationId,
      location_name  as LocationName,
      location_type  as LocationType,
      transport_time as TransportTime
}
