https://stackoverflow.com/questions/3321011/parsing-xls-and-xlsx-ms-excel-files-with-ruby

gem "roo", "~> 2.7.0"
gem "roo-xls"

require 'roo'
require 'roo-xls'


workbook = Roo::Spreadsheet.open('/home/user/data_grib1.xls')
0.upto(workbook.sheets.count-1) do |sheet|
	#Taken First Spreadsheet
	workbook.default_sheet = workbook.sheets[sheet]

	#Excel Header Store on hash
	headers = Hash.new

	#Retrieve Excel Header Info
	workbook.row(1).each_with_index {|header,index|  headers[header] = index}

	ticket_title,scenario_title,case_id,ticket_id,expected = "","","","",""
	pages,elements,actions,inputs = [],[],[],[]

	((workbook.first_row + 1)..workbook.last_row).each do |row|
	   ticket_title = workbook.row(row)[headers['Ticket Title']] if workbook.row(row)[headers['Ticket Title']]!=nil
	   scenario_title = workbook.row(row)[headers['Scenario Title']] if workbook.row(row)[headers['Scenario Title']]!=nil
	   case_id = workbook.row(row)[headers['Case Id']] if workbook.row(row)[headers['Case Id']]!=nil
	   ticket_id = workbook.row(row)[headers['Ticket Id']] if workbook.row(row)[headers['Ticket Id']]!=nil
	   pages.push(workbook.row(row)[headers['Page']]) if workbook.row(row)[headers['Page']]!=nil
	   elements.push(workbook.row(row)[headers['Element']]) if workbook.row(row)[headers['Element']]!=nil 
	   actions.push(workbook.row(row)[headers['Action']]) if workbook.row(row)[headers['Action']]!=nil
	   inputs.push(workbook.row(row)[headers['Input Data']]) 
	 end  
	  
	  dir_path = "/home/user/features"
	  Dir.mkdir(dir_path) unless File.directory?(dir_path)
	  @page_object=[]

	  file = File.open("#{dir_path}/#{ticket_title.gsub(/[ ]/,'_').downcase}spec.rb","a+")
	  file.write "require 'spec_helper'\n\n"
	  file.write "feature '#{ticket_id} : #{ticket_title}',\n\ttype: :feature,js:true do\n\n"
	  file.write "#Helper Module Include Here\n"
	  file.write "include BasicSettings\n\n"
	  file.write "#Helper Module Include Here\n"
	  pages.each do |page|
	    @page_object.push(page.downcase.split('::').first)
	    file.write  "let!(:#{page.downcase.split('::').first}) { #{page}.new }\n"
	  end
	  file.write  "\n"
	  file.write "scenario '#{case_id} : #{scenario_title}' do\n"
	  elements.each_with_index do |element,index|
	    if inputs[index]==nil
	      file.write "\t#{@page_object[0]}.#{element}.#{actions[index]}\n" 
	    else
	      file.write "\t#{@page_object[0]}.#{element}.#{actions[index]} '#{inputs[index]}'\n" 
	    end
	  end
	  file.write  "\texpect(#{@page_object[0]}).to have_text ""\n"
	  file.write "end\n"
	  file.close
 end
