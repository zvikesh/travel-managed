@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking Supplement (Basic View)'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ZVKS_R_BookingSuppl
  as select from /dmo/booksuppl_m
  -- Value Tables (Ideally Basic Views on the Top of Value Tables should only be used)
  association [1..1] to /DMO/I_Travel_M       as _Travel         on $projection.TravelID = _Travel.travel_id
  association [1..1] to /DMO/I_Supplement     as _Product        on $projection.SupplementID = _Product.SupplementID
  association [1..*] to /DMO/I_SupplementText as _SupplementText on $projection.SupplementID = _SupplementText.SupplementID
{

  //TBD: EndUser Text Label

  key travel_id             as TravelID,
  key booking_id            as BookingID,
  key booking_supplement_id as BookingSupplementID,
      supplement_id         as SupplementID,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      price                 as Price,
      currency_code         as CurrencyCode,

      /*Administrative Fields*/
      //All fields should be maintained like, ZVKS_R_Travel
      @Semantics.systemDateTime.localInstanceLastChangedAt: true //local ETag field --> OData ETag
      last_changed_at       as LastChangedAt,

      /* Associations */
      _Travel,
      _Product,
      _SupplementText

}
