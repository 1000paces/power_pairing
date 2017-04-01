require 'rubyXL'

module Spreadsheet

	def self.open(path)
		workbook = RubyXL::Parser.parse(path)
		return workbook
	end

	def self.to_a(workbook, sheet_name)
		worksheet = workbook[sheet_name]
		arry = []
		worksheet.each do |row|
			row_val = []
			next if row.nil? || row[1].nil? || row[1].value == ""
			row && row.cells.each do |cell|
				val = cell && cell.value
				val.strip! if val.kind_of?(String)
				row_val << val
			end
			arry << row_val.join(",") if row_val.any?
		end
		return arry
	end

	def self.write(workbook, sheet_name, pairings, table, games, season_start)
		worksheet = workbook[sheet_name]
		r = games.size+1 #get the index of the next row to insert in the spreadsheet
		pairings.each_with_index do |p,i|
			worksheet.insert_row(r)
			key1, key2 = p.split("|")
			team1 = table[key1.to_i]
			team2 = table[key2.to_i]
			subround = team1.scheduled(games, true)
			d = (season_start + (subround*7)).strftime("%m/%d/%Y")
			subround += 1
			worksheet.add_cell(r,0,"")
			worksheet.add_cell(r,1,"#{d}")
			worksheet.add_cell(r,2,"#{team1.label}")
			worksheet.add_cell(r,3,"")
			worksheet.add_cell(r,4,"")
			worksheet.add_cell(r,5,"#{team2.nil? ? 'BYE' : team2.label}")
			worksheet.add_cell(r,6,"#{subround}".to_i)
			worksheet.add_cell(r,7,"#{team1.position}".to_i)
			worksheet.add_cell(r,8,"#{team2.nil? ? '--' : team2.position}".to_i)
			r += 1
		end
	end

	def self.save(workbook, path)
		workbook.save(path)
	end

end