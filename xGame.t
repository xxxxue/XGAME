--┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
--┃		 									 ┃
--┃    ◆一款开箱即用的框架                   ┃
--┃                         ◆ xGame/xRobot   ┃
--┃                                          ┃
--┃                         ▶ by xue         ┃
--┃                         ▶ QQ 1659809758  ┃
--┃		 									 ┃
--┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛


--框架适用于 指端精灵


--文件介绍:
--xGame.t	--> 工具类
--xRobot.t 	--> 框架类 (自动配置框架的文件)


--使用步骤:

--▶▶▶▶▶▶  0. 
--	前提1: 	项目中导入了XM.lua 插件
--	前提2:	将 xGame.t 和 xRobot.t 两个文件 手动复制到 项目的目录中.
--			然后到 AIS IDE 的 左侧 项目管理中 右击项目后在菜单 点击刷新,
--			此时两个文件就到项目中了.

--▶▶▶▶▶▶  1. 
--	脚本参数初始化 格式 ↓  全部复制, 然后根据项目需求改参数   (参数作用 在 xRobot.t 中有注释)

--xRobot.Run("test")	--任务入口

--xRobot.Set_Robot_Options("sleep_time",1000)
--xRobot.Set_Robot_Options("loop_sw",true)
--xRobot.Set_Robot_Options("xmlog_sw",true)
--xRobot.Set_Robot_Options("applog_sw",false)
--xRobot.Set_Robot_Options("ide_print_sw",true)

--xRobot.Set_Script_Options("scale_xy",{ 720, 1280 })
--xRobot.Set_Script_Options("msgbox_position_xy",{ 129, 709 })
--xRobot.Set_Script_Options("center_msgbox_position_xy",{ 43, 290 })
--xRobot.Set_Script_Options("homekey_position","下")
--xRobot.Set_Script_Options("logfolder_name","xGame日志文件夹")
--xRobot.Set_Script_Options("zd_floatwindow_location_xy",{ 702, 243 })



--▶▶▶▶▶▶  2. 
--	任务 初始化 格式 ↓  (根据需要选择格式)

--不带参数
--xRobot.Task("test1",
--function (list)  
--    
--    return list.name
--end
--)

--带参数
--xRobot.Task("test2",{ key1 = true , key2 = "我是key2" },
--function (list)
--    
--    return list.name
--end
--)


--▶▶▶▶▶▶ 3. 
--	脚本中 一定要用 xGame/xRobot 对象 完成相关操作,
--	重写后 新增的功能 ,在Function 的注释上都有说明
--	如果xGame暂时没有重写某个XM方法, 最后会间接的调用XM.. (xGame 完全继承 XM 所有子类.)

--	智能提示问题: 
--	没重写的方法可以用 "XM." 来完成智能提示,输入完后,将 XM 改为xGame
--	大家也可以自己动手给xGame添加一个 同名的方法.间接的调用XM. 就有智能提示了. 


--这个框架 为啥是两个文件,不能合成一个文件吗?
--	答: 因为 xGame 和 xRobot 放同一个文件里  AIS IDE 就没有智能提示了.




--------------------Util-----START---------------

xGame = {}

--- 倒计时
--	list.name: 任务名称
--	s: 倒计时时间(单位:秒) 尽量大于10秒再用此方法
function xGame.Wait(list, s)
    
    sleep(1000)
    list = list or { name = "任务" }
    --间隔x秒               
    local second = s
    while true do
        if second <= 0 then
            return true
        else
            xGame.Show("***[" .. list.name .. "]-->>>>>>倒计时:" .. xGame.DateRet(second))
        end
        second = second - 10
        sleep(10000)
        
    end
end


-- 重写 滑动

