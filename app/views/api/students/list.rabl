object false
node(:total_pages) { @students.total_pages }
node(:current_page) { @current_page }

child(@students => :data) do |s|
  attributes :id, :teacher_id, :first_name, :last_name
  node(:birthday) { |s| s.birthday_string }
  node(:gender) { |s| s.gender_string }
  node(:photo_url) { |s| s.photo_file_name.blank? ? "" : s.photo_url }
end
