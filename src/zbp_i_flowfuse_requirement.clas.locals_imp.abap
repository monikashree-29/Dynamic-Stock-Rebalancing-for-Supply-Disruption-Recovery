CLASS lhc_Requirement DEFINITION
  INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS get_global_authorizations
      FOR GLOBAL AUTHORIZATION
      REQUEST requested_authorizations
      FOR Requirement
      RESULT result.

    METHODS GenerateRecommendation
      FOR MODIFY
      IMPORTING keys FOR ACTION Requirement~GenerateRecommendation.

ENDCLASS.


CLASS lhc_Requirement IMPLEMENTATION.


  METHOD get_global_authorizations.

    result-%create = if_abap_behv=>auth-allowed.
    result-%update = if_abap_behv=>auth-allowed.
    result-%delete = if_abap_behv=>auth-allowed.

  ENDMETHOD.


  METHOD GenerateRecommendation.

    READ ENTITIES OF ZI_FLOWFUSE_REQUIREMENT IN LOCAL MODE
      ENTITY Requirement
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_requirement).


    LOOP AT lt_requirement INTO DATA(ls_requirement).


      "------------------------------------------------------------
      " 1. Calculate shortage
      "------------------------------------------------------------

      DATA lv_shortage TYPE zyff_de_quantity.

      lv_shortage =
        ls_requirement-RequiredQty
        - ls_requirement-AvailableQty.

      IF lv_shortage <= 0.
        CONTINUE.
      ENDIF.


      "------------------------------------------------------------
      " 2. Find stock for same material
      "------------------------------------------------------------

      SELECT FROM zyff_stock
        FIELDS
          stock_id,
          material_id,
          location_id,
          unit_field,
          available_qty,
          safety_qty
        WHERE material_id = @ls_requirement-MaterialId
        INTO TABLE @DATA(lt_stock).


      DATA lv_remaining TYPE zyff_de_quantity.

      lv_remaining = lv_shortage.


      "------------------------------------------------------------
      " 3. Find next Transfer ID
      "------------------------------------------------------------

      SELECT SINGLE FROM zyff_transfer
        FIELDS MAX( transfer_id )
        WHERE transfer_id LIKE 'TRF%'
        INTO @DATA(lv_last_transfer_id).


      DATA lv_next_number TYPE i VALUE 1.

      IF lv_last_transfer_id IS NOT INITIAL.

        lv_next_number =
          CONV i( lv_last_transfer_id+3(3) ) + 1.

      ENDIF.


      "------------------------------------------------------------
      " 4. Process each possible source
      "------------------------------------------------------------

      LOOP AT lt_stock INTO DATA(ls_stock).


        IF lv_remaining <= 0.
          EXIT.
        ENDIF.


        "----------------------------------------------------------
        " 5. Calculate usable source quantity
        "----------------------------------------------------------

        DATA lv_usable_qty TYPE zyff_de_quantity.

        lv_usable_qty =
          ls_stock-available_qty
          - ls_stock-safety_qty.

        IF lv_usable_qty <= 0.
          CONTINUE.
        ENDIF.


        "----------------------------------------------------------
        " 6. Calculate transfer quantity
        "----------------------------------------------------------

        DATA lv_transfer_qty TYPE zyff_de_quantity.

        lv_transfer_qty = lv_usable_qty.

        IF lv_transfer_qty > lv_remaining.

          lv_transfer_qty = lv_remaining.

        ENDIF.


        "----------------------------------------------------------
        " 7. Generate unique Transfer ID
        "----------------------------------------------------------

        DATA(lv_transfer_id) =
          |TRF{ lv_next_number WIDTH = 3 PAD = '0' }|.

        lv_next_number = lv_next_number + 1.


        "----------------------------------------------------------
        " 8. Recovery Score calculation
        "----------------------------------------------------------

        DATA lv_availability_score TYPE p LENGTH 8 DECIMALS 2.
        DATA lv_safety_score       TYPE p LENGTH 8 DECIMALS 2.
        DATA lv_transport_score    TYPE p LENGTH 8 DECIMALS 2.
        DATA lv_urgency_score      TYPE p LENGTH 8 DECIMALS 2.
        DATA lv_recovery_score     TYPE p LENGTH 8 DECIMALS 2.


        "----------------------------------------------------------
        " Availability = 40%
        "----------------------------------------------------------

        IF lv_shortage > 0.

          lv_availability_score =
            ( lv_transfer_qty / lv_shortage ) * 100.

        ELSE.

          lv_availability_score = 0.

        ENDIF.


        IF lv_availability_score > 100.

          lv_availability_score = 100.

        ENDIF.


        "----------------------------------------------------------
        " Source Safety = 25%
        " Score based on remaining safety buffer
        "----------------------------------------------------------

        DATA lv_remaining_source TYPE zyff_de_quantity.
        DATA lv_safety_ratio     TYPE p LENGTH 8 DECIMALS 2.

        lv_remaining_source =
          ls_stock-available_qty - lv_transfer_qty.


        IF ls_stock-safety_qty <= 0.

          lv_safety_score = 100.

        ELSEIF lv_remaining_source <= 0.

          lv_safety_score = 0.

        ELSE.

          lv_safety_ratio =
            ( lv_remaining_source / ls_stock-safety_qty ) * 100.


          IF lv_safety_ratio >= 200.

            lv_safety_score = 100.

          ELSEIF lv_safety_ratio >= 100.

            lv_safety_score =
              70 + ( ( lv_safety_ratio - 100 ) * 30 / 100 ).

          ELSE.

            lv_safety_score =
              lv_safety_ratio * 70 / 100.

          ENDIF.

        ENDIF.


