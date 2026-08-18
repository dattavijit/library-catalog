@EndUserText.label: 'Book - Interface View'
define root view entity ZI_LIB_BOOK
  as select from zlib_book
  association [1..1] to ZI_LIB_AUTHOR as _Author on $projection.author_id = _Author.Id
  association [1..1] to ZI_LIB_GENRE  as _Genre  on $projection.genre_id  = _Genre.Id
{
  key id,
      title,
      publish_date,
      isbn,
      author_id,
      genre_id,
      last_changed_at,

      /* Associations */
      _Author,
      _Genre
}
