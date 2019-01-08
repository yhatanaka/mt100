#!/usr/bin/ruby

require 'pp'
require 'csv'
require 'nokogiri'

inputFile = ARGV.shift
outputFile = ARGV.shift

fileHash = {
	mtAll: ['mountains',''],
	mt100: ['100',''],
	mt100New: ['100-new',''],
	mtFlw: ['hana','#mw-content-text > div > table:nth-child(6) > tbody > tr > td > table > tbody > tr'],
	mtFlwNew: ['hana-new','#mw-content-text > div > table:nth-child(7) > tbody > tr > td > table > tbody > tr']
}

funcHash = Hash.new

# 全角含めスペースを削除
def strip_all_space(str)
	return str.gsub(/(^[[:space:]]+)|([[:space:]]+$)/, '')
end

# 表示できる文字があるか
def text_is_not_empty?(str)
	if str && str != '' && /\S/ =~ str
		return true
	else
		return false
	end
end

# 子ノードごとに文字をarrayに
def multiVarColm(node)
	varAry = Array.new
	node.children.each do |eachVar|
		if text_is_not_empty?(eachVar.text )
			varAry.push(strip_all_space(eachVar.text))
		end
	end
	return varAry
end #def


# 国土交通省
def mtAll(html_obj, dummy)
	mountains = html_obj.css('table tbody tr')
	dataCsvAry = Array.new
	mt_count = 1
	mountains.each do |mts|
		colmAry = Array.new
		colms = mts.css('td')
		if colms[0]
# 番号
			colmAry.push(mt_count)
			mt_count = mt_count + 1
			summit_name = ''
			other_name = ''
			mt_name = strip_all_space(colms[0].css('a').text)
			if /^([^<>]+)<(.+)>/ =~ mt_name
				summit_name = $2
				mt_name = $1
			elsif /^([^（）]+)（(.+)）/ =~ mt_name
				other_name = $2
				mt_name = $1
			end #if
# 山名
			colmAry.push(strip_all_space(mt_name))
# 別名
			colmAry.push(strip_all_space(other_name))
# 山頂名
			colmAry.push(strip_all_space(summit_name))
# 読み
			colmAry.push(strip_all_space(colms[0].child.text))
# 都道府県
			prefs = strip_all_space(colms[1].text)
			prefAry = prefs.split(' ')
			prefs_txt = prefAry.join(', ')
			colmAry.push(prefs_txt)
# 標高
			colmAry.push(strip_all_space(colms[3].text).gsub(/m/, ''))
# 所在地
			colmAry.push(strip_all_space(colms[2].text))
# 地図
			colmAry.push(strip_all_space(colms[0].css('a').attribute('href').value))
# 緯度・経度
			latlong = colms[4].inner_html
			latlongAry = latlong.split('<br>')
# 緯度
			colmAry.push(strip_all_space(latlongAry[0]))
# 経度
			colmAry.push(strip_all_space(latlongAry[1]))
# 三角点名等
			colmAry.push(strip_all_space(colms[5].text))
# 備考
			colmAry.push(strip_all_space(colms[6].text))
		end #if
		dataCsvAry.push(colmAry)
	end #do
	dataCsvAry[0] = ['番号','山名','別名','山頂名','読み','都道府県','標高','所在地','地図','緯度','経度','三角点名等','備考']
	return dataCsvAry
end #def
funcHash[:mtAll] = method(:mtAll)

# wikipedia 百名山
def mt100(html_obj, dummy)
	mountains = html_obj.css('#mw-content-text > div > table.sortable > tbody > tr')
	dataCsvAry = Array.new
	mountains.each do |mts|
		colmAry = Array.new
		colms = mts.css('td')
		if colms[0]
# 番号
			colmAry.push(strip_all_space(colms[0].text))
# 山名
			colmAry.push(strip_all_space(colms[1].text))
# 読み
			colmAry.push(strip_all_space(colms[2].text))

# 都道府県
			multiVar = multiVarColm(colms[5])
			colmAry.push(multiVar.join(', '))

# 標高
			colmAry.push(strip_all_space(colms[3].text.gsub(/,/, '')))
# 山系
			colmAry.push(strip_all_space(colms[4].text))

# 備考
			multiVar = multiVarColm(colms[6])
			colmAry.push(multiVar.join("\n"))

		end #if
		dataCsvAry.push(colmAry)
	end #do
	dataCsvAry[0] = ['リスト番号','山名','読み','都道府県','標高','山系','備考']
	return dataCsvAry
