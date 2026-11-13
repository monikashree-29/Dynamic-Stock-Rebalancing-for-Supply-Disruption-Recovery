CLASS zcl_flowfuse_seed_location DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_flowfuse_seed_location IMPLEMENTATION.


METHOD if_oo_adt_classrun~main.

  DATA ls_location TYPE zyff_location.

  DELETE FROM zyff_location.

  ls_location-client = sy-mandt.
  ls_location-location_id = 'LOCA'.
  ls_location-location_name = 'Location A'.
  ls_location-location_type = 'PLANT'.
  ls_location-transport_time = 1.
  INSERT zyff_location FROM @ls_location.

  CLEAR ls_location.
  ls_location-client = sy-mandt.
  ls_location-location_id = 'LOCB'.
  ls_location-location_name = 'Location B'.
  ls_location-location_type = 'PLANT'.
  ls_location-transport_time = 2.
  INSERT zyff_location FROM @ls_location.

  CLEAR ls_location.
  ls_location-client = sy-mandt.
  ls_location-location_id = 'LOCC'.
  ls_location-location_name = 'Location C'.
  ls_location-location_type = 'PLANT'.
  ls_location-transport_time = 3.
  INSERT zyff_location FROM @ls_location.

  CLEAR ls_location.
  ls_location-client = sy-mandt.
  ls_location-location_id = 'LOCD'.
  ls_location-location_name = 'Location D'.
  ls_location-location_type = 'PLANT'.
  ls_location-transport_time = 4.
  INSERT zyff_location FROM @ls_location.

  COMMIT WORK.

  out->write( 'Location data inserted successfully.' ).

ENDMETHOD.
ENDCLASS.
