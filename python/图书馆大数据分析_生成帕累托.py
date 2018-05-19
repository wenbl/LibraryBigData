########################################################
# 绘制某个词条在各图书分类中分布的帕累托图
# 本模块运行前，需要先完成主题词的抽取，生成words.xlsx
#作者：东北石油大学 计算机与信息技术学院 文必龙
########################################################
from wordcloud import WordCloud
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt

def Paretochart(keyword):
    #准备数据
    word = words.loc[(words['词条'] == keyword),] #提取词条对应的记录
    xlable = ['']+list(word['图书分类号']) #加一个空的分类号
    tf = [0]+list(word['dw_count']) #空分类的词频为0
    cumtf=[0]+list(word['cumtf']*100) #空分类的累计词频为0，这样就会将累计曲线起点设置到坐标原点
    num=len(word)+1 #多加一个点数
    index = np.arange(num) #利用numpy的生成值为0~num-1的列表，共num个值，用来作为X坐标值

    #设置图形基本格式
    plt.close() #先关闭打开有图板
    plt.rcParams['font.sans-serif'] = ['SimHei']
    plt.title(keyword) #设置图的标题
    plt.xticks(index, xlable)  # X轴标签
    plt.xlim(0, num) #X轴显示的起止范围

    #绘制词条频次条形图
    ax1 = plt
    color = 'tab:red'
    ax1.xlabel('图书分类')
    ax1.ylabel('词条频次（次）', color=color)
    ax1.bar(index, tf, color=color)
    ax1.tick_params(axis='y', labelcolor=color) #设置刻度线格式
    #ax1.ylim(top=100, bottom=0)  # Y轴范围

    #绘制词频折线图
    ax2 = ax1.twinx()  # instantiate a second axes that shares the same x-axis
    color = 'tab:blue'
    ax2.set_ylabel('累计词频(%)', color=color)  # we already handled the x-label with ax1
    ax2.plot(index, cumtf, 'o-', color=color)  # 实线，圆圈标点
    ax2.tick_params(axis='y', labelcolor=color)
    ax2.set_ylim(top=100, bottom=0)  # Y轴范围
    plt.show()
dataPath='数据文件保存路径'
words = pd.DataFrame(pd.read_excel(dataPath+'\\words.xlsx'))
Paretochart('程序设计')
plt.show()