CLASS lhc_Book DEFINITION INHERITING FROM cl_abap_behavior_handler.

  PRIVATE SECTION.

    METHODS validateIsbn FOR VALIDATE ON SAVE
      IMPORTING keys FOR Book~validateIsbn.

ENDCLASS.


CLASS lhc_Book IMPLEMENTATION.

**********************************************************************
* Validation: ISBN must be present, 10 or 13 digits (hyphens/spaces
* allowed as entered), a 13-digit ISBN must start with 978 or 979,
* and must be unique across all books.
**********************************************************************
  METHOD validateIsbn.

    READ ENTITIES OF zi_lib_book IN LOCAL MODE
      ENTITY Book
        FIELDS ( isbn )
        WITH CORRESPONDING #( keys )
      RESULT DATA(books).

    LOOP AT books INTO DATA(book).

      APPEND VALUE #( %tky        = book-%tky
                      %state_area = 'VALIDATE_ISBN' ) TO reported-book.

      " Work on a STRING copy, not the fixed-length CHAR20 field directly -
      " REPLACE/CONDENSE against an all-blank fixed-length field can loop
      " forever (REPLACE_INFINITE_LOOP) because the field keeps getting
      " re-padded with the very blanks being stripped.
      DATA(isbn_digits) = CONV string( book-isbn ).
      REPLACE ALL OCCURRENCES OF '-' IN isbn_digits WITH ''.
      CONDENSE isbn_digits NO-GAPS.

      IF isbn_digits IS INITIAL.
        APPEND VALUE #( %tky = book-%tky ) TO failed-book.
        APPEND VALUE #( %tky          = book-%tky
                        %state_area   = 'VALIDATE_ISBN'
                        %element-isbn = if_abap_behv=>mk-on
                        %msg          = new_message_with_text(
                                          severity = if_abap_behv_message=>severity-error
                                          text     = 'Please enter an ISBN' ) )
               TO reported-book.
        CONTINUE.
      ENDIF.

      IF NOT (     isbn_digits co '0123456789'
               AND ( strlen( isbn_digits ) = 10 OR strlen( isbn_digits ) = 13 ) ).
        APPEND VALUE #( %tky = book-%tky ) TO failed-book.
        APPEND VALUE #( %tky          = book-%tky
                        %state_area   = 'VALIDATE_ISBN'
                        %element-isbn = if_abap_behv=>mk-on
                        %msg          = new_message_with_text(
                                          severity = if_abap_behv_message=>severity-error
                                          text     = 'ISBN must be 10 or 13 digits (hyphens and spaces are fine)' ) )
               TO reported-book.
        CONTINUE.
      ENDIF.

      IF strlen( isbn_digits ) = 13 AND isbn_digits(3) <> '978' AND isbn_digits(3) <> '979'.
        APPEND VALUE #( %tky = book-%tky ) TO failed-book.
        APPEND VALUE #( %tky          = book-%tky
                        %state_area   = 'VALIDATE_ISBN'
                        %element-isbn = if_abap_behv=>mk-on
                        %msg          = new_message_with_text(
                                          severity = if_abap_behv_message=>severity-error
                                          text     = 'A 13-digit ISBN must start with 978 or 979' ) )
               TO reported-book.
        CONTINUE.
      ENDIF.

      SELECT id FROM zlib_book INTO TABLE @DATA(existing_books)
        WHERE isbn = @book-isbn AND id <> @book-%tky-id.

      IF existing_books IS NOT INITIAL.
        APPEND VALUE #( %tky = book-%tky ) TO failed-book.
        APPEND VALUE #( %tky          = book-%tky
                        %state_area   = 'VALIDATE_ISBN'
                        %element-isbn = if_abap_behv=>mk-on
                        %msg          = new_message_with_text(
                                          severity = if_abap_behv_message=>severity-error
                                          text     = |ISBN { book-isbn } is already used by another book| ) )
               TO reported-book.
      ENDIF.

    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
