--┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
--┃		 									 ┃
--┃    ◆一款开箱即用的框架                   ┃
--┃                         ◆ xGame/xRobot   ┃
--┃                                          ┃
--┃                         ▶ by xue         ┃
--┃                         ▶ QQ 1659809758  ┃
--┃		 									 ┃
--┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

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

--获取数组的值 必须是H表的item
--	格式: {"TableName","ItemName"}
function xGame.GetTable(value)
    return GetTable(value)
end


--找色
-- 同时调用 Keep 与 Find
------------------------
function xGame.Find(...)
    XM.KeepScreen()    --刷新图色    
    return xGame.XMFind(...)    
end

function xGame.XMFind(...)
    
    return XM.Find(...)
end

--找色 (已废弃,请使用FindNotCallKeep)
--不刷新
--	兼容老版本
function xGame.Find2(...)    
    return xGame.FindNoCallKeep(...)  
end
--找色 
--不刷新
function xGame.FindNoCallKeep(...)    
    return xGame.XMFind(...)
end

--循环找图
--	colors,isClick: Find 参数
--	timeOut: 超时时间 (单位:毫秒,默认 5秒)
function xGame.FindWait(...)
    --colors,isClick,timeOut
    local arr= {...}
    
    local colors= arr[1]
    local isClick= false
    local timeOut = 5000
    
    if type(arr[2])=="number" then
        timeOut = arr[2]
    else
        isClick= arr[2]
        timeOut = arr[3] or 5000
    end    
    
    local appendMsg=""
    if timeOut/1000 < 200 then
        appendMsg= appendMsg .." / "..(timeOut/1000)    
    end
    
    local runTime = 0  
    
    while true do
        if xGame.Find(colors,isClick) then
            xGame.MsgClose()
            return true
        else
            xGame.Show("等待["..colors[1].."]["..colors[2].."] --->计时: "..(runTime/1000)..appendMsg)
            if runTime >= timeOut then
                xGame.MsgClose()
                return false
            end
        end
        sleep(400)
        runTime = runTime + 400
    end    
end

--找色 并 多次确认
--	colors: find 色点
--	isClick: 是否点击 (可空)
--	maxCount: 最大的验证次数
--	sleepTime: 间隔时间
function xGame.FindManyTimes(...)
    --colors,isClick,maxCount,sleepTime,isKeep,countOut
    local arr= {...}
    
    local colors= arr[1]
    local isClick=false
    local maxCount= 0
    local sleepTime = 0
    local isCallKeep = true
    local countOut = 0
    
    if type(arr[2])=="boolean" then
        isClick=arr[2] 
        maxCount= arr[3]
        sleepTime = arr[4]
        isCallKeep= arr[5] or true
        countOut= arr[6] or 5
    else
        maxCount= arr[2]
        sleepTime = arr[3]
        isCallKeep= arr[4] or true
        countOut= arr[5] or 5
    end
    
    local count = 0 
    
    while true do        
        
        local findRes=false
        
        if isCallKeep then                       
            findRes =xGame.Find(colors,isClick)            
        else            
            findRes =xGame.FindNoCallKeep(colors,isClick)
        end
        
        if findRes then
            count = count + 1 
            
            xGame.Show("验证["..colors[1].."]["..colors[2].."] --->次数: "..count.." / ".. maxCount)
            
            if count == maxCount then
                xGame.MsgClose()
                return true
            end
            
        else
            xGame.MsgClose()
            return false
        end    
        
        sleep(sleepTime)
    end 
end


--开关
--	name: 唯一名称 	(进入一次后. 需要手动开启才可以再进入)
-------------------------
function xGame.Switch(name)
    return XM.Switch(name)
end

--偏移点击
--	x,y: 坐标
-- 	r: 偏移量
function xGame.RndTap(x, y,msg, r)
    if msg~="" and msg~=nil then
        xGame.Show("点击: "..msg)   
    end
    return XM.RndTap(x, y, r)
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

--关闭信息框
function xGame.MsgClose()
    XM.MsgClose()
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


--数组/表  是否包含某个值
--	arr: 表
--	val: 要检查的值
-- 	返回格式 : { 结果true/false , 位置下标}
function xGame.ArrContainVal(arr,val)   
    
    if type(arr) ~="table" then
        lineprint("xGame.ArrContainVal: arr不是table 类型")
        return false        
    end
    
    for i=1,#arr,1 do
        if arr[i] == val then
            return {true,i}
        end
    end
    
    return {false,0}
end


--------------------Util--END---------------