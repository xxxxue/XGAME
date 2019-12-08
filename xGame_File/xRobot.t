
-----------------Global---Variable----START-------------------

Unit = {}
Unit.State = {}
Unit.State.Name = "" --脚本启动的入口(需自定义)
Unit.Param = {}

H = {}

HomeKeyPositionEnum = {}

-----------------Global---Variable----END-------------------

----------------Options-Table------START--------------------

--脚本机器人 设置
H["ScriptRobot_Options"] = {

sleep_time = 1000            --运行间隔

, loop_sw = true            --脚本整体是否无限循环

, xmlog_sw = true            --xm调试日志开关

, applog_sw = false        --app日志 开关	(会记录在app的目录中)

, ide_print_sw = false			--IDE 控制台  普通输出
}

--脚本设置
H["Script_Options"] = {

scale_xy = { 720, 1280 }                        --编写脚本的分辨率

, msgbox_position_xy = { 129, 709 }            --屏幕显示信息的位置

, center_msgbox_position_xy = { 43, 290 }        --屏幕中心显示信息的位置

, homekey_position = "下"                    --home键位置(竖屏:下 横屏:右)

, logfolder_name = "xGame日志"            --存放日志的文件夹

, zd_floatwindow_location_xy = { 702, 243 }    --指端悬浮窗位置(脚本启动后自动调整位置)
}
----------------Options-Table-------END--------------------

xRobot={}

-- 指定 脚本 任务 入口
function xRobot.Run(name)
    if name=="" or name == nil then
        while true do
            
            lineprint("xRobot.Run  name 不能为空")
            sleep(3000)
        end
    end
    Unit.State.Name=name
end

-- 注册 任务
--	name: 任务名称
--	par: 传入参数table 或者 方法体
--  fun: par 传入参数table后, 这个fun就是 方法体
--	例子在 xGame.t 顶部
function xRobot.Task(name,par,fun)    
    if fun then
        Unit.Param[name]=par
        Unit.Param[name]["name"]=name 
        Unit.State[name]=fun
        
    else        
        Unit.Param[name]={}
        Unit.Param[name]["name"]=name 
        Unit.State[name]=par
    end
end

---------------------Getter--Setter---START--------------------

--机器人
function xRobot.Get_Robot_Options(key)
    return H["ScriptRobot_Options"][key]
end
function xRobot.Set_Robot_Options(key,val)
    H["ScriptRobot_Options"][key]=val
end

--脚本
function xRobot.Get_Script_Options(key)
    return H["Script_Options"][key]
end
function xRobot.Set_Script_Options(key,val)
    H["Script_Options"][key]=val
end
---------------------Getter--Setter---END--------------------


-----------------FrameWork--START----------------

--状态机主程序
function xRobot.Main()
    --异常处理
    local res, error = pcall(
    function()
    --调用状态机
    Unit.State.Name = xRobot.ProcessState(    
    Unit.State, --所有状态
    Unit.State.Name, --调用的状态
    Unit.Param[Unit.State.Name]        --调用状态的参数    
    )    
 
    --休息间隔
    local sTime = xRobot.Get_Robot_Options("sleep_time")
    sleep(sTime)    
    XM.MsgClose() --关闭屏幕信息
    end)
    --提示并记录 错误信息
    if res == false then
        
        xGame.Show("发生了错误!!!! \n" .. error)
        
        if xGame.WriteFile(error) then
            xGame.Show("日志记录成功..")
            
        end
    end    
end


--初始化全局变量
function xRobot.InitGlobalVariable()
    --home 枚举
    HomeKeyPositionEnum = { 下 = 0, 右 = 1, 左 = 2, 上 = 3, }
end

--初始化脚本框架
function xRobot.InitFrameWork()
    
    require("XM")        --加载XM
    
    xRobot.InitGlobalVariable()
    
    setmetatable(xGame,{__index=XM})	--继承 XM 的所有方法
    
    XM.AddTable(H) --添加 XM 特征表
    
    --打开 XM Log日志
    local xmlog_sw = xRobot.Get_Robot_Options("xmlog_sw")
    
    if xmlog_sw then
        XM.XMLogExOpen()
    end
    
    --打开 独立apk log日志
    local applog_sw = xRobot.Get_Robot_Options("applog_sw")
    if applog_sw then
        logopen()
    end
    
    --设置编写脚本时的分辨率,用于同比例屏幕适配
    local scale_xy = xRobot.Get_Script_Options("scale_xy")
    XM.SetScale(scale_xy[1], scale_xy[2])
    
    --设置 Home 键位置
    local homekeyPos = xRobot.Get_Script_Options("homekey_position")
    setrotatescreen(HomeKeyPositionEnum[homekeyPos])
    
    traceprint("xGame Init finish !")
end

--状态机调用对应的方法
function xRobot.ProcessState (stateTable, stateName, stateParam)
    
    if stateTable[stateName] ~= nil then
        return stateTable[stateName](stateParam)
    end
    xGame.Print(stateTable)	
    lineprint("没有找到 【"..stateName.."】")
    return "Error"
end

--
--悬浮窗启动按钮入口
--
function floatwinrun()
    
    xRobot.InitFrameWork()
    
    if Unit.State.Name ~= "" then
        lineprint("脚本开始")
        if xRobot.Get_Robot_Options("loop_sw") then
            while true do
                --所有脚本执行完毕 无限循环
                xRobot.Main()
            end
        else
            xRobot.Main()        --所有脚本执行完毕 停止
        end
    else
        traceprint("程序异常,状态机 State.Name 为空,请使用xRobot.Run 指定入口")
    end
    lineprint("脚本结束")
    sleep(1000)
    XM.MsgClose()
end

-----------------FrameWork--END----------------