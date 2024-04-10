CLASS lhc_booking DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS earlynumbering_cba_Bookingsupp FOR NUMBERING
      IMPORTING entities FOR CREATE Booking\_Bookingsupplements.

ENDCLASS.

CLASS lhc_booking IMPLEMENTATION.

  METHOD earlynumbering_cba_Bookingsupp.

    DATA: max_booking_suppl_id TYPE /dmo/booking_supplement_id .

    READ ENTITIES OF ZVKS_R_TravelTP IN LOCAL MODE
      ENTITY booking BY \_BookingSupplements
        FROM CORRESPONDING #( entities )
        LINK DATA(booking_supplements).

    " Loop over all unique tky (TravelID + BookingID)
    LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking_group>) GROUP BY <booking_group>-%tky.

      " Get highest bookingsupplement_id from bookings belonging to booking
      max_booking_suppl_id = REDUCE #( INIT max = CONV /dmo/booking_supplement_id( '0' )
                                       FOR  booksuppl IN booking_supplements USING KEY entity
                                                                             WHERE (     source-TravelID  = <booking_group>-TravelID
                                                                                     AND source-BookingID = <booking_group>-BookingID )
                                       NEXT max = COND /dmo/booking_supplement_id( WHEN   booksuppl-target-BookingSupplementID > max
                                                                          THEN booksuppl-target-BookingSupplementID
                                                                          ELSE max )
                                     ).
      " Get highest assigned bookingsupplement_id from incoming entities
      max_booking_suppl_id = REDUCE #( INIT max = max_booking_suppl_id
                                       FOR  entity IN entities USING KEY entity
                                                               WHERE (     TravelID  = <booking_group>-TravelID
                                                                       AND BookingID = <booking_group>-BookingID )
                                       FOR  target IN entity-%target
                                       NEXT max = COND /dmo/booking_supplement_id( WHEN   target-BookingSupplementID > max
                                                                                     THEN target-BookingSupplementID
                                                                                     ELSE max )
                                     ).

      " Loop over all entries in entities with the same TravelID and BookingID
      LOOP AT entities ASSIGNING FIELD-SYMBOL(<booking>) USING KEY entity WHERE TravelID  = <booking_group>-TravelID
                                                                            AND BookingID = <booking_group>-BookingID.

        " Assign new booking_supplement-ids
        LOOP AT <booking>-%target ASSIGNING FIELD-SYMBOL(<booksuppl_wo_numbers>).
          APPEND CORRESPONDING #( <booksuppl_wo_numbers> ) TO mapped-bookingsuppl ASSIGNING FIELD-SYMBOL(<mapped_booksuppl>).
          IF <booksuppl_wo_numbers>-BookingSupplementID IS INITIAL.
            max_booking_suppl_id += 1 .
            <mapped_booksuppl>-BookingSupplementID = max_booking_suppl_id .
          ENDIF.
        ENDLOOP.

      ENDLOOP.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.

*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations
