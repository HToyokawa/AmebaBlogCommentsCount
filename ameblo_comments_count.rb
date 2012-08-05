
require "rss"
require "uri"
require "net/http"
require "nokogiri"
require "date"
require "time"
require "rubygems"
require "ruby-growl"


# 渡されたURLのブログに含まれる記事のURLとタイトルを配列で取得する．
# 配列の各要素は、記事のURLとタイトルをそれぞれurl, titleというキーで
# Hashに詰めたもの。
def get_recent_entries(path)
	entries = []

	rss_results = ""
	url = URI.parse(path).normalize()

	open(url) do |http|
		res = http.read
		rss_results = RSS::Parser.parse(res, false)
	
			rss_results.items.each do |item|
			if(item.link().to_s.index("rss") == nil)
				h = Hash.new
				h["url"] = item.link()
				h["title"] = item.title()
				entries.push(h)
			end
		end
	end
	
	return entries
end


# 渡された記事URLの記事からコメント部分を抜き出し、その情報を配列で返す．
# 配列の各要素は、コメント本文と書き込み時間をそれぞれtext, dateというキーで
# Hashに詰めたもの。50件以上の書き込みがあっても、最新の50件までしか取得できない．
def enum_comments(url)
	ary = []
	open(url, 'r:Shift_JIS') do |data|
		doc = Nokogiri::HTML(data)
		
		bodies = doc.search(".comment_body")
		dates = doc.search(".comment_date")

		for i in 1..bodies.size()
			h = Hash.new()
			h["text"] = bodies[i-1].text
			h["date"] = dates[i-1].text
			ary.push h
		end
  end
	return ary
end

# ブログのRSSのURL （TODO: 取得するブログごとにURLを変えること！）
url='http://feedblog.ameba.jp/rss/ameblo/*****/rss20.xml'

# 新しいブログ記事を取得
entries =  get_recent_entries(url)

print "タイトル\tコメント件数\n"

show_notification = false

# 最新の5件について、記事ごとにコメント件数を表示していく
warn_titles = []
show_notification = false
for i in 0..4 do
	comments = enum_comments(entries[i]["url"])
	
	print entries[i]["title"], "\t", comments.size(), "\n"

end

