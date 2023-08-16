
                     ****公司内部薪酬差距与组织绩效关系的实证研究****

***论文程序实现主要是看论文的实证部分，论文用到哪些数据？这些数据可以从哪里获得**
***数据我已经提前下载好，程序主要是基于已经从CSMAR数据库中下载的相关数据，主要是程序实现**
***关于如何从CSMAR中下载数据，找时间我再演示给你看**

*因此我们现在基于已经拿到的原始数据，开始操作并得到实证的结果
*-------------------------------------------------------------------------------

***我们一共有11个表格，都是原始数据，我们需要进行简单的处理，然后将他们合并到一起
*-Top3 公司高管的薪酬总额，表中还有高管人数，公司职工总数
*-asset 来自资产负债表，年末资产
*-beta 风险系数
*-Contrshr 控制人性质
*-totaltop_pay 都是关于高管薪酬的数据,因为没有找到高管薪酬数据，只有董事监事高管薪酬总额
*-emp_pay 员工薪酬数据，来自现金流量表的支付给职工的以及为职工支付的现金，近似为总工资
*-H10 前十大股东的股权集中度，主要是10大股东的股权之和
*-ind 行业数据，每个公司的行业是什么，我们后期要控制行业数据
*—profit 来自利润表的 公司每年净利润

*-------------------------------------------------------------------------------

**可以把我发给你的data文件夹放到stata默认路径下，然后重新指定软件路径，
cd D:\stata\data  // 默认路径D:\stata,后面加上 \data ,前面加上 cd 就可以指定

*-------------------------------------------------------------------------------

**处理高管前三的薪酬表格 Top3**
import excel using Top3.xls, first clear   // import 调入Top3 excel文件
br // 浏览数据，发现变量名不易识别，因此修改变量名，同时加标签（下载数据时会自带txt文本格式，说明变量含义）
rename Y0601b emp_num   // 重命名为 emp_num 表示 员工总数（变量含义来自于数据带有的txt，你先不用管怎么来的）
rename Y1501e top3_pay  // 重命名为 top3_pay 表示 前三高管薪酬总额

*- label var 变量名 "标签内容" 为变量加标签，让自己以后看起来更加的清晰，不易忘记
label var emp_num "员工人数"  
label var top3_pay "高管前三薪酬总额"  
drop Y1301b
rename Reptdt Accper  // 将Reptdt（统计截止日期） 重命名为 Accper （会计期间）
*为了后面合并不同的表做准备，需要有相同变量名的字段，所以改为一致的变量名称

split  Accper , parse(-) destring ignore("-") // split 表示将Accper分割成年、月、日三个变量
*Accper1 是 Accper 中的年度,Accper2 是 Accper 中的月度，Accper3 是 Accper 中的日度

keep if Accper2 == 12   // 保留12月份统计的数据，我们只要这个数据
drop Accper  Accper2  Accper3 // 删除掉 Accper  Accper2  Accper3 三个变量
rename  Accper1  Accper // 将Accper1 重命名为 Accper，一样的理由，合并不同的表需要有共同的变量名
destring Stkcd, replace // 将Stkcd（股票代码）由字符型转变为数值型，用destring命令
order Stkcd Accper   // 将Stkcd Accper 变量提到最前面，直接看数据表格最为直观
sort Stkcd Accper   // 日常sort，按照Stkcd Accper 变量排序，这两个变量可以唯一确定一条记录
duplicates drop Stkcd Accper , force // 删除表格中可能存在的重复的记录，每个公司每一年只有一条记录
save Top3,replace  // 将数据保存为dta格式的文件，方便以后调用

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------

**处理所有高管薪酬的数据**
**没有在CSMAR数据找到高管薪酬数据总额，只有由董事监事高管薪酬总额数据代替
import excel using totaltop_pay,first clear  // import 调入totaltop_payexcel文件
rename Y1501a totaltop_pay // 变量重命名
gen top_num = Y1101a + Y1201a  // 计算高管数量，用董事人数加上监事人数。
drop Y1101a  Y1201a  // 删除多余变量
label var totaltop_pay  "高管总薪酬"
label var top_num "高管人数" // 和之前的操作一样，给变量加标签

rename Reptdt Accper   //  将Reptdt（统计截止日期） 重命名为 Accper （会计期间）
*为了后面合并不同的表做准备，需要有相同变量名的字段，所以改为一致的变量名称

split  Accper , parse(-) destring ignore("-") // split 表示将Accper分割成年、月、日三个变量
*Accper1 是 Accper 中的年度,Accper2 是 Accper 中的月度，Accper3 是 Accper 中的日度

