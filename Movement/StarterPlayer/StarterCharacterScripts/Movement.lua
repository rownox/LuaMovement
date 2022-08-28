local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")

local TweenService = game:GetService("TweenService")
local statModule = require(RS.PlayerStats.StatModule)
local AnimationFolder = RS.Animations.DashAndRun

local player = game.Players.LocalPlayer
local Char = player.Character or player.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")
local HRP = Char:WaitForChild("HumanoidRootPart")

local Event = script:WaitForChild("Event")
local Run = RS:WaitForChild("Run")
local StaminaOut = RS:WaitForChild("StaminaOut")
local Slided = RS:WaitForChild("Slide")
local Dashed = RS:WaitForChild("Dash")

-- MODIFY SPEED
local run = 23 
local walk = 14
local DebounceTime = 0.2

-- ANIMATIONS
local ForwardDashAnime = Hum:LoadAnimation(AnimationFolder:WaitForChild("ForwardDash"))
local BackDashAnime =  Hum:LoadAnimation(AnimationFolder:WaitForChild("BackDash"))
local LeftDashAnime = Hum:LoadAnimation(AnimationFolder:WaitForChild("LeftDash"))
local RightDashAnime =  Hum:LoadAnimation(AnimationFolder:WaitForChild("RightDash"))
local RunFront =  Hum:LoadAnimation(game.ReplicatedStorage.Animations.Run)
local WalkRight = Hum:LoadAnimation(game.ReplicatedStorage.Animations.WalkRight)
local WalkLeft = Hum:LoadAnimation(game.ReplicatedStorage.Animations.WalkLeft)
local slideAnim =  Hum:LoadAnimation(game.ReplicatedStorage.Animations.Slide)

-- Sprint
UIS.InputBegan:Connect(function(key, txt)
	if txt then return end
	slide(key)
	if (key.KeyCode == Enum.KeyCode.X) then
		RunFront:Stop()
		WalkLeft:Stop()
		WalkRight:Stop()
	elseif (UIS:IsKeyDown(Enum.KeyCode.X)) then
		return
	elseif (key.KeyCode == Enum.KeyCode.LeftShift) then
		if (UIS:IsKeyDown(Enum.KeyCode.W)) then
			if (UIS:IsKeyDown(Enum.KeyCode.D) or UIS:IsKeyDown(Enum.KeyCode.A)) then
				return
			else
				if (statModule.getStamina(player.UserId) <= 0) then return end
				RunFront:Play()
				player.Character.Humanoid.WalkSpeed = run
			end
		end
	elseif (key.KeyCode == Enum.KeyCode.W) then
		if (UIS:IsKeyDown(Enum.KeyCode.LeftShift)) then
			if (UIS:IsKeyDown(Enum.KeyCode.D) or UIS:IsKeyDown(Enum.KeyCode.A)) then
				return
			else
				if (statModule.getStamina(player.UserId) <= 0) then return end
				RunFront:Play()
				player.Character.Humanoid.WalkSpeed = run
			end
		end
	elseif (key.KeyCode == Enum.KeyCode.A) then
		if (UIS:IsKeyDown(Enum.KeyCode.W) and UIS:IsKeyDown(Enum.KeyCode.LeftShift) and not UIS:IsKeyDown(Enum.KeyCode.D)) then
			player.Character.Humanoid.WalkSpeed = walk
			RunFront:Stop()
			WalkLeft:Play()
		elseif (UIS:IsKeyDown(Enum.KeyCode.D)) then
			WalkRight:Stop()
		else
			WalkLeft:Play()
		end
	elseif (key.KeyCode == Enum.KeyCode.S) then
		if (UIS:IsKeyDown(Enum.KeyCode.W) and UIS:IsKeyDown(Enum.KeyCode.LeftShift)) then
			player.Character.Humanoid.WalkSpeed = walk
			RunFront:Stop()
		end
	elseif (key.KeyCode == Enum.KeyCode.D) then
		if (UIS:IsKeyDown(Enum.KeyCode.W) and UIS:IsKeyDown(Enum.KeyCode.LeftShift) and not UIS:IsKeyDown(Enum.KeyCode.A)) then
			player.Character.Humanoid.WalkSpeed = walk
			RunFront:Stop()
			WalkRight:Play()
		elseif (UIS:IsKeyDown(Enum.KeyCode.A)) then
			WalkLeft:Stop()
		else
			WalkRight:Play()
		end
	end
end)

