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
#百: 'リスト番号', '山名', '読み', '都道府県', '標高', '山系', '備考'
#新 'リスト番号', '山名', '読み', '都道府県', '標高', '百名山・他', '備考'
#花 'リスト番号', '山名', '読み', '都道府県', '標高', '花', '備考'

csvFileHash = {
# 	mtAll: 'mountains',
	mt100: '100',
	mt100New: '100-new',
	mtFlw: 'hana',
	mtFlwNew: 'hana-new',
}

headersHash = {
	mt100: [:番号_h, :山名, :読み, :都道府県, :標高, :山系_h, :備考_h],
	mt100New: [:番号_n, :山名, :読み, :都道府県, :標高, :百名山他_n, :備考_n],
	mtFlw: [:番号_f, :山名, :読み, :都道府県, :標高, :花_f, :備考_f],
	mtFlwNew: [:番号_fn, :山名, :読み, :都道府県, :標高, :花_fn, :備考_fn],
}
commonColmAry = [:山名, :読み, :都道府県, :標高]

# joinedHds = headersHash.values.flatten.uniq
# pp joinedHds
# exit
mergedHeaders = [:番号_h, :番号_n, :番号_f, :番号_fn, :山名, :読み, :都道府県, :標高, :花_f, :花_fn, :山系_h, :百名山・他_n, :備考_h, :備考_n, :備考_f, :備考_fn]
mergedHash = Hash.new('')
mergedHeaders.each do |colm|
	mergedHash[colm] = ''
end
# mergedHash : {:番号_h=>"", :番号_n=>"", :番号_f=>"", :番号_fn=>"", :山名=>"", :読み=>"", :都道府県=>"", :標高=>"", :花_f=>"", :花_fn=>"", :山系_h=>"", :百名山・他_n=>"", :備考_h=>"", :備考_n=>"", :備考_f=>"", :備考_fn=>""}

outputFile = ARGV.shift

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

csv_r_opton = {
# 	headers:	false,
# 	encoding:	"Shift_JIS:UTF-8",
	encoding:	"UTF-8",
	return_headers:	false,
	skip_blanks: true
}

# データ収納用
mergedHashRows = []

csvDataHash = Hash.new
# outputCsvAry = [mergedHeaders]
csvFileHash.each do |key, value|
	csv_r_opton[:headers] = headersHash[key]
	dataTable = CSV.read( value + '.csv', csv_r_opton)
	dataTable.each do |row|
# 各行収納用のHash
		mergedHash_1 = mergedHash.dup
# 既存行の変更だったか
		setRowFlag = false
# 収納したデータを1行ずつチェック
		mergedHashRows.each do |mRow|
# キーとなる列での同一性判断
			if (mRow[:山名] == row[:山名] || sameMt(mRow[:山名]) == sameMt(row[:山名]) ) && mRow[:標高] == row[:標高]
# p mRow
# p row
# 必要な列のデータを付け加える
				row.each do |header, value|
					if !commonColmAry.include?(header)
						mRow[header] = value
					end #if
				end #each
				setRowFlag = true
				break
			end
		end
		if setRowFlag == false
			mergedHeaders.each do |colm|
				mergedHash_1[colm] = row[colm]
			end #each
			mergedHashRows.push(mergedHash_1)
		end #if
	end
# 	pp dataTable.to_a
	csvDataHash[key] = dataTable
end #each



CSV.open('merged.csv',"wb", output_option) do |outputCSV|
	mergedHashRows.each do |row|
		outputCSV << row.values
	end #each
end

# 