#================================
#nokogiri:
#================================
require 'nokogiri'
require 'open-uri'
require 'mechanize'

class AutoGeneratingPOM
  def create_pom_file page_name,page_url
    agent = Mechanize.new
    document = agent.get(page_url);

    #================================
    #   Mechanize ---- Login
    #================================
    document.form['user[login]'] = "testadmin"
    document.form['user[password]'] = "9994813212.It"
    document.form.submit

    document = agent.get(page_url);

    @pom_idendifier = []
    @elements = []

    #All the elements id and class stroed on array @pom_idendifier
    ['input','link','a'].each do |elements|
       @pom_idendifier.push(document.css(elements).map(&:attributes).select{|i| i.keys.include?("class")||i.keys.include?("id")})
       @pom_idendifier.reject!(&:empty?)
    end

    #All the elements are stored in to on hash @elements
    @pom_idendifier.each do |i|
       i.each do |j|
         j["id"]==nil ? @elements.push({j["class"].name=>j["class"].value}) : @elements.push({j["id"].name=>j["id"].value})
       end
    end

    #Create a pom file for particular folder
    dir_path = "spec/page_object"
    Dir.mkdir(dir_path) unless File.directory?(dir_path)

    #Page path
    Dir.mkdir("#{dir_path}/#{page_name}")
    Dir.mkdir("#{dir_path}/#{page_name}/pages")

    #Page Creation
    file = File.open("#{dir_path}/#{page_name}/pages/#{page_name}.rb","a+")
    file.write "module  #{page_name.capitalize}\n"
    file.write "\tclass #{page_name.capitalize}Page < SitePrism::Page\n"
    file.write "\tset_url '#{page_url}'\n"
    @elements.each do |element|
       if element["id"] != nil
    	    file.write "\telement :#{element["id"].gsub(/[-| ]/,'')},\t '#{'#'}#{element["id"]}' \n"
       else
    	    file.write "\telement :#{element["class"].gsub(/[-| ]/,'')},\t '#{'.'}#{element["class"].gsub(" ",'.')}' \n"
       end
    end
    file.write "end\n"
    file.write "end\n"
    file.close
  end
end