keep if Accper2 == 12   // 保留12月份统计的数据，我们只要这个数据
drop Accper  Accper2  Accper3 // 删除掉 Accper  Accper2  Accper3 三个变量
rename  Accper1  Accper // 将Accper1 重命名为 Accper，一样的理由，合并不同的表需要有共同的变量名
destring Stkcd, replace // 将Stkcd（股票代码）由字符型转变为数值型，用destring命令
order Stkcd Accper   // 将Stkcd Accper 变量提到最前面，直接看数据表格最为直观
sort Stkcd Accper   // 日常sort，按照Stkcd Accper 变量排序，这两个变量可以唯一确定一条记录

duplicates drop Stkcd Accper , force  // 删除表格中可能存在的重复的记录，每个公司每一年只有一条记录
save totaltop_pay,replace  // 将数据保存为dta格式的文件，方便以后调用

*-------------------------------------------------------------------------------

***总结一下，基本表格处理的套路都是一样的
**首先是打开表格，这样才有处理的对象；其次是对变量重命名，结合其真实的含义，便于记忆
**然后是对变量加标签，便于识别；还需要从数据的日期中提取出年份，接下来就是把股票代码去字符化，变成数值
**还有就是对股票代码和会计期间变量进行order 和 sort ，还需要强制删除多余的记录，最后保存数据

*-------------------------------------------------------------------------------

**处理职工总薪酬**
import excel using emp_pay.xls, first clear  // import 调入emp_pay excel文件
rename C001020000 totalemp_pay  // 变量重命名
label var totalemp_pay "职工总薪酬"  // 变量加标签
format totalemp_pay %20.2g   // 职工总薪酬变量是科学计数法表示，更改其表示格式
split  Accper , parse(-) destring ignore("-")  // 分离年度，月份，日期变量
keep if Accper2 == 12 // 保留十二月份的数据，我们只需要年终的数据，而不是所有数据
drop Accper  Accper2  Accper3  // drop 多余变量
rename  Accper1  Accper // 变量重命名
destring Stkcd, replace  // 变量去字符化，变成数值型变量
order Stkcd Accper   //变量自身顺序排序（横向）
sort Stkcd Accper   //变量数值大小排序（纵向）
duplicates drop Stkcd Accper , force  //确保Stkcd Accper能够唯一确认一条记录
save totalemp_pay,replace // 保存数据

*-------------------------------------------------------------------------------
*-------------------------------------------------------------------------------
***处理资产表格**

import excel using asset.xls, first clear // import 调入asset excel文件
drop A002000000  // 这个数据含义是负债，下载的时候没注意，并不需要，因此直接删除
rename  A001000000 asset  // 变量重命名
label var asset "年末资产总额 "  // 变量加标签
format asset %20.2g    //资产变量是科学计数法表示，更改其表示格式
split  Accper , parse(-) destring ignore("-")  // 分离年度，月份，日期变量
keep if Accper2 == 12  // 保留十二月份的数据，我们只需要年终的数据，而不是所有数据
drop Accper  Accper2  Accper3 // drop 多余变量
rename  Accper1  Accper // 变量重命名
destring Stkcd, replace  // 变量去字符化，变成数值型变量
order Stkcd Accper //变量自身顺序排序（横向）
sort Stkcd Accper //变量数值大小排序（纵向）
duplicates drop Stkcd Accper , force //确保Stkcd Accper能够唯一确认一条记录
save asset,replace // 保存数据

*-------------------------------------------------------------------------------

**处理利润表格** 
import excel using profit.xls, first clear // import 调入profit excel文件
rename B002000000 profit // 变量重命名
label var profit "净利润" // 变量加标签
format profit %20.2g  //利润是科学计数法表示，更改其表示格式
split  Accper , parse(-) destring ignore("-")  // 分离年度，月份，日期变量
keep if Accper2 == 12 // 保留十二月份的数据，我们只需要年终的数据，而不是所有数据
drop Accper  Accper2  Accper3  // drop 多余变量
rename  Accper1  Accper // 变量重命名
destring Stkcd, replace  // 变量去字符化，变成数值型变量
order Stkcd Accper  //变量自身顺序排序（横向）
sort Stkcd Accper //变量数值大小排序（纵向）
duplicates drop Stkcd Accper , force  //确保Stkcd Accper能够唯一确认一条记录
save profit,replace // 保存数据

*-------------------------------------------------------------------------------
 
