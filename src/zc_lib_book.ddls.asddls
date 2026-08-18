@EndUserText.label: 'Book'
@UI.headerInfo: { typeName: 'Book', typeNamePlural: 'Books', title: { type: #STANDARD, value: 'title' } }
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_LIB_BOOK
  provider contract transactional_query
  as projection on ZI_LIB_BOOK
{
      @EndUserText.label: 'Book ID'
      @UI.facet: [{ id: 'BookDetails', type: #FIELDGROUP_REFERENCE, targetQualifier: 'BookDetails', label: 'Book Details', position: 10 }]
      @UI.lineItem: [{ position: 10, importance: #HIGH }]
      @UI.fieldGroup: [{ qualifier: 'BookDetails', position: 10 }]
  key id,

      @EndUserText.label: 'Title'
      @UI.lineItem: [{ position: 20, importance: #HIGH }]
      @UI.selectionField: [{ position: 10 }]
      @UI.fieldGroup: [{ qualifier: 'BookDetails', position: 20 }]
      title,

      @EndUserText.label: 'Publish Date'
      @UI.lineItem: [{ position: 30, importance: #MEDIUM }]
      @UI.fieldGroup: [{ qualifier: 'BookDetails', position: 30 }]
      publish_date,

      @EndUserText.label: 'ISBN'
      @UI.lineItem: [{ position: 40, importance: #MEDIUM }]
      @UI.fieldGroup: [{ qualifier: 'BookDetails', position: 40 }]
      isbn,

      @EndUserText.label: 'Author ID'
      @UI.fieldGroup: [{ qualifier: 'BookDetails', position: 70 }]
      author_id,

      @EndUserText.label: 'Genre ID'
      @UI.fieldGroup: [{ qualifier: 'BookDetails', position: 80 }]
      genre_id,

      @EndUserText.label: 'Author'
      @UI.lineItem: [{ position: 50, importance: #HIGH }]
      @UI.selectionField: [{ position: 20 }]
      @UI.fieldGroup: [{ qualifier: 'BookDetails', position: 50 }]
      _Author.Name        as author_name,

      @EndUserText.label: 'Genre'
      @UI.lineItem: [{ position: 60, importance: #HIGH }]
      @UI.selectionField: [{ position: 30 }]
      @UI.fieldGroup: [{ qualifier: 'BookDetails', position: 60 }]
      _Genre.Description  as genre_description
}
