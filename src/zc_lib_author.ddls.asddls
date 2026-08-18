@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Author'
@Search.searchable: true
define view entity ZC_LIB_AUTHOR
  as select from ZI_LIB_AUTHOR
{
  key Id,
      @Search.defaultSearchElement: true
      Name,
      Nationality
}
