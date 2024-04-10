@EndUserText.label: 'Travel (Basic View)'
-- DCL
@AccessControl.authorizationCheck: #NOT_REQUIRED
-- Metadata
@Metadata.ignorePropagatedAnnotations: true
-- Data Model
//@VDM.viewType: #BASIC
-- Performance
@ObjectModel.usageType:{
    serviceQuality: #A,
    dataClass: #TRANSACTIONAL,
    sizeCategory: #XL
}
--- Analytical
@Analytics.dataCategory: #DIMENSION
define view entity ZVKS_R_Travel
  as select from /dmo/travel_m
  -- Value Tables (Ideally Basic Views on the Top of Value Tables should only be used)
  association [0..1] to /DMO/I_Agency            as _Agency        on $projection.AgencyID = _Agency.AgencyID
  association [0..1] to /DMO/I_Customer          as _Customer      on $projection.CustomerID = _Customer.CustomerID
  association [0..1] to I_Currency               as _Currency      on $projection.CurrencyCode = _Currency.Currency
  association [1..1] to /DMO/I_Overall_Status_VH as _OverallStatus on $projection.OverallStatus = _OverallStatus.OverallStatus
{
  key travel_id       as TravelID,
      agency_id       as AgencyID,
      customer_id     as CustomerID,
      begin_date      as BeginDate,
      end_date        as EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      booking_fee     as BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      total_price     as TotalPrice,
      currency_code   as CurrencyCode,
      description     as Description,
      overall_status  as OverallStatus,

      /*Administrative Fields*/
      @Semantics.user.createdBy: true
      created_by      as CreatedBy,
      @Semantics.systemDateTime.createdAt: true
      created_at      as CreatedAt,
      @Semantics.user.lastChangedBy: true
      last_changed_by as LastChangedBy,
      //local ETag field --> OData ETag
      @Semantics.systemDateTime.localInstanceLastChangedAt: true //local ETag field --> OData ETag
      last_changed_at as LastChangedAt,

      /* Associations */
      _Agency,
      _Customer,
      _Currency,
      _OverallStatus

}