UIS.InputEnded:Connect(function(key, txt)
	if txt then return end
	if (UIS:IsKeyDown(Enum.KeyCode.X)) then
		return
	elseif (key.KeyCode == Enum.KeyCode.LeftShift) then
		if (UIS:IsKeyDown(Enum.KeyCode.W)) then
			player.Character.Humanoid.WalkSpeed = walk
			RunFront:Stop()
		end
	elseif (key.KeyCode == Enum.KeyCode.W) then
		if (UIS:IsKeyDown(Enum.KeyCode.LeftShift)) then
			player.Character.Humanoid.WalkSpeed = walk
			RunFront:Stop()
		end
	elseif (key.KeyCode == Enum.KeyCode.A) then
		if (UIS:IsKeyDown(Enum.KeyCode.D)) then
			WalkRight:Play()
		elseif (UIS:IsKeyDown(Enum.KeyCode.W) and UIS:IsKeyDown(Enum.KeyCode.LeftShift)) then
			if (statModule.getStamina(player.UserId) <= 0) then player.Character.Humanoid.WalkSpeed = walk else
				RunFront:Play()
				player.Character.Humanoid.WalkSpeed = run
			end
			WalkLeft:Stop()
		else
			WalkLeft:Stop()
		end
	elseif (key.KeyCode == Enum.KeyCode.S) then
		if (UIS:IsKeyDown(Enum.KeyCode.W) and UIS:IsKeyDown(Enum.KeyCode.LeftShift)) then
			if (statModule.getStamina(player.UserId) <= 0) then return end
			RunFront:Play()
			player.Character.Humanoid.WalkSpeed = run
		end
	elseif (key.KeyCode == Enum.KeyCode.D) then
		if (UIS:IsKeyDown(Enum.KeyCode.A)) then
			WalkLeft:Play()
		elseif (UIS:IsKeyDown(Enum.KeyCode.W) and UIS:IsKeyDown(Enum.KeyCode.LeftShift)) then
			if (statModule.getStamina(player.UserId) <= 0) then player.Character.Humanoid.WalkSpeed = walk else
				RunFront:Play()
				player.Character.Humanoid.WalkSpeed = run
			end
			WalkRight:Stop()
		else
			WalkRight:Stop()
		end
	end	
end)

-- Dash
function dash(Vector, Animation, Modifier) 
	local groundColor = Hum.FloorMaterial
	local Tween = TweenService:Create(HRP,TweenInfo.new(DebounceTime,Enum.EasingStyle.Linear,Enum.EasingDirection.Out),{Velocity = Vector * Modifier})
	Tween:Play()
	Animation:Play()
	delay(DebounceTime + 0.1,function()
		Animation:Stop()
		statModule.setIsDashing(player.UserId, false)
	end)
end

UIS.InputBegan:Connect(function(Key,IsTyping)
	if (statModule.getStamina(player.UserId) - 4) <= 0 then return end
	if IsTyping then return end
	if not (Hum.FloorMaterial ~= Enum.Material.Air and Hum.FloorMaterial ~= Enum.Material.Water) then return end
	if (UIS:IsKeyDown(Enum.KeyCode.X)) then return end
	if (UIS:IsKeyDown(Enum.KeyCode.Space)) then return end
	if Key.KeyCode == Enum.KeyCode.Q then
		if statModule.getDebounce(player.UserId) == false and Char:FindFirstChild("Deb") == nil then
			statModule.setDebounce(player.UserId, true)
			delay(DebounceTime + 0.7,function()
				statModule.setDebounce(player.UserId, false)
			end)
			statModule.setIsDashing(player.UserId, true)
			if UIS:IsKeyDown(Enum.KeyCode.W) then
				dash(HRP.CFrame.LookVector, ForwardDashAnime, 80)
			elseif UIS:IsKeyDown(Enum.KeyCode.A) then
				dash(HRP.CFrame.RightVector, LeftDashAnime, -90)
			elseif UIS:IsKeyDown(Enum.KeyCode.S) then
				dash(HRP.CFrame.LookVector, BackDashAnime, -80)
			elseif UIS:IsKeyDown(Enum.KeyCode.D) then
				dash(HRP.CFrame.RightVector, RightDashAnime, 90)
			end
		end
	end
end)

-- Slide
function slide(key) 
	if (statModule.getStamina(player.UserId) - 4) <= 0 then return end
	if not statModule.getCanSlide(player.UserId) then return end
	if not (Hum.FloorMaterial ~= Enum.Material.Air and Hum.FloorMaterial ~= Enum.Material.Water) then return end
	if statModule.getDebounce(player.UserId) == true then return end
	if (UIS:IsKeyDown(Enum.KeyCode.Space)) then return end
	if (UIS:IsKeyDown(Enum.KeyCode.X)) then
		return
	elseif (key.KeyCode == Enum.KeyCode.F and UIS:IsKeyDown(Enum.KeyCode.W)) then
		statModule.setDebounce(player.UserId, true)
		player.Character.Humanoid.JumpPower = 0
		delay(DebounceTime + 0.7,function()
			statModule.setDebounce(player.UserId, false)
			player.Character.Humanoid.JumpPower = 30
		end)

		slideAnim:Play()

		local slide = Instance.new("BodyVelocity")
		slide.MaxForce = Vector3.new(1,0,1)*10000
		slide.Velocity = Char.HumanoidRootPart.CFrame.lookVector*100
		slide.Parent = Char.HumanoidRootPart

		for count = 1,8 do
			wait(0.1)
			slide.Velocity*=0.7
		end
		slideAnim:Stop()
		slide:Destroy()
	end
end