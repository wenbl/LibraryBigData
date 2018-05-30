##################################################
# 根据分析结果绘制帕累托图
#作者：东北石油大学 计算机与信息技术学院 文必龙
###################################################

library(openxlsx)
dataPath='数据文件保存路径'
words = read.xlsx(paste(dataPath,"\\words_R.xlsx",sep=""),sheet=1)
Paretochart = function(dict,keyword) {
  theWord = subset(dict,词条==keyword) #获取keyword对应的词条数据，这些数据按频次由高到低排列
  index = c(0:(nrow(theWord))) #横坐标值，帕累托图的累计频次折线从(0,0)开始，因此插入1个零点
  value1 = c(0,theWord$dw_count)  #词条频次, 插入1个零点
  value2=c(0,theWord$cumtf*100)  #累计频次, 插入1个零点
  ylabels =seq(0,value1[2]+200,by=200) #生成以200为间隔的词条频次坐标值
  ymax = ylabels[length(ylabels)] #坐标轴上刻度的最大值
  xmax = nrow(theWord) #横坐标上的最大值
  sp=c(-0.5,rep(1.5,13)) #帕累托图中词频条形间的间隔值，第一个为负数，把零点左移到适当的位置
  xlabels = c("",theWord$图书分类号)
  
  #设置绘图参数，mgp的三个值分为坐标轴标签、刻度标签、刻度线与坐标轴的间距
  #new=F表示绘制新图，mai为四周底、左、顶、右图形区的空白距离(按英寸),
  #cex.axis刻度标签字体大小,cex.lab为坐标名字体大小,col是画笔的颜色
  par(mgp = c(1.5, 0.8, 0),new=F,mai=c(0.7,0.7,0.5,1),cex.axis="0.7",cex.lab=0.8,col="black") 
  #绘图区顶上一条线，绘图区的最右边的X坐标值为xmax+0.2，加上0.2是为了最右边的点留出一点空
  plot(x=c(0,xmax),type = "l",y=c(ymax,ymax),axes=F,ylab=NA,xlab=NA,xlim=c(0,xmax),ylim = c (0,ymax))
  #绘制词条频次坐标轴，side=2表示左侧,las=1表示刻度标签为水平方向
  #at指定要绘制的刻度值，pos指定轴的位置，col.axis是刻度标签的颜色
  Axis(side=2,las=1,at=ylabels,pos=0, col.axis="red") 
  #绘制条形图，坐标轴标签、条形柱都用红色，add表示将条形将加在当前图形上。
  barplot(height=value1,xlab="图书分类号",ylab="词条频次(次)",
          col.lab="red",col="red",axes=F,xlim=c(0,xmax),width=0.4,space=sp,ylim=c(0,ymax),add=T)
  Axis(side=1,labels=xlabels,at=index,pos=0,col.axis="black") #side=1,横坐标轴

  #设置绘图参数，new=T表示在当前图上绘制
  par(new=T)
  #绘制折线，type表示线型，pch表示数据点用实心圆,lwd线宽
  plot(x=index,y=value2,xlab=NA,ylab=NA,col.lab="blue",type = "o",
       pch=16,lwd=2,col='blue',axes=F,xlim=c(0,xmax),ylim = c (0,100))
  #side=4,右侧纵坐轴，即累计频度
  Axis(side=4,x=value2,las=1,pos=xmax, col.axis="blue",col.ticks="blue") 
  mtext(text='累计频度(%)',side=4,col='blue',line=1)
  
  title(keyword)
}
Paretochart(dict=words,keyword="考研")
#Paretochart(dict=words,keyword="程序设计")
#Paretochart(dict=words,keyword="考试")


