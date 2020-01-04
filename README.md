# XGAME

## 介绍

指端精灵/飞天助手 的一个开箱即用的框架.

将文件 引入项目 就可以开始编写代码了.

省去繁杂的人工配置,解放程序员

## 文件介绍

- xGame.t	--> 工具类

- xRobot.t 	--> 框架类 (自动配置框架的文件)

## 如何使用???

###  ▶▶▶▶▶▶准备阶段

 - 项目中导入了XM.lua 插件
 - 将 xGame.t 和 xRobot.t 两个文件 手动复制到 项目的目录中.
	然后到 AIS IDE 的 左侧 项目管理中 右击项目后在菜单 点击刷新,此时两个文件就到项目中了.



### ▶▶▶▶▶▶初始化

初始化 格式 ↓  全部复制, 然后根据项目需求改 参数   (参数作用 在 xRobot.t 中有注释)

```lua
--初始化 设置
xRobot.Set_InitSettings(
function ()   
    
    xRobot.Run("test")	--任务入口
        
    xRobot.Set_Robot_Options("sleep_time",1000)
    xRobot.Set_Robot_Options("loop_sw",true)
    xRobot.Set_Robot_Options("xmlog_sw",true)
    xRobot.Set_Robot_Options("applog_sw",false)
    xRobot.Set_Robot_Options("ide_print_sw",true)

    xRobot.Set_Script_Options("scale_xy",{ 720, 1280 })
    xRobot.Set_Script_Options("msgbox_position_xy",{ 129, 709 })
    xRobot.Set_Script_Options("center_msgbox_position_xy",{ 43, 290 })
    xRobot.Set_Script_Options("homekey_position","下")
    xRobot.Set_Script_Options("logfolder_name","xGame日志文件夹")
    xRobot.Set_Script_Options("zd_floatwindow_location_xy",{ 702, 243 })
    
end
)

--在Task之前执行(仅执行一次)
xRobot.Set_BeforeRun(
function ()
    --例如
        
    --广告入口
    --showscriptad()
    
    --检查环境信息
    --xGame.CheckRun(2)
    
    --获取界面选择的任务
    --GetSelectTask()
        
    --自己的代码
end
)

```



### ▶▶▶▶▶▶ 颜色的格式 (必须用 H对象)

提示: 可以新建一个 Colors.t 文件用来存放 颜色信息

```lua
H["界面"]={
	{"背包",1195,524,1279,604,"80CBEB-111111","-11|4|F7BDAF-111111,14|4|EEAEA1-111111"}
	,{"活动界面",98,663,128,694,"BE9D59-111111","-2|-270|6DABA3-111111,-20|-475|F6D27A-111111,27|-599|538983-111111,144|-525|7D748B-111111,644|-566|865E41-111111,1047|-566|A2894D-111111,1094|-536|EE8EA2-111111"}
	,{"关闭使用物品界面",926,357,975,400,"826940-111111","0|-10|F4EABE-111111,0|10|D1BB7A-111111,-12|-2|E6D8A1-111111,12|-1|DECD93-111111,-20|4|AD6A47-111111,-103|152|FFEDB3-111111,-128|178|BFCDC5-111111,-5|178|A1C8BA-111111,-8|64|EEECDD-111111"}
}

H["界面2"]={
	{"背包2",1195,524,1279,604,"80CBEB-111111","-11|4|F7BDAF-111111,14|4|EEAEA1-111111"}
	,{"活动界面2",98,663,128,694,"BE9D59-111111","-2|-270|6DABA3-111111,-20|-475|F6D27A-111111,27|-599|538983-111111,144|-525|7D748B-111111,644|-566|865E41-111111,1047|-566|A2894D-111111,1094|-536|EE8EA2-111111"}
	,{"关闭使用物品界面2",926,357,975,400,"826940-111111","0|-10|F4EABE-111111,0|10|D1BB7A-111111,-12|-2|E6D8A1-111111,12|-1|DECD93-111111,-20|4|AD6A47-111111,-103|152|FFEDB3-111111,-128|178|BFCDC5-111111,-5|178|A1C8BA-111111,-8|64|EEECDD-111111"}
}
```





### ▶▶▶▶▶▶ 方法格式

```lua
--无参数
xRobot.Task("test1",
function (list)  
        
    --自己的逻辑代码
        
    return list.name --返回当前方法名,供框架 循环调用,不需要循环,可以不写,并将 "初始化"中的 loop_sw 改为 false
end
)
```

```lua
--有参数
xRobot.Task("test2",{ key1 = true , key2 = "我是key2" },
function (list)
    
    --自己的逻辑代码
    --list.key1
    --list.key2
        
    return list.name
end
)
```





### ▶▶▶▶▶▶ 说明

```
脚本中 一定要用 xGame/xRobot 对象 完成相关操作,
重写 和 新增的功能 ,在Function 的注释上都有说明
如果xGame暂时没有重写某个XM方法, 最后会间接的调用XM.(xGame 完全继承 XM 所有子类.)
XM方法说明 在 AIS IDE 里查看

智能提示问题: 
	没重写的方法可以用 "XM." 来完成智能提示,输入完后,将 XM 改为xGame
	大家也可以自己动手给xGame添加一个 同名的方法.间接的调用XM. 就有智能提示了. 


这个框架 为啥是两个文件,不能合成一个文件吗?
	答: 因为 xGame 和 xRobot 放同一个文件里  AIS IDE 就没有智能提示了.

```





## 如何批量同步xGame文件 一键同步到 各个项目中???

1. 在xGame_File文件夹中  新建一个.bat文件
2. 将下面的代码 根据自己的需求修改. 粘贴到bat 文件中 保存.  多个路径就 多写几个 `copy  /y`
3. 保存, 双击运行

注意 :

bat 文件必须是 ANSI编码, 中文才能正常. 其他编码会出现中文乱码

*.t 是同目录下所有的.t文件  可以改为 绝对路径文件和文件夹

```bat
@echo off

echo ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
echo ┃                                          ┃
echo ┃    ◆一款开箱即用的框架                  ┃
echo ┃                         ◆ xGame/xRobot  ┃
echo ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

echo ◆
echo 将XGAME框架 同步到各个项目路径

echo ◆
copy /y *.t  目标项目绝对路径

echo ◆
echo 脚本执行完成
pause

```



## 参考项目

[点击查看仓库](https://github.com/xxxxue/sdxl2_fuzu)

