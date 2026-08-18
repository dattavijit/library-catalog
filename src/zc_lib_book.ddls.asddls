@EndUserText.label: 'Book'

@Metadata.ignorePropagatedAnnotations: true

@UI.headerInfo: { typeName: 'Book',
                  typeNamePlural: 'Books',
                  title: { type: #STANDARD, value: 'title' } }

define root view entity ZC_LIB_BOOK
  provider contract transactional_query
  as projection on ZI_LIB_BOOK

{
      @EndUserText.label: 'Book ID'
      @UI.facet: [ { id: 'BookDetails',
                     type: #FIELDGROUP_REFERENCE,
                     targetQualifier: 'BookDetails',
                     label: 'Book Details',
                     position: 10 } ]
      @UI.fieldGroup: [ { qualifier: 'BookDetails', position: 10 } ]
      @UI.lineItem: [ { position: 10, importance: #HIGH } ]
  key id,

      @EndUserText.label: 'Title'
      @UI.fieldGroup: [ { qualifier: 'BookDetails', position: 20 } ]
      @UI.lineItem: [ { position: 20, importance: #HIGH } ]
      @UI.selectionField: [ { position: 10 } ]
      title,

      @EndUserText.label: 'Publish Date'
      @UI.fieldGroup: [ { qualifier: 'BookDetails', position: 30 } ]
      @UI.lineItem: [ { position: 30, importance: #MEDIUM } ]
      publish_date,

      @EndUserText.label: 'ISBN'
      @UI.fieldGroup: [ { qualifier: 'BookDetails', position: 40 } ]
      @UI.lineItem: [ { position: 40, importance: #MEDIUM } ]
      isbn,

      @EndUserText.label: 'Author ID'
      @UI.fieldGroup: [ { qualifier: 'BookDetails', position: 70 } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_LIB_AUTHOR', element: 'Id' }, useForValidation: true }]
      author_id,

      @EndUserText.label: 'Genre ID'
      @UI.fieldGroup: [ { qualifier: 'BookDetails', position: 80 } ]
      @Consumption.valueHelpDefinition: [{ entity: { name: 'ZC_LIB_GENRE', element: 'Id' }, useForValidation: true }]
      genre_id,

      @EndUserText.label: 'Author'
      @UI.fieldGroup: [ { qualifier: 'BookDetails', position: 50 } ]
      @UI.lineItem: [ { position: 50, importance: #HIGH } ]
      @UI.selectionField: [ { position: 20 } ]
      _Author.Name       as author_name,

      @EndUserText.label: 'Genre'
      @UI.fieldGroup: [ { qualifier: 'BookDetails', position: 60 } ]
      @UI.lineItem: [ { position: 60, importance: #HIGH } ]
      @UI.selectionField: [ { position: 30 } ]
      _Genre.Description as genre_description
}
