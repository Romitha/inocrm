json.file_name @document_attachment.file_path.file.try(:filename)
json.file_path polymorphic_path([@document_attachment.attachable, @document_attachment], "document_attachment[downloadable]" => true)
json.downloadable @document_attachment.downloadable ? true : false
if @document_attachment.downloadable
	json.document_attachment_file_path_url @document_attachment.file_path.url
end