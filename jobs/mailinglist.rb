#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
require 'mechanize'
require 'date'

# Sweet mother of pearl, MailMan gives you NO ID's or Classes to work with.
# All data scrapes are going to be prone to failure if this DOM ever changes.
# I dont like it but i'll deal with what i can when i can.


max_length = 7
month_and_year = Date.today.strftime("%Y-%B")
url = "https://lists.ubuntu.com/archives/juju/#{month_and_year}/thread.html"

SCHEDULER.every '30m', :first_in => 0 do |job|
  mechanize = Mechanize.new
  page = mechanize.get(url)
  posts = {}
  page.search('li').each do |post|
    # Skip the header, we ALWAYS match it.
    next if post.at('i').nil?

    author = post.at('i').text.strip
    author_key = author.gsub!(' ','_')
    if posts.has_key?(author_key)
        posts[author_key] += 1
    else
        posts[author_key] = 1
    end

  end

  contestants = Array.new
  posts = posts.sort_by {|k,v| v}.reverse

  posts.each do |contestant|
    next if contestants.count >= max_length
    contestants.push({label: contestant[0][0, 20].gsub('_', ' '), value: contestant[1]}) 
  end

  send_event('ml_highscore', { items: contestants })
end
