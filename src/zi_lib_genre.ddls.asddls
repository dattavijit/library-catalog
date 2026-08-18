@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Genre - Interface View'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZI_LIB_GENRE
  as select from zlib_genre
{
  key id          as Id,
      description as Description
}