-- 99 滑动后停顿松开	(x1,y1,x2,y2,{ID`99`,持续时间`111`})
-- 98 滑动长按 			(x1,y1,x2,y2,{ID`98`,持续时间`?`})
-- 97 匀速偏移滑动  	(x1,y1,x2,y2,{ID`97`,偏移`±5`,持续时间`400`})
----------------------------------
function xGame.Swipe(xa, ya, xb, yb, ...)
    
    --初始化参数
    local parArr = xGame.InitTable(...)
    
    local id = parArr[1] or 1 --默认id为1
    local rd = parArr[2] or 5 --偏移量 基数 
    
    local x1, y1, x2, y2 = xGame.ColorChange(xa, ya, xb, yb)
    
    local r = rnd(-1 * rd, rd) --计算最终偏移量
    
    if id == 99 then
        -- 滑动 后停顿
        --{id,偏移,结束间隔}
        
        --拖动结束后间隔x毫秒 松开   
        local endSleep = parArr[3] or 111
        
        touchdown(x1 + r, y1 + r, 0)
        Sleep(200)
        touchmove(x2 + r, y2 + r, 0)
        Sleep(endSleep)
        touchup(0)
        
        
    elseif id == 98 then
        --滑动长按 (可用于人物移动)
        --{id,持续时间}
        local par2 = parArr[2] or 1000    --持续时间
        local stime = rnd(par2 - 500, par2 + 500)
        
        touchdown(x1, y1, 0)
        sleep(500)
        touchmove(x2, y2, 0)
        Sleep(stime)
        touchup(0)
        
    elseif id == 97 then
        --匀速偏移滑动
        --{id,偏移范围,持续时间}
        local sTime = parArr[3] --持续时间
        
        local diff1 = x1 - x2
        local diff2 = y1 - y2
        sTime = sTime or 400
        if sTime < 400 then
            sTime = 400
        end
        local time = (sTime - 100) / 300
        local count1 = diff1 / time
        local count2 = diff2 / time
        x1 = x1 + r
        x2 = x2 + r
        y1 = y1 + r
        y2 = y2 + r
        singletouchdown(x1, y1)
        for i = 1, time do
            singletouchmove(x1 - (count1 * (i - 1)), y1 - (count2 * (i - 1)), x1 - (count1 * (i)), y1 - (count2 * (i)))
        end
        sleep(100)
        singletouchup(x2, y2)
    else
        lineprint("调用XM 的Swipe")
        XM.Swipe(xa, ya, xb, yb, id, rd)  --调用XM中的Swipe        
    end
end

--色点缩放
function xGame.ColorChange(...)
    return ColorChange(...) --调用XM中的 ColorChange
end

--初始化表格
function xGame.InitTable(...)
    local res
    if ... == nil then
        res = { ... }
    else
        if type(...) == "table" then
            res = ...
        else
            
            res = { ... }
        end  
    end   
    return res
end

--找色
-- 同时调用 Keep 与 Find
------------------------
function xGame.Find(...)
    XM.KeepScreen()    --刷新图色
    return XM.Find(...)
end

--开关
--	name: 唯一名称 	(进入一次后. 需要手动开启才可以再进入)
-------------------------
function xGame.Switch(name)
    return XM.Switch(name)
end

--计时器
--	name: 唯一名称
--	t: 时间
--------------------------
function xGame.Timer(name, t)
    return XM.Timer(name, t)
end

--将秒 转为 时分秒格式 返回
--	s: 秒数
function xGame.DateRet(s)
    return XM.DateRet(s)
end

--获取区域内某种颜色的数量
-- par: 色点table
function xGame.FindNumRet(par)
    XM.KeepScreen()    --刷新图色
   return XM.FindNumRet(par)
end 


-----------------Msg/Log---START--------
-- 控制台打印信息(支持字符串和table)
function xGame.Print(content)
    XM.Print(content)
end

-- 在屏幕上 显示提示信息
function xGame.Msg(content,x,y)
    local msgBoxPos_xy = xRobot.Get_Script_Options("msgbox_position_xy")
    x= x or msgBoxPos_xy[1]
    y= y or msgBoxPos_xy[2]
    
    XM.Msg(content, x, y)
end

