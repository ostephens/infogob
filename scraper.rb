require 'scraperwiki'
require 'nokogiri'
require 'uri'
require 'open-uri'

class District
    def initialize(uri)
        @uri = uri
        @officials = Array.new()
    end

    attr_reader :uri
    attr_accessor :name, :officials

    def getOfficials
        begin
            page = Nokogiri::HTML(open(@uri))
            page.xpath('//table[@id="ctl00_ContentPlaceHolder1_cab_ubigeo1_gvAutUbigeo"]/tr/td[2]/a').each do |o|
                  official_name = o.inner_text
                  official_uri = o.attributes['href']
                  @officials.push(Official.new(official_name,official_uri))
            end
          rescue
            puts "Error while getting " + @uri
          end
    end
end

class Official
    def initialize(name,uri)
        @uri = uri
        @name = name
    end

    attr_reader :name, :uri
end

scrape_url = "http://infogob.com.pe/Localidad/ubigeo.aspx?IdUbigeo=010102&IdLocalidad=84&IdTab=0"
d = District.new(scrape_url)
d.getOfficials
d.officials.each do |o|
    data = {
        name: o.name.to_s,
        uri: o.uri.to_s
    }
    ScraperWiki::save_sqlite([], data)
end