**处理公司风险系数**
import excel using beta.xls, first clear // import 调入beta excel文件
rename Betavals beta  // 变量重命名
label var beta "风险系数 beta" // 变量加标签
rename Trddt Accper // 把交易时间（Trddt） 重命名成 Accper（会计期间）；后期合并需要
destring Stkcd Accper, replace  // 变量去字符化，变成数值型变量；同时把Stkcd Accper都去数值化
**表格数据都是以年份呈现的，不用从年月日的日期形式中剥离出年度数据，所以要先观察数据结构

order Stkcd Accper  //变量自身顺序排序（横向）
sort Stkcd Accper  //变量数值大小排序（纵向）
duplicates drop Stkcd Accper , force //确保Stkcd Accper能够唯一确认一条记录
save beta,replace // 保存数据

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------

**处理股权集中度***
import excel using H10.xls, first clear // import 调入beta excel文件
rename Reptdt Accper   // 变量重命名
split  Accper , parse(-) destring ignore("-") // 分离年度，月份，日期变量
keep if Accper2 == 12 // 保留十二月份的数据，我们只需要年终的数据，而不是所有数据
drop Accper  Accper2  Accper3   // drop 多余变量
rename  Accper1  Accper // 变量重命名
destring Stkcd, replace // 变量去字符化，变成数值型变量
order Stkcd Accper  //变量自身顺序排序（横向）
sort Stkcd Accper //变量数值大小排序（纵向）
rename Shrcr4 H10  // 变量重命名 H10 表示前十大股东持股比例之和
replace H10 = H10 / 100 // 数据处理，观察数据发现是0-100中的数值，不是比例，变换成比例
duplicates drop Stkcd Accper , force  //确保Stkcd Accper能够唯一确认一条记录
save H10,replace  // 保存数据

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
**处理实际控制人**
import excel using Contrshr.xls, first clear // import 调入beta excel文件
drop S0701a  // 发现这个数据并没有意义，2代表是从控制链数据获得数据
rename Reptdt Accper  // 变量重命名,后期合并需要同变量名
split Accper, parse(-) destring ignor("-") // 分离年度，月份，日期变量
drop Accper Accper2 Accper3  // drop 多余变量
rename Accper1 Accper  // 变量重命名
gen SOE=0 // 产生一个新变量 

***代码中含有1100，2000，,2100,2120的是国有企业产权***

replace SOE=1 if strmatch(S0702b, "*1100*") //国有企业
replace SOE=1 if strmatch(S0702b, "*2000*") //行政机关、事业单位
replace SOE=1 if strmatch(S0702b, "*2100*") //中央机构
replace SOE=1 if strmatch(S0702b, "*2120*") //地方机构
**replace 表示替换，将SOE变量的值替换成1，如果：strmatch命令是字符匹配，从S0702b这个
**变量中匹配，是否有""中包含的字符，星号代表任意字符，*1100* 变量中只要有1100就可以把SOE替换成1

destring Stkcd,replace  // 变量去字符化，变成数值型变量
keep Stkcd Accper SOE  // keep 只保留  Stkcd Accper SOE 三个变量，其余的变量全被drop掉
sort Stkcd Accper  // 对变量数值排序（纵向）
duplicates drop  Stkcd Accper, force //确保Stkcd Accper能够唯一确认一条记录
save CONT, replace  // 保存数据

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------

***处理公司的行业**
import excel using ind.xls, first clear // import 调入ind excel文件

split Accper, parse(-) destring ignor("-")  // 分离年度，月份，日期变量
drop Accper Accper2 Accper3 // drop 多余变量
rename Accper1 Accper // 变量重命名

clonevar ind =  Indcd  // clonevar 克隆命令，克隆一个新变量，ind 变量和Indcd变量完全一致
br  // 可以看一下是否生成新的变量ind 
replace ind = substr(Indcd,1,1) if substr(Indcd,1,1) != "C"
**行业分类，replace表示替代，因为这个变量之前是有值的，所以是replace，而不是gen（产生变量）
**substr（A,B,C）表示从A这个变量中，从第B个字符开始提取字符，提取C个字符
**substr(Indcd,1,1)表示从Indcd变量中，从第1个字符开始提取，提取1字符
** if substr(Indcd,1,1) != "C" 表示如果提取出来的字符等于 C （C表示制造业）
replace ind = substr(Indcd,1,2) if substr(Indcd,1,1) == "C"
**两句replace是说，当表征行业变量Indcd第一个字符不是C的时候，提取第一个字符；
**但Indcd第一个字符是C的时候，提取两个字符；这是因为制造业分类更多，所以要细分，而其他行业分类较少不必细分

