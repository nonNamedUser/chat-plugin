--[[
MIT License
(c) 2026 nonNamedUser
https://github.com/nonNamedUser/chat-plugin
]]

assert(plugin, "Please run this as a plugin")

local StudioService = game:GetService("StudioService")
local https=game:GetService("HttpService")
local url="https://users.roproxy.com/v1/users/"

local userId = StudioService:GetUserId()

if userId == 0 then return end

local toolbar = plugin:CreateToolbar("Chatin'")
local button = toolbar:CreateButton(
	"Chat!",
	"Chattin thing",
	"http://www.roblox.com/asset/?id=127305073924596"
)

local widgetInfo = DockWidgetPluginGuiInfo.new(
	Enum.InitialDockState.Float,
	false,
	false,
	995,  
	643, 
	30,
	30
)

local widget = plugin:CreateDockWidgetPluginGuiAsync(
	"Chat Window",
	widgetInfo
)

widget.Title = "Chat Window"
widget.Enabled = false

local ui=script.Parent.UI:Clone()

ui.Parent=widget

button.Click:Connect(function()
	widget.Enabled=not widget.Enabled
end)

local folder=game.ServerStorage:FindFirstChild("K_ChatPlugin") or Instance.new("Folder",game.ServerStorage)
folder.Name="K_ChatPlugin"

local s=folder:FindFirstChild("DO NOT DELETE ANYTHING OR ADD ANYTHING INSIDE THIS FOLDER") or Instance.new("StringValue",folder)
s.Name="DO NOT DELETE ANYTHING OR ADD ANYTHING INSIDE THIS FOLDER"

--local remote=folder:FindFirstChild("Event") or Instance.new("BindableEvent",folder)

local myFolder=folder:FindFirstChild(userId) or Instance.new("Folder",folder)
myFolder.Name=userId

local bg=myFolder:FindFirstChild("bg") or Instance.new("Folder",myFolder)
bg.Name="bg"

local msg=myFolder:FindFirstChild("msg") or Instance.new("StringValue",myFolder);msg.Name="msg"

local uiGrad=bg:FindFirstChild("UIGradient") or script.UIGradient:Clone()
uiGrad.Parent=bg

local timeout=0
local running=false

local SoundService = game:GetService("SoundService")

local sound=Instance.new("Sound")
sound.SoundId="rbxassetid://17208361335"
sound.Volume=0.5
sound.Parent=widget
function t()
	running=true
	sound:Play()
	while task.wait(1) do
		--print(timeout)
		if timeout == 1 then
			timeout=0
			running=false
			break
		end
		timeout-=1
	end
end

for _, g in folder:GetChildren() do
	if g:IsA("Folder") then
		local template=ui.ScrollingFrame.Template:Clone()
		template.userid.Value=tonumber(g.Name)
		template.msg.Text=g.msg.Value
		pcall(function()
			template.ImageLabel.Image=game.Players:GetUserThumbnailAsync(tonumber(g.Name),Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)
		end)
		local s=pcall(function()
			local h=https:JSONDecode(https:GetAsync(url..g.Name))
			template.Display.Text=h["displayName"]
		end)
		if not s then
			pcall(function()
				template.Display.Text=game:GetService("Players"):GetNameFromUserIdAsync(tonumber(g.Name))
			end)
		end
		template.UIGradient.Color=g.bg.UIGradient.Color
		template.Parent=ui.ScrollingFrame
		g.bg.UIGradient.Changed:Connect(function(prop)
			if string.lower(prop)=="color" then
				template.UIGradient.Color=g.bg.UIGradient.Color
			end
		end)
		g.msg.Changed:Connect(function(val)
			if not running and g.Name~=tostring(userId) then
				timeout=7
				t()
			end
			template.msg.Text=val
		end)
		template.Parent=ui.ScrollingFrame
		template.Name=template.userid.Value
		template.Visible=true
	end
end

folder.ChildAdded:Connect(function(child)
	if child:IsA("Folder") then
		repeat task.wait() until tonumber(child.Name)
		local chbg=child:WaitForChild("bg")
		local chuigrad=bg:WaitForChild("UIGradient")
		local template=ui.ScrollingFrame.Template:Clone()
		local g=child
		template.userid.Value=tonumber(g.Name)
		template.msg.Text=g.msg.Value
		pcall(function()
			template.ImageLabel.Image=game.Players:GetUserThumbnailAsync(template.userid.Value,Enum.ThumbnailType.HeadShot,Enum.ThumbnailSize.Size420x420)
		end)
		local s=pcall(function()
			local h=https:JSONDecode(https:GetAsync(url..g.Name))
			template.Display.Text=h["displayName"]
		end)
		if not s then
			pcall(function()
				template.Display.Text=game:GetService("Players"):GetNameFromUserIdAsync(tonumber(g.Name))
			end)
		end
		template.UIGradient.Color=g.bg.UIGradient.Color
		template.Parent=ui.ScrollingFrame
		g.bg.UIGradient.Changed:Connect(function(prop)
			if string.lower(prop)=="color" then
				template.UIGradient.Color=g.bg.UIGradient.Color
			end
		end)
		g.msg.Changed:Connect(function(val)
			if not running and g.Name~=tostring(userId) then
				timeout=7
				t()
			end
			template.msg.Text=val
		end)
		template.Parent=ui.ScrollingFrame
		template.Name=template.userid.Value
		template.Visible=true
	end
end)

ui.Frame.TextBox.Changed:Connect(function(prop)
	if string.lower(prop)=="text" then
		--remote:Fire(userId,ui.Frame.TextBox.Text)
		msg.Value=ui.Frame.TextBox.Text
		plugin:SetSetting("msg",ui.Frame.TextBox.Text)
	end
end)

local data=plugin:GetSetting("msg")
if data then
	msg.Value=data
end
