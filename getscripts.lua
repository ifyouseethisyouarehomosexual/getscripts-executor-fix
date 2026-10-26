local env = getgenv()
if env.gsfix then env.gsfix.stop() end
local gsfix = {state={
        old=nil,
        active=false,
    }
}
gsfix.scan = function(): {LuaSourceContainer}
    local out, seen = {}, {}
    local function add(i: Instance): ()
        if seen[i] or not i:IsA("LuaSourceContainer") then return end
        seen[i]=true
        out[#out+1]=i
    end
    local ok, got = pcall(gsfix.state.old)
    if ok and type(got)=="table" then for _, i in ipairs(got) do add(i) end end
    for _, i in ipairs(game:GetDescendants()) do add(i) end
    if getnilinstances then
        for _, i in ipairs(getnilinstances()) do
            add(i)
            for _, d in ipairs(i:GetDescendants()) do add(d) end
        end
    end
    return out
end
gsfix.start = function(): ()
    if gsfix.state.active or not getscripts then return end
    gsfix.state.active=true
    if hookfunction then
        gsfix.state.old=hookfunction(getscripts,newcclosure and newcclosure(gsfix.scan) or gsfix.scan)
    else
        gsfix.state.old=getscripts
        env.getscripts=gsfix.scan
    end
end
gsfix.stop = function(): ()
    if not gsfix.state.active then return end
    gsfix.state.active=false
    if hookfunction then
        if restorefunction then restorefunction(getscripts) else hookfunction(getscripts,gsfix.state.old) end
    else
        env.getscripts=gsfix.state.old
    end
    env.gsfix=nil
end
env.gsfix=gsfix
gsfix.start()
