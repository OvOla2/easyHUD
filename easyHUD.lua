-- easyHUDv1.0 - 玩家状态显示系统
-- easyHUDv1.0 - Player Status Display System
-- License:MIT
-- Author:OvOla2

local easyHUD = {}

-- 变量声明 / Variable Declarations
local lastUpdate = 0  -- 上次更新计时器 / Last update timer
local UPDATE_INTERVAL = 5  -- 更新间隔（单位：tick） / Update interval (in ticks)

-- 文本任务存储 / Text task storage
local textTasks = {}
-- 存储文本配置 / Store text configurations
local textConfigs = {}

-- 初始化HUD和文本任务 / Initialize HUD and text tasks
local function initHUD()

    -- 创建文本任务 / Create text tasks
    textTasks.health = models.model.Hud.health_text:newText("health_text")
    textTasks.hunger = models.model.Hud.hunger_text:newText("hunger_text")
    textTasks.saturation = models.model.Hud.saturation_text:newText("saturation_text")
    textTasks.experience = models.model.Hud.experience_text:newText("experience_text")
    textTasks.oxygen = models.model.Hud.oxygen_text:newText("oxygen_text")
    textTasks.absorption = models.model.Hud.absorption_text:newText("absorption_text")

    -- 默认文本配置 / Default text configurations
    textConfigs = {
        health = {x = 10, y = 0, z = 0, scale = 0.5},
        absorption = {x = 10, y = 0, z = 0, scale = 0.5},
        hunger = {x = 10, y = 0, z = 0, scale = 0.5},
        saturation = {x = 10, y = 0, z = 0, scale = 0.5},
        experience = {x = 10, y = 0, z = 0, scale = 0.5},
        oxygen = {x = 10, y = 0, z = 0, scale = 0.5},
    }

    -- 应用文本配置 / Apply text configurations
    for name, task in pairs(textTasks) do
        if textConfigs[name] then
            task:setPos(textConfigs[name].x, textConfigs[name].y, textConfigs[name].z)
            task:setScale(textConfigs[name].scale, textConfigs[name].scale, textConfigs[name].scale)
        end
    end

    -- 确保HUD可见 / Ensure HUD is visible
    models.model.Hud:setVisible(true)
end

-- 更新生命值显示 / Update health display
local function updateHealth()
    if not player:isLoaded() then return end  -- 玩家未加载时返回 / Return if player not loaded

    local health = player:getHealth()  -- 当前生命值 / Current health
    local maxHealth = player:getMaxHealth()  -- 最大生命值 / Maximum health
    local healthPercent = math.min(health / maxHealth, 1.0)  -- 生命值百分比 / Health percentage

    -- 更新前景条 / Update foreground bar
    if models.model.Hud.health_foreground then
        models.model.Hud.health_foreground:setScale(healthPercent, 1, 1)
    end

    -- 更新文本显示 / Update text display
    if textTasks.health then
        textTasks.health:setText(string.format("❤ %.1f/%.1f", health, maxHealth))
    end
end

-- 更新伤害吸收显示 / Update absorption display
local function updateAbsorption()
    if not player:isLoaded() then return end

    local absorption = player:getAbsorptionAmount()  -- 伤害吸收值 / Absorption amount
    local absorptionPercent = math.min(absorption / 20.0, 1.0)  -- 伤害吸收百分比 / Absorption percentage

    if models.model.Hud.absorption_foreground then
        models.model.Hud.absorption_foreground:setScale(absorptionPercent, 1, 1)
    end

    if textTasks.absorption then
        textTasks.absorption:setText(string.format("🛡 %.1f", absorption))
    end
end

-- 更新饥饿值显示 / Update hunger display
local function updateHunger()
    if not player:isLoaded() then return end

    local food = player:getFood()  -- 当前饥饿值 / Current food level
    local foodPercent = math.max(0, math.min(food / 20.0, 1.0))  -- 饥饿值百分比 / Food percentage

    if models.model.Hud.hunger_foreground then
        models.model.Hud.hunger_foreground:setScale(foodPercent, 1, 1)
    end

    if textTasks.hunger then
        textTasks.hunger:setText(string.format("🍖 %d/20", food))
    end