"----------------------------------------------------------
" Transport Time = 20%
" Read transport time from source location
"----------------------------------------------------------

DATA lv_transport_time TYPE zyff_de_transtime.

SELECT SINGLE transport_time
  FROM zyff_location
  WHERE location_id = @ls_stock-location_id
  INTO @lv_transport_time.

IF sy-subrc <> 0.

  "If transport time is not maintained,
  "use a neutral score
  lv_transport_score = 50.

ELSE.

  CASE lv_transport_time.

    WHEN 1.
      lv_transport_score = 100.

    WHEN 2.
      lv_transport_score = 80.

    WHEN 3.
      lv_transport_score = 60.

    WHEN 4.
      lv_transport_score = 40.

    WHEN OTHERS.
      lv_transport_score = 20.

  ENDCASE.

ENDIF.
        "----------------------------------------------------------
        " Urgency = 15%
        "----------------------------------------------------------

        CASE ls_requirement-Urgency.

          WHEN 'HIGH'.

            lv_urgency_score = 100.

          WHEN 'MEDIUM'.

            lv_urgency_score = 70.

          WHEN 'LOW'.

            lv_urgency_score = 40.

          WHEN OTHERS.

            lv_urgency_score = 50.

        ENDCASE.


        "----------------------------------------------------------
        " Final weighted Recovery Score
        "----------------------------------------------------------

        lv_recovery_score =

            ( lv_availability_score * 40 / 100 )

          + ( lv_safety_score       * 25 / 100 )

          + ( lv_transport_score    * 20 / 100 )

          + ( lv_urgency_score      * 15 / 100 ).


        "----------------------------------------------------------
        " 9. Automatically create Transfer
        "----------------------------------------------------------

        MODIFY ENTITIES OF ZI_FLOWFUSE_TRANSFER

          ENTITY Transfer

          CREATE FIELDS (

            TransferId
            RequirementId
            MaterialId
            SourceLocation
            TargetLocation
            UnitField
            TransferQty
            RecoveryScore
            Status
            EscalationRequired
            Explanation

          )

          WITH VALUE #(

            (

              %cid =
                |TRANSFER_{ lv_transfer_id }|

              TransferId =
                lv_transfer_id

              RequirementId =
                ls_requirement-RequirementId

              MaterialId =
                ls_requirement-MaterialId

              SourceLocation =
                ls_stock-location_id

              TargetLocation =
                ls_requirement-LocationId

              UnitField =
                ls_stock-unit_field

              TransferQty =
                lv_transfer_qty

              RecoveryScore =
                lv_recovery_score

              Status =
                'RECOMMENDED'

              EscalationRequired =
                'N'

              Explanation =
                |SOURCE { ls_stock-location_id } COVERS { lv_transfer_qty } UNITS|

            )

          ).


        "----------------------------------------------------------
        " 10. Reduce remaining shortage
        "----------------------------------------------------------

        lv_remaining =
          lv_remaining - lv_transfer_qty.


        "----------------------------------------------------------
        " 11. Update Requirement status
        "----------------------------------------------------------

        MODIFY ENTITIES OF ZI_FLOWFUSE_REQUIREMENT IN LOCAL MODE

          ENTITY Requirement

          UPDATE FIELDS ( Status )

          WITH VALUE #(

            (

              %tky = ls_requirement-%tky

              Status = 'RECOMMENDED'

            )

          ).


      ENDLOOP.


    ENDLOOP.


  ENDMETHOD.


ENDCLASS.