drop Indcd  //删除掉多余的变量 
destring Stkcd,replace // 变量去字符化，变成数值型变量
sort Stkcd Accper  // 对变量数值排序（纵向）
duplicates drop  Stkcd Accper, force //确保Stkcd Accper能够唯一确认一条记录
save ind, replace // 保存数据

*-------------------------------------------------------------------------------

*我们通过一系列数据处理，已经得到了9个dta数据文件，数据中有我们需要的变量也有我们
*合并需要的相同的对接字段：Stkcd Accper（公司代码，和会计期间）

**九个dta数据文件分别是：
**asset.dta（资产数据），H10.dta（前十大股东持股比例），CONT.dta（实际控制人数据）
**beta.dta（公司风险系数），totaltop_pay.dta（高管总薪酬数据），totalemp_pay.dta（职工总薪酬）
**，profit.dta（利润），Top3.dta（高管薪酬前三总额），ind.dta（行业数据）

*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
**开始合并所有表**
**开始合并前了解一下 merge命令，复制网址百度  http://blog.sina.com.cn/s/blog_629bb758010123av.html
**merge 表示纵向合并，就是把两张表通过唯一确定的关键词横向拼接到一起。用三种方式 
**1:1 (一对一)，1:m（一对多） ,m:m（多对多）
**比如一张表有id（股票代码） year（年份），asset（年末总资产）三个变量
**还有一张表有id（股票代码） year（年份），profit（净利润）三个变量
**通过merge组成的新表，有四个变量id（股票代码） year（年份），asset（年末总资产），profit（净利润）四个变量
**是不是觉得很傻，那干嘛下载数据的不下到一起，说的很对，关键问题就是很多数据不能下到一起

use asset,clear    // 打开asset数据文件，dta的数据文件，直接用use，不是用import


merge 1:1  Stkcd Accper using H10 // 和H10这个dta文件一对一横向拼接，识别关键词是 Stkcd Accper 
**关键词很重要，就是两张表中共有的可以用来表示数据唯一性的变量
drop if _merge != 3  // 匹配后会产生_merge 变量；
**只有_merge 等于3才是匹配成功，如果等于1表示数据只有主表中（master）中有，而副表中没有
**_merge 等于1表示数据只有在副表中有，在主表中没有
**主表就是最先打开的表 此例中的asset数据；副表就是using后面的数据，此例中的H10数据
drop _merge // 必须删除掉_merge 这个变量，后面的合并才能继续


merge 1:1  Stkcd Accper using CONT  // 由asset和H10组成的新数据 和CONT这个dta文件一对一横向拼接
drop if _merge != 3 // 删除掉那些没有匹配成功的数据（是一行记录一行记录的删除，不是某个变量）
drop _merge // 必须删除掉_merge 这个变量，后面的合并才能继续

merge 1:1  Stkcd Accper using beta // 合并形成的新数据和beta.dta文件的合并
drop if _merge != 3 // 删除掉那些没有匹配成功的数据
drop _merge // 必须删除掉_merge 这个变量，后面的合并才能继续

merge 1:1  Stkcd Accper using totaltop_pay // 合并形成的新数据和totaltop_pay.dta文件的合并
drop if _merge != 3   // 删除掉那些没有匹配成功的数据
drop _merge // 必须删除掉_merge 这个变量，后面的合并才能继续

merge 1:1  Stkcd Accper using totalemp_pay // 合并形成的新数据和totalemp_pay.dta文件的合并
drop if _merge != 3  // 删除掉那些没有匹配成功的数据
drop _merge // 必须删除掉_merge 这个变量，后面的合并才能继续

merge 1:1  Stkcd Accper using profit // 合并形成的新数据和profit.dta文件的合并
drop if _merge != 3 // 删除掉那些没有匹配成功的数据
drop _merge  // 必须删除掉_merge 这个变量，后面的合并才能继续

merge 1:1  Stkcd Accper using Top3 // 合并形成的新数据和Top3.dta文件的合并
drop if _merge != 3 // 删除掉那些没有匹配成功的数据
drop _merge // 必须删除掉_merge 这个变量，后面的合并才能继续