end

-- 更新饱和度显示 / Update saturation display
local function updateSaturation()
    if not player:isLoaded() then return end

    local saturation = player:getSaturation()  -- 饱和度值 / Saturation value
    local saturationInt = math.floor(saturation)  -- 取整 / Convert to integer
    saturationInt = math.max(0, math.min(saturationInt, 20))  -- 限制范围 / Clamp value
    local saturationPercent = saturationInt / 20.0  -- 饱和度百分比 / Saturation percentage

    if models.model.Hud.saturation_foreground then
        models.model.Hud.saturation_foreground:setScale(saturationPercent, 1, 1)
    end

    if textTasks.saturation then
        -- 显示整数饱和度值 / Display integer saturation value
        textTasks.saturation:setText(string.format("🥐 %d", saturationInt))
    end
end

-- 更新经验值显示 / Update experience display
local function updateExperience()
    if not player:isLoaded() then return end

    local expProgress = player:getExperienceProgress()  -- 经验进度 / Experience progress
    local expLevel = player:getExperienceLevel()  -- 经验等级 / Experience level

    if models.model.Hud.experience_foreground then
        models.model.Hud.experience_foreground:setScale(expProgress, 1, 1)
    end

    if textTasks.experience then
        textTasks.experience:setText(string.format("🌟 Lv.%d (%.1f%%)", expLevel, expProgress * 100))
    end
end

-- 更新氧气值显示 / Update oxygen display
local function updateOxygen()
    if not player:isLoaded() then return end

    local viewer = client:getViewer()  -- 获取观察者 / Get viewer
    local air = viewer:getAir()  -- 当前氧气值 / Current air
    local maxAir = viewer:getMaxAir()  -- 最大氧气值 / Maximum air

    air = math.max(0, air)  -- 确保非负 / Ensure non-negative

    local airPercent = 0
    if maxAir > 0 then
        airPercent = math.max(0, math.min(air / maxAir, 1.0))  -- 氧气百分比 / Oxygen percentage
    end

    if models.model.Hud.oxygen_foreground then
        models.model.Hud.oxygen_foreground:setScale(airPercent, 1, 1)
    end

    if textTasks.oxygen then
        textTasks.oxygen:setText(string.format("🫧 %d/%d", air, maxAir))
    end
end

-- 更新状态效果 / Update status effects
local function updateStatus()
    if not player:isLoaded() then return end

    if models.model.Hud.fire_status then
        models.model.Hud.fire_status:setVisible(player:isOnFire())  -- 显示燃烧状态 / Show fire status
    end
end

-- 主更新函数 / Main update function
local function updateHUD()
    if not player:isLoaded() then return end

    -- 计时器控制 / Timer control
    lastUpdate = lastUpdate + 1
    if lastUpdate < UPDATE_INTERVAL then return end
    lastUpdate = 0

    -- 更新所有状态显示 / Update all status displays
    updateHealth()
    updateAbsorption()
    updateHunger()
    updateSaturation()
    updateExperience()
    updateOxygen()
    updateStatus()
end

-- ========== API函数 / API Functions ==========

-- 设置单个文本任务位置 / Set single text task position
function easyHUD.setTextPosition(textName, x, y, z)
    if textTasks[textName] then
        textTasks[textName]:setPos(x, y, z or 0)
        if textConfigs[textName] then
            textConfigs[textName].x = x
            textConfigs[textName].y = y
            textConfigs[textName].z = z or 0
        end
    else
        log("错误：找不到文本任务 '" .. textName .. "' / Error: Text task '" .. textName .. "' not found")
    end
end

