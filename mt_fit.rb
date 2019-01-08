#!/usr/bin/ruby

require 'pp'
require 'csv'

# script.rb (-fm) input.csv output => output_customer.csv, output_papers.csv
# 普通に実行するとutl-8で出力するが，「-fm」を最初につけるとShift_JISで出力
output_option = {}
# if (ARGV[0] == "-fm")
# 	output_option = {:encoding => "Shift_JIS"}
# 	ARGV.shift
# end

# '番号', '山名', '別名', '山頂名', '読み', '都道府県', '標高', '所在地', '地図', '緯度', '経度', '三角点名等', '備考'
# 'リスト番号', '山名', '読み', '都道府県', '標高', '山系', '備考'
# 'リスト番号', '山名', '読み', '都道府県', '標高', '百名山・他', '備考'
# 'リスト番号', '山名', '読み', '都道府県', '標高', '花', '備考
csvFileHash = {
	mtAll: 'mountains',
	mt100: '100',
	mt100New: '100-new',
	mtFlw: 'hana',
	mtFlwNew: 'hana-new'
}

# inputFile = ARGV.shift
outputFile = ARGV.shift

csv_r_opton = {
	headers:	true,
# 	encoding:	"Shift_JIS:UTF-8",
	encoding:	"UTF-8",
	return_headers:	false,
	skip_blanks: true
}

csvDataHash = Hash.new
csvFileHash.each do |key, value|
	dataTable = CSV.read( value + '.csv', csv_r_opton)
# 	pp dataTable.to_a
	csvDataHash[key] = dataTable
end #each

def conv2ary(str)
	return str.split(/\s+,\s+/)
end

def consist_prefs_str(str1, str2, flag)
	str1_ary = conv2ary(str1)
	str2_ary = conv2ary(str2)
	return true
end

def sameMt(str)
	return str.gsub(/[岳山]$/, '')
end


# 比較開始
mtAllData = csvDataHash[:mtAll]

csvDataHash.each do |key, value|
	if key != :mtAll
		matchAry = [['番号', '番号all']]
		sgstAry = [['番号', '番号all']]
		nohitAry = [['番号', '番号all']]
		
		value.each do |row|
			mt100Name = row['山名']
			mt100PprefsAry = conv2ary(row['都道府県'])
			mt100Alt = row['標高']
			matchedAll = nil
			mtAllData.each do |row_all|
				if (row_all['標高'].to_i - row['標高'].to_i).abs < 10
					if row_all['山名'] == row['山名'] || row_all['別名'] == row['山名']
						matchedAll = row_all['番号']
						matchAry.push([row['リスト番号'], matchedAll])
					elsif sameMt(row_all['山名']) == sameMt(row['山名']) || sameMt(row_all['別名']) == sameMt(row['山名'])
						matchedAll = row_all['番号']
						sgstAry.push([row['リスト番号'], matchedAll])
						matchAry.push([row['リスト番号'], matchedAll])
					end
				end
			end
			if matchedAll == nil
				nohitAry.push([row['リスト番号'], ''])
				matchAry.push([row['リスト番号'], ''])
			end
		# pp row
		end #each
		outputFile = csvFileHash[key] + '_match.csv'
		CSV.open(outputFile,"wb", output_option) do |outputCSV|
			matchAry.each do |eachRow|
				outputCSV << eachRow
			end #each
		end #
		
		pp sgstAry, nohitAry
	end #if
end #each


# 