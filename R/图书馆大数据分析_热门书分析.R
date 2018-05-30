##################################################
# 基于图书馆书籍借阅数据，对书籍借阅情况进行分析
# 哪些书被借次数最多，反映出读者学习方向
#作者：东北石油大学 计算机与信息技术学院 文必龙
# bilong_wen@126.com
###################################################
library(jiebaR)
library(openxlsx)
library(dplyr)
library(tidyr)
library(stringr)
library(wordcloud)

dataPath='数据文件保存路径'
cutter= worker(user=paste(dataPath,"\\library_new_words.txt",sep=""),
              stop_word = paste(dataPath,"\\stopwords.txt",sep=""))#设置分词引擎
book =  read.xlsx(paste(dataPath,"\\图书目录.xlsx",sep=""),sheet=1)
topicWords =  read.xlsx(paste(dataPath,"\\TopicWords_R.xlsx",sep=""),sheet=1)
operations =  read.xlsx(paste(dataPath,"\\图书借还2017.xlsx",sep=""),sheet=1)

book$书名=str_trim(book$书名)
borrowed = subset(operations,操作类型=="借" ,select=c("图书ID")) 
borrowed = subset(merge(borrowed,book,by='图书ID'),select=c('图书分类号','书名'))
#按"图书ID"进行关联
borrowed=na.omit(borrowed) #去掉空值行
words = data.frame(词条=borrowed[which(str_sub(borrowed$图书分类号,1,1)=="I"),"书名"]) #文学类的不分词，直接用书名作主题词

words_noi = subset(borrowed,str_sub(图书分类号,1,1)!="I",select=c("书名")) #非文学类的
words_noi = data.frame(词条=apply(matrix(words_noi$书名),2,function(x) segment(x,cutter)))
words_noi = rbind(words,words_noi)

words=summarise(group_by(words_noi, 词条),count = n())
words=merge(words,topicWords,by="词条")
words = arrange(words,desc(count)) 
words = words[1:300,]
write.xlsx(words,paste(dataPath,"\\借书2017_top300R.xlsx",sep=""),colNames=TRUE)
mycolor <- colorRampPalette(c("blue", "red"))(400)
#新建jpeg图片文件，以备后面使用，图片大小是800 x 800像素
jpeg(filename=paste(dataPath,"\\借书2017_top300R.png",sep=""), width=800,height=800,units='px')
wordcloud(words$词条,words$count,c(6,1),random.order=FALSE,color=mycolor)
dev.off()
print('-------------- 热门书分析完毕 -----------------')




