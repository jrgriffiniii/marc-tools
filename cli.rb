require 'marc'
require 'thor'
require 'pry-byebug'

class MarcCli < Thor
  desc "compare BASE_FILE_PATH to SECOND_FILE_PATH", "Compares two MARC record batches"
  def compare(u_marc_file_path, v_marc_file_path)
    u_reader = MARC::Reader.new(u_marc_file_path, external_encoding: "UTF-8")
    v_reader = MARC::Reader.new(v_marc_file_path, external_encoding: "UTF-8")
    u_records = u_reader.to_a
    v_records = v_reader.to_a

    u_titles = u_records.to_a.map { |record| record['856']['u'] }
    v_titles = v_records.to_a.map { |record| record['856']['u'] }
    intersect = []
    uniq_to_u = []
    uniq_to_v = []

    u_records.each do |record|
      if v_titles.include?(record['856']['u'])
        intersect << record
      else
        uniq_to_u << record
      end
    end
    v_records.each do |record|
      unless u_titles.include?(record['856']['u'])
        uniq_to_v << record
      end
    end

    writer = MARC::Writer.new('output/intersection.mrc')
    intersect.each do |intersect_record|
      writer.write(intersect_record)
    end
    writer.close()

    writer = MARC::Writer.new('output/unique_to_base.mrc')
    uniq_to_u.each do |uniq_record|
      writer.write(uniq_record)
    end
    writer.close()

    writer = MARC::Writer.new('output/unique_to_variant.mrc')
    uniq_to_v.each do |uniq_record|
      writer.write(uniq_record)
    end
    writer.close()
  end
end

MarcCli.start(ARGV)
