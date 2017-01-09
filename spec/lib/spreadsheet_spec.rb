require 'spreadsheet'

describe Spreadsheet do
	before do
		@path = "./results.xlsx"
		@results_sheet = "Results"
	end
	
	describe ".open" do
		it "returns a workbook object from a path" do
			wb = Spreadsheet.open(@path)
			expect(wb).to be_kind_of(RubyXL::Workbook)
		end
	end

	describe ".to_a" do
		it "returns an array of rows for a RubyXL::Workbook sheet" do
			wb = Spreadsheet.open(@path)
			retval = Spreadsheet.to_a(wb,@results_sheet)
			expect(retval).to be_kind_of(Array)
		end
	end

end