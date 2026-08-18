@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Genre'
@ObjectModel.resultSet.sizeCategory: #XS
define view entity ZC_LIB_GENRE
  as select from ZI_LIB_GENRE
{
  key Id,
      Description
}
