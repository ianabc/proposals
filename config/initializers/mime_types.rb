# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf


Mime::Type.register "application/pdf", :pdf, ['text/pdf'], ['pdf']
Mime::Type.register "booklet/pdf", :pdf, ['text/pdf'], ['pdf']

# Add new mime types for use in respond_to blocks:
Mime::Type.register "application/vnd.ms-excel", :xls
Mime::Type.register "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", :xlsx

