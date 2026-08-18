@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Genre'
define view entity ZC_LIB_GENRE
  as select from ZI_LIB_GENRE
{
  key Id,
      Description
}
