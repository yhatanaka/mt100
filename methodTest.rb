#!/usr/bin/ruby
testHash = {
	test1: '1だよ',
	test2: '2です'	
}

def test1(a,b)
	return 'a: ' + a.to_s
end

def test2(a, b)
	return 'a: ' + a.to_s + "\n" + 'b: ' + b.to_s
end

def call_test(arg1,arg2,fun)
	puts fun.call(arg1,arg2)
end

test1Func = method(:test1)
test2Func = method(:test2)


# test2Func.call('テスト1','テスト3')
call_test('テスト5','テスト9',test1Func)


# 