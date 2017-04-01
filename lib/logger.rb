module Logger

	def self.info(msg)
		return nil unless $verbose
		puts msg
	end
end