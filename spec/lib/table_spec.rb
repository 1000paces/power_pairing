require "table"
require "spreadsheet"
require 'team'

describe Table do
	before do
		@path = "./results.xlsx"
		@table_sheet = "Table"
		@results_sheet = "Results"
	end

	describe ".to_h" do
		it "returns a hash from an array, using the position as the key" do
			wb = Spreadsheet.open(@path)
			raw_table = Spreadsheet.to_a(wb, @table_sheet)
			table = Table.to_h(raw_table)
			expect(table).to be_kind_of(Hash)
			expect(table.size).to eq(16) 
		end
	end

end