end #def
funcHash[:mt100] = method(:mt100)

def mtFlw(html_obj, css)
	mountains = html_obj.css(css)
	dataCsvAry = Array.new
	mountains.each do |mts|
		colmAry = Array.new
		colms = mts.css('td')
		if colms[0]
# 番号
			colmAry.push(strip_all_space(colms[0].text))
# 山名
			multiVar = multiVarColm(colms[2])
			colmAry.push(multiVar[0])
# 読み
			colmAry.push(multiVar[1])

# 県，花
# 県
			varAry1 = Array.new
			varAry2 = Array.new
			multiVar = multiVarColm(colms[4])
			multiVar.each do |preforflw|
				if /\p{katakana}/ =~ preforflw # 長音記号は含まれない
					varAry2.push(preforflw)
				else
					varAry1.push(preforflw)				
				end
			end	
			colmAry.push(varAry1.join(', '))
# 標高
			colmAry.push(strip_all_space(colms[3].text).gsub(/[m,]/, ''))
# 花
			colmAry.push(varAry2[0])
# 備考
			multiVar = multiVarColm(colms[7])
			colmAry.push(multiVar.join("\n"))
		end #if
		dataCsvAry.push(colmAry)
	end #do
	dataCsvAry[0] = ['リスト番号','山名','読み','都道府県','標高','花','備考']
	return dataCsvAry
end #def
funcHash[:mtFlw] = method(:mtFlw)
funcHash[:mtFlwNew] = method(:mtFlw)

def mt100New(html_obj, dummy)
	mountains = html_obj.css('#mw-content-text > div > table.wikitable.sortable > tbody > tr')
	dataCsvAry = Array.new
	mountains.each do |mts|
		colmAry = Array.new
		colms = mts.css('td')
		if colms[0]
# 番号
			colmAry.push(strip_all_space(colms[0].text))
# 山名
			multiVar = multiVarColm(colms[2])
			colmAry.push(multiVar[1])
# 読み
			colmAry.push(multiVar[0])
# 県
			multiVar = multiVarColm(colms[3])
			colmAry.push(multiVar.join(', '))
# 標高
			colmAry.push(strip_all_space(colms[4].text).gsub(/[m,]/, ''))

# 百名山・他
			multiVar = multiVarColm(colms[6])
			colmAry.push(multiVar.join("\n"))
# 備考
			multiVar = multiVarColm(colms[7])
			colmAry.push(multiVar.join("\n"))
		end #if
		dataCsvAry.push(colmAry)
	end #do
	dataCsvAry[0] = ['リスト番号','山名','読み','都道府県','標高','百名山・他','備考']
	return dataCsvAry
end #def
funcHash[:mt100New] = method(:mt100New)

def call_func(fun, html_src, css)
	return fun.call(html_src, css)
end


begin

	fileHash.each do |key, value|
		src_html = value[0] + '.html'
		output_csv = value[0] + '.csv'
		rowHtmlContent = File.read(src_html)
		htmlObject = Nokogiri::HTML.parse(rowHtmlContent, nil, 'UTF-8')
		outputAry = call_func(funcHash[key], htmlObject, value[1])
		CSV.open(output_csv,"wb") do |outputCSV|
			outputAry.each do |eachRow|
				outputCSV << eachRow
			end #each
		end #
		pp outputAry
	end

# 主要な山（DBベース）
# 	outputAry = mtAll(htmlObject)
# 百名山
# 	outputAry = mt100(htmlObject)
# 花
# 	outputAry = hana(htmlObject, '#mw-content-text > div > table:nth-child(6) > tbody > tr > td > table > tbody > tr')
# 新百
# 	outputAry = shin_hyaku(htmlObject)
# 新花
# 	outputAry = hana(htmlObject, '#mw-content-text > div > table:nth-child(7) > tbody > tr > td > table > tbody > tr')

rescue SystemCallError => e
  puts %Q(class=[#{e.class}] message=[#{e.message}])
rescue IOError => e
  puts %Q(class=[#{e.class}] message=[#{e.message}])
end



# pp outputAry
exit
=begin
if outputFile then
    CSV.open(outputFile,"wb") do |outputCSV|
    	outputAry.each do |eachRow|
    		outputCSV << eachRow
    	end #each
    end #
elsif
    puts 'you can set outputFile as ARGV, '
end #if
=end
# 2