require 'rubygems'
require 'nokogiri'
require "rest-client"
require 'colorize'

EPL_TABLE_URL= "http://www.premierleague.com/en-gb/matchday/league-table.html"

page = Nokogiri::HTML(RestClient.get(EPL_TABLE_URL))

teams= page.css(".leagueTable td.col-club").map(&:text)
wins = page.css(".col-w").map(&:text)
losses = page.css(".col-l").map(&:text)
draw = page.css(".col-d").map(&:text)
goals_for = page.css(".col-gf").map(&:text)
goals_away = page.css(".col-ga").map(&:text)

class Team
  attr_accessor :name, :wins, :losses, :draws, :goals_for, :goals_away, :status

def initialize(name,wins,losses,draws,goals_for,goals_away,status)
   @name=name
   @wins=wins.to_i
   @losses=losses.to_i
   @draws=draws.to_i
   @goals_for=goals_for.to_i
   @goals_away=goals_away.to_i
   @status=status
end

def points
   points=(3*wins)+ draws
end

def goal_difference
  goal_difference=(goals_for-goals_away)
end

end
@team=[]
for x in (0..19)
  # instancename="team#{x+1}"
  # puts instancename
  @team[x]=Team.new(teams[x],wins[x+1],losses[x+1], draw[x+1], goals_for[x+1], goals_away[x+1], status="normal")
  # puts "#{instancename} is #{instancename.name} with #{instancename.wins} wins #{instancename.losses} losses and #{instancename.draws} draws"
  # puts "#{instancename.name} has #{instancename.points.to_s} points"
end

 
@team.sort_by! {|x| [-x.points, -x.goal_difference, -x.goals_for]}
for x in (0..@team.length-1)
  @team[x].status="champions" if x > -1 && x < 4
  @team[x].status="relegation" if x > 16
end


@team.each do |x|
   color="blue"
   case x.status
       when "relegation"
         color="red"
       when "champions"
         color="green"
   end

  puts "#{x.name} has #{x.points} points and a goal difference of #{x.goal_difference} and a status of #{x.status}".send color
end


