require 'csv'

puts "- Cleaning DB"
Record.destroy_all

puts "- Creating records from csv..."
CSV.foreach( File.dirname(__FILE__) + '/fixtures/markers.csv', headers: :first_row, header_converters: :symbol) do |row|
   Record.create!(row.to_h)
   print '.'
end

puts "(#{Record.count})"

puts "- Adding ST_Point to records"

AddSTPointToRecordService.new.call

puts "- Done!"
