@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Travel Business Object'
define root view entity ZVKS_R_TravelTP
  as select from ZVKS_R_Travel
  composition [0..*] of ZVKS_R_BookingTP as _Booking
{
  //TBD: EndUser Text Label
  
  key TravelID,
      AgencyID,
      CustomerID,
      BeginDate,
      EndDate,
      BookingFee,
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus,

      /*Administrative Fields*/
      @Semantics.user.createdBy: true
      CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      CreatedAt,
      @Semantics.user.lastChangedBy: true
      LastChangedBy,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true //local ETag field --> OData ETag
      LastChangedAt,

      /* Associations */
      _Agency,
      _Currency,
      _Customer,
      _OverallStatus,

      /* BO Compositions */
      _Booking
}
