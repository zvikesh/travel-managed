CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.
    METHODS earlynumbering_create FOR NUMBERING
      IMPORTING entities FOR CREATE travel.

    METHODS earlynumbering_cba_booking FOR NUMBERING
      IMPORTING entities FOR CREATE travel\_booking.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD earlynumbering_create.
    "importing
    " entities  type table for create zvks_r_traveltp\\travel  [ derived type... ]
    "changing
    " mapped    type response for mapped early zvks_r_traveltp  [ derived type... ]
    " failed    type response for failed early zvks_r_traveltp  [ derived type... ]
    " reported  type response for reported early zvks_r_traveltp  [ derived type... ]


    DATA:
      entity        TYPE STRUCTURE FOR CREATE ZVKS_R_TravelTP,
      travel_id_max TYPE /dmo/travel_id.

    " Ensure Travel ID is not set yet (idempotent)- must be checked when BO is draft-enabled
    LOOP AT entities INTO entity WHERE TravelID IS NOT INITIAL.
      "Because the FOR NUMBERING method is called twice in a managed scenario with draft capabilities
      "(once during the CREATE and once during the save sequence), the implementation includes a
      "mapping for travels that already have an ID, so that the ID assigned during the CREATE isn’t
      "overwritten during the save sequence.This step is only applicable for draft enabled application
      "and not for an active-only managed BO.
      APPEND CORRESPONDING #( entity ) TO mapped-travel.
    ENDLOOP.

    "For Draft Scenario: IDs are only assigned to travels that didn't have an ID before.
    DATA(entities_wo_travelid) = entities.
    DELETE entities_wo_travelid WHERE TravelID IS NOT INITIAL.

    " Get Numbers
    TRY.
        cl_numberrange_runtime=>number_get(
          EXPORTING
            nr_range_nr       = '01'
            object            = '/DMO/TRV_M'
            quantity          = CONV #( lines( entities_wo_travelid ) )
          IMPORTING
            number            = DATA(number_range_key)
            returncode        = DATA(number_range_return_code)
            returned_quantity = DATA(number_range_returned_quantity)
        ).

      CATCH cx_number_ranges INTO DATA(lx_number_ranges).
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #(  %cid = entity-%cid
                           %key = entity-%key
                           %msg = lx_number_ranges
                        ) TO reported-travel.
          APPEND VALUE #(  %cid = entity-%cid
                           %key = entity-%key
                        ) TO failed-travel.
        ENDLOOP.
        EXIT.
    ENDTRY.

    CASE number_range_return_code.
      WHEN '1'.
        " 1 - the returned number is in a critical range (specified under “percentage warning” in the object definition)
        LOOP AT entities_wo_travelid INTO entity.
          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %msg = NEW /dmo/cm_flight_messages(
                                      textid = /dmo/cm_flight_messages=>number_range_depleted
                                      severity = if_abap_behv_message=>severity-warning )
                        ) TO reported-travel.
        ENDLOOP.

      WHEN '2' OR '3'.
        " 2 - the last number of the interval was returned
        " 3 - if fewer numbers are available than requested,  the return code is 3
        LOOP AT entities_wo_travelid INTO entity.

          APPEND VALUE #( %cid = entity-%cid
                          %key = entity-%key
                          %msg = NEW /dmo/cm_flight_messages(
                                      textid = /dmo/cm_flight_messages=>not_sufficient_numbers
                                      severity = if_abap_behv_message=>severity-warning )
                        ) TO reported-travel.

          APPEND VALUE #( %cid        = entity-%cid
                          %key        = entity-%key
                          %fail-cause = if_abap_behv=>cause-conflict
                        ) TO failed-travel.
        ENDLOOP.
        EXIT.
    ENDCASE.

    " At this point ALL entities get a number!
    ASSERT number_range_returned_quantity = lines( entities_wo_travelid ).

    "If several numbers are requested, the number always returns the highest number and
    "the starting point of the assignment is calculated by subtracting the requested
    "number of numbers. The number count is then increased by 1 for each instance.
    travel_id_max = number_range_key - number_range_returned_quantity.

    " Set Travel ID
    LOOP AT entities_wo_travelid INTO entity.
      travel_id_max += 1.
      entity-TravelID = travel_id_max .

      APPEND VALUE #( %cid  = entity-%cid
                      %key  = entity-%key
                    ) TO mapped-travel.
    ENDLOOP.

  ENDMETHOD.

  METHOD earlynumbering_cba_Booking.

    DATA: max_booking_id TYPE /dmo/booking_id.

    "With a read-by-association all booking-ids are retrieved.
    READ ENTITIES OF ZVKS_R_TravelTP IN LOCAL MODE
      ENTITY travel BY \_booking
        FROM CORRESPONDING #( entities )
        LINK DATA(bookings).

    " Loop over all unique TravelIDs
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel_group>) GROUP BY <travel_group>-TravelID.

      " Get highest booking_id from bookings belonging to travel
      max_booking_id = REDUCE #( INIT max = CONV /dmo/booking_id( '0' )
                                 FOR  booking IN bookings USING KEY entity WHERE ( source-TravelID  = <travel_group>-TravelID )
                                 NEXT max = COND /dmo/booking_id( WHEN booking-target-BookingID > max
                                                                  THEN booking-target-BookingID
                                                                  ELSE max )
                               ).
      " Get highest assigned booking_id from incoming entities
      max_booking_id = REDUCE #( INIT max = max_booking_id
                                 FOR  entity IN entities USING KEY entity WHERE ( TravelID  = <travel_group>-TravelID )
                                 FOR  target IN entity-%target
                                 NEXT max = COND /dmo/booking_id( WHEN target-BookingID > max
                                                                  THEN target-BookingID
                                                                  ELSE max )
                               ).
      " Loop over all entries in entities with the same TravelID
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<travel>) USING KEY entity WHERE TravelID = <travel_group>-TravelID.

        " Assign new booking-ids if not already assigned
        LOOP AT <travel>-%target ASSIGNING FIELD-SYMBOL(<booking_wo_numbers>).
          APPEND CORRESPONDING #( <booking_wo_numbers> ) TO mapped-booking ASSIGNING FIELD-SYMBOL(<mapped_booking>).
          IF <booking_wo_numbers>-BookingID IS INITIAL.
            max_booking_id += 10 .
            <mapped_booking>-BookingID = max_booking_id .
          ENDIF.
        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
