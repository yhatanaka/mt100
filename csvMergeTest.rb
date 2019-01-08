#!/usr/bin/ruby

require 'pp'
require 'csv'

headers_1 = [:列1, :列2]
headers_2 = [:列1, :列3]
mergedHeaders = [:列1, :列2, :列3] 
mergedHash = Hash.new('')
mergedHeaders.each do |colm|
	mergedHash[colm] = ''
end
# mergedHash : {:列1=>"", :列2=>"", :列3=>""}

csv1_s = <<EOS
春, 4
夏, 7
秋, 10
EOS

csv2_s = <<EOS
春, イチゴ
夏, スイカ
秋, ナシ
EOS

csv_r_opton = {headers:  headers_1}
csv1 = CSV.parse(csv1_s, csv_r_opton)
csv_r_opton = {headers:  headers_2}
csv2 = CSV.parse(csv2_s, csv_r_opton)

# pp csv1.to_a
# [[:列1, :列2], ["春", " 4"], ["夏", " 7"], ["秋", " 10"]]
# pp csv2.to_a
# [[:列1, :列3], ["春", " イチゴ"], ["夏", " スイカ"], ["秋", " ナシ"]]

# mergedCsv = [mergedHeaders]
# [[:列1, :列2, :列3] ]
#  {:列1=>"", :列2=>"", :列3=>""}

# データ収納用
mergedHashRows = []
csv1.each do |row|
# 各行収納用のHash
	mergedHash_1 = mergedHash.dup
# 各列のデータを行に収納（そのCSVにない列は空文字のまま）
	mergedHeaders.each do |colm|
		mergedHash_1[colm] = row[colm]
	end
# 行を収納
	mergedHashRows.push(mergedHash_1)
end

# 次のCSV
csv2.each do |row|
# 収納したデータを1行ずつチェック
	mergedHashRows.each do |mRow|
# キーとなる列での同一性判断
		if mRow[:列1] == row[:列1]
# 必要な列のデータを付け加える
			mRow[:列3] = row[:列3]
		end
	end
end

pp mergedHashRows