-- 设置单个文本任务缩放 / Set single text task scale
function easyHUD.setTextScale(textName, scale)
    if textTasks[textName] then
        if type(scale) == "number" then
            textTasks[textName]:setScale(scale, scale, scale)
        elseif type(scale) == "table" then
            textTasks[textName]:setScale(scale.x or 1, scale.y or 1, scale.z or 1)
        end
        if textConfigs[textName] then
            if type(scale) == "number" then
                textConfigs[textName].scale = scale
            end
        end
    else
        log("错误：找不到文本任务 '" .. textName .. "' / Error: Text task '" .. textName .. "' not found")
    end
end

-- 设置单个文本任务可见性 / Set single text task visibility
function easyHUD.setTextVisible(textName, visible)
    if textTasks[textName] then
        textTasks[textName]:setVisible(visible)
    else
        log("错误：找不到文本任务 '" .. textName .. "' / Error: Text task '" .. textName .. "' not found")
    end
end

-- 批量设置所有文本任务位置 / Batch set all text task positions
function easyHUD.setAllTextPositions(positions)
    for name, task in pairs(textTasks) do
        if positions[name] then
            task:setPos(positions[name].x, positions[name].y, positions[name].z or 0)
            if textConfigs[name] then
                textConfigs[name].x = positions[name].x
                textConfigs[name].y = positions[name].y
                textConfigs[name].z = positions[name].z or 0
            end
        end
    end
end

-- 批量设置所有文本任务缩放 / Batch set all text task scales
function easyHUD.setAllTextScales(scales)
    for name, task in pairs(textTasks) do
        if scales[name] then
            if type(scales[name]) == "number" then
                task:setScale(scales[name], scales[name], scales[name])
                if textConfigs[name] then
                    textConfigs[name].scale = scales[name]
                end
            elseif type(scales[name]) == "table" then
                task:setScale(scales[name].x or 1, scales[name].y or 1, scales[name].z or 1)
            end
        end
    end
end

-- 获取文本任务位置 / Get text task position
function easyHUD.getTextPosition(textName)
    if textConfigs[textName] then
        return {
            x = textConfigs[textName].x,
            y = textConfigs[textName].y,
            z = textConfigs[textName].z
        }
    end
    return nil
end

-- 获取文本任务缩放 / Get text task scale
function easyHUD.getTextScale(textName)
    if textConfigs[textName] then
        return textConfigs[textName].scale
    end
    return nil
end

-- HUD位置调整函数 / HUD position adjustment function
function easyHUD.setHUDPosition(x, y, z)
    if models.model.Hud then
        models.model.Hud:setPos(x, y, z or 0)
    end
end

-- HUD缩放调整函数 / HUD scale adjustment function
function easyHUD.setHUDScale(scale)
    if models.model.Hud then
        if type(scale) == "number" then
            models.model.Hud:setScale(scale, scale, scale)
        elseif type(scale) == "table" then
            models.model.Hud:setScale(scale.x or 1, scale.y or 1, scale.z or 1)
        end
    end
end

-- 设置HUD可见性 / Set HUD visibility
function easyHUD.setHUDVisible(visible)
    if models.model.Hud then
        models.model.Hud:setVisible(visible)
    end
end

-- 获取HUD位置 / Get HUD position
function easyHUD.getHUDPosition()
    if models.model.Hud then
        return models.model.Hud:getPos()
    end
    return nil
end

-- 获取HUD缩放 / Get HUD scale
function easyHUD.getHUDScale()
    if models.model.Hud then
        return models.model.Hud:getScale()
    end
    return nil
end

-- 获取所有文本任务名称 / Get all text task names
function easyHUD.getTextTaskNames()
    local names = {}
    for name, _ in pairs(textTasks) do
        table.insert(names, name)
    end
    return names
end

-- ========== 事件注册 / Event Registration ==========

-- 注册tick事件 / Register tick event
events.tick:register(function()
    updateHUD()
end, "easyHUD_update")

-- 注册entity_init事件 / Register entity_init event
events.entity_init:register(function()
    initHUD()
    easyHUD.setHUDPosition(0, -20)
    easyHUD.setHUDScale(2)
end, "easyHUD_init")

return easyHUD
