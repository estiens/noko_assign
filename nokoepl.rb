require 'rubygems'
require 'nokogiri'
require "rest-client"
require 'colorize'
require 'erb'
require 'CGI'
require 'open-uri'

#scraping team info# 

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


class NewsHeadlines
  attr_accessor :headline, :link, :keyword

  def initialize (headline,link,keyword)
    @headline=headline
    @link=link
    @keyword=keyword
  end
end


class Database
  attr_accessor :team_array, :headlines_array

  def initialize
    @team_array=[]
    @headlines_array=[]
  end

  def convert_erb_html_file
    template_file = File.open("index.html.erb", 'r').read
    erb = ERB.new(template_file)
    File.open("index.html", 'w+') { |file| file.write(erb.result(binding)) }
  end

end

@db=Database.new

#creating teams
for x in (0..19)
    @db.team_array<<Team.new(teams[x],wins[x+1],losses[x+1], draw[x+1], goals_for[x+1], goals_away[x+1], status="normal")
end


#scraping headlines#
NEWS_HEADLINES_URL="http://www.newsnow.co.uk/h/Sport/Football/Premier+League"
page = Nokogiri::HTML(RestClient.get(NEWS_HEADLINES_URL))
mainnews = page.css("#newsfeed_1 div a")[0..4]
mainnews.each do |link|
  @db.headlines_array<<NewsHeadlines.new(link.text, "http://www.newsnow.co.uk#{link.attribute('href').to_s}", "mainheadlines") 
end 


#scraping injuries#
INJURY_HEADLINE_URL="http://injuryleague.com/"
page = Nokogiri::HTML(RestClient.get(INJURY_HEADLINE_URL))
injurynews = page.css("div.box-post-content h2 a")[0..4]
injurynews.each do |link|
  @db.headlines_array<<NewsHeadlines.new(CGI.unescape(link.text), link.attribute('href').to_s,"injuries")
end 

#scraping fantasy news
FANTASY_HEADLINE_URL="http://www.fantasyfootballscout.co.uk/"
page = Nokogiri::HTML(open(FANTASY_HEADLINE_URL))
page.encoding = 'utf-8'
fantasynews = page.css("h3.entry-title.index-entry-title a")[0..4]
fantasynews.each do |link|
  @db.headlines_array<<NewsHeadlines.new(link.text, link.attribute('href').to_s,"fantasynews")
end 

#scraping all teams, need to add rescue clause if news is empty!#

# BASE_URL="https://www.google.com/search?hl=en&gl=ca&tbm=nws&authuser=0&q="
# @db.team_array.each do |team|
#   team_url=BASE_URL+CGI.escape(team.name)+"+fc"
#   puts "now getting info from #{team_url}"
#   page = Nokogiri::HTML(RestClient.get(team_url))
#   news = page.css("h3.r a.l")[0..4]
#   news.each do |link|
#     @db.headlines_array<<NewsHeadlines.new(news.text, link.attribute('href').to_s, team.name.chop.downcase)
#   end
# end

# @db.headlines_array.each do |x| 
#   if x.keyword == "mainheadlines"
#   puts "#{x.headline} is coded as MAIN"
#   elsif x.keyword == "injuries"
#   puts "#{x.headline} is coded as INJURIES"
#   end
# end


@db.team_array.sort_by! {|x| [-x.points, -x.goal_difference, -x.goals_for]}
for x in (0..@db.team_array.length-1)
  @db.team_array[x].status="champions" if x > -1 && x < 4
  @db.team_array[x].status="relegation" if x > 16
end


@db.team_array.each do |x|
   color="blue"
   case x.status
       when "relegation"
         color="red"
       when "champions"
         color="green"
   end

  
end

@db.convert_erb_html_file
puts "All completed."

