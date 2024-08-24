# frozen_string_literal: true

def fixture_file_path(filename)
  Rails.root.join('spec/fixtures', filename).to_s
end

def read_file_fixture(filename)
  file_path = fixture_file_path(filename)
  file_extension = File.extname(filename)

  case file_extension
  when '.xlsx'
    Roo::Excelx.new(file_path)
  when '.json'
    JSON.parse(File.read(file_path)).tap do |parsed|
      return parsed.with_indifferent_access if parsed.is_a?(Hash)
    end
  else
    File.read(file_path)
  end
end