-- 屏幕中心 显示信息 (由于文字数量不同,取屏幕中心点来显示并不合理,所以是自己指定,)
function xGame.CenterMsg(content)
    
    local cMsgBoxPos_xy = xRobot.Get_Script_Options("center_msgbox_position_xy")
    XM.Msg(content, cMsgBoxPos_xy[1], cMsgBoxPos_xy[2])
end

-- app 记录日志
function xGame.Logex(content)
    logex(content)
end

-- 写入文件
function xGame.WriteFile(content)
    xGame.Print(">> 写入log 文件: " .. content)
    local res = false
    local dateNow = timenow()
    local folderName = xRobot.Get_Script_Options("logfolder_name")
    local logFileName = timeyear(dateNow) .. "_" .. timemonth(dateNow) .. "_" .. timeday(dateNow)
    
    --创建日志文件夹
    if xGame.Switch("CreateLogFolder") then
        foldercreate("/sdcard/" .. folderName)
    end
    
    --文件句柄
    local fileHandle = fileopen("/sdcard/" .. folderName .. "/" .. logFileName .. ".txt", "a+")
    
    if (fileHandle > 0) then
        content = "\n" .. tostring(timenow()) .. "\n\n\t\t" .. content
        
        if xGame.Switch("日志") then
            content = "\n\n\n------------------------------\n" .. content
        end
        
        res = filewriteline(fileHandle, content)
    end
    
    fileclose(fileHandle)
    
    if res == false then
        xGame.Show(error, true)
    end
    
    return res
end

--多种显示信息同时调用
--	屏幕,app日志,IDE控制台,log文件
--	发布时可以根据需求注释掉一些
function xGame.Show(content, isWriteFile)
    
    isWriteFile = isWriteFile or false
    content = tostring(content)
    
    xGame.Msg(content)    --屏幕
    
    if xRobot.Get_Robot_Options("applog_sw") then
        xGame.Logex(content) 	--app log
    end  
    
    if xRobot.Get_Robot_Options("ide_print_sw") then
        xGame.Print(content)    --IDE控制台
    end     
    
    if isWriteFile then
        xGame.WriteFile(content) --文件日志
    end
    
end

-----------------Msg/Log----END--------
--检查设备是否符合运行要求
--	s: 倒计时(单位:s   默认:3) 
function xGame.CheckRun(s)   
       
    s= s or 3
    local msg = ""
    local list = XM.GetScreenSimulator() --当前分辨率    
    local folderName = xRobot.Get_Script_Options("logfolder_name")
    local floatwindow_xy = xRobot.Get_Script_Options("zd_floatwindow_location_xy")
   
    setfloatwindowlocation(floatwindow_xy[1], floatwindow_xy[2])   --移动 飞天悬浮窗到指定位置
    
    msg = msg .. "推荐分辨率: 720 * 1280  DPI: 320 \n当前分辨率: " .. list[1] .. " * " .. list[2] .. "  DPI: " .. list[3]
    
    msg = msg .. "\n---------------------------------------------"
    msg = msg .. "\n【飞天助手】海量免费辅助搭配【红手指】\n免充电、免Root、免流量、24小时离线挂机!"
    msg = msg .. "\n---------------------------------------------"
    msg = msg .. "\n任务日志在设备的【根目录 / " .. folderName .. "】 文件夹中\n文件名格式:年-月-日.txt\n(可以查看此文件查看历史任务情况)\n\n脚本出现异常可以将此日志发给作者.."
    msg = msg .. "\n---------------------------------------------"
    msg = msg .. "\n请确保 所有弹窗已关闭"
    msg = msg .. "\n---------------------------------------------"
    if list[1] == 720 and list[2] == 1280 and list[3] == 320 then
        
    else
        msg = msg .. "\n【分辨率不匹配.脚本运行过程可能不稳定】"
    end
    
    msg = msg .. "\n智能检测运行环境,正在启动【新版防封框架】..."
    
    msg = msg .. "\n---------------------------------------------"
    
    
    for i = s, 0, -1 do
        sleep(1000)
        
        xGame.CenterMsg(msg .. "\n" .. i .. "秒后开始运行....")
    end
    
end

--------------------Util--END---------------