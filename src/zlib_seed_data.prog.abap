REPORT zlib_seed_data.

START-OF-SELECTION.
  PERFORM seed_data.

FORM seed_data.
  DATA: lt_author TYPE STANDARD TABLE OF zlib_author,
        lt_genre  TYPE STANDARD TABLE OF zlib_genre,
        lt_book   TYPE STANDARD TABLE OF zlib_book.

  DATA: lv_author_le_guin    TYPE sysuuid_x16,
        lv_author_murakami   TYPE sysuuid_x16,
        lv_author_adichie    TYPE sysuuid_x16,
        lv_author_marquez    TYPE sysuuid_x16,
        lv_author_christie   TYPE sysuuid_x16,
        lv_genre_scifi       TYPE sysuuid_x16,
        lv_genre_litfic      TYPE sysuuid_x16,
        lv_genre_mystery     TYPE sysuuid_x16,
        lv_genre_magicreal   TYPE sysuuid_x16,
        lv_genre_nonfiction  TYPE sysuuid_x16,
        lv_now                TYPE timestampl.

  DELETE FROM zlib_book.
  DELETE FROM zlib_author.
  DELETE FROM zlib_genre.

  lv_author_le_guin   = cl_system_uuid=>create_uuid_x16_static( ).
  lv_author_murakami  = cl_system_uuid=>create_uuid_x16_static( ).
  lv_author_adichie   = cl_system_uuid=>create_uuid_x16_static( ).
  lv_author_marquez   = cl_system_uuid=>create_uuid_x16_static( ).
  lv_author_christie  = cl_system_uuid=>create_uuid_x16_static( ).

  lv_genre_scifi      = cl_system_uuid=>create_uuid_x16_static( ).
  lv_genre_litfic     = cl_system_uuid=>create_uuid_x16_static( ).
  lv_genre_mystery    = cl_system_uuid=>create_uuid_x16_static( ).
  lv_genre_magicreal  = cl_system_uuid=>create_uuid_x16_static( ).
  lv_genre_nonfiction = cl_system_uuid=>create_uuid_x16_static( ).

  GET TIME STAMP FIELD lv_now.

  lt_author = VALUE #(
    ( client = sy-mandt id = lv_author_le_guin  name = 'Ursula K. Le Guin'         nationality = 'United States' )
    ( client = sy-mandt id = lv_author_murakami name = 'Haruki Murakami'           nationality = 'Japan' )
    ( client = sy-mandt id = lv_author_adichie  name = 'Chimamanda Ngozi Adichie'  nationality = 'Nigeria' )
    ( client = sy-mandt id = lv_author_marquez  name = 'Gabriel Garcia Marquez'    nationality = 'Colombia' )
    ( client = sy-mandt id = lv_author_christie name = 'Agatha Christie'           nationality = 'United Kingdom' )
  ).

  lt_genre = VALUE #(
    ( client = sy-mandt id = lv_genre_scifi      description = 'Science Fiction' )
    ( client = sy-mandt id = lv_genre_litfic     description = 'Literary Fiction' )
    ( client = sy-mandt id = lv_genre_mystery    description = 'Mystery' )
    ( client = sy-mandt id = lv_genre_magicreal  description = 'Magical Realism' )
    ( client = sy-mandt id = lv_genre_nonfiction description = 'Non-Fiction' )
  ).

  lt_book = VALUE #(
    ( client = sy-mandt id = cl_system_uuid=>create_uuid_x16_static( )
      title = 'The Left Hand of Darkness' publish_date = '19690101' isbn = '978-0-441-47812-5'
      author_id = lv_author_le_guin  genre_id = lv_genre_scifi      last_changed_at = lv_now )
    ( client = sy-mandt id = cl_system_uuid=>create_uuid_x16_static( )
      title = 'Norwegian Wood' publish_date = '19870904' isbn = '978-0-375-70402-2'
      author_id = lv_author_murakami genre_id = lv_genre_litfic     last_changed_at = lv_now )
    ( client = sy-mandt id = cl_system_uuid=>create_uuid_x16_static( )
      title = 'Half of a Yellow Sun' publish_date = '20060101' isbn = '978-0-00-720028-3'
      author_id = lv_author_adichie  genre_id = lv_genre_litfic     last_changed_at = lv_now )
    ( client = sy-mandt id = cl_system_uuid=>create_uuid_x16_static( )
      title = 'One Hundred Years of Solitude' publish_date = '19670530' isbn = '978-0-06-088328-7'
      author_id = lv_author_marquez  genre_id = lv_genre_magicreal  last_changed_at = lv_now )
    ( client = sy-mandt id = cl_system_uuid=>create_uuid_x16_static( )
      title = 'And Then There Were None' publish_date = '19391106' isbn = '978-0-06-207348-8'
      author_id = lv_author_christie genre_id = lv_genre_mystery    last_changed_at = lv_now )
  ).

  MODIFY zlib_author FROM TABLE lt_author.
  IF sy-subrc = 0.
    WRITE: / |Inserted { lines( lt_author ) } authors|.
  ELSE.
    WRITE: / 'Author insert failed'.
  ENDIF.

  MODIFY zlib_genre FROM TABLE lt_genre.
  IF sy-subrc = 0.
    WRITE: / |Inserted { lines( lt_genre ) } genres|.
  ELSE.
    WRITE: / 'Genre insert failed'.
  ENDIF.

  MODIFY zlib_book FROM TABLE lt_book.
  IF sy-subrc = 0.
    WRITE: / |Inserted { lines( lt_book ) } books|.
  ELSE.
    WRITE: / 'Book insert failed'.
  ENDIF.

  COMMIT WORK.
ENDFORM.
