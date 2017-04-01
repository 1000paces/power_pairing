require "spec_helper"

describe Game do
	describe "attributes" do
		subject do
			Game.new(
				:game_number => 1,
				:game_date => "01/01/2017",
				:home_team => "Team1",
				:home_goals => 5,
				:away_goals => 2,
				:away_team => "Team2",
				:subround => 1,
				:p1 => 1,
				:p2 => 2
				)
		end
		it { is_expected.to respond_to(:game_number) }
		it { is_expected.to respond_to(:game_date) }
		it { is_expected.to respond_to(:home_team) }
		it { is_expected.to respond_to(:home_goals) }
		it { is_expected.to respond_to(:away_goals) }
		it { is_expected.to respond_to(:away_team) }
		it { is_expected.to respond_to(:subround) }
		it { is_expected.to respond_to(:p1) }
		it { is_expected.to respond_to(:p2) }
	end
end