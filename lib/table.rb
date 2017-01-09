class Table

=begin
	Returns a Hash using the position as the key and a Team object as the value
=end
	def self.to_h(raw_table)
		table = Hash.new
		raw_table.each_with_index do |row, index| 
			x = row.split(",")
			next if x[0] == "POS"
			x.each_slice(10) {|position, label, p, won, drew, lost, gf, ga, gd, pts| table[position.to_i] = Team.new(position, label, won, drew, lost, gf, ga)}	
		end
		return table
	end

	def self.print(table, games)
		retval = ""
		table.each do |key, value|
			retval += "#{key}:#{value.label} \t w#{value.won}d#{value.drew}l#{value.lost}\th#{value.home_games} \t\tAVAILABLE: #{value.unmatched(games,table)}\n"
		end
		return retval
	end

end