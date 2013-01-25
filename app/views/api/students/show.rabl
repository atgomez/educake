object @student
attributes :id, :teacher_id, :first_name, :last_name
node(:birthday) { |s| s.birthday_string }
node(:gender) { |s| s.gender_string }
node(:photo_url) { |s| s.photo_file_name.blank? ? "" : s.photo_url }
