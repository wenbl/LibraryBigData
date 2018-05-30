##################################################
# 根据分析结果排名变化图
#作者：东北石油大学 计算机与信息技术学院 文必龙
###################################################

library(openxlsx)
dataPath='数据文件保存路径'
years =c('2014','2015','2016','2017')
top = 20

#读入年度数据
words_years = data.frame()
top_words = data.frame()
for ( year in years) {
  words_year = read.xlsx(paste(dataPath,"\\借书名TOP20：2014-2017排名变化.xlsx",sep=""),sheet=year)
  words_year['year'] = year
  words_year$rank1 = row(words_year['词条'])
  words_years = rbind(words_years,words_year)
  top_words = rbind(top_words,words_year[1:top,])
}

#整理TOP20数据
top_words=unique(top_words[,'词条'])
words_count = length(top_words)
top_words = data.frame(词条=top_words)
words=merge(words_years,top_words,by="词条")

words = words[order(words$year,words$rank1),]
words = transform(words,rank2=unlist(tapply(rank1,year,rank)))

#绘制排名变化图
x_index=c(0,1,2,3,4,5) #x轴坐标值
x_labels=c("",years,"") #x轴刻度
y_min = top-words_count #y轴最小值，注意不是从0开始，是一个负数
y_index=c(y_min:top) #y轴坐标值
y_labels=c(rep("",words_count-top+1),top+1-c(1:top)) #y轴刻度

#定义图形及坐标轴
plot(1:17, 1:17,xlab="年度",ylab="排名", main="图书馆大数据-年度Top20变化",
     xlim = c(0.5,length(years)+1),ylim=c(y_min,top), type="n",axes=F)
Axis(side=2,at=y_index,labels=y_labels,pos=0.5,col.axis="black",las=1)
Axis(side=1,at=x_index,labels=x_labels,pos=y_min,col.axis="black") #side=1,横坐标轴

lines(c(0.5,length(years)+1),c(0.5,0.5),type = "l",lty=2) #TOP20分隔线

year_index = c(1:length(years))
cols = rainbow(50) #生成一个有50种颜色的颜色表
for (word in top_words$词条) {
  points=c()
  for (theYearIndex in year_index) {
    theyear = years[theYearIndex]
    theWord = subset(words,词条==word & year==theyear,)
    rank1 = theWord$rank1[1]
    rank2 = theWord$rank2[1]
    theRank = rank1
    if (rank1>top) {
      #排名top20之外的，采用特殊方式绘点
      theRank = rank2
      text(x=theYearIndex-0.05, 21-0.7-rank2, 
           as.character(rank1),cex=0.7,adj = c(0,0))
    }
    points = c(points,top+1-theRank)
  }
  
  theColor=cols[as.integer(runif(1, 1, 50))]
  lines(x=year_index,y=points,col=theColor,type="o",lwd=2,pch=16)
  text(x=length(years)+0.1, y=top+1-0.1-theRank, labels=word,cex=0.7,adj=c(0,0))
}

