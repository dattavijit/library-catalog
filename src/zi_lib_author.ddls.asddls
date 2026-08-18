@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Author - Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_LIB_AUTHOR
  as select from zlib_author
{
  key id          as Id,
      name        as Name,
      nationality as Nationality
}
