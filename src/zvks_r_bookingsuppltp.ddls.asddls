@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel BO - Booking Supplements'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZVKS_R_BookingSupplTP
  as select from ZVKS_R_BookingSuppl
  association        to parent ZVKS_R_BookingTP as _Booking on  $projection.TravelID  = _Booking.TravelID
                                                            and $projection.BookingID = _Booking.BookingID
  association [1..1] to ZVKS_R_TravelTP         as _Travel  on  $projection.TravelID = _Travel.TravelID
{
  key TravelID,
  key BookingID,
  key BookingSupplementID,
      SupplementID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,
      CurrencyCode,

      /*Administrative Fields*/
      //All fields should be maintained like, ZVKS_R_Travel
      @Semantics.systemDateTime.localInstanceLastChangedAt: true //local ETag field --> OData ETag
      LastChangedAt,

      /* Associations */
      _Product,
      _SupplementText,

      /* BO Compositions */
      _Booking,
      _Travel
}
