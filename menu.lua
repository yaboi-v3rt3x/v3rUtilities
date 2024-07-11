getgenv().SecureMode = true
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "v3rMenu",
   LoadingTitle = "v3rMenu",
   LoadingSubtitle = "by v3rt3x",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = v3rHub, 
      FileName = "config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false,
   KeySettings = {
      Title = "v3rMenu",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided",
      FileName = "Key",
      SaveKey = true,
      GrabKeyFromSite = false,
      Key = {"v3rt3x"} 
   }
})



Rayfield:LoadConfiguration()
