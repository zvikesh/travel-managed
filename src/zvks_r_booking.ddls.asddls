@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking (Basic View)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZVKS_R_Booking
  as select from /dmo/booking_m
  -- Value Tables (Ideally Basic Views on the Top of Value Tables should only be used)
  association [1..1] to /DMO/I_Customer          as _Customer      on  $projection.CustomerID = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier           as _Carrier       on  $projection.AirlineID = _Carrier.AirlineID
  association [1..1] to /DMO/I_Connection        as _Connection    on  $projection.AirlineID    = _Connection.AirlineID
                                                                   and $projection.ConnectionID = _Connection.ConnectionID
  association [1..1] to /DMO/I_Booking_Status_VH as _BookingStatus on  $projection.BookingStatus = _BookingStatus.BookingStatus
{

  //TBD: EndUser Text Label
  
  key travel_id       as TravelID,
  key booking_id      as BookingID,
      booking_date    as BookingDate,
      customer_id     as CustomerID,
      carrier_id      as AirlineID,
      connection_id   as ConnectionID,
      flight_date     as FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      flight_price    as FlightPrice,
      currency_code   as CurrencyCode,
      booking_status  as BookingStatus,

      /*Administrative Fields*/
      //All fields should be maintained like, ZVKS_R_Travel
      @Semantics.systemDateTime.localInstanceLastChangedAt: true //local ETag field --> OData ETag
      last_changed_at as LastChangedAt,

      /* Associations */
      _Customer,
      _Carrier,
      _Connection,
      _BookingStatus

}
