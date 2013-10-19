require 'nokogiri'
require 'open-uri'
require 'sqlite3'
require 'erb'
require 'pry'

URL = 'http://www.adk46er.org/peaks/index.html'
require_relative './mountain.rb'
require_relative './scrape.rb'