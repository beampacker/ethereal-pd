--[[
    Notes:
    Synapse's text editor will show an error with typed lua, ignore it, it doesnt affect anything.

    For Pieta to do:
]]

if not LPH_OBFUSCATED then
    LPH_JIT = function(...) return ... end
    LPH_JIT_MAX = function(...) return ... end
    LPH_NO_VIRTUALIZE = function(...) return ... end
    LPH_NO_UPVALUES = function(f) return(function(...) return f(...) end) end
    LPH_ENCSTR = function(...) return ... end
    LPH_ENCNUM = function(...) return ... end
end;

--// Init
repeat wait() until game.IsLoaded(game);
--// Services
local function GetService(ServiceName)
    return game.GetService(game, ServiceName);
end;
local Players, ReplicatedStorage, ReplicatedFirst, Lighting, TweenService, CoreGui, RunService, UserInputService, TeleportService, HttpService = GetService("Players"), GetService("ReplicatedStorage"), GetService("ReplicatedFirst"), GetService("Lighting"), GetService("TweenService"), GetService("CoreGui"), GetService("RunService"), GetService("UserInputService"), GetService("TeleportService"), game:GetService("HttpService");

--// Object variables
local FindFirstChild, FindFirstChildOfClass, FindFirstAncestor, FindFirstAncestorOfClass, GetChildren, GetDescendants = game.FindFirstChild, game.FindFirstChildOfClass, game.FindFirstAncestor, game.FindFirstAncestorOfClass, game.GetChildren, game.GetDescendants;

--// Task
local Spawn, Wait = task.spawn, task.wait;

--// Misc variables
local LastHitTick = tick();
local Plr, Mouse, Camera = Players.LocalPlayer, Players.LocalPlayer:GetMouse(), Workspace.CurrentCamera;
local WTVP, WTSP, ViewportSize = Camera.WorldToViewportPoint, Camera.WorldToScreenPoint, Camera.ViewportSize;

--// Delta variables 
local PlayerGui, MainGui 
local PlayerData, SelfData = ReplicatedStorage.Players, ReplicatedStorage.Players[Plr.Name]

local LastViewerTick = tick();
local LastTarget = nil;
local DeltaFramework = {}; LPH_NO_VIRTUALIZE(function()
    for Index, Value in next, getgc(true) do 
        if type(Value) == "function" and getinfo(Value).name == "RecoilCamera" and getinfo(Value).short_src == "ReplicatedStorage.Modules.FPS.Bullet" then 
            DeltaFramework.Recoil = Value 
        end;
        if type(Value) == "table" then 
            if rawget(Value, "RecoilCamera") then 
                DeltaFramework.VFX = Value;
            elseif rawget(Value, "SetZoomTarget") then 
                DeltaFramework.ZoomFuncs = Value;
            elseif rawget(Value, "CreateMessageLabel") then 
                ChatLabel = Value.CreateMessageLabel
            elseif rawget(Value, "CreateBullet") then 
                DeltaFramework.Bullet = Value;
            elseif rawget(Value, "fireMode") then 
                DeltaFramework.FPS = Value;
            elseif rawget(Value, "Stabilize") then 
                DeltaFramework.Interactions = Value;
            elseif rawget(Value, "Consumable") and type(rawget(Value,  "Consumable")) == "function" then 
                DeltaFramework.Consumable = v;
            end;
        end;
    end;
end)();
--// ez hook fix lol
getgenv().NoRecoil = false;

--// Library
local Ethereal, UIUtilities, Flags, Theme = loadstring(game:HttpGet("REDACTED FOR PRIVACY"))();

--// Drawing extension for, yk, drawing things.
local Extension = loadstring(game:HttpGet("https://raw.githubusercontent.com/EtherealMane/Main/main/Extension.lua"))();

--// Startup
local ColorCorrection = FindFirstChild(Lighting, "Fullbright");
local Atmosphere, Clouds = FindFirstChild(Lighting, "Atmosphere"), FindFirstChild(Workspace.Terrain, "Clouds");
local OGLighting = {
    -- Default lighting
    Ambient = Lighting.Ambient,
    Technology = gethiddenproperty(Lighting, "Technology");
    
    -- Atmosphere
    FogColor = Atmosphere and Atmosphere.Color,
    FogDecay = Atmosphere and Atmosphere.Decay,
    Haze = Atmosphere and Atmosphere.Haze;
    Density = Atmosphere and Atmosphere.Density; 
    Glare = Atmosphere and Atmosphere.Glare;
    
    -- ColorCorrection
    Brightness = ColorCorrection.Brightness;
    Saturation = ColorCorrection.Saturation;
    Contrast = ColorCorrection.Contrast;
};

local OGTerrain = {};

--// Raycast parameters
local RayParams = RaycastParams.new(); do
    RayParams.FilterType = Enum.RaycastFilterType.Blacklist;
    RayParams.FilterDescendantsInstances = {Camera, Plr.Character};
    RayParams.IgnoreWater = true;
end;

--// Conversions
local DistanceConversions = {};
function DistanceConversions:RegisterConversion(Name, Data)
    DistanceConversions[Name] = {
        Suffix = Data.Suffix,
        Conversion = Data.Conversion
    };
end;
--// Hitmarker shit
local HitmarkerSounds = {
    ["Rust"] = "1255040462",
    ["Gamesense"] = "4817809188",
    ["CSGO"] = "6937353691",
    ["Neverlose"] = "8726881116",
    ["Minecraft"] = "4018616850",
};
--// Default distance setups
DistanceConversions:RegisterConversion("Studs", {Suffix = "s", Conversion = 1});
DistanceConversions:RegisterConversion("Meters", {Suffix = "m", Conversion = 3});

--// Loaded modules
local LoadedModules = {};
--// Instance
local InstanceFuncs = {}; do 
    function InstanceFuncs:New(Class, Properties)
        local NewInstance = Instance.new(Class);
        for Index, Value in next, Properties do 
            NewInstance[Index] = Value;
        end;
        return NewInstance;
    end;
end;
--// Drawing
local DrawFuncs = {}; do
    function DrawFuncs:New(Class, Properties)
        local NewDrawing = Drawing.new(Class);
        for Index, Value in next, Properties do 
            NewDrawing[Index] = Value;
        end;
        return NewDrawing;
    end;
end;
--// Tweening
local Tween = {}; LPH_NO_VIRTUALIZE(function()
    Tween.EasingStyle = {
        [Enum.EasingStyle.Linear] = {
            [Enum.EasingDirection.In] = function(Delta)
                return Delta
            end,

            [Enum.EasingDirection.Out] = function(Delta)
                return Delta
            end,

            [Enum.EasingDirection.InOut] = function(Delta)
                return Delta
            end
        }, 
        
        [Enum.EasingStyle.Cubic] = {
            [Enum.EasingDirection.In] = function(Delta)
                return Delta^3
            end,

            [Enum.EasingDirection.Out] = function(Delta)
                return (Delta - 1)^3 + 1
            end,

            [Enum.EasingDirection.InOut] = function(Delta)
                if Delta <= 0.5 then
                    return (4 * Delta)^3
                else
                    return (4 * (Delta - 1))^3 + 1
                end
            end
        },
        [Enum.EasingStyle.Quad] = {
            [Enum.EasingDirection.In] = function(Delta)
                return Delta^2
            end,

            [Enum.EasingDirection.Out] = function(Delta)
                return -(Delta - 1)^2 + 1
            end,

            [Enum.EasingDirection.InOut] = function(Delta)
                if Delta <= 0.5 then
                    return (2 * Delta)^2
                else
                    return (-2 * (Delta - 1))^2 + 1
                end
            end
        },
        [Enum.EasingStyle.Quart] = {
            [Enum.EasingDirection.In] = function(Delta)
                return Delta^4
            end,

            [Enum.EasingDirection.Out] = function(Delta)
                return -(Delta - 1)^4 + 1
            end,

            [Enum.EasingDirection.InOut] = function(Delta)
                if Delta <= 0.5 then
                    return (8 * Delta)^4
                else
                    return (-8 * (Delta - 1))^4 + 1
                end
            end
        },
        [Enum.EasingStyle.Quint] = {
            [Enum.EasingDirection.In] = function(Delta)
                return Delta^5
            end,
            [Enum.EasingDirection.Out] = function(Delta)
                return (Delta - 1)^5 + 1
            end,
            [Enum.EasingDirection.InOut] = function(Delta)
                if Delta <= 0.5 then
                    return (16 * Delta)^5
                else
                    return (16 * (Delta - 1))^5 + 1
                end
            end
        },
        [Enum.EasingStyle.Sine] = {
            [Enum.EasingDirection.In] = function(Delta)
                return math.sin(math.pi / 2 * Delta - math.pi / 2)
            end,

            [Enum.EasingDirection.Out] = function(Delta)
                return math.sin(math.pi / 2 * Delta)
            end,

            [Enum.EasingDirection.InOut] = function(Delta)
                return 0.5 * math.sin(math.pi * Delta - math.pi / 2) + 0.5
            end
        },
        [Enum.EasingStyle.Exponential] = {
            [Enum.EasingDirection.In] = function(Delta)
                return 2^(10 * Delta - 10) - 0.001
            end,
            [Enum.EasingDirection.Out] = function(Delta)
                return 1.001 * -2^(-10 * Delta) + 1
            end,
            [Enum.EasingDirection.InOut] = function(Delta)
                if Delta <= 0.5 then
                    return 0.5 * 2^(20 * Delta - 10) - 0.0005
                else
                    return 0.50025 * -2^(-20 * Delta + 10) + 1
                end
            end
        },
        [Enum.EasingStyle.Back] = {
            [Enum.EasingDirection.In] = function(Delta)
                return Delta^2 * (Delta * (1.70158 + 1) - 1.70158)
            end,
            [Enum.EasingDirection.Out] = function(Delta)
                return (Delta - 1)^2 * ((Delta - 1) * (1.70158 + 1) + 1.70158) + 1
            end,
            [Enum.EasingDirection.InOut] = function(Delta)
                if Delta <= 0.5 then
                    return (2 * Delta * Delta) * ((2 * Delta) * (2.5949095 + 1) - 2.5949095)
                else
                    return 0.5 * ((Delta * 2) - 2)^2 * ((Delta * 2 - 2) * (2.5949095 + 1) + 2.5949095) + 1
                end
            end
        },
        [Enum.EasingStyle.Bounce] = {
            [Enum.EasingDirection.In] = function(Delta)
                if Delta <= 0.25 / 2.75 then
                    return -7.5625 * (1 - Delta - 2.625 / 2.75)^2 + 0.015625
                elseif Delta <= 0.75 / 2.75 then
                    return -7.5625 * (1 - Delta - 2.25 / 2.75)^2 + 0.0625
                elseif Delta <= 1.75 / 2.75 then
                    return -7.5625 * (1 - Delta - 1.5 / 2.75)^2 + 0.25
                else
                    return 1 - 7.5625 * (1 - Delta)^2
                end
            end,
            [Enum.EasingDirection.Out] = function(Delta)
                if Delta <= 1 / 2.75 then
                    return 7.5625 * (Delta * Delta)
                elseif Delta <= 2 / 2.75 then
                    return 7.5625 * (Delta - 1.5 / 2.75)^2 + 0.75
                elseif Delta <= 2.5 / 2.75 then
                    return 7.5625 * (Delta - 2.25 / 2.75)^2 + 0.9375
                else
                    return 7.5625 * (Delta - 2.625 / 2.75)^2 + 0.984375
                end
            end,
            [Enum.EasingDirection.InOut] = function(Delta)
                if Delta <= 0.125 / 2.75 then
                    return 0.5 * (-7.5625 * (1 - Delta * 2 - 2.625 / 2.75)^2 + 0.015625)
                elseif Delta <= 0.375 / 2.75 then
                    return 0.5 * (-7.5625 * (1 - Delta * 2 - 2.25 / 2.75)^2 + 0.0625)
                elseif Delta <= 0.875 / 2.75 then
                    return 0.5 * (-7.5625 * (1 - Delta * 2 - 1.5 / 2.75)^2 + 0.25)
                elseif Delta <= 0.5 then
                    return 0.5 * (1 - 7.5625 * (1 - Delta * 2)^2)
                elseif Delta <= 1.875 / 2.75 then
                    return 0.5 + 3.78125 * (2 * Delta - 1)^2
                elseif Delta <= 2.375 / 2.75 then
                    return 3.78125 * (2 * Delta - 4.25 / 2.75)^2 + 0.875
                elseif Delta <= 2.625 / 2.75 then
                    return 3.78125 * (2 * Delta - 5 / 2.75)^2 + 0.96875
                else
                    return 3.78125 * (2 * Delta - 5.375 / 2.75)^2 + 0.9921875
                end
            end
        },
        [Enum.EasingStyle.Elastic] = {
            [Enum.EasingDirection.In] = function(Delta)
                return -2^(10 * (Delta - 1)) * math.sin(math.pi * 2 * (Delta - 1 - 0.3 / 4) / 0.3)
            end,

            [Enum.EasingDirection.Out] = function(Delta)
                return 2^(-10 * Delta) * math.sin(math.pi * 2 * (Delta - 0.3 / 4) / 0.3) + 1
            end,

            [Enum.EasingDirection.InOut] = function(Delta)
                if Delta <= 0.5 then
                    return -0.5 * 2^(20 * Delta - 10) * math.sin(math.pi * 2 * (Delta * 2 - 1.1125) / 0.45)
                else
                    return 0.5 * 2^(-20 * Delta + 10) * math.sin(math.pi * 2 * (Delta * 2 - 1.1125) / 0.45) + 1
                end
            end
        },
        [Enum.EasingStyle.Circular] = {
            [Enum.EasingDirection.In] = function(Delta)
                return -math.sqrt(1 - Delta^2) + 1
            end,

            [Enum.EasingDirection.Out] = function(Delta)
                return math.sqrt(-(Delta - 1)^2 + 1)
            end,

            [Enum.EasingDirection.InOut] = function(Delta)
                if Delta <= 0.5 then
                    return -math.sqrt(-Delta^2 + 0.25) + 0.5
                else
                    return math.sqrt(-(Delta - 1)^2 + 0.25) + 0.5
                end
            end
        };
    };
end)();
--// Utility
local Utility = {}; LPH_JIT_MAX(function() 
    function Utility:FloorVector(Vector)
        if typeof(Vector) == "Vector2" then 
            return Vector2.new(math.floor(Vector.X), math.floor(Vector.Y));
        else 
            return Vector3.new(math.floor(Vector.X), math.floor(Vector.Y), math.floor(Vector.Z));
        end;
    end;

    function Utility:IsVisible(Destination)
        if not Destination then return false end;
        
        local RaycastResult = workspace:Raycast(Camera.CFrame.p, (Destination.Position - Camera.CFrame.p).Unit * 10000, RayParams);
        if RaycastResult and RaycastResult.Instance then 
            if RaycastResult.Instance:IsDescendantOf(Destination.Parent) then 
                return true;
            end;
        end;
        return false;
    end;

    function Utility:GetMousePos()
        return UserInputService:GetMouseLocation();
    end;

    function Utility:GetWeapon(Model)
        local ModelData = FindFirstChild(PlayerData, Model.Name);
        if not ModelData then return "None" end;
        local Status = FindFirstChild(ModelData, "Status");
        if not Status then return "None" end;
        local GameplayVars = FindFirstChild(Status, "GameplayVariables")
        
        if GameplayVars and FindFirstChild(GameplayVars, "EquippedTool") then 
            return FindFirstChild(GameplayVars, "EquippedTool").Value ~= nil and tostring(FindFirstChild(GameplayVars, "EquippedTool").Value) or "None";
        end 
        return "None";
    end;

    function Utility:GetDistance(Origin, Destination, Type)
        local DistanceConversion = DistanceConversions[Type].Conversion;
        local Magnitude = (Origin - Destination).Magnitude / DistanceConversion;
        return math.floor(Magnitude);
    end;

    function Utility:RotateVector2(Vec, Rotation)
        local Cosine = math.cos(Rotation); 
        local Sine = math.sin(Rotation); 
        return Vector2.new(Cosine * Vec.X - Sine * Vec.Y, Sine * Vec.X + Cosine * Vec.Y);
    end;

    function Utility:ToRotation(Angle)
        return Vector2.new(math.sin(math.rad(Angle)), math.cos(math.rad(Angle)));
    end;

    function Utility:Rotate(CF)
        local X, Y, Z = CF:ToOrientation();
        return CFrame.new(CF.Position) * CFrame.Angles(0, Y, 0);
    end;
    
    function Utility:GetBoundingBox(Root)
        local BoxInfo = {};
        local RootPos, IsOnScreen = WTVP(Camera, Root.Position);
        local SF = 1 / (RootPos.Z * math.tan(math.rad(Camera.FieldOfView / 2)) * 2) * 1000; 
        local Width = Flags["BoxWidth"] and Flags["BoxWidth"]:Get() * SF or 3 * SF;
        local Height = Flags["BoxHeight"] and Flags["BoxHeight"]:Get() * SF or 6 * SF;

        BoxInfo.Width = Width;
        BoxInfo.Height = Height;

        local Size, Pos = Utility:FloorVector(Vector2.new(math.max(Width, 6), math.max(Height, 10))), Utility:FloorVector(Vector2.new(RootPos.X - Width / 2, RootPos.Y - Height / 2));
        Pos = Flags["BoxOffset"] and Vector2.new(0,Flags["BoxOffset"]:Get()) + Pos or Pos;
        local Center = Vector2.new(Pos.X + Size.X / 2, Pos.Y + Size.Y / 2);

        BoxInfo.BoxSize = Size;
        BoxInfo.BoxPos = Pos;
        BoxInfo.Center = Center;
        BoxInfo.IsOnScreen = IsOnScreen;

        return BoxInfo;
    end;
end)();
--// Combat
local Combat = {["Aim assist target"] = nil, ["Silent aim target"] = nil}; LPH_JIT(function() 

    function Combat:AimAt(Delta)
        if Combat["Aim assist target"] and Flags["Aim assist"] and Flags["AimAssist"] and Flags["AimAssist"]:Get() and Flags["Aim assist"]:Active() then
            local TargetPos = WTVP(Camera, Combat["Aim assist target"].Position);
            local MousePos = Utility:GetMousePos();
            local MagnitudeX = MousePos.X - TargetPos.X / 1;
            local MagnitudeY = MousePos.Y - TargetPos.Y / 1;

            local Humanization = Flags["Humanization"]:Get() and Flags["HumanizationScale"]:Get() or 1.5;

            mousemoverel(-MagnitudeX / (Humanization), -MagnitudeY / Humanization);
        end;
    end;
end)();
--// Visuals
local Visuals = {}; LPH_NO_VIRTUALIZE(function() 
    Visuals.CustomPositioning = {
        CurrentPosition = Vector2.new();
    };

    Visuals.Objects = {
        ESP = {};
        Customs = {};
        Hitmarkers = {};
        Crosshair = {
            {DrawFuncs:New("Line", {}), DrawFuncs:New("Line", {})};
            {DrawFuncs:New("Line", {}), DrawFuncs:New("Line", {})};
            {DrawFuncs:New("Line", {}), DrawFuncs:New("Line", {})};
            {DrawFuncs:New("Line", {}), DrawFuncs:New("Line", {})};
        };
        SilentAimFOV = {
            Outline = DrawFuncs:New("Circle", {
                ZIndex = 5000,
                Radius = 50,
                NumSides = 12,
                Thickness = 5,
            });
            Fill = DrawFuncs:New("Circle", {
                ZIndex = 5000,
                Radius = 50, 
                NumSides = 12,
                Color = Color3.new(1,1,1),
                Thickness = 2,
            });
        };
        AimAssistFOV = {
            Outline = DrawFuncs:New("Circle", {
                ZIndex = 5000,
                Radius = 50,
                NumSides = 12,
                Thickness = 5,
            });
            Fill = DrawFuncs:New("Circle", {
                ZIndex = 5000,
                Radius = 50, 
                NumSides = 12,
                Color = Color3.new(1,1,1),
                Thickness = 2,
            });
        };
    };
    --// Visuals functions
    function Visuals:NewHitmarker(Position)
        local Index = #Visuals.Objects.Hitmarkers + 1;
        Visuals.Objects.Hitmarkers[Index] = {
            Time = tick();
            Position = Position;
            Drawings = {
                [1] = DrawFuncs:New("Line", {
                    Thickness = 1.5,
                    ZIndex = 9000,
                    Color = Flags["HitmarkerColor"] and Flags["HitmarkerColor"]:Get().Color or Color3.fromRGB(255,255,255),
                }),
                [2] = DrawFuncs:New("Line", {
                    Thickness = 1.5,
                    ZIndex = 9000,
                    Color = Flags["HitmarkerColor"] and Flags["HitmarkerColor"]:Get().Color or Color3.fromRGB(255,255,255),
                }),
                [3] = DrawFuncs:New("Line", {
                    Thickness = 1.5,
                    ZIndex = 9000,
                    Color = Flags["HitmarkerColor"] and Flags["HitmarkerColor"]:Get().Color or Color3.fromRGB(255,255,255),
                }),
                [4] = DrawFuncs:New("Line", {
                    Thickness = 1.5,
                    ZIndex = 9000,
                    Color = Flags["HitmarkerColor"] and Flags["HitmarkerColor"]:Get().Color or Color3.fromRGB(255,255,255),
                }),
            };
        };

        Spawn(function()
            Wait(Flags["HitmarkerLifetime"] and Flags["HitmarkerLifetime"]:Get() or 1);
            for i = 1, 0, -0.1 do 
                Wait(0.05);
                Visuals.Objects.Hitmarkers[Index].Drawings[1].Transparency = i;
                Visuals.Objects.Hitmarkers[Index].Drawings[2].Transparency = i;
                Visuals.Objects.Hitmarkers[Index].Drawings[3].Transparency = i;
                Visuals.Objects.Hitmarkers[Index].Drawings[4].Transparency = i;
            end;
            Visuals.Objects.Hitmarkers[Index].Drawings[1]:Remove();
            Visuals.Objects.Hitmarkers[Index].Drawings[2]:Remove();
            Visuals.Objects.Hitmarkers[Index].Drawings[3]:Remove();
            Visuals.Objects.Hitmarkers[Index].Drawings[4]:Remove();
            Visuals.Objects.Hitmarkers[Index] = nil;
        end);
    end;

    function Visuals:UpdateHits(Hit)
        local Entry = Visuals.Objects.Hitmarkers[Hit];
        local Drawings = Entry.Drawings 

        local Pos, IsOnScreen = WTVP(Camera, Entry.Position);

        Drawings[1].Visible = IsOnScreen;
        Drawings[2].Visible = IsOnScreen;
        Drawings[3].Visible = IsOnScreen;
        Drawings[4].Visible = IsOnScreen;
        if Drawings[1].Visible then 
            local X, Y = Pos.X, Pos.Y;
            Drawings[1].From = Vector2.new(X + 4, Y + 4);
            Drawings[1].To = Vector2.new(X + 10, Y + 10);
            
            Drawings[2].From = Vector2.new(X + 4, Y - 4);
            Drawings[2].To = Vector2.new(X + 10, Y - 10);

            Drawings[3].From = Vector2.new(X - 4, Y - 4);
            Drawings[3].To = Vector2.new(X - 10, Y - 10);

            Drawings[4].From = Vector2.new(X - 4, Y + 4);  
            Drawings[4].To = Vector2.new(X - 10, Y + 10);
        end;
    end;
    
    --// ESP
    function Visuals:New(Player, Class, CurrentHealth, MaxHealth)
        local PlayerInfo = setmetatable({
            Main = Player;
            Components = {Adornments = {}};
            Class = Class;
            CurrentHealth = CurrentHealth;
            MaxHealth = MaxHealth;
            LastAdornmentRefresh = tick();
        }, self);
        --// Components
        Spawn(function()
            --// Bounding box
            PlayerInfo.Components.Box = DrawFuncs:New("Square", {Filled = false, Thickness = 1, ZIndex = 3});
            PlayerInfo.Components.BoxFill = DrawFuncs:New("Square", {Filled = false, Thickness = 1, ZIndex = 1});
            PlayerInfo.Components.BoxOutline = DrawFuncs:New("Square", {Filled = false, Thickness = 3, ZIndex = 2});

            --// Healthbar
            PlayerInfo.Components.Healthbar = DrawFuncs:New("Square", {Filled = true, Thickness = 1, ZIndex = 2});
            PlayerInfo.Components.HealthbarOutline = DrawFuncs:New("Square", {Filled = true, Thickness = 4, ZIndex = 1});

            --// Text
            do 
                PlayerInfo.Components.Name = {
                    Main = DrawFuncs:New("Text", {
                        Outline = true, 
                        Center = true,
                        Size = 15.5,
                        Font = 3,
                        Color = Color3.new(1,1,1),
                    });

                    Bold = DrawFuncs:New("Text", {
                        Outline = false, 
                        Center = true,
                        Size = 15.5,
                        Font = 3,
                        Color = Color3.new(1,1,1),
                    });
                };

                PlayerInfo.Components.Distance = {
                    Main = DrawFuncs:New("Text", {
                        Outline = true, 
                        Center = true,
                        Size = 15.5,
                        Font = 3,
                        Color = Color3.new(1,1,1),
                    });

                    Bold = DrawFuncs:New("Text", {
                        Outline = false, 
                        Center = true,
                        Size = 15.5,
                        Font = 3,
                        Color = Color3.new(1,1,1),
                    });
                };

                PlayerInfo.Components.Health = {
                    Main = DrawFuncs:New("Text", {
                        Outline = true, 
                        Center = false,
                        Size = 13,
                        Font = 2,
                        Color = Color3.new(1,1,1),
                    });

                    Bold = DrawFuncs:New("Text", {
                        Outline = false, 
                        Center = false,
                        Size = 13,
                        Font = 2,
                        Color = Color3.new(1,1,1),
                    });
                };
                
                PlayerInfo.Components.ViewAngle = DrawFuncs:New("Line", {
                    Thickness = 1,
                    ZIndex = 4,
                })
                PlayerInfo.Components.Weapon = {
                    Main = DrawFuncs:New("Text", {
                        Outline = true, 
                        Center = true,
                        Size = 15.5,
                        Font = 3,
                        Color = Color3.new(1,1,1),
                    });
                
                    Bold = DrawFuncs:New("Text", {
                        Outline = false, 
                        Center = true,
                        Size = 15.5,
                        Font = 3,
                        Color = Color3.new(1,1,1),
                    });
                };

                PlayerInfo.Components.Flag = {
                    Main = DrawFuncs:New("Text", {
                        Outline = true, 
                        Center = true,
                        Size = 15.5,
                        Font = 3,
                        Color = Color3.new(1,1,1),
                    });

                    Bold = DrawFuncs:New("Text", {
                        Outline = false, 
                        Center = true,
                        Size = 15.5,
                        Font = 3,
                        Color = Color3.new(1,1,1),
                    });
                };
            end;
            --// Offscreen arrows
            do 
                PlayerInfo.Components.Offscreen = {
                    OutlineBold = DrawFuncs:New("Quad", {
                        Visible = false,
                        Filled = false,
                        Thickness = 5,
                    });
                
                    Outline = DrawFuncs:New("Quad", {
                        Visible = false,
                        Filled = false,
                        Thickness = 5,
                    });
                    Bold = DrawFuncs:New("Quad", {
                        Visible = false,
                        Thickness = 3,
                        Filled = false,
                        Color = Color3.new(1,1,1),
                    });
                    Fill = DrawFuncs:New("Quad", {
                        Visible = false,
                        Thickness = 1,
                        Filled = true,
                        Color = Color3.new(1,1,1),
                    });
                };
            end;
        end);
        
        function PlayerInfo:Update()
            local Main = self.Main;
            local Class = self.Class;
            local Character = Class == "Player" and Main.Character or Main;
            local Components = self.Components;
            --// Adornments
            local Adornments = Components.Adornments;
            
            local CurrentHealth = self.CurrentHealth;
            --// Drawing components
            local Box = Components.Box;
            local BoxFill = Components.BoxFill;
            local BoxOutline = Components.BoxOutline;
            local Healthbar = Components.Healthbar;
            local HealthbarOutline = Components.HealthbarOutline;
            local NameText = Components.Name;
            local HealthText = Components.Health;
            local DistanceText = Components.Distance;

            local WeaponText = Components.Weapon;
            local Offscreen = Components.Offscreen;
            
            local ViewAngle = Components.ViewAngle;
            
            if Character and Flags["DistanceMode"] then 
                local Root = FindFirstChild(Character, "HumanoidRootPart") or FindFirstChildOfClass(Character, "BasePart");
                local Humanoid = FindFirstChildOfClass(Character, "Humanoid");
                if Root and Humanoid then 
                    local BoxInfo = Utility:GetBoundingBox(Root);
                    MaxHealth = Humanoid.MaxHealth
                    
                    if Class ~= "Player" then 
                        CurrentHealth = Humanoid.Health;
                    end;
                    local BoxSize, BoxPos, BoxCenter, IsOnScreen, BoxWidth, BoxHeight = BoxInfo.BoxSize, BoxInfo.BoxPos, BoxInfo.Center, BoxInfo.IsOnScreen, BoxInfo.Width, BoxInfo.Height;
    
                    --// Player only specifics 
                    if Class == "Player" and Main ~= Plr then 
                        if tick() - self.LastAdornmentRefresh >( Flags["ChamsRefreshRate"] and Flags["ChamsRefreshRate"]:Get() or 5) then 
                            self.LastAdornmentRefresh = tick();
    
                            for Index, Value in next, GetChildren(Character) do
                                if not Adornments[Value] and Value:IsA("BasePart") and Value.Name ~= "HumanoidRootPart" then
                                    local AdornmentsTable = {};
                                    for Index2 = 1, 2 do 
                                        if Value.Name == "Head" then 
                                            NewCham = InstanceFuncs:New("CylinderHandleAdornment", {
                                                Parent = Value,
                                                Adornee = Value,
                                                Height = 1+ 0.2,
                                                --// YEEAAA FUCK ROBLOX SCALING
                                                Radius = 0.65,--(Value.Size.X * 0.5)+ 0.1,
                                                CFrame = CFrame.new(Vector3.new(), Vector3.new(0, 1, 0));
                                            });
                                            if Index2 == 1 then 
                                                NewCham.Radius = NewCham.Radius - 0.15;
                                                NewCham.Height = NewCham.Height - 0.15;
                                                NewCham.Transparency = NewCham.Transparency - 0.1;
                                            end;
                                        else
                                            if Value and Value.Size then 
                                                NewCham = InstanceFuncs:New("BoxHandleAdornment", {
                                                    Parent = Value,
                                                    Size = Value.Size + Vector3.new(0.1, 0.1, 0.1),
                                                    Adornee = Value;
                                                });
                                                if Index2 == 1 then 
                                                    NewCham.Size = NewCham.Size - Vector3.new(0.15, 0.15, 0.15);
                                                end;
                                            end;
                                        end;
                                        NewCham.Name = Index2 == 1 and "Invisible" or "Visible";
                                        NewCham.Adornee = Value;
                                        NewCham.ZIndex = Index2 == 1 and 2 or 1;
                                        NewCham.AlwaysOnTop = Index2 == 1;
    
                                        AdornmentsTable[Index2] = NewCham;
                                    end;
                                    Adornments[Value] = AdornmentsTable;
                                end;
                                if Adornments[Value] then
                                    --// Invisible
                                    Adornments[Value][1].Visible = Flags["ESPChams"]:Get();
                                    Adornments[Value][1].Color3 = Flags["Invisible color"]:Get().Color;
                                    Adornments[Value][1].Transparency = Flags["Invisible color"]:Get().Transparency;
    
                                    --// Visible
                                    Adornments[Value][2].Visible = Flags["ESPChams"]:Get();
                                    Adornments[Value][2].Color3 = Flags["Visible color"]:Get().Color;
                                    Adornments[Value][2].Transparency = Flags["Visible color"]:Get().Transparency;
                                end;
                            end;
                        end;
                    end;
                    do  
                        if not IsOnScreen and Root then
                            ViewAngle.Visible = false;
                            Box.Visible = false;
                            BoxOutline.Visible = false;
                            NameText.Main.Visible = false;
                            NameText.Bold.Visible = false;
                            DistanceText.Bold.Visible = false;
                            DistanceText.Main.Visible = false; 
                            WeaponText.Bold.Visible = false;
                            WeaponText.Main.Visible = false;
                            HealthbarOutline.Visible = false;
                            HealthText.Main.Visible = false;
                            HealthText.Bold.Visible = false;
                            Healthbar.Visible = false;
                            Offscreen.Fill.Visible  = Flags["ESPOffscreen"] and Flags["ESPOffscreen"]:Get();
                            if Offscreen.Fill.Visible then 
                                local Proj = Camera.CFrame:PointToObjectSpace(Root.Position);
                                local Angle = math.atan2(Proj.Z, Proj.X);
                                local Direction = Vector2.new(math.cos(Angle), math.sin(Angle));
                                local Position = (Direction * Flags["OffscreenRadius"]:Get()) + ViewportSize / 2;
                                local PointA = Position;
                                local PointB = PointA - Utility:RotateVector2(Direction, math.rad(26)) * Flags["OffscreenSize"]:Get();
                                local PointC = PointA - Direction * (Flags["OffscreenSize"]:Get() / 1.525);
                                local PointD = PointA - Utility:RotateVector2(Direction, -math.rad(26)) * Flags["OffscreenSize"]:Get();
    
                                local Center = Vector2.new((PointA.X + PointB.X + PointC.X + PointD.X) / 4, (PointA.Y + PointB.Y + PointC.Y + PointD.Y) / 4);
    
                                local PointSize = Vector2.new(Flags["OffscreenSize"]:Get(),  Flags["OffscreenSize"]:Get());
                                local PointPosition = (Center - Vector2.new(Flags["OffscreenSize"]:Get() / 2,  Flags["OffscreenSize"]:Get() / 2));
    
                                --// Setting positions
                                do
                                    Offscreen.Outline.PointA = PointA;
                                    Offscreen.Outline.PointB = PointB;
                                    Offscreen.Outline.PointC = PointC;
                                    Offscreen.Outline.PointD = PointD;
    
                                    Offscreen.OutlineBold.PointA = PointA;
                                    Offscreen.OutlineBold.PointB = PointB;
                                    Offscreen.OutlineBold.PointC = PointC;
                                    Offscreen.OutlineBold.PointD = PointD;
    
                                    Offscreen.Fill.PointA = PointA;
                                    Offscreen.Fill.PointB = PointB;
                                    Offscreen.Fill.PointC = PointC;
                                    Offscreen.Fill.PointD = PointD;
    
                                    Offscreen.Bold.PointA = PointA;
                                    Offscreen.Bold.PointB = PointB;
                                    Offscreen.Bold.PointC = PointC;
                                    Offscreen.Bold.PointD = PointD;
                                end;
                                if Flags["BlinkingArrows"] and Flags["BlinkingArrows"]:Get() then 
                                    local Transp = math.sin(tick() * 5) + 1 / 2;
                                    Offscreen.Bold.Transparency = Transp;
                                    Offscreen.Fill.Transparency = Transp;
                                    Offscreen.Outline.Transparency = Transp;
                                    Offscreen.OutlineBold.Transparency = Transp;
                                else 
                                    Offscreen.Bold.Transparency = 1;
                                    Offscreen.Fill.Transparency = 1;
                                    Offscreen.Outline.Transparency = 1;
                                    Offscreen.OutlineBold.Transparency = 1;
                                end;
                                if Flags["OffscreenColor"] then 
                                    Offscreen.Bold.Color = Flags["OffscreenColor"]:Get().Color;
                                    Offscreen.Fill.Color = Flags["OffscreenColor"]:Get().Color;
                                end;
                                if Flags["OutlineArrows"] and Flags["OutlineArrows"]:Get() then 
                                    Offscreen.Outline.Visible = true;
                                    Offscreen.OutlineBold.Visible = true;
                                else 
                                    Offscreen.Outline.Visible = false;
                                    Offscreen.OutlineBold.Visible = false;
                                end;
                                Offscreen.Bold.Visible = true;
                            else 
                                Offscreen.Bold.Visible = false;
                                Offscreen.Outline.Visible = false;
                                Offscreen.OutlineBold.Visible = false;
                            end;
                        else 
                            Offscreen.Bold.Visible = false;
                            Offscreen.Outline.Visible = false;
                            Offscreen.OutlineBold.Visible = false;
                            Offscreen.Fill.Visible = false;
                        end;
    
                        if IsOnScreen and Root then
                            Offscreen.Bold.Visible = false;
                            Offscreen.Fill.Visible = false;
                            Offscreen.Outline.Visible = false;
                            Offscreen.OutlineBold.Visible = false;
                            local Health, MaxHealth = self.CurrentHealth, Character.Humanoid.MaxHealth;
                            if Health < 0 then Health = 0 end;
    
                            local Distance = Utility:GetDistance(Camera.CFrame.p, Root.Position, Flags["DistanceMode"]:Get());
                            
                            --// Bounds
                            local TopBounds = Vector2.new();
                            local LeftBounds = Vector2.new();
                            local BottomBounds = Vector2.new();
                            local RightBounds = Vector2.new();
    
                            --// Offsets 
                            local TopOffset = Utility:FloorVector(Vector2.new(BoxCenter.X, BoxPos.Y - 16));
                            local BottomOffset = Utility:FloorVector(Vector2.new(BoxCenter.X, BoxSize.Y + BoxPos.Y + 1));
                            --// Bounding box
                            Box.Visible = Flags["ESPBoxes"] and Flags["ESPBoxes"]:Get();
                            if Box.Visible then
                                Box.Size = BoxSize;
                                Box.Position = BoxPos;
                                Visuals:Colorize(Box, "ESPBoxColor", Character);
    
                                BoxOutline.Size = BoxSize;
                                BoxOutline.Position = BoxPos;
                                BoxOutline.Color = Color3.new();
                                BoxOutline.Visible = true;
                                --[[
                                BoxFill:SetProperty("Size", BoxSize);
                                BoxFill:SetProperty("Position", BoxPos);
                                BoxFill:SetProperty("Color", Flags["BoxFillColor"]:Get().Color);
                                BoxFill:SetProperty("Transparency", Flags["BoxFillColor"]:Get().Transparency);]]
                            else 
                                BoxOutline.Visible = false;
                            end;
                            
                            --// View angle 
                            
                            if Flags["Viewangle"] and Flags["Viewangle"]:Get()  and FindFirstChild(Character, "Head") then 
                                local Origin = Character.Head.Position; 
                                local Direction = Character.Head.CFrame.LookVector;
                                do
                                    local RayHit, HitPos = workspace:FindPartOnRayWithIgnoreList(Ray.new(Origin, Direction * 12), {Camera, Character}, false, true, "");
                                    if HitPos then
                                        local HitPos2, IsOnScreen = WTVP(Camera, HitPos);
                                        local Pos2  = WTVP(Camera, Origin);
                                        if IsOnScreen then
                                            ViewAngle.Visible = true;
                                            ViewAngle.To = Vector2.new(HitPos2.X, HitPos2.Y);
                                            ViewAngle.From = Vector2.new(Pos2.X, Pos2.Y);
                                        else 
                                            ViewAngle.Visible = false
                                        end
                                        ViewAngle.Color = Flags["AngleColor"]:Get().Color;
                                    else 
                                        ViewAngle.Visible = false;
                                    end;
                                end;
                            else 
                                ViewAngle.Visible = false;
                            end;
                            --// Healthbar 
                            Healthbar.Visible = Flags["ESPHealthbar"] and Flags["ESPHealthbar"]:Get()
                            if Healthbar.Visible then 
                                HealthbarOutline.Size = Vector2.new(3, BoxSize.Y + 2);
                                HealthbarOutline.Position = BoxPos + Vector2.new(-5, -1);
                                Healthbar.Size = Vector2.new(1, -((HealthbarOutline.Size.Y -2) * (CurrentHealth / MaxHealth)));
                                Healthbar.Position = HealthbarOutline.Position + Vector2.new(1, -1 + HealthbarOutline.Size.Y);
                                HealthbarOutline.Visible = true; 

                                Healthbar.Color = Flags["LowerHealth"]:Get().Color:Lerp(Flags["HigherHealth"]:Get().Color, CurrentHealth / MaxHealth);
                            else 
                                HealthbarOutline.Visible = false;
                            end;

                            --// Healthtext 
                            HealthText.Main.Visible = Flags["ESPHealth"] and Flags["ESPHealth"]:Get() 
                            if HealthText.Main.Visible then 
                                HealthText.Main.Text = tostring(math.floor(CurrentHealth));
                                HealthText.Main.Color = Flags["ESPHealthColor"]:Get().Color;
                                HealthText.Bold.Visible = true;
                                HealthText.Bold.Text = tostring(math.floor(CurrentHealth));
                                HealthText.Bold.Color = Flags["ESPHealthColor"]:Get().Color
                                if (Camera.CFrame.p - Root.CFrame.p).Magnitude < 100 then
                                    local Top = BoxPos.Y + BoxSize.Y;
                                    local HealthLerped = Top - (CurrentHealth / MaxHealth) * BoxSize.Y
                                    HealthText.Main.Position = Vector2.new(BoxPos.X - 27, HealthLerped);
                                    if Flags["BoldText"] and Flags["BoldText"]:Get() then 
                                        HealthText.Bold.Position = Vector2.new(BoxPos.X - 27, HealthLerped) + Vector2.new(1, 0);
                                    else 
                                        HealthText.Bold.Position = Vector2.new(BoxPos.X - 27, HealthLerped);
                                    end;
                                else 
                                    HealthText.Main.Position = Vector2.new(BoxPos.X - 27, (BoxPos.Y + BoxSize.Y) - 1 * BoxSize.Y);
                                    if Flags["BoldText"] and Flags["BoldText"]:Get() then 
                                        HealthText.Bold.Position = Vector2.new(BoxPos.X - 27, (BoxPos.Y + BoxSize.Y) - 1 * BoxSize.Y) + Vector2.new(1, 0);
                                    else 
                                        HealthText.Bold.Position = Vector2.new(BoxPos.X - 27, (BoxPos.Y + BoxSize.Y) - 1 * BoxSize.Y);
                                    end;
                                end;
                            else 
                                HealthText.Bold.Visible = false;
                            end;

                            --// Name
                            NameText.Main.Visible = Flags["ESPNames"] and Flags["ESPNames"]:Get();
    
                            if NameText.Main.Visible then 
                                NameText.Main.Text = Main.Name;
                                NameText.Main.Position = TopOffset + TopBounds;
    
                                Visuals:Colorize(NameText.Main, "ESPNameColor" ,Character);
    
                                NameText.Bold.Color = NameText.Main.Color;
                                NameText.Bold.Visible = true;
                                NameText.Bold.Text = Main.Name;
    
                                if Flags["BoldText"] and Flags["BoldText"]:Get() then 
                                    NameText.Bold.Position = TopOffset + TopBounds + Vector2.new(1, 0);
                                else 
                                    NameText.Bold.Position = TopOffset + TopBounds + Vector2.new(0, 0);
                                end;
                            else 
                                NameText.Bold.Visible = false;
                            end;
                            
                            --// Weapon 
                            WeaponText.Main.Visible = Flags["ESPWeapon"] and Flags["ESPWeapon"]:Get();
    
                            if WeaponText.Main.Visible then
                                local CurrentWeapon = Utility:GetWeapon(Character)
                                WeaponText.Main.Text = CurrentWeapon;
                                WeaponText.Bold.Visible = true;
                                WeaponText.Main.Position = Utility:FloorVector(BottomOffset + BottomBounds);
                                Visuals:Colorize(WeaponText.Main, "ESPWeaponColor", Character);
                                
                                WeaponText.Bold.Text = CurrentWeapon;
                                WeaponText.Bold.Color = WeaponText.Main.Color
                                if Flags["BoldText"] and Flags["BoldText"]:Get() then 
                                    WeaponText.Bold.Position = BottomBounds + BottomOffset + Vector2.new(1, 0);
                                else 
                                    WeaponText.Bold.Position = BottomBounds + BottomOffset + Vector2.new(0, 0);
                                end;
                                BottomBounds += Vector2.new(0, 14);
                            else 
                                WeaponText.Bold.Visible = false;
                            end;
                            
                            --// Distance
                            DistanceText.Main.Visible = (Flags["ESPDistance"] and Flags["ESPDistance"]:Get() or false);
                            if DistanceText.Main.Visible then 
                                DistanceText.Main.Text = tostring(Distance)..DistanceConversions[Flags["DistanceMode"]:Get()].Suffix;
                                DistanceText.Main.Position = (BottomOffset + BottomBounds);
    
                                Visuals:Colorize(DistanceText.Main, "ESPDistanceColor", Character);
    
                                DistanceText.Bold.Color = DistanceText.Main.Color;
                                DistanceText.Bold.Visible = true;
                                DistanceText.Bold.Text = DistanceText.Main.Text;
    
                                if Flags["BoldText"] and Flags["BoldText"]:Get() then 
                                    DistanceText.Bold.Position = (BottomBounds + BottomOffset + Vector2.new(1, 0));
                                else 
                                    DistanceText.Bold.Position = (BottomOffset + BottomBounds);
                                end;
                                BottomBounds += Vector2.new(0, 14);
                            else 
                                DistanceText.Bold.Visible = false;
                            end;
                        end;
                    end;
                else
                    Offscreen.Bold.Visible = false;
                    Offscreen.Fill.Visible = false;
                    Offscreen.Outline.Visible = false;
                    Offscreen.OutlineBold.Visible = false;
                    ViewAngle.Visible = false;
                    Box.Visible = false;
                    BoxOutline.Visible = false;
                    NameText.Main.Visible = false;
                    NameText.Bold.Visible = false;
                    DistanceText.Bold.Visible = false;
                    DistanceText.Main.Visible = false; 
                    WeaponText.Bold.Visible = false;
                    WeaponText.Main.Visible = false;
                    HealthbarOutline.Visible = false;
                    HealthText.Main.Visible = false;
                    HealthText.Bold.Visible = false;
                    Healthbar.Visible = false;
                end;
            end;
        end;
        
        self.Objects.ESP[Player] = PlayerInfo;
        return PlayerInfo;
    end;
    
    function Visuals:Get(CachedObject)
        return Visuals.Objects.ESP[CachedObject];
    end;

    function Visuals:GetCustom(Model)
        return Visuals.Objects.Customs[Model];
    end;
    
    function Visuals:Remove(Model)
        local Info = Visuals:GetCustom(Model);
        if Info then 
            Info.Components.Main:Remove();
            Info.Components.Bold:Remove();
        end;
        Visuals.Objects.Customs[Model] = nil;
    end;
    function Visuals:NewCustom(Model, Class, WorldPos, Name)
        local ItemInfo = setmetatable({
            Main = Model,
            Class = Class,
            Name = Model.Name,
            Components = {},
            Parent = Model.Parent,
            WorldPos = WorldPos;
        }, self);
    
        ItemInfo.Components["Main"] = DrawFuncs:New("Text", {
            Font = 3,
            Size = 15.5,
            Color = Color3.new(1, 1, 1),
            Outline = true,
            Center = true,
        })
    
        ItemInfo.Components["Bold"] = DrawFuncs:New("Text", {
            Font = 3,
            Size = 15.5,
            Outline = false,
            Center = true,
            Color = Color3.new(1, 1, 1)
        });
        
        function ItemInfo:Update()
            local MainText = self.Components.Main;
            local BoldText = self.Components.Bold
            if Flags["ESP"..Class] and Flags["ESP"..Class]:Get() then
                if self.WorldPos and self.Main then
                    local Class = self.Class
                    local WorldPos = self.WorldPos;
                    local Main = self.Main;
                    if Class == "Exit" then 
                        WorldPos = Main.Position;
                    end 
                    if Class == "Corpse" and Main.PrimaryPart then 
                        self.WorldPos = Main.PrimaryPart.Position;
                    end;
                    local Main = self.Main;
                    local Distance = Utility:GetDistance(Camera.CFrame.p, WorldPos, Flags["DistanceMode"]:Get());
                    if Distance <= Flags["CustomDistance"]:Get() then 
                        local Pos, IsOnScreen = WTVP(Camera, WorldPos);
                        MainText.Visible = IsOnScreen;
                        BoldText.Visible = IsOnScreen;
                        if MainText.Visible then
                            if Class == "Corpse" then 
                                MainText.Text = "Body of "..Name.."\n"..tostring(Distance)..DistanceConversions[Flags["DistanceMode"]:Get()].Suffix;
                            else 
                                MainText.Text = Name.."\n"..tostring(Distance)..DistanceConversions[Flags["DistanceMode"]:Get()].Suffix;
                            end;
                            BoldText.Text = MainText.Text;
                            MainText.Position = Vector2.new(Pos.X, Pos.Y);
                            
                            BoldText.Color = Flags[Class.."Color"]:Get().Color;
                            MainText.Color = Flags[Class.."Color"]:Get().Color;
                            
                            if Flags["BoldText"] and Flags["BoldText"]:Get() then 
                                BoldText.Position = MainText.Position + Vector2.new(1, 0);
                            else 
                                BoldText.Position = MainText.Position;
                            end;
                        end;
                    else 
                        MainText.Visible = false;
                        BoldText.Visible = false;
                    end;
                else 
                    MainText.Visible = false;
                    BoldText.Visible = false;
                end;
            else 
                MainText.Visible = false;
                BoldText.Visible = false;
            end;
        end;
        Visuals.Objects.Customs[Model] = ItemInfo;
    end;

    function Visuals:Colorize(Object, Normal, Character)
        local Prefer = Flags["RelationPrefers"]:Get();
        local NormalColor = Flags[Normal] and Flags[Normal]:Get().Color;
        local EnemyColor = Flags["EnemyColor"]:Get().Color;

        if Flags["UseRelationColors"] and Flags["UseRelationColors"]:Get() and Combat[Prefer.." target"] and Character == Combat[Prefer.." target"].Parent then 
            Object.Color = EnemyColor;
        else 
            Object.Color = NormalColor;
        end;
    end;
end)();

--// Inventory viewer (kms..)
local Viewer = {}; LPH_NO_VIRTUALIZE(function() 
    Viewer.MainFrame = Extension:NewDrawing("Square", {
        Visible = false,
        Filled = true,
        Thickness = 1,
        Size = UDim2.new(0, 200, 0, 150),
        Position = UDim2.new(0, 100, 0, 100),
        ZIndex = 9000,
        Color = Theme.outlinle
    });

    Viewer.Inner1 = Extension:NewDrawing("Square", {
        Visible = true,
        Filled = true,
        Thickness = 1,
        Color = Color3.fromRGB(75, 75, 75),
        ZIndex = 9000,
        Size = UDim2.new(1, -2, 1, -2, Viewer.MainFrame),
        Position = UDim2.new(0, 1, 0, 1, Viewer.MainFrame),
        Parent = Viewer.MainFrame,
        Color = Theme.lightcontrast
    });

    Viewer.Inner2 = Extension:NewDrawing("Square", {
        Visible = true,
        Filled = true,
        Thickness = 1,
        Color = Color3.fromRGB(25, 25, 25),
        Position = UDim2.new(0, 1, 0, 1, Viewer.Inner1),
        Size = UDim2.new(1, -2, 1, -2, Viewer.Inner1),
        Parent = Viewer.Inner1,
        ZIndex = 9000,
        Color = Theme.darkcontrast
    });

    Viewer.PlayersName = Extension:NewDrawing("Text", {
        Visible = true,
        Size = 13,
        Center = true,
        Font = 2,
        Position = UDim2.new(0.5, 0, 0, 3, Viewer.Inner2),
        Parent = Viewer.Inner2,
        ZIndex = 9000,
        Color = Color3.new(1,1,1),
        Outline = true,
        Text = "Player",
        Color = Theme.textcolor,
        OutlineColor = textborder,
    });

    Viewer.Accent = Extension:NewDrawing("Square", {
        AnchorPoint = Vector2.new(0.5, 0),
        Parent = Viewer.Inner2, 
        Visible = true,
        Filled = true,
        Thickness = 0,
        ZIndex = 9001,
        Size  = UDim2.new(1, 0, 0, 2, Viewer.Inner2),
        Color = Color3.fromRGB(118, 111, 181),
        Position = UDim2.new(0.5, 0, 0, 0, Viewer.Inner2),
        Color = Theme.accent
    });

    Viewer.MainText = Extension:NewDrawing("Text", {
        Parent = Viewer.Inner2,
        Visible = true,
        ZIndex = 9001,
        Size = 13,
        Font = 2,
        Outline = true,
        Center = false,
        Color = Color3.new(0.8, 0.8, 0.8),
        Position = UDim2.new(0, 4, 0, 11),
        Text = "",
        Color = Theme.textcolor,
        OutlineColor = textborder,
    }); 
    
    function Viewer:Update(Target, Root)
        Viewer.MainText.Text = "";
        
        local PlayersData = FindFirstChild(PlayerData, Target.Name)
        if PlayersData and Flags["PlayerInfo"] and Flags["Viewer"] and Flags["Viewer"]:Get() then 
            Viewer.MainFrame.Visible = true;
            Viewer.PlayersName.Text = Target.Name;
            for Index, Value in next, Flags["PlayerInfo"]:Get() do
                if Value == "Distance" and Root then 
                    local Distance = math.floor((Camera.CFrame.p - Root.CFrame.p).Magnitude / 3)
                    Viewer.MainText.Text = Viewer.MainText.Text .. "\nDistance :   "..tostring(Distance).."m";
                end;
                if Value == "Health" and FindFirstChildOfClass(Target, "Humanoid") then                       --"Distance: "
                    Viewer.MainText.Text = Viewer.MainText.Text .."\nHealth   :   "..tostring(math.floor(Target.Humanoid.Health)).."/"..tostring(Target.Humanoid.MaxHealth);
                end;
                if Value == "Visible" and Root then 
                    local IsVisible = Utility:IsVisible(Root)
                    Viewer.MainText.Text = Viewer.MainText.Text .."\nVisible  :   "..tostring(IsVisible);
                end;
                if Value == "Hotbar" then 
                    if #GetChildren(PlayersData.Inventory) > 0 then 
                        Viewer.MainText.Text = Viewer.MainText.Text .. "\n[Hotbar] :";
                        for _, Item in next, GetChildren(PlayersData.Inventory) do 
                            Viewer.MainText.Text = Viewer.MainText.Text .. "\n  ".. Item.Name;
                        end;
                    else 
                        Viewer.MainText.Text = Viewer.MainText.Text .. "\n[Hotbar]: EMPTY";
                    end
                end;
                if Value == "Inventory" then 
                    Viewer.MainText.Text = Viewer.MainText.Text .. "\n[Inventory]:"
                    local Clothing = FindFirstChild(PlayersData, "Clothing")
                    if Clothing then 
                        for _, Clothes in next, GetChildren(Clothing) do 
                            local Inventory = FindFirstChild(Clothes, "Inventory");

                            if Inventory and #GetChildren(Inventory) > 0 then 
                                Viewer.MainText.Text = Viewer.MainText.Text.."\n  ["..Clothes.Name.."]:"

                                for _, Item in next, GetChildren(Inventory) do 
                                    Viewer.MainText.Text = Viewer.MainText.Text .. "\n    "..Item.Name;
                                end;
                            else 
                                Viewer.MainText.Text = Viewer.MainText.Text .."\n  "..Clothes.Name
                            end;
                        end;
                    end;
                end;
            end;
        else 
            Viewer.MainFrame.Visible = false;
        end;
        Viewer.MainFrame.Size = UDim2.new(0, Viewer.MainText.TextBounds.X + 15 + Viewer.PlayersName.TextBounds.X, 0, Viewer.MainText.TextBounds.Y + 30)
    end;
end)();
--// Hooks
local Hooks = {}; LPH_NO_VIRTUALIZE(function() 
    Hooks.Index = nil; Hooks.NewIndex = nil; Hooks.Namecall = nil;

    local OldClient, OldBullet, OldFiremode, OldConsume = DeltaFramework.FPS.updateClient, DeltaFramework.Bullet.CreateBullet, DeltaFramework.FPS.fireMode, DeltaFramework.Consumable
    local OldZoom = DeltaFramework.ZoomFuncs.SetZoomTarget; 
    local OldStabilize = DeltaFramework.Interactions.Stabilize;
    
    Hooks.NewIndex = hookmetamethod(game, "__newindex", function(self, prop, val)
        if self == Camera and prop == "CFrame" then 
            if Flags["ThirdPerson"] and Flags["ThirdPerson"]:Get() and Flags["Third person"] and Flags["Third person"]:Active() then 
                return Hooks.NewIndex(self, prop, val + Camera.CFrame.LookVector * -Flags["Thirdperson offset"]:Get())
            end;
            if debug.traceback() and Flags["RemoveBobbing"] and Flags["RemoveBobbing"]:Get()then
                local Split = string.split(tostring(debug.traceback()), "function ");
                if Split[2] and Split[2]:find("updateClient") then
                    return Hooks.NewIndex(self, prop, Camera.CFrame)
                end
            end;
        end;
        return Hooks.NewIndex (self, prop, val)
    end);

    Hooks.Namecall = hookmetamethod(game, "__namecall", function(self, ...)
        local Args = {...};
        local Method = getnamecallmethod();
        
        if not checkcaller() then
            
            if Method == "Play" and self.Parent and self.Parent.Name == "Temp" and Flags["SilentBullet"] and Flags["SilentBullet"]:Get() then 
                return
            end;

            if Method == "GetAttribute" then 
                if Args[1] == "MuzzleVelocity" and Flags["InstantBullet"] and Flags["InstantBullet"]:Get() then 
                    DeltaFramework.RealVelo = self.GetAttribute(self, "MuzzleVelocity");
                    return 9e9
                end;
                if Args[1] == "ProjectileDrop" and Flags["RemoveDrop"] and Flags["RemoveDrop"]:Get() then 
                    DeltaFramework.RealDrop = self.GetAttribute(self, "ProjectileDrop");
                    return 0
                end;


                if Args[1] == "AccuracyDeviation" then 
                    DeltaFramework.RealSpread = self.GetAttribute(self, "AccuracyDeviation") 
                    if Flags["RemoveSpread"] and Flags["RemoveSpread"]:Get() then 
                        return 0; 
                    end;
                end;

                if Args[1] == "Tracer" and Flags["ForceTracers"] and Flags["ForceTracers"]:Get() then 
                    return true; 
                end;

                if Args[1] == "UpAngle" and Flags["ResolverEnabled"] and Flags["ResolverEnabled"]:Get() and Flags["ResolverOptions"] and table.find(Flags["ResolverOptions"]:Get(), "Pitch") then 
                    return 0;
                end;
                
                if Args[1] == "SideAngle" and Flags["ResolverEnabled"] and Flags["ResolverEnabled"]:Get() and Flags["ResolverOptions"] and table.find(Flags["ResolverOptions"]:Get(), "Leaning") then 
                    return 0;
                end;
            end;
            if Method == "FireServer" then
                
                if self.Name == "CharacterTilt" and Flags["AntiAim"] and Flags["AntiAim"]:Get() and Flags["Pitch"] and Flags["PitchBase"] then
                    if Flags["PitchBase"]:Get() == "Up" then 
                        Args[1] = 2;
                    end 

                    if Flags["PitchBase"]:Get() == "Down" then 
                        Args[1] = -2;
                    end; 

                    if Flags["PitchBase"]:Get() == "Custom" then 
                        Args[1] = Flags["Pitch"]:Get();
                    end;

                    if Flags["PitchBase"]:Get() == "Random" then 
                        Args[1] = math.random(2, -2);
                    end;
                end;
                
                if self.Name == "Drowning" and Flags["AntiDrown"] and Flags["AntiDrown"]:Get() then 
                    return
                end;

                if self.Name == "ProjectileInflict" then 
                    if typeof(Args[1]) == "string" and string.len(Args[1]) == 1 then 
                        return coroutine.yield();
                    end;
                    
                    if typeof(Args[3]) == "string" and string.len(Args[3]) == 1 then 
                        return coroutine.yield();
                    end;
                end
                
                if self.Name == "ProjectileInflict" then
                    local Distance = (Args[3].Position - Camera.CFrame.p).Magnitude;
                    if (Flags["InstantBullet"] and Flags["InstantBullet"]:Get()) or (Flags["RemoveDrop"] and Flags["RemoveDrop"]:Get())  then 
                        if Distance > 15 then 
                            for Index = 1, math.floor(Distance / 17) do
                                if not Args[2][Index] then 
                                    Args[2][Index] = {
                                        ["step"] = (math.random() / 10)
                                    };
                                end
                            end;
                        end;
                    end;

                    Spawn(function()
                        if Flags["Hitmarkers"] and Flags["Hitmarkers"]:Get() then
                            Visuals:NewHitmarker(Args[3].Position);
                        end;
                        if Flags["Hitlogs"] and Flags["Hitlogs"]:Get() then 
                            local Distance = (Args[3].Position - Camera.CFrame.p).Magnitude /3
                            Ethereal.notifications.Notify("Hit "..Args[3].Parent.Name .. " in the "..Args[3].Name .. " from "..tostring(math.floor(Distance)).."m")
                        end;
                    end);
                end;
            end;
            
        end;
        return Hooks.Namecall(self, unpack(Args))
    end);
    DeltaFramework.FPS.updateClient = function(...)
        local Args = {...};
        if Flags["RemoveGunBobbing"] and Flags["RemoveGunBobbing"]:Get() then 
            Args[1].bobbingSprint.angularFrequency = 0;
            Args[1].bobbing.angularFrequency = 0;
        else 
            Args[1].bobbing.angularFrequency = 20;
            Args[1].bobbingSprint.angularFrequency = 13;
        end;
        
        if Args[1].aimPart then 
            DeltaFramework.AimPart = Args[1].aimPart;
        end;

        if Flags["RemoveGunSway"] and Flags["RemoveGunSway"]:Get() then
            Args[1].sway.angularFrequency = 0;
            Args[1].armTilt.angularFrequency = 0;
        else 
            Args[1].sway.angularFrequency = 15;
            Args[1].armTilt.angularFrequency = 10;
        end;

        if Flags["RemoveOcclusion"] and Flags["RemoveOcclusion"]:Get() then 
            Args[1].TouchWallPosY = 0;
            Args[1].TouchWallPosZ = 0;
            Args[1].TouchWallRotX = 0;
            
            Args[1].TouchWallRotY = 0;
        end;

        if Flags["InstantAim"] and Flags["InstantAim"]:Get() then 
            Args[1].AimInSpeed = 0;
            Args[1].AimOutSpeed = 0;
        end;
        if Flags["UnlockFiremodes"] and Flags["UnlockFiremodes"]:Get() then 
            Args[1].FireModes = {
                "Auto", "Semi"
            };
        end;
        return OldClient(unpack(Args))
    end;
    DeltaFramework.Interactions.Stabilize = function(Arg1)
        if Flags["InstantRevive"] and Flags["InstantRevive"]:Get() then
            local V5, V6 = ReplicatedStorage.Remotes.ReviveSystem:InvokeServer("Start", Arg1.deepAncestor, Arg1.position);
            
            if V5 and V5.Parent and V5:GetAttribute("Unconscious") then 
                ReplicatedStorage.Remotes.ReviveSystem:InvokeServer("End", V5);
                return
            end;
        end;
        return OldStabilize(Arg1)
    end;
    DeltaFramework.ZoomFuncs.SetZoomTarget = function(...)
        local Args = {...};
        if Flags["RemoveAimFOV"] and Flags["RemoveAimFOV"]:Get() then 
            return 
        end; 
        return OldZoom(unpack(Args));
    end;
    DeltaFramework.Bullet.CreateBullet = function(self, ...)
        local Args = {...};
        LastShot = tick();
        if Flags["SilentAim"] and Flags["SilentAim"]:Get() and Combat["Silent aim target"] then
            local Chance = math.floor(Random.new().NextNumber(Random.new(), 0, 1) * 100) / 100 

            if Chance <= Flags["Hitchance"]:Get() / 100 then 
                local Origin = Camera.CFrame.p; 
                local Destination = Combat["Silent aim target"].Position;
                local BulletInfo = FindFirstChild(ReplicatedStorage.AmmoTypes, Args[5]);
                local BulletSpeed = BulletInfo:GetAttribute("MuzzleVelocity");
                local BulletDrop = BulletInfo:GetAttribute("ProjectileDrop");

                local Velocity = Combat["Silent aim target"].Velocity 

                if Flags["ResolverEnabled"] and Flags["ResolverEnabled"]:Get() and table.find(Flags["ResolverOptions"]:Get(), "Velocity") then 
                    Velocity = Vector3.new(0,0,0);
                end;

                Args[8] = {ClassName = "Part", CFrame = CFrame.new(Origin, Destination)};
            else 
                local Origin = Args[8].Position; 
                local Destination = Combat["Silent aim target"].Position;

                local RandomX = Destination.X + math.random(4, 10);
                local RandomY = Destination.Y + math.random(2, 10);
                local RandomZ = Destination.Z + math.random(0, 10);
                
                Args[8] = {ClassName = "Part", CFrame = CFrame.new(Origin, Vector3.new(RandomX, RandomY, RandomZ))};
            end
        end;
        return OldBullet(self, unpack(Args));
    end;
    LPH_NO_UPVALUES(function()
        local OldRecoil; OldRecoil = replaceclosure(DeltaFramework.Recoil, function(...)
            if getgenv().NoRecoil or NoRecoil then
                return 
            end
            return OldRecoil(...)
        end);
    end)();
end)();
--// Connections
local Connections = {}; LPH_NO_VIRTUALIZE(function() 
    for Index, Player in next, GetChildren(Players) do 
        Spawn(function()
            local Character = Player.Character; 
            repeat Wait() until Character
            local Humanoid = Character:WaitForChild("Humanoid", 9e9);
    
            if Humanoid and Humanoid.Health and Humanoid.MaxHealth and Player ~= Plr then
                Wait(0.2)
                Visuals:New(Player, "Player", Humanoid.Health, Humanoid.MaxHealth);
    
                Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                    local PlayerObject = Visuals:Get(Player);
                    local Health = Humanoid.Health;
                    local OldHealth = PlayerObject.CurrentHealth; 
                    if Health < 0 then Health = 0 end;
                    if Health < OldHealth then 
                        for Index = OldHealth, Health, -1 do 
                            Wait(0.0005);
        
                            PlayerObject.CurrentHealth = Index;
                        end;
                    else 
                        for Index = OldHealth, Health, 1 do 
                            Wait(0.0005);
        
                            PlayerObject.CurrentHealth = Index;
                        end;
                    end;
                end);
            end;
    
            Player.CharacterAdded:Connect(function()
                local Character = Player.Character;
                local PlayerObject = Visuals:Get(Player);
                repeat Wait() until Character
                local Humanoid = Character:WaitForChild("Humanoid", 9e9);
        
                if Humanoid and Humanoid.Health and Humanoid.MaxHealth then
                    Wait(0.1);
                    PlayerObject.CurrentHealth = Humanoid.Health;
                    Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                        local PlayerObject = Visuals:Get(Player);
                        local Health = Humanoid.Health;
                        local OldHealth = PlayerObject.CurrentHealth; 
                        if Health < 0 then Health = 0 end;
                        if Health < OldHealth then 
                            for Index = OldHealth, Health, -1 do 
                                Wait(0.0005);
            
                                PlayerObject.CurrentHealth = Index;
                            end;
                        else 
                            for Index = OldHealth, Health, 1 do 
                                Wait(0.0005);
                                if Index <= Humanoid.MaxHealth then 
                                    PlayerObject.CurrentHealth = Index;
                                end;
                            end;
                        end;
                    end);
                end;
            end);
        end);
    end;
    do
        if FindFirstChild(workspace, "AiZones") and FindFirstChild(workspace.AiZones, "Sawmill") then 
            Connections.AntonAdded = workspace.AiZones.Sawmill.ChildAdded:Connect(function(Bot)
                Wait(0.5);
                if Bot and Bot:IsA("Model") and FindFirstChildOfClass(Bot, "Humanoid") then 
                    Visuals:New(Bot, "Bot", Bot.Humanoid.Health, Bot.Humanoid.MaxHealth);
                end;
            end);
            
            Connections.WhisperAdded = workspace.AiZones.Whisper.ChildAdded:Connect(function(Bot)
                Wait(0.5);
                if Bot and Bot:IsA("Model") and FindFirstChildOfClass(Bot, "Humanoid") then 
                    Visuals:New(Bot, "Bot", Bot.Humanoid.Health, Bot.Humanoid.MaxHealth);
                end;
            end);
        
            Connections.TownAdded = workspace.AiZones.Town.ChildAdded:Connect(function(Bot)
                Wait(0.5);
                if Bot and Bot:IsA("Model") and FindFirstChildOfClass(Bot, "Humanoid") then 
                    Visuals:New(Bot, "Bot", Bot.Humanoid.Health, Bot.Humanoid.MaxHealth);
                end;
            end);
    
            Connections.GasAdded = workspace.AiZones.GasStation.ChildAdded:Connect(function(Bot)
                Wait(0.5);
                if Bot and Bot:IsA("Model") and FindFirstChildOfClass(Bot, "Humanoid") then 
                    Visuals:New(Bot, "Bot", Bot.Humanoid.Health, Bot.Humanoid.MaxHealth);
                end;
            end);
    
            Connections.FactoryAdded = workspace.AiZones.Factory.ChildAdded:Connect(function(Bot)
                Wait(0.5);
                if Bot and Bot:IsA("Model") and FindFirstChildOfClass(Bot, "Humanoid") then 
                    Visuals:New(Bot, "Bot", Bot.Humanoid.Health, Bot.Humanoid.MaxHealth);
                end;
            end);
    
            Connections.FactoryRemoving = workspace.AiZones.Factory.ChildRemoved:Connect(function(Bot)
                local BotObject = Visuals:Get(Bot);
                if BotObject then 
                    BotObject.Components.Box:Remove();
                    BotObject.Components.BoxOutline:Remove();
                    BotObject.Components.Healthbar:Remove();
                    BotObject.Components.HealthbarOutline:Remove();
                    BotObject.Components.ViewAngle:Remove();
                    Spawn(function()
                        BotObject.Components.Offscreen.Fill:Remove();
                        BotObject.Components.Offscreen.Bold:Remove();
                        BotObject.Components.Offscreen.Outline:Remove();
                        BotObject.Components.Offscreen.OutlineBold:Remove();
                    end);
                    for Index, Value in next, BotObject.Components do 
                        if type(Value) == "table" and rawget(Value, "Bold") and not rawget(Value, "Fill") then 
                            Value.Main:Remove();
                            Value.Bold:Remove();
                        end;    
                    end;
                    Visuals.Objects.ESP[Bot] = nil;
                end;
            end);
            
            Connections.TownRemoving = workspace.AiZones.Town.ChildRemoved:Connect(function(Bot)
                local BotObject = Visuals:Get(Bot);
                if BotObject then 
                    BotObject.Components.Box:Remove();
                    BotObject.Components.BoxOutline:Remove();
                    BotObject.Components.Healthbar:Remove();
                    BotObject.Components.HealthbarOutline:Remove();
                    BotObject.Components.ViewAngle:Remove();
                    Spawn(function()
                        BotObject.Components.Offscreen.Fill:Remove();
                        BotObject.Components.Offscreen.Bold:Remove();
                        BotObject.Components.Offscreen.Outline:Remove();
                        BotObject.Components.Offscreen.OutlineBold:Remove();
                    end);
                    for Index, Value in next, BotObject.Components do 
                        if type(Value) == "table" and rawget(Value, "Bold") and not rawget(Value, "Fill") then 
                            Value.Main:Remove();
                            Value.Bold:Remove();
                        end;    
                    end;
                    Visuals.Objects.ESP[Bot] = nil;
                end;
            end);
    
            Connections.AntonRemoving = workspace.AiZones.Sawmill.ChildRemoved:Connect(function(Bot)
                local BotObject = Visuals:Get(Bot);
                if BotObject then 
                    BotObject.Components.Box:Remove();
                    BotObject.Components.BoxOutline:Remove();
                    BotObject.Components.Healthbar:Remove();
                    BotObject.Components.HealthbarOutline:Remove();
                    BotObject.Components.ViewAngle:Remove();
                    Spawn(function()
                        BotObject.Components.Offscreen.Fill:Remove();
                        BotObject.Components.Offscreen.Bold:Remove();
                        BotObject.Components.Offscreen.Outline:Remove();
                        BotObject.Components.Offscreen.OutlineBold:Remove();
                    end);
                    for Index, Value in next, BotObject.Components do 
                        if type(Value) == "table" and rawget(Value, "Bold") and not rawget(Value, "Fill") then 
                            Value.Main:Remove();
                            Value.Bold:Remove();
                        end;    
                    end;
                    Visuals.Objects.ESP[Bot] = nil;
                end;
            end);
    
            Connections.GasStationRemoving = workspace.AiZones.GasStation.ChildRemoved:Connect(function(Bot)
                local BotObject = Visuals:Get(Bot);
                if BotObject then 
                    BotObject.Components.Box:Remove();
                    BotObject.Components.BoxOutline:Remove();
                    BotObject.Components.Healthbar:Remove();
                    BotObject.Components.HealthbarOutline:Remove();
                    BotObject.Components.ViewAngle:Remove();
                    Spawn(function()
                        BotObject.Components.Offscreen.Fill:Remove();
                        BotObject.Components.Offscreen.Bold:Remove();
                        BotObject.Components.Offscreen.Outline:Remove();
                        BotObject.Components.Offscreen.OutlineBold:Remove();
                    end);
                    for Index, Value in next, BotObject.Components do 
                        if type(Value) == "table" and rawget(Value, "Bold") and not rawget(Value, "Fill") then 
                            Value.Main:Remove();
                            Value.Bold:Remove();
                        end;    
                    end;
                    Visuals.Objects.ESP[Bot] = nil;
                end;
            end);
            
            Connections.WhisperRemoving = workspace.AiZones.Whisper.ChildRemoved:Connect(function(Bot)
                local BotObject = Visuals:Get(Bot);
                if BotObject then 
                    BotObject.Components.Box:Remove();
                    BotObject.Components.BoxOutline:Remove();
                    BotObject.Components.Healthbar:Remove();
                    BotObject.Components.HealthbarOutline:Remove();
                    BotObject.Components.ViewAngle:Remove();
                    Spawn(function()
                        BotObject.Components.Offscreen.Fill:Remove();
                        BotObject.Components.Offscreen.Bold:Remove();
                        BotObject.Components.Offscreen.Outline:Remove();
                        BotObject.Components.Offscreen.OutlineBold:Remove();
                    end);
                    for Index, Value in next, BotObject.Components do 
                        if type(Value) == "table" and rawget(Value, "Bold") and not rawget(Value, "Fill") then 
                            Value.Main:Remove();
                            Value.Bold:Remove();
                        end;    
                    end;
                    Visuals.Objects.ESP[Bot] = nil;
                end;
            end);
    
            for Index, Bot in next, GetChildren(workspace.AiZones.Factory) do 
                if Bot and Bot:IsA("Model") and FindFirstChildOfClass(Bot, "Humanoid") then 
                    Visuals:New(Bot, "Bot", Bot.Humanoid.Health, Bot.Humanoid.MaxHealth);
                end;
            end;
    
            for Index, Bot in next, GetChildren(workspace.AiZones.Sawmill) do 
                if Bot and Bot:IsA("Model") and FindFirstChildOfClass(Bot, "Humanoid") then 
                    Visuals:New(Bot, "Bot", Bot.Humanoid.Health, Bot.Humanoid.MaxHealth);
                end;
            end;
            
            for Index, Bot in next, GetChildren(workspace.AiZones.Whisper) do 
                if Bot and Bot:IsA("Model") and FindFirstChildOfClass(Bot, "Humanoid") then 
                    Visuals:New(Bot, "Bot", Bot.Humanoid.Health, Bot.Humanoid.MaxHealth);
                end;
            end;
        
            for Index, Bot in next, GetChildren(workspace.AiZones.Town) do 
                if Bot and Bot:IsA("Model") and FindFirstChildOfClass(Bot, "Humanoid") then 
                    Visuals:New(Bot, "Bot", Bot.Humanoid.Health, Bot.Humanoid.MaxHealth);
                end;
            end;
            
            for Index, Bot in next, GetChildren(workspace.AiZones.GasStation) do 
                if Bot and Bot:IsA("Model") and FindFirstChildOfClass(Bot, "Humanoid") then 
                    Visuals:New(Bot, "Bot", Bot.Humanoid.Health, Bot.Humanoid.MaxHealth);
                end;
            end;
        end;
    end;
    if FindFirstChild(workspace, "DroppedItems") then
        Spawn(function()
            for Index, Value in next, GetChildren(workspace.DroppedItems) do
                if Value:IsA("Model") and not FindFirstChild(ReplicatedStorage.ItemsListLocal, Value.Name) and Value.PrimaryPart then 
                    Visuals:NewCustom(Value, "Corpse", Value.PrimaryPart.Position, Value.Name);
                end;
            end;
    
            workspace.DroppedItems.ChildAdded:Connect(function(Value)
                Wait(0.5);
                repeat Wait() until Value.PrimaryPart ~= nil;
                if Value:IsA("Model") and not FindFirstChild(ReplicatedStorage.ItemsListLocal, Value.Name) then 
                    Visuals:NewCustom(Value, "Corpse", Value.PrimaryPart.Position, Value.Name);
                end;
            end);
    
            workspace.DroppedItems.ChildRemoved:Connect(function(Value)
                if Value:IsA("Model") and not FindFirstChild(ReplicatedStorage.ItemsListLocal, Value.Name) then
                    if Visuals.Objects.Customs[Value] then
                        Visuals:Remove(Value);
                    end;
                end;
            end);
        end);
    end;

    if FindFirstChild(workspace.NoCollision, "ExitLocations") then
        Spawn(function()
            for Index, Value in next, GetChildren(workspace.NoCollision.ExitLocations) do
                if Value and Value.Position then
                    Visuals:NewCustom(Value, "Exit", Value.Position, "Extract");
                end;
            end;
    
            workspace.NoCollision.ExitLocations.ChildAdded:Connect(function(Value)
                Wait(0.5);
                Visuals:NewCustom(Value, "Exit", Value.Position, "Extract");
            end);
    
            workspace.NoCollision.ExitLocations.ChildRemoved:Connect(function(Value)
                if Visuals.Objects.Customs[Value] then
                    Visuals:Remove(Value);
                end;
            end);
        end);
    end;
    Connections.PlayerAdded = Players.PlayerAdded:Connect(function(Player)
        repeat Wait() until FindFirstChild(Players, Player.Name)
        Visuals:New(Player, "Player", 100, 100);
        Spawn(function()
            repeat Wait() until Player.Character ~= nil;
            local Character = Player.Character; 
            local Humanoid = Character:WaitForChild("Humanoid", 9e9);
            
            Wait(0.5);
            if Humanoid and Humanoid.Health and Humanoid.MaxHealth then
                local PlayerObject = Visuals:Get(Player);
                
                Wait(0.2);
                PlayerObject.CurrentHealth = Humanoid.Health
                Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                    local Health = Humanoid.Health;
                    local OldHealth = PlayerObject.CurrentHealth; 
                    if Health < 0 then Health = 0 end;
                    if Health < OldHealth then 
                        for Index = OldHealth, Health, -1 do 
                            Wait(0.0005);
    
                            PlayerObject.CurrentHealth = Index;
                        end;
                    else 
                        for Index = OldHealth, Health, 1 do 
                            Wait(0.0005);
    
                            PlayerObject.CurrentHealth = Index;
                        end;
                    end;
                end);
            end;

            Player.CharacterAdded:Connect(function()
                local Character = Player.Character;
                local PlayerObject = Visuals:Get(Player);
                repeat Wait() until Character
                local Humanoid = Character:WaitForChild("Humanoid", 9e9);
    
                if Humanoid and Humanoid.Health and Humanoid.MaxHealth then
                    Wait(0.1);
                    if not Visuals.Objects.ESP[Player] then 
                        Visuals:New(Player, "Player", Humanoid.Health, Humanoid.MaxHealth);
                    end;
                    PlayerObject.CurrentHealth = Humanoid.Health;
                    Humanoid:GetPropertyChangedSignal("Health"):Connect(function()
                        local PlayerObject = Visuals:Get(Player);
                        local Health = Humanoid.Health;
                        local OldHealth = PlayerObject.CurrentHealth; 
                        if Health < 0 then Health = 0 end;
                        if Health < OldHealth then 
                            for Index = OldHealth, Health, -1 do 
                                Wait(0.0005);
        
                                PlayerObject.CurrentHealth = Index;
                            end;
                        else 
                            for Index = OldHealth, Health, 1 do 
                                Wait(0.0005);
        
                                PlayerObject.CurrentHealth = Index;
                            end;
                        end;
                    end);
                end;
            end);
        end);
    end)
    Connections.PlayerRemoving = Players.PlayerRemoving:Connect(function(Player)
        local PlayerObject = Visuals:Get(Player);
        PlayerObject.Components.Box:Remove();
        PlayerObject.Components.BoxOutline:Remove();
        PlayerObject.Components.Healthbar:Remove();
        PlayerObject.Components.HealthbarOutline:Remove();
        PlayerObject.Components.ViewAngle:Remove();
        Spawn(function()
            PlayerObject.Components.Offscreen.Fill:Remove();
            PlayerObject.Components.Offscreen.Bold:Remove();
            PlayerObject.Components.Offscreen.Outline:Remove();
            PlayerObject.Components.Offscreen.OutlineBold:Remove();
        end);
        for Index, Value in next, PlayerObject.Components do 
            if type(Value) == "table" and rawget(Value, "Bold") and not rawget(Value, "Fill") then 
                Value.Main:Remove();
                Value.Bold:Remove();
            end;    
        end;
        Visuals.Objects.ESP[Player] = nil;
    end);
    
    Connections.VmAdded = Camera.ChildAdded:Connect(function()
        Wait(0.1);
        if Flags["ViewmodelChams"] and Flags["ViewmodelChams"]:Get() then
            local Parts = {};
            local ArmColor, GloveColor, ItemColor, ShirtColor = Flags["ArmColor"]:Get().Color, Flags["GloveColor"]:Get().Color, Flags["ItemColor"]:Get().Color, Flags["ShirtColor"]:Get().Color
            for Index, Part in next, GetDescendants(Camera.ViewModel) do
                if Flags["ShirtChams"]:Get() and (FindFirstAncestor(Part, "CamoShirt") or FindFirstAncestor(Part, "CivilianShirt") or FindFirstAncestor(Part, "GhillieTorso") or FindFirstAncestor(Part, "WastelandShirt")) then 
                    if Part:IsA("Part") or Part:IsA("MeshPart") then 
                        Part.Color = ShirtColor;
                        Part.Material = "ForceField";
                        table.insert(Parts, Part);
                    end;
                    if Part:IsA("SurfaceAppearance") then Part:Destroy(); end;
                elseif Flags["ItemChams"]:Get() and FindFirstAncestor(Part, "Item") then
                    if Part:IsA("Part") or Part:IsA("MeshPart") then 
                        Part.Color = ItemColor;
                        Part.Material = "ForceField";
                        table.insert(Parts, Part);
                    end;
                    if Part:IsA("SurfaceAppearance") then Part:Destroy(); end;
    
                elseif Flags["GloveChams"]:Get() and (FindFirstAncestor(Part, "HandWraps") or FindFirstAncestor(Part, "CombatGloves")) then
                    if Part:IsA("Part") or Part:IsA("MeshPart") then 
                        Part.Color = GloveColor;
                        Part.Material = "ForceField";
                        table.insert(Parts, Part);
                    end;
                    if Part:IsA("SurfaceAppearance") then Part:Destroy(); end;
                else 
                    if (Part:IsA("Part") or Part:IsA("MeshPart")) and Flags["ArmChams"]:Get() then 
                        Part.Color = ArmColor;
                        Part.Material = "ForceField";
                        table.insert(Parts, Part);
                    end;
                end;
            end;
        end;
    end);
    Connections.MouseMove = Mouse.Move:Connect(function()
        if Flags["FOV Position"] and Flags["FOV Position"]:Get() == "Mouse" then
            local MousePosition = Utility.GetMousePos();
            Visuals.Objects.AimAssistFOV.Fill.Position = MousePosition;
            Visuals.Objects.AimAssistFOV.Outline.Position = MousePosition;
        end;

        if Flags["Silent FOV Position"] and Flags["Silent FOV Position"]:Get() == "Mouse" then
            local MousePosition = Utility.GetMousePos();
            Visuals.Objects.SilentAimFOV.Fill.Position = MousePosition;
            Visuals.Objects.SilentAimFOV.Outline.Position = MousePosition;
        end;
    end);

    local function NewCharacter()
        repeat Wait() until Plr.Character; 
        Spawn(function()
            PlayerGui = Plr:WaitForChild("PlayerGui");
            MainGui = PlayerGui:WaitForChild("MainGui");
            MainGui.ChildAdded:Connect(function(Sound)
                if Sound and Sound:IsA("Sound") and Flags["CustomHitSounds"] and Flags["CustomHitSounds"]:Get() then 
                    local SoundId = Sound.SoundId

                    if SoundId == "rbxassetid://4585351098" or SoundId == "rbxassetid://4585382589" then
                        Sound.SoundId = "rbxassetid://"..HitmarkerSounds[Flags["HeadshotSound"]:Get()];
                    end;

                    if SoundId == "rbxassetid://4585382046" or SoundId == "rbxassetid://4585364605" then 
                        Sound.SoundId = "rbxassetid://"..HitmarkerSounds[Flags["BodyshotSound"]:Get()];
                    end;
                end;
            end);
        end);

        RayParams.FilterDescendantsInstances = {workspace.NoCollision, Camera, Plr.Character};
        Plr.Character.ChildAdded:Connect(function(Item)
            task.spawn(function()
                if Item and Item:IsA("Model") then 
                    local Root = Item:WaitForChild("ItemRoot");
                    if Root then 
                        for Index, Value in next, GetChildren(Root) do 
                            if Value:IsA("Sound") and Flags["SilentBullet"] and Flags["SilentBullet"]:Get() then
                                Value:Clone().Parent = Value.Parent;
                                Wait();
                                Value:Destroy();
                            end;
                        end;
                    end;
                end;
            end);
        end);
    end;

    Connections.CharacterAdded = Plr.CharacterAdded:Connect(function()
        NewCharacter();
    end);
    Spawn(function()
        repeat Wait() until Plr.Character ~= nil;
        NewCharacter();
    end);
