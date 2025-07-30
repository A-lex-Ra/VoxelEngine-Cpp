local PriorityQueue = require("priority_queue")

local Timer = {}
Timer.__index = Timer

local active_timers = PriorityQueue:new()
local paused_timers = {}
local timer_id_counter = 0
local tickCounter = 0

local function get_current_time()
    return tickCounter
end

function Timer.create(name, delay, repetitions, callback, ...)
    if not (type(delay) == "number" and delay > 0) then
        error("Bad argument: delay; positive number expected, received " .. type(delay))
    end
    if not ((type(repetitions) == "number" and repetitions > 0) or (repetitions == "inf")) then
        error("Bad argument: repetitions; expected a positive number or the string \"inf\", received " .. tostring(repetitions))
    end
    local timer = {
        id = timer_id_counter,
        name = name or ("timer_" .. timer_id_counter),
        delay = delay,
        repetitions = (repetitions ~= "inf") and repetitions or nil,
        is_loop = repetitions == "inf",
        calls_counter = 0,
        callback = callback,
        args = {...},
        next_call_time = get_current_time() + delay,
        paused = false
    }
    -- print("created timer: " .. timer.name .. " with id " .. timer.id)
    active_timers:push(timer, timer.next_call_time)
    timer_id_counter = timer_id_counter + 1
    
    return timer.id
end

function Timer.delay(delay, callback, ...)
    return Timer.create("delay_timer_" .. get_current_time(), delay, 1, callback, ...)
end

function Timer.interval(delay, repetitions, callback, ...)
    if type(repetitions) ~= "number" and repetitions ~= "inf" then
        error("Bad argument: repetitions; must be a positive number or \"inf\", received " .. repetitions)
    end
    return Timer.create("interval_timer_" .. get_current_time(), delay, repetitions, callback, ...)
end

function Timer.loop(delay, callback, ...)
    return Timer.create("interval_timer_" .. get_current_time(), delay, "inf", callback, ...)
end

-- executing what needs to be executed, deleting what needs to be deleted
function on_world_tick()
    local currentTime = get_current_time()
    -- local start = os.clock()
    if active_timers:is_empty() then return end --unnecessary but cool
    local timer = active_timers:front()

    while timer and currentTime >= timer.next_call_time do
        local success, err = pcall(timer.callback, unpack(timer.args))
        timer.calls_counter = timer.calls_counter + 1
        
        if not success then
            print("Timer error (" .. timer.name .. "): " .. err)
            -- Optionally log the error to a file or system logger here
            -- Optionally re-raise the error if you want to stop execution
            -- error("Timer callback failed: " .. err)
        end

        if timer.is_loop or (timer.repetitions and timer.calls_counter < timer.repetitions) then
            timer.next_call_time = currentTime + timer.delay
            active_timers:update_front_priority(timer.next_call_time)
        else
            active_timers:pop()
        end

        timer = active_timers:front()
    end

    tickCounter = tickCounter + 1
    -- print("ticktimer tick time: " ..(os.clock() - start) )
end


function Timer.pause(id)
  local timer = active_timers:get_by_id(id)
  if timer then
    timer.paused = true
    timer.remaining_time = timer.next_call_time - get_current_time()
    paused_timers[timer.id] = timer
    active_timers:remove_by_id(id)
    return true
  end
  return false
end

function Timer.resume(id)
  local timer = paused_timers[id]
  if timer then
    timer.paused = false
    local remaining = timer.remaining_time or timer.delay
    timer.next_call_time = get_current_time() + remaining
    timer.remaining_time = nil
    active_timers:push(timer, timer.next_call_time)
    paused_timers[id] = nil
    return true
  end
  return false
end

function Timer.exists(id)
    return active_timers:exists(id) or paused_timers[id] ~= nil
end

function Timer.get_data(id)
  local timer = active_timers:get_by_id(id) or paused_timers[id]
  if timer then
    return table.deep_copy(timer)
  end
  return nil
end

function Timer.destroy(id)
    if active_timers:exists(id) then
        active_timers:remove_by_id(id)
        return true
    end
    if paused_timers[id] then
        paused_timers[id] = nil
        return true
    end
    return false
end

function Timer.is_paused(id)
    return paused_timers[id] ~= nil
end

function Timer.is_active(id)
    return active_timers:exists(id)
end

function Timer.time_to_next_call(id)
    if not Timer.is_active(id) then return nil end
    return math.max(0, active_timers:get_by_id(id).next_call_time - get_current_time())
end

function Timer.remaining_time(id)
    if not Timer.is_paused(id) then
      return Timer.time_to_next_call(id)
    end
    local timer = paused_timers[id]
    if timer and timer.remaining_time then
      return timer.remaining_time
    end
    return nil
end

function Timer.destroy_all()
    active_timers = PriorityQueue:new()
    paused_timers = {}
    timer_id_counter = 0
    tickCounter = 0
end

-- function Timer.get_active_timers_queue()
--     return active_timers
-- end

return Timer