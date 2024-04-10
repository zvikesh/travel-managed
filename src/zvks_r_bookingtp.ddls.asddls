@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel BO - Bookings'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZVKS_R_BookingTP
  as select from ZVKS_R_Booking
  association to parent ZVKS_R_TravelTP       as _Travel on $projection.TravelID = _Travel.TravelID
  composition [0..*] of ZVKS_R_BookingSupplTP as _BookingSupplements
{
  key TravelID,
  key BookingID,
      BookingDate,
      CustomerID,
      AirlineID,
      ConnectionID,
      FlightDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      FlightPrice,
      CurrencyCode,
      BookingStatus,

      /*Administrative Fields*/
      //All fields should be maintained like, ZVKS_R_TravelTP
      @Semantics.systemDateTime.localInstanceLastChangedAt: true //local ETag field --> OData ETag
      LastChangedAt,

      /* Associations */
      _BookingStatus,
      _Carrier,
      _Connection,
      _Customer,

      /* BO Compositions */
      _Travel,
      _BookingSupplements

}