end)();
--// Loops 
local Loops = {}; LPH_NO_VIRTUALIZE(function()
    Loops.RenderStepped = RunService.RenderStepped:Connect(function()
        local SilentClosest, SilentDistance;
        local AssistClosest, AssistDistance;
        local ViewerClosest, ViewerDistance = nil, 9e9;
        for Index, Value in pairs(Visuals.Objects.ESP) do
            Spawn(function()
                local Main = Value.Main;
                local Class = Value.Class; 
                local Character = Main;
                
                if Class == "Player" then 
                    Character = Main.Character;
                end; 
                
                if Character and Main ~= Plr then 
                    local Root = FindFirstChild(Character, "HumanoidRootPart");
                    local Humanoid = FindFirstChildOfClass(Character, "Humanoid");
    
                    if Root and Humanoid then 
                        local ScreenPos, OnScreen = WTSP(Camera, Root.Position);
    
                        if OnScreen then
                            Spawn(function()
                                local Center = Visuals.Objects.AimAssistFOV.Fill.Position;
                                if Flags["AimAssist"] and Flags["AimAssist"]:Get() and ((Flags["AssistVisCheck"]:Get() and Utility:IsVisible(Root)) or Flags["AssistVisCheck"]:Get() == false) and (Root.Position - Camera.CFrame.p).Magnitude <= Flags["AssistMaxDistance"]:Get() then 
                                    local DistanceFromCenter = (Center - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude;
                                    if (DistanceFromCenter <= (AssistDistance or (Flags["Use FOV"]:Get() and Visuals.Objects.AimAssistFOV.Fill.Radius) or 2000)) then 
                                        local AllowedParts = Flags["AssistParts"]:Get() 
                                        AssistClosest = Character[AllowedParts[math.random(1, #AllowedParts)]];
                                        AssistDistance = DistanceFromCenter;
                                    end
                                end;
                            end);
                            
                            Spawn(function()
                                local SilentCenter = Visuals.Objects.SilentAimFOV.Fill.Position;
                                if Flags["SilentAim"] and Flags["SilentAim"]:Get() and ((Flags["SilentVisCheck"]:Get() and Utility:IsVisible(Root)) or Flags["SilentVisCheck"]:Get() == false) and ((Flags["LimitDistance"] and Flags["LimitDistance"]:Get() and (Root.Position - Camera.CFrame.p).Magnitude <= Flags["SilentMaxDistance"]:Get()) or Flags["LimitDistance"] and not Flags["LimitDistance"]:Get()) then 
                                    local DistanceFromCenter = (SilentCenter - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude;
                                    if (DistanceFromCenter <= (SilentDistance or (Flags["Silent Use FOV"]:Get() and Visuals.Objects.SilentAimFOV.Fill.Radius) or 2000)) then 
                                        local AllowedParts = Flags["SilentParts"]:Get();
                                        SilentClosest = Character[AllowedParts[math.random(1, #AllowedParts)]];
                                        SilentDistance = DistanceFromCenter;
                                    end
                                end;
                            end);
                            
                            if Flags["PlayerInfo"] then 
                                Spawn(function()
                                    local ViewerCenter = Camera.ViewportSize / 2;
                                    if Flags["Viewer"] and Flags["Viewer"]:Get() then 
                                        local DistanceFromCenter = (ViewerCenter - Vector2.new(ScreenPos.X, ScreenPos.Y)).Magnitude; 
                                        if (DistanceFromCenter <= ViewerDistance) then 
                                            ViewerClosest = Character;
                                            ViewerDistance = DistanceFromCenter
                                        end;
                                    end;
                                end);
                            end;
                        end;
                    end;
                end;
            end);
            
            Spawn(function()
                Value:Update();
            end);
        end;
        
        if Flags["Viewer"] and Flags["Viewer"]:Get() then 
            Combat["Viewer target"] = ViewerClosest;
        end;

        if Combat["Viewer target"] then 
            if tick() - LastViewerTick > 0.5 then 
                LastViewerTick = tick();
                Viewer:Update(Combat["Viewer target"], Combat["Viewer target"].PrimaryPart);
            end;
        else 
            Viewer.MainFrame.Visible = false;
        end;
        Combat["Aim assist target"] = AssistClosest;
        Combat["Silent aim target"] = SilentClosest;

        do 
            -- Lighting stuff
            if Flags["Ambient"] and Flags["Ambient"]:Get() and Flags["AmbientColor"] then 
                Lighting.Ambient = Flags.AmbientColor:Get().Color;
            else 
                Lighting.Ambient = OGLighting.Ambient
            end;

            if Flags["Clocktime"] and Flags["Clocktime"]:Get() and Flags["ClocktimeValue"] then 
                Lighting.ClockTime = Flags["ClocktimeValue"]:Get();
            end;

            if Flags["EnableFogColor"] and Flags["EnableFogColor"]:Get() and Flags["FogColor"] then 
                Lighting.FogColor = Flags["FogColor"]:Get().Color;
            else 
                Lighting.FogColor = OGLighting.FogColor
            end;
        end;
        --// Atmosphere eiting
        do 
            if Atmosphere then 
                if Flags["FogDensity"] and Flags["FogDensity"]:Get() and Flags["FogDensityValue"]  then 
                    Atmosphere.Density = Flags["FogDensityValue"]:Get();
                else
                   -- Atmosphere.Density = OGLighting.Density;
                end;
    
                if Flags["EnableFogColor"] and Flags["EnableFogColor"]:Get() and Flags["FogColor"] then 
                    Atmosphere.Color = Flags["FogColor"]:Get().Color;
                    Atmosphere.Decay = Flags["FogColor"]:Get().Color;
                else
                    Atmosphere.Color = OGLighting.FogColor;
                    Atmosphere.Decay = OGLighting.FogDecay;
                end;
                
                if Flags["EnableGlare"] and Flags["EnableGlare"]:Get() and Flags["GlareValue"] then 
                    Atmosphere.Glare = Flags["GlareValue"]:Get();
                else 
                    Atmosphere.Glare = OGLighting.Glare;
                end;
                
                if Flags["EnableHaze"] and Flags["EnableHaze"]:Get() and Flags["HazeValue"] then 
                    Atmosphere.Haze = Flags["HazeValue"]:Get();
                else 
                    Atmosphere.Haze = OGLighting.Haze;
                end;
            end;
        end
        do  
            ColorCorrection.Enabled = Flags["ChangeCC"] and Flags["ChangeCC"]:Get();
            if Flags["ChangeSaturation"] and Flags["ChangeSaturation"]:Get() and Flags["SaturationValue"] then 
                ColorCorrection.Saturation = Flags["SaturationValue"]:Get();
            else 
                ColorCorrection.Saturation = OGLighting.Saturation;
            end;
                
            if Flags["ChangeContrast"] and Flags["ChangeContrast"]:Get() and Flags["ContrastValue"] then 
                ColorCorrection.Contrast = Flags["ContrastValue"]:Get();
            else 
                ColorCorrection.Contrast = OGLighting.Contrast;
            end;
                
            if Flags["ChangeBrightness"] and Flags["ChangeBrightness"]:Get() and Flags["BrightnessValue"] then 
                ColorCorrection.Brightness = Flags["BrightnessValue"]:Get();
            else 
                ColorCorrection.Brightness = OGLighting.Brightness;
            end;
        end;
        if Flags["Hitmarkers"] and Flags["Hitmarkers"]:Get() then 
            for Hit, Info in next, Visuals.Objects.Hitmarkers do 
                Visuals:UpdateHits(Hit)
            end;
        end;

        if Plr.Character and FindFirstChildOfClass(Plr.Character, "Humanoid") then 
            local Humanoid = Plr.Character.Humanoid;
            local PlayerGui = FindFirstChild(Plr, "PlayerGui");
            
            if PlayerGui and FindFirstChild(PlayerGui, "MainGui") and FindFirstChild(PlayerGui.MainGui, "MainFrame") then
                local ScreenVFX = FindFirstChild(PlayerGui.MainGui.MainFrame, "ScreenEffects");
                local Mask = ScreenVFX and FindFirstChild(ScreenVFX, "Mask");
                local Visor = ScreenVFX and FindFirstChild(ScreenVFX, "Visor");
                local HelmetMask = ScreenVFX and FindFirstChild(ScreenVFX, "HelmetMask");
                
                if Flags["RemoveVisor"] and Flags["RemoveVisor"]:Get() and Visor and HelmetMask and Mask then 
                    Visor.Visible = false;
                    Mask.Visible = false;
                    HelmetMask.Visible = false;
                elseif Flags["RemoveVisor"] and not Flags["RemoveVisor"]:Get() and Visor and HelmetMask and Mask then 
                    Visor.Visible = true;
                    Mask.Visible = true;
                    HelmetMask.Visible = true;
                end;
            end;
            if PlayerGui then 
                ServerInfo = PlayerGui:WaitForChild("PerformanceMonitor2");  
                if Flags["RemoveServerInfo"] and Flags["RemoveServerInfo"]:Get() then
                    ServerInfo.Enabled = false;
                else 
                    if ServerInfo then ServerInfo.Enabled = true end;
                end;
            end;

            if Flags["AntiAim"] and Flags["AntiAim"]:Get() and Flags["YawBase"] and Humanoid.RootPart then
                Humanoid.AutoRotate = false;
                local Root = Humanoid.RootPart;

                local Angle = -math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X) + math.rad(-90); do
                    if Flags["YawBase"]:Get() == "Random" then 
                        Angle = -math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X + math.rad(math.random(0, 360)));
                    elseif Flags["YawBase"]:Get() == "Spin" then 
                        Angle = -math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X) + tick() * 10 % 360;
                    elseif Flags["YawBase"]:Get() == "None" then 
                        Angle = -math.atan2(Camera.CFrame.LookVector.Z, Camera.CFrame.LookVector.X) + math.rad(-90);
                    end
                end;

                local Offset = math.rad(Flags["YawOffset"]:Get())

                local Angled = CFrame.new(Root.Position) * CFrame.Angles(0, Angle + Offset, 0);

                if Flags["YawBase"]:Get() == "Targets" and Combat["Silent aim target"] then 
                    Angled = CFrame.new(Root.Position, Combat["Silent aim target"].Position) * CFrame.Angles(0, Offset, 0);
                end;
                Root.CFrame = Utility:Rotate(Angled)
            else 
                Humanoid.AutoRotate = true;
            end;
            
            if Flags["Speedhack"] and Flags["Speedhack"]:Get() then
                RunService.Heartbeat:Wait();
                local Direction = Humanoid.MoveDirection;
                local Root = FindFirstChild(Plr.Character, "HumanoidRootPart");
                    
                if Root and Flags["SpeedValue"] then 
                    Root.CFrame = Root.CFrame + Vector3.new(Direction.X * Flags["SpeedValue"]:Get(), Direction.Y * Flags["SpeedValue"]:Get(), Direction.Z * Flags["SpeedValue"]:Get())
                end
            end;
            
            if Flags["Jumphack"] and Flags["Jumphack"]:Get() then
                Humanoid.JumpHeight = Flags["JumpValue"]:Get();
            end;
            
            if Flags["KillAura"] and Flags["KillAura"]:Get() and Combat["Silent aim target"] and tick() - LastHitTick > 1.5 then 
                LastHitTick = tick();
                local Character = Combat["Silent aim target"].Parent;
                local Position = Camera.CFrame.p;
                local MeleeInflict = ReplicatedStorage.Remotes.MeleeInflict;
                local MeleeReplicate = ReplicatedStorage.Remotes.MeleeReplicate;
                local LookVec = (Position - Combat["Silent aim target"].Position).Unit
                Spawn(function()
                    MeleeInflict:FireServer(Character, Combat["Silent aim target"], "PowerAttack");
                    Wait(0.3);
                    MeleeReplicate:FireServer(Combat["Silent aim target"], Combat["Silent aim target"].Position, LookVec , Enum.Material.Plastic);
                end);
            end;
        end;
        
        for Index, Value in pairs(Visuals.Objects.Customs) do 
            Value:Update()
        end;
    end);
    Loops.Heartbeat = RunService.Heartbeat:Connect(function(Delta)
        Combat:AimAt(Delta);
        
        local LastHealthbarTick = tick()
        if tick() - LastHealthbarTick > 0.01 and Ethereal.Window then 
            Ethereal.Window.VisualPreview:UpdateHealthBar();
            Ethereal.Window.VisualPreview:UpdateHealthValue(5);
    
            LastHealthbarTick = tick();
        end;
    end);
end)();
--// Loaded modules setup
do 
    LoadedModules.Loops = Loops;
    LoadedModules.DistanceConversions = DistanceConversions;
    LoadedModules.Connections = Connections;
    LoadedModules.Visuals = Visuals;
    LoadedModules.Drawing = DrawFuncs;
    LoadedModules.Instance = InstanceFuncs;
    LoadedModules.Tween = Tween;
    LoadedModules.Hooks = Hooks;
    LoadedModules.Combat = Combat;
end;

local Window = Ethereal:New({name = "Ethereal", Style = 1, Size = Vector2.new(600, 750), PageAmmount = 6, callback = function(Page) Ethereal.VisualPreview:SetPreviewState(Page == "ESP"); end});

LPH_NO_VIRTUALIZE(function() 
    local LegitPage = Window:Page({name = "Legit"}); do 
        local Assist = LegitPage:Section({name = "Aim Assist", side = "Left", Fill = false}); do 
            Assist:Toggle({name = "Enabled", pointer = "AimAssist"}):Keybind({flag = "Aim assist", mode = "On Hold"});
            Assist:Toggle({name = "Humanization", pointer = "Humanization"})
            Assist:Slider({pointer = "HumanizationScale", min = 1, max = 10, decimals = 0.01, default = 1.5})

            Assist:Toggle({name = "Visible check", pointer = "AssistVisCheck"});
            Assist:Slider({name = "Max distance", pointer = "AssistMaxDistance", min = 20, max = 10000});

            Assist:Multibox({name = "Hit boxes", pointer = "AssistParts", options = {
                "Head",
                "UpperTorso",
                "Torso",
                "LowerTorso",
                "HumanoidRootPart",
                "RightUpperArm",
                "Right Arm",
                "RightLowerArm",
                "LeftUpperArm",
                "Left Arm",
                "LeftLowerArm",
            }});
        end;

        local LeigtSettings = LegitPage:Section({name = "Settings", side = "Right", Fill = false}); do 
            LeigtSettings:Toggle({name = "Use field of view", pointer = "Use FOV"})

            LeigtSettings:Toggle({name = "Show field of view", pointer = "Show FOV", callback = function() Visuals.Objects.AimAssistFOV.Fill.Visible = Flags["Show FOV"] and Flags["Show FOV"]:Get(); Visuals.Objects.AimAssistFOV.Outline.Visible = Flags["Show FOV"] and Flags["Show FOV"]:Get() end}):Colorpicker({transp = 1, pointer = "FOV Color", callback = function() 
                Visuals.Objects.AimAssistFOV.Fill.Color = Flags["FOV Color"] and Flags["FOV Color"]:Get().Color
            end});

            LeigtSettings:Slider({name = "Radius", max = 1000, min = 15, pointer = "Radius", callback = function()
                Visuals.Objects.AimAssistFOV.Fill.Radius = Flags["Radius"] and Flags["Radius"]:Get() or 15;
                Visuals.Objects.AimAssistFOV.Outline.Radius = Flags["Radius"] and Flags["Radius"]:Get() or 15;
            end});

            LeigtSettings:Slider({name = "Sides", max = 1000, min = 4, pointer = "Sides", callback = function()
                Visuals.Objects.AimAssistFOV.Fill.NumSides = Flags["Sides"] and Flags["Sides"]:Get() or 4;
                Visuals.Objects.AimAssistFOV.Outline.NumSides = Flags["Sides"] and Flags["Sides"]:Get() or 4;
            end})

            LeigtSettings:Dropdown({name = "Field of view position", pointer = "FOV Position", max = 2, options = {"Mouse", "Center"}, callback = function(State)
                if State == "Center" then 
                    Visuals.Objects.AimAssistFOV.Fill.Position = Camera.ViewportSize / 2;
                    Visuals.Objects.AimAssistFOV.Outline.Position = Camera.ViewportSize / 2;
                end;
            end})
        end;
    end;

    local RagePage = Window:Page({name = "Rage"}); do 
        local SilentAim = RagePage:Section({name = "Silent aim", side = "Left"}); do 
            SilentAim:Toggle({name = "Enabled", pointer = "SilentAim"})
            SilentAim:Slider({name = "Hitchance", min = 0, max = 100, default = 100, decimals = 0.1, pointer = "Hitchance"})
            
            SilentAim:Toggle({name = "Visible check", pointer = "SilentVisCheck"})
            SilentAim:Toggle({name = "Kill aura", pointer = "KillAura"});
            
            SilentAim:Toggle({name = "Limit distance", pointer = "LimitDistance"})
            SilentAim:Slider({pointer = "SilentMaxDistance", min = 20, max = 10000});

            SilentAim:Toggle({name = "Resolver", pointer = "ResolverEnabled"});
            SilentAim:Multibox({pointer = "ResolverOptions", options = {"Leaning", "Pitch", "Velocity"}});

            SilentAim:Multibox({name = "Hit boxes", pointer = "SilentParts", options = {
                "Head",
                "HumanoidRootPart",
                "RightUpperArm",
                "RightLowerArm",
                "LeftUpperArm",
                "LeftLowerArm",
                "UpperTorso",
                "LowerTorso",
        
            }});
        end;

        local SilentAimSettings = RagePage:Section({name = "Settings", side = "Right"}); do
            SilentAimSettings:Toggle({name = "Use field of view", pointer = "Silent Use FOV"})

            SilentAimSettings:Toggle({name = "Show field of view", pointer = "SilentShowFOV",  callback = function() Visuals.Objects.SilentAimFOV.Fill.Visible = Flags["SilentShowFOV"] and Flags["SilentShowFOV"]:Get();Visuals.Objects.SilentAimFOV.Outline.Visible = Flags["SilentShowFOV"] and Flags["SilentShowFOV"]:Get() end}):Colorpicker({transp = 1, pointer = "Silent FOV Color", callback = function() 
                Visuals.Objects.SilentAimFOV.Fill.Color = Flags["Silent FOV Color"] and Flags["Silent FOV Color"]:Get().Color
            end});

            SilentAimSettings:Slider({name = "Radius", max = 1000, min = 15, pointer = "SilentRadius", callback = function()
                Visuals.Objects.SilentAimFOV.Fill.Radius = Flags["SilentRadius"] and Flags["SilentRadius"]:Get() or 15;
                Visuals.Objects.SilentAimFOV.Outline.Radius = Flags["SilentRadius"] and Flags["SilentRadius"]:Get() or 15;
            end})
    
            SilentAimSettings:Slider({name = "Sides", max = 1000, min = 4, pointer = "SilentSides", callback = function()
                Visuals.Objects.SilentAimFOV.Fill.NumSides = Flags["SilentSides"] and Flags["SilentSides"]:Get() or 4;
                Visuals.Objects.SilentAimFOV.Outline.NumSides = Flags["SilentSides"] and Flags["SilentSides"]:Get() or 4;
            end})

            SilentAimSettings:Dropdown({name = "Field of view position", pointer = "Silent FOV Position", max = 2, options = {"Mouse", "Center"}, callback = function(State)
                if State == "Center" then 
                  Visuals.Objects.SilentAimFOV.Fill.Position = Camera.ViewportSize / 2;
                  Visuals.Objects.SilentAimFOV.Outline.Position = Camera.ViewportSize / 2;
                end;
            end})
        end;

        local Mods = RagePage:Section({name = "Weapon mods", side = "Right"}); do
            Mods:Toggle({name = "Instant revive", pointer = "InstantRevive"})
            Mods:Toggle({name = "Force tracers", pointer = "ForceTracers"});
            Mods:Toggle({name = "No FOV Change", pointer = "RemoveAimFOV"});
            Mods:Toggle({name = "No gun sounds", pointer = "SilentBullet"});
            Mods:Toggle({name = "Instant bullet", pointer = "InstantBullet"});
            Mods:Toggle({name = "Instant aim", pointer = "InstantAim"});
            Mods:Toggle({name = "No recoil", pointer = "RemoveRecoil", callback = function(State)
                getgenv().NoRecoil = Flags["RemoveRecoil"] and Flags["RemoveRecoil"]:Get();
            end});
            Mods:Toggle({name = "No spread", pointer = "RemoveSpread"});
            Mods:Toggle({name = "No occlusion", pointer = "RemoveOcclusion"});
            Mods:Toggle({name = "No bobbing", pointer = "RemoveGunBobbing"});
            Mods:Toggle({name = "No sway", pointer = "RemoveGunSway"});
            Mods:Toggle({name = "Unlock firemodes", pointer = "UnlockFiremodes"});
        end;
    end;

    local ESP = Window:Page({name = "ESP"}); do 
        local Main = ESP:Section({name = "Main", side = "left"}); do 
            Main:Toggle({name = "Bounding box", pointer = "ESPBoxes"}):Colorpicker({pointer = "ESPBoxColor", default = Color3.fromRGB(255,255,255), callback = function()
                Ethereal.VisualPreview:SetComponentProperty("Box", "Color", Flags["ESPBoxColor"]:Get().Color, "Box");
            end});
            Main:Toggle({name = "View angle", pointer = "Viewangle"}):Colorpicker({pointer = "AngleColor"})
            local HealthbarToggle = Main:Toggle({name = "Healthbars", pointer = "ESPHealthbar", callback = function() 
                Ethereal.VisualPreview:SetComponentProperty("HealthBar", "Visible", Flags["ESPHealthbar"]:Get(), "Box");
                Ethereal.VisualPreview:SetComponentProperty("HealthBar", "Visible", Flags["ESPHealthbar"]:Get(), "Outline");
            end}); do 
                HealthbarToggle:Colorpicker({pointer = "HigherHealth", default = Color3.fromRGB(0,255,0), callback = function()
                    Window.VisualPreview.Color1 = Flags["HigherHealth"]:Get().Color
                end});
                HealthbarToggle:Colorpicker({pointer = "LowerHealth", default = Color3.fromRGB(255,0,0), callback = function()
                    Window.VisualPreview.Color2 = Flags["LowerHealth"]:Get().Color
                end});
            end;
            Main:Toggle({name = "Name", pointer = "ESPNames"}):Colorpicker({pointer = "ESPNameColor", default = Color3.fromRGB(255,255,255), callback = function()
                Ethereal.VisualPreview:SetComponentProperty("Title", "Color", Flags["ESPNameColor"]:Get().Color, "Text");
            end});
            Main:Toggle({name = "Distance", pointer = "ESPDistance"}):Colorpicker({pointer = "ESPDistanceColor", default = Color3.fromRGB(255,255,255), callback = function()
                Ethereal.VisualPreview:SetComponentProperty("Distance", "Color", Flags["ESPDistanceColor"]:Get().Color, "Text");
            end});
            Main:Toggle({name = "Weapon", pointer = "ESPWeapon"}):Colorpicker({pointer = "ESPWeaponColor", default = Color3.fromRGB(255,255,255), callback = function()
                Ethereal.VisualPreview:SetComponentProperty("Tool", "Color", Flags["ESPWeaponColor"]:Get().Color, "Text");
            end});
            Main:Toggle({name = "Health", pointer = "ESPHealth"}):Colorpicker({pointer = "ESPHealthColor", default = Color3.fromRGB(255,255,255)});
            --[[Main:Toggle({name = "Flag", pointer = "ESPFlag"}):Colorpicker({pointer = "ESPFlagColor", default = Color3.fromRGB(255,255,255), callback = function()
                Ethereal.VisualPreview:SetComponentProperty("Flags", "Color", Flags["ESPFlagColor"]:Get().Color, "Text");
            end});]]
            
            for Index, Value in next, Window.VisualPreview.Components.Skeleton do 
                if type(Value) == "table" then
                    for I2, V2 in next, Value do 
                        V2.Visible = false;
                    end;
                end;
            end;
            --[[Main:Toggle({name = "Skeletons", pointer = "ESPSkeletons"}):Colorpicker({pointer = "ESPSkeletonColor", default = Color3.fromRGB(255,255,255), callback = function()
                Window.VisualPreview.Components.Skeleton["Head"][2].Color = Flags["ESPSkeletonColor"]:Get().Color
                Window.VisualPreview.Components.Skeleton["Torso"][2].Color = Flags["ESPSkeletonColor"]:Get().Color
                Window.VisualPreview.Components.Skeleton["HipsTorso"][2].Color = Flags["ESPSkeletonColor"]:Get().Color
                Window.VisualPreview.Components.Skeleton["LeftArm"][2].Color = Flags["ESPSkeletonColor"]:Get().Color
                Window.VisualPreview.Components.Skeleton["RightArm"][2].Color = Flags["ESPSkeletonColor"]:Get().Color
                Window.VisualPreview.Components.Skeleton["LeftLeg"][2].Color = Flags["ESPSkeletonColor"]:Get().Color
                Window.VisualPreview.Components.Skeleton["RightLeg"][2].Color = Flags["ESPSkeletonColor"]:Get().Color
            end});]]

            local ChamsToggle = Main:Toggle({name = "Chams", pointer = "ESPChams", callback = function(State)
                Ethereal.VisualPreview:SetComponentProperty("Chams", "Visible", Flags["ESPChams"]:Get(), "Box");
                Ethereal.VisualPreview:ValidateSize("X", State and 5 or 1);
            end}); do 
                ChamsToggle:Colorpicker({transp = 0.5,pointer = "Invisible color", default = Color3.fromRGB(255,255,255), callback = function()

                end});
                ChamsToggle:Colorpicker({transp = 0.5, pointer = "Visible color", default = Color3.fromRGB(255,0,0), callback = function()

                end});
            end;
            Main:Slider({pointer = "ChamsRefreshRate", name = "Chams referesh tick", decimals = 0.01, min = 0, max = 5, default = 0})

            local OffscreenToggle = Main:Toggle({name = "Offscreen arrows", pointer = "ESPOffscreen"}); do 
                --Main:Multibox({name = "Indicators", pointer = "OffscreenIndicators", max = 4, options = {"Name","Distance","Weapon","Healthbar"}});
                OffscreenToggle:Colorpicker({pointer = "OffscreenColor", default = Color3.fromRGB(255,255,255)});
                Main:Slider({min = 40, max = 500, name = "Radius", pointer = "OffscreenRadius"});
                Main:Slider({min = 10, max = 30, name = "Size", pointer = "OffscreenSize"});
                
                Main:Toggle({name = "Blinking arrows", pointer = "BlinkingArrows"});
                Main:Toggle({name = "Outline arrows", pointer = "OutlineArrows"});
            end;
        end;

        local Options = ESP:Section({name = "Settings", side = "Right"}); do
            local RelationColors = Options:Toggle({name = "Target color", pointer = "UseRelationColors"}); do 
                RelationColors:Colorpicker({pointer = "EnemyColor", default = Color3.fromRGB(255,0,0)});
                Options:Dropdown({pointer = "RelationPrefers", options = {"Silent aim", "Aim assist"}});
            end;
            Options:Toggle({name = "Bold text", pointer = "BoldText"})
            
            Options:Dropdown({name = "Distance conversion", pointer = "DistanceMode", options = {"Studs", "Meters"}, default = "Studs"})
            Options:Slider({default = 3, min = 3, max = 15, name = "Box width", pointer = "BoxWidth"});
            Options:Slider({default = 6, min = 6, max = 19, name = "Box height", pointer = "BoxHeight"});
            Options:Slider({default = 0, max = 20, min = -20, name = "Box offset", pointer = "BoxOffset"})
        end;
        local Customs = ESP:Section({name = "World", side = "Right"}); do
            Customs:Toggle({name = "Extract points", pointer = "ESPExit"}):Colorpicker({default = Color3.fromRGB(255,255,255), pointer = "ExitColor"});
            Customs:Toggle({name = "Lootable corpses", pointer = "ESPCorpse"}):Colorpicker({default = Color3.fromRGB(255,255,255), pointer = "CorpseColor"})
            Customs:Slider({name = "Distance", pointer = "CustomDistance", min = 0, max = 2000})
        end;
    end;

    local VisualsPage = Window:Page({name = "Visuals"}); do 
        local Lighting = VisualsPage:Section({name = "World", side = "Left"}); do 
            Lighting:Toggle({name = "Ambient", pointer = "Ambient"}):Colorpicker({pointer = "AmbientColor"});
            Lighting:Toggle({name = "Clocktime", pointer = "Clocktime"});
            Lighting:Slider({min = 0, max = 12, pointer = "ClocktimeValue"});
            Lighting:Dropdown({name = "Lighting technology", pointer = "LightingTech", default = "None", options = {"ShadowMap","Voxel","Future","Compatibility","Legacy"}, callback = function()
                if Flags["LightingTech"] and Flags["LightingTech"]:Get() ~= "None" then
                    sethiddenproperty(game.Lighting, "Technology", Flags["LightingTech"]:Get())
                end;
            end})

            Lighting:Toggle({name = "Visors", pointer = "RemoveVisor"});
            Lighting:Toggle({name = "Server info", pointer = "RemoveServerInfo"});
            Lighting:Toggle({name = "Grass", pointer = "RemoveGrass", callback = function(State)
                sethiddenproperty(Workspace.Terrain, "Decoration", not State)
            end})
        end;
        
        local WeatherSec = VisualsPage:Section({name = "Weather", side = "Left"}); do 
            WeatherSec:Toggle({name = "Fog density", pointer = "FogDensity"});
            WeatherSec:Slider({pointer = "FogDensityValue", min = 0, max = 1, decimals = 0.001})
            
            WeatherSec:Toggle({name = "Haze", pointer = "EnableHaze"});
            WeatherSec:Slider({pointer = "HazeValue", min = 0, max = 1, decimals = 0.001})
        
            WeatherSec:Toggle({name = "Glare", pointer = "EnableGlare"});
            WeatherSec:Slider({pointer = "GlareValue", min = 0, max = 1, decimals = 0.001})
            
            WeatherSec:Toggle({name = "Fog color", pointer = "EnableFogColor"}):Colorpicker({pointer = "FogColor"});
        end;
        
        local CombatVis = VisualsPage:Section({name = "Combat", side = "Left"}); do 
            CombatVis:Toggle({name = "Hitlogs", pointer = "Hitlogs"});
            CombatVis:Toggle({name = "Hitmarkers", pointer = "Hitmarkers"}):Colorpicker({default = Color3.fromRGB(255,255,255), pointer = "HitmarkerColor"}); do 
                CombatVis:Slider({pointer = "HitmarkerLifetime", max = 5, min = 0});
            end
        end;
        
        local MiscVis = VisualsPage:Section({name = "Miscellaneous", side = "Right"}); do 
            MiscVis:Toggle({name = "Third person", pointer = "ThirdPerson"}):Keybind({pointer = "Third person", mode = "Toggle"}); 
            MiscVis:Slider({min = 0, max = 20, pointer = "Thirdperson offset"})
            MiscVis:Toggle({name = "Remove bobbing", pointer = "RemoveBobbing"})
            MiscVis:Toggle({name = "Zoom", pointer = "ZoomEnabled"}):Keybind({mode = "On Hold", pointer = "Zoom", callback = function()
                if Flags["ZoomEnabled"] and Flags["ZoomEnabled"]:Get() and Flags["Zoom"] and Flags["Zoom"]:Active() then 
                    Camera.FieldOfView = Flags["ZoomAmt"]:Get();
                else 
                    Camera.FieldOfView = ReplicatedStorage.Players[Plr.Name].Settings.GameplaySettings:GetAttribute("DefaultFOV");
                end;
            end});
            MiscVis:Slider({pointer = "ZoomAmt", min = 0, max = 100});
            MiscVis:Toggle({name = "Default FOV", pointer = "UseDFOV", callback = function() 
                if Flags["UseDFOV"] and Flags["UseDFOV"]:Get() then 
                    ReplicatedStorage.Players[Plr.Name].Settings.GameplaySettings:SetAttribute("DefaultFOV", Flags["DefaultFOV"]:Get())
                else
                    ReplicatedStorage.Players[Plr.Name].Settings.GameplaySettings:SetAttribute("DefaultFOV", 70)
                end;
                
            end});
            MiscVis:Slider({min = 0, max = 120, pointer = "DefaultFOV", callback = function()
                if Flags["UseDFOV"] and Flags["UseDFOV"]:Get() then 
                    ReplicatedStorage.Players[Plr.Name].Settings.GameplaySettings:SetAttribute("DefaultFOV", Flags["DefaultFOV"]:Get())
                end;
            end});
            
            MiscVis:Toggle({name = "Viewmodel chams", pointer = "ViewmodelChams"}); do
                MiscVis:Toggle({name = "Shirts", pointer = "ShirtChams"}):Colorpicker({flag = "ShirtColor"});
                MiscVis:Toggle({name = "Arms", pointer = "ArmChams"}):Colorpicker({flag = "ArmColor"});
                MiscVis:Toggle({name = "Gloves", pointer = "GloveChams"}):Colorpicker({flag = "GloveColor"});
                MiscVis:Toggle({name = "Item", pointer = "ItemChams"}):Colorpicker({flag = "ItemColor"});
            end;
        end;

        local ViewerSec = VisualsPage:Section({name = "Display info", side = "Right"}); do 
            ViewerSec:Toggle({name = "Enabled", pointer = "Viewer"}); do 
                ViewerSec:Multibox({pointer = "PlayerInfo", max = 4, options = {"Health", "Visible", "Distance", "Hotbar", "Inventory"}})
                ViewerSec:Slider({name = "Position X", pointer = "PositionX", min = 0, max = 100, callback = function()
                    if Flags["PositionX"] and Flags["PositionY"] then 
                        Viewer.MainFrame.Position = UDim2.new(Flags["PositionX"]:Get() / 100, 0, Flags["PositionY"]:Get() / 100, 0)
                    end;
                end});
                ViewerSec:Slider({name = "Position Y", pointer = "PositionY", min = 0, max = 100, callback = function()
                    if Flags["PositionX"] and Flags["PositionY"] then 
                        Viewer.MainFrame.Position = UDim2.new(Flags["PositionX"]:Get() / 100, 0, Flags["PositionY"]:Get() / 100, 0)
                    end;
                end});
            end;
        end;
    end;

    local Misc = Window:Page({name = "Misc"}); do 
        local CharacterSec = Misc:Section({name = "Character", side = "Left", fill = false}); do
            CharacterSec:Toggle({name = "Remove drowning",pointer = "AntiDrown"});
            CharacterSec:Toggle({name = "Speedhack", pointer = "Speedhack"});
            CharacterSec:Slider({pointer = "SpeedValue", min = 0, max = 1, decimals = 0.001})
            CharacterSec:Toggle({name = "Jumphack", pointer = "Jumphack"});
            CharacterSec:Slider({pointer = "JumpValue", min = 0, max = 50});
            CharacterSec:Button({name = "Remove landmines", callback = function()
                for i, v in next, FindFirstChild(Workspace.AiZones, "OutpostLandmines"):GetChildren() do 
                    if v then 
                        v:Destroy()
                    end;
                end;
                        
                FindFirstChild(Workspace.AiZones, "OutpostLandmines").ChildAdded:Connect(function(v)
                    v:Destroy()
                end);
            end});
        end;

        local AntiAimSec = Misc:Section({name = "Anti aimbot", side = "Left"}); do 
            AntiAimSec:Toggle({pointer = "AntiAim", name = "Enabled"});

            AntiAimSec:Slider({name = "Pitch angle", pointer = "Pitch",max = 2, min = -2, increment = 0.1})
            AntiAimSec:Slider({name = "Yaw offset", pointer = "YawOffset", min = -360, max = 360})

            AntiAimSec:Dropdown({max = 4, name = "Yaw base", pointer = "YawBase", options = {"None", "Random", "Spin", "At targets"}});
            AntiAimSec:Dropdown({max = 4, name = "Pitch base", pointer = "PitchBase", options = {"Up", "Down", "Custom", "Random"}});
        end;
        
        local MiscExtra = Misc:Section({name = "Extra", side = "Right"}); do 
            MiscExtra:Toggle({name = "Click teleportation", pointer = "BindTeleport"}):Keybind({mode = "Toggle", pointer = "Teleport", callback = function()
                if Flags["Teleport"]:Active() then
                    if (Camera.CFrame.p - Mouse.Hit.p).Magnitude / 3 < 600 and Mouse.Hit then 
                        Plr.Character.HumanoidRootPart.CFrame = Mouse.Hit;
                        Wait(0.05);
                        Plr.Character.HumanoidRootPart.CFrame = Mouse.Hit;
                    else 
                        Ethereal.notifications.Notify("Ethereal - Distance is too far to teleport to!")
                    end;
                end;
            end});

            MiscExtra:Toggle({name = "Hit sounds", pointer = "CustomHitSounds"}); 

            MiscExtra:Dropdown({max = 5, options = {"Rust", "Neverlose", "Gamesense", "CSGO", "Minecraft"}, name = "Head sound", pointer = "HeadshotSound"})
            MiscExtra:Dropdown({max = 5, options = {"Rust", "Neverlose", "Gamesense", "CSGO", "Minecraft"}, name = "Body sound", pointer = "BodyshotSound"})
        end;
    end;

    local ConfigurationPage = Window:Page({Name = "Settings"}) do
        -- Additions
        local MenuAdditions = ConfigurationPage:Section({Name = "Extra", Fill = false, Side = "Left"}) do
            MenuAdditions:Toggle({Pointer = "SettingsMenuKeybindList", Name = "Keybind list", Callback = function(State) 
                Window.keybindslist:Update("Visible", State) 
            end})

            MenuAdditions:Button({name = "Reconnect to server", Callback = function()
                Ethereal.notifications.Notify("Ethereal - Reconnecting...")
                game:GetService("TeleportService"):Teleport(game.PlaceId)
            end})

            MenuAdditions:ButtonHolder({Buttons = {
                {"Get connect script", function()
                    Ethereal.notifications.Notify("Ethereal - Successfully copied LUA connect to your clipboard!")
                    setclipboard(([[game:GetService("TeleportService"):TeleportToPlaceInstance(%s, "%s")]]):format(game.PlaceId, game.JobId));
                end}, 
                {"Unload script", function()
                    Window:Unload()
                end}}
            })
        end

        local CreditsSection = ConfigurationPage:Section({Name = "Ethereal Credits", Fill = false, Side = "Left"}) do
            CreditsSection:Label({Name = "Main developer: Ethereal.#6691"})
        end

        -- Configuration
        local MenuConfiguration = ConfigurationPage:Section({Name = "Configuration", Fill = false, Side = "Right"}) do
            local CurrentList = {} do
                local function UpdateConfigList()
                    local List = {}
                    for idx, file in ipairs(listfiles("Ethereal/Configs")) do
                        local FileName = file:gsub("Ethereal/Configs\\", ""):gsub(".txt", "")
                        List[#List + 1] = FileName
                    end
    
                    local IsNew = #List ~= #CurrentList
                    if not IsNew then
                        for idx, file in ipairs(List) do                    
                            if file ~= CurrentList[idx] then
                                IsNew = true;
                                break
                            end
                        end
                    end
        
                    if IsNew then
                        CurrentList = List
                        Flags.SettingConfigurationList.options = CurrentList;
                        Flags.SettingConfigurationList:UpdateScroll()
                    end
                end
    
                MenuConfiguration:Keybind({Pointer = "SettingsMenuKeybind", Name = "Open / Close", Default = Enum.KeyCode.C, Callback = function(State) 
                    Window.uibind = State 
                end})

                MenuConfiguration:List({Pointer = "SettingConfigurationList"});
                MenuConfiguration:TextBox({Pointer = "SettingsConfigurationName", PlaceHolder = "Config name"});
                MenuConfiguration:ButtonHolder({Buttons = {{"Create", function()
                    local Success, Error = pcall(function()
                        local ConfigName = Flags.SettingsConfigurationName:Get()
    
                        if ConfigName == "" or isfile("Ethereal/Configs/" .. ConfigName .. ".txt") then
                            Ethereal.notifications.Notify("Ethereal - Config '"..tostring(Flags.SettingsConfigurationName:Get()).."' already exists!")
                            return
                        end
    
                        writefile("Ethereal/Configs/" .. ConfigName .. ".txt", "");
                        UpdateConfigList()
                    end)
                    if not Success and Error then
                        printconsole(tostring(Error))
                        Ethereal.notifications.Notify("Ethereal - Error creating config '"..tostring(Flags.SettingsConfigurationName:Get()).."'")
                    else
                        Ethereal.notifications.Notify("Ethereal - Successfully created config '"..tostring(Flags.SettingsConfigurationName:Get()).."'")
                    end
                end}, {"Delete", function()
                    local SelectedConfig = Flags.SettingConfigurationList:Get()
                    if SelectedConfig then
                        delfile("Ethereal/Configs/" .. SelectedConfig .. ".txt")
                        UpdateConfigList()
                        Ethereal.notifications.Notify("Ethereal - Successfully deleted config '"..tostring(Flags.SettingsConfigurationName:Get()).."'")
                    end
                end}}})
    
                MenuConfiguration:ButtonHolder({buttons = {{"Load", function()
                    local Success, Error = pcall(function()
                        local SelectedConfig = Flags.SettingConfigurationList:Get()
                        if SelectedConfig then
                            Window:LoadConfig(readfile("Ethereal/Configs/" .. SelectedConfig .. ".txt"))
                        end
                    end)
                    
                    if not Success and Error then
                        printconsole(tostring(Error))
                        Ethereal.notifications.Notify("Ethereal - Error loading config '"..tostring(debug.traceback()).."'")
                    else
                        Ethereal.notifications.Notify("Ethereal - Successfully loaded config '"..tostring(Flags.SettingsConfigurationName:Get()).."'")
                    end
                    
                end}, {"Save", function()
                    local Success, Error = pcall(function()
                        local SelectedConfig = Flags.SettingConfigurationList:Get()
                        if SelectedConfig then
                            writefile("Ethereal/Configs/" .. SelectedConfig .. ".txt", Window:GetConfig())
                        end
                    end)
                    
                    if not Success and Error then 
                        printconsole(tostring(Error))
                        Ethereal.notifications.Notify("Ethereal - Error saving config '"..tostring(Flags.SettingsConfigurationName:Get()).."'")
                    else
                        Ethereal.notifications.Notify("Ethereal - Successfully saved config '"..tostring(Flags.SettingsConfigurationName:Get()).."'")
                    end
                end}}});
    
                MenuConfiguration:Button({Name = "Refresh", Callback = function()
                    UpdateConfigList()
                    Ethereal.notifications.Notify("Ethereal - Refreshed configs.")
                end})
                UpdateConfigList()
            end
        end
    end
end)();
Window.uibind = Enum.KeyCode.C
Window:Initialize();