merge 1:1  Stkcd Accper using ind   // 合并形成的新数据和ind.dta文件的合并
drop if _merge != 3  // 删除掉那些没有匹配成功的数据
drop _merge // 必须删除掉_merge 这个变量，后面的合并才能继续
save hebing,replace // 所有的数据合并完成，保存数据
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
**生成变量以及为最终的变量加标签***
label var H10 "前10大股东股权集中度" // 直接用前10大股东的股权比例之和作为股权集中的代理变量
rename SOE CONT  // 为了同论文保持一致，将SOE产权性质重命名成 CONT 最终控制人
label var CONT "最终控制人类型" // 为变量加标签
label var totalemp_pay "公司职工总薪酬"  // 为变量加标签
label var totaltop_pay "公司高管总薪酬"  // 为变量加标签
label var ind "行业" // 为变量加标签

gen SIZE = ln(asset) // 产生一个新变量，公司规模用资产的对数表示
label var SIZE "公司规模"  // 为变量加标签
gen ROA = profit / asset   // 产生一个新变量，ROA用净利润除以年末资产
label var ROA "总资产收益率" // 为变量加标签
**关键是产生自变量GAP1 和 GAP2 需要发挥一点想象力
**GAP1 变量定义为 高管薪酬前三的平均值  top3_pay/3 和 除薪酬前三高管其余高管薪酬平均值的差值的对数
**所以需要构建除薪酬前三高管其余高管薪酬平均值：所有高管薪酬减去薪酬前三高管薪酬然后除以（高管总人数-3）
**GAP2 按照这个思路，其余高管的薪酬平均值已经构建好了，就差职工的薪酬的平均值了；
**采用现金流量表中的支付给职工的现金和为职工支付的现金近似替代为职工支付的工资；但是要扣除所有高管的薪酬
**才是一般职员的总工资然后除以（公司总员工减去高管人数）

gen GAP1 = ln(top3_pay/3 - (totaltop_pay - top3_pay)/(top_num - 3))
gen GAP2 = ln((totaltop_pay - top3_pay)/(top_num - 3)-(totalemp_pay-totaltop_pay)/(emp_num-top_num))

order Stkcd Accper ROA GAP1 GAP2 SIZE beta H10 CONT  // 变量横向调整顺序，就方便好看

drop if ROA == . 
drop if  GAP1 == .  
drop if  GAP2 == .  
drop if SIZE == . 
drop if beta == . 
drop if H10 == .
drop if CONT == .
// 删除掉数据中缺失的值，连续变量都不能有缺失值（. 就是表示缺失）
*-------------------------------------------------------------------------------

*-------------------------------------------------------------------------------
**数据的处理，描述性统计，相关系数，回归结果
drop if ind =="J" // 剔除金融行业公司的数据

*-在1和99分位上缩尾处理
winsor2 ROA GAP1 GAP2 SIZE beta H10, replace cut(1 99)

*-描述性统计
tabstat  ROA GAP1 GAP2 SIZE beta H10 CONT,stat(n mean sd min max p25 p50 p75 ) col (stat) f(%9.3f)

*-相关性系数
pwcorr_a ROA GAP1 GAP2 SIZE beta H10 CONT 
**回归，文中提到用FGLS 广义最小二乘法，那奈何小哥哥不会呀，没办法那就用OLS 和带固定效应模型来回归吧

*简单的回归，不控制行业和年度
reg ROA GAP1 SIZE beta H10 CONT  
reg ROA GAP2 SIZE beta H10 CONT 

*回归，控制行业和年度；前面加xi：后面加i.ind i.Accper，程序会自动控制
xi :reg ROA GAP1 SIZE beta H10 CONT i.ind i.Accper
xi :reg ROA GAP2 SIZE beta H10 CONT i.ind i.Accper

*加入固定效应，回归
xtset Stkcd Accper // 申明面板数据
xi:xtreg ROA GAP1 SIZE beta H10 CONT i.ind i.Accper, fe
xi:xtreg ROA GAP2 SIZE beta H10 CONT i.ind i.Accper, fe

**最终结果回归都是显著为正的，直接看系数和P值，P值都是极小的。

***基本到这里这篇文章的主效应就检验的程序就到这里了
***这篇文章的程序复制有那么几个点不是非常的好
**-首先没有找到高管薪酬的数据，所以用的是董事监事高管的薪酬总额代替
**-为了和董事监事高管薪酬总额相互对应，高管人数用的是监事+董事；没有直接使用数据库高管人数；董事会高管人数较多无法分离
**-基于以上原因，到后面计算GAP1和GAP2失去了很多样本，虽然结果仍旧相同，但是仍然属于一个不好的结果
**-但是小哥哥已经尽力去复制这篇论文了，差不多马马虎虎70分，三个致命点，每点扣十分。









