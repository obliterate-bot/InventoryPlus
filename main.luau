 























































local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")
local SoundService = game:GetService("SoundService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local ENV = (getgenv and getgenv()) or _G
local CONTROLLER_KEY = "__DQ_INVENTORY_CLASS_SORTER_V1"
local PERSIST_KEY = "__DQ_INVENTORY_QOL_PERSIST_V5"
local SAVE_FILE = "DQ_Inventory_QOL_v5.json"


local old = ENV[CONTROLLER_KEY]
if type(old) == "table" and type(old.Stop) == "function" then
    pcall(old.Stop, old)
end

local Persistent = ENV[PERSIST_KEY]
if type(Persistent) ~= "table" then
    Persistent = {
        Favorites = {},
        Locked = {},
        Loadouts = {},
        Wishlist = {},
        KeepRules = {},
        ItemNotes = {},
        ItemTags = {},
        SavedSearches = {},
        SettingsProfiles = {},
        ClassProfiles = {},
        ItemFirstSeen = {},
        LootHistory = {},
        KnownIDs = {},
        NewIDs = {},
        KnownInitialized = false,
        SeededKnownIDs = false,
        UIState = {
            ClassFilter = "",
            SearchText = "",
            BestLoadout = false, 
            BestMode = "Off",
            JunkOnly = false,
            PendingAutoUpgradeClass = "",
        },
        Settings = {
            SortMode = "Highest Pot",
            HideCommon = false,
            HideAbilities = false,
            OnlyUpgradable = false,
            OnlyEquipable = false,
            GroupDupes = false,
            HideJunk = false,
            MinLevel = 0,

            GoldReserve = 0,
            SpendCap = 0, 
            TargetUpgradePct = 100,
            UpgradeWeapon = true,
            UpgradeChest = true,
            UpgradeHelmet = true,

            AutoSellMaxValue = 0, 
            HideBadges = false,
            CompactTooltip = false,
            TooltipTextSize = 13,
            JunkMode = "NonBest",
            KeepCopies = 1,
            ProtectGodpot = true,
            ProtectSRolls = true,
            ProtectLegendary = true,
            WishlistAutoLock = true,
            InventoryCapacity = 300,
            InventoryWarningPct = 90,
            MinImprovementPct = 0,
            MinImprovementFlat = 0,
            RequireBetterNow = false,
            HighValueWarning = 0,
            HighSpendPct = 50,
            AdvancedSearch = true,
            AutoCleanupPrompt = true,
            HideStatusBadge = false,
            HideNewBadge = false,
            HideUpgradeBadge = false,
            HideProtectionBadge = false,
            DropNotifications = true,
            WishlistNotifications = true,
            GodpotNotifications = true,
            SRollNotifications = false,
            LegendaryNotifications = false,
            AutoExportSession = false,
            ImportMode = "Replace",
            GridScale = 100,
            GridColumns = 0,
            DropSoundId = "",
            GoldMilestone = 0,
            LootMilestone = 0,
            QOLTab = "Overview",
        },
    }
    ENV[PERSIST_KEY] = Persistent
end

Persistent.Favorites = Persistent.Favorites or {}
Persistent.Locked = Persistent.Locked or {}
Persistent.Loadouts = type(Persistent.Loadouts) == "table" and Persistent.Loadouts or {}
Persistent.Wishlist = type(Persistent.Wishlist) == "table" and Persistent.Wishlist or {}
Persistent.KeepRules = type(Persistent.KeepRules) == "table" and Persistent.KeepRules or {}
Persistent.ItemNotes = type(Persistent.ItemNotes) == "table" and Persistent.ItemNotes or {}
Persistent.ItemTags = type(Persistent.ItemTags) == "table" and Persistent.ItemTags or {}
Persistent.SavedSearches = type(Persistent.SavedSearches) == "table" and Persistent.SavedSearches or {}
Persistent.SettingsProfiles = type(Persistent.SettingsProfiles) == "table" and Persistent.SettingsProfiles or {}
Persistent.ClassProfiles = type(Persistent.ClassProfiles) == "table" and Persistent.ClassProfiles or {}
Persistent.ItemFirstSeen = type(Persistent.ItemFirstSeen) == "table" and Persistent.ItemFirstSeen or {}
Persistent.LootHistory = type(Persistent.LootHistory) == "table" and Persistent.LootHistory or {}
Persistent.KnownIDs = Persistent.KnownIDs or {}
Persistent.NewIDs = Persistent.NewIDs or {}
Persistent.KnownInitialized = Persistent.KnownInitialized == true
Persistent.UIState = Persistent.UIState or {
    ClassFilter = "",
    SearchText = "",
    BestLoadout = false,
    BestMode = "Off",
    JunkOnly = false,
    PendingAutoUpgradeClass = "",
}
Persistent.UIState.PendingAutoUpgradeClass =
    tostring(Persistent.UIState.PendingAutoUpgradeClass or "")


local savedBestMode = tostring(Persistent.UIState.BestMode or "")
if savedBestMode ~= "Now"
    and savedBestMode ~= "Potential"
    and savedBestMode ~= "Budget"
    and savedBestMode ~= "Off"
then
    savedBestMode = Persistent.UIState.BestLoadout == true and "Potential" or "Off"
end
Persistent.UIState.BestMode = savedBestMode

Persistent.Settings = Persistent.Settings or {}
Persistent.Settings.SortMode = Persistent.Settings.SortMode or "Highest Pot"
Persistent.Settings.HideCommon = Persistent.Settings.HideCommon == true
Persistent.Settings.HideAbilities = Persistent.Settings.HideAbilities == true
Persistent.Settings.OnlyUpgradable = Persistent.Settings.OnlyUpgradable == true
Persistent.Settings.OnlyEquipable = Persistent.Settings.OnlyEquipable == true
Persistent.Settings.GroupDupes = Persistent.Settings.GroupDupes == true
Persistent.Settings.HideJunk = Persistent.Settings.HideJunk == true
Persistent.Settings.MinLevel = math.max(0, tonumber(Persistent.Settings.MinLevel) or 0)

Persistent.Settings.GoldReserve = math.max(0, tonumber(Persistent.Settings.GoldReserve) or 0)
Persistent.Settings.SpendCap = math.max(0, tonumber(Persistent.Settings.SpendCap) or 0)
Persistent.Settings.TargetUpgradePct = math.clamp(
    tonumber(Persistent.Settings.TargetUpgradePct) or 100,
    0,
    100
)
Persistent.Settings.UpgradeWeapon = Persistent.Settings.UpgradeWeapon ~= false
Persistent.Settings.UpgradeChest = Persistent.Settings.UpgradeChest ~= false
Persistent.Settings.UpgradeHelmet = Persistent.Settings.UpgradeHelmet ~= false

Persistent.Settings.AutoSellMaxValue =
    math.max(0, tonumber(Persistent.Settings.AutoSellMaxValue) or 0)
Persistent.Settings.HideBadges = Persistent.Settings.HideBadges == true
Persistent.Settings.CompactTooltip = Persistent.Settings.CompactTooltip == true
Persistent.Settings.TooltipTextSize = math.clamp(
    math.floor(tonumber(Persistent.Settings.TooltipTextSize) or 13),
    10,
    18
)
Persistent.Settings.JunkMode = (Persistent.Settings.JunkMode == "Duplicates" or Persistent.Settings.JunkMode == "NonBest") and Persistent.Settings.JunkMode or "NonBest"
Persistent.Settings.KeepCopies = math.clamp(nonNegativeInteger and nonNegativeInteger(Persistent.Settings.KeepCopies, 1) or math.floor(tonumber(Persistent.Settings.KeepCopies) or 1), 1, 20)
Persistent.Settings.ProtectGodpot = Persistent.Settings.ProtectGodpot ~= false
Persistent.Settings.ProtectSRolls = Persistent.Settings.ProtectSRolls ~= false
Persistent.Settings.ProtectLegendary = Persistent.Settings.ProtectLegendary ~= false
Persistent.Settings.WishlistAutoLock = Persistent.Settings.WishlistAutoLock ~= false
Persistent.Settings.InventoryCapacity = math.max(1, math.floor(tonumber(Persistent.Settings.InventoryCapacity) or 300))
Persistent.Settings.InventoryWarningPct = math.clamp(tonumber(Persistent.Settings.InventoryWarningPct) or 90, 1, 100)
Persistent.Settings.MinImprovementPct = math.max(0, tonumber(Persistent.Settings.MinImprovementPct) or 0)
Persistent.Settings.MinImprovementFlat = math.max(0, tonumber(Persistent.Settings.MinImprovementFlat) or 0)
Persistent.Settings.RequireBetterNow = Persistent.Settings.RequireBetterNow == true
Persistent.Settings.HighValueWarning = math.max(0, tonumber(Persistent.Settings.HighValueWarning) or 0)
Persistent.Settings.HighSpendPct = math.clamp(tonumber(Persistent.Settings.HighSpendPct) or 50, 0, 100)
Persistent.Settings.AdvancedSearch = Persistent.Settings.AdvancedSearch ~= false
Persistent.Settings.AutoCleanupPrompt = Persistent.Settings.AutoCleanupPrompt ~= false
Persistent.Settings.HideStatusBadge = Persistent.Settings.HideStatusBadge == true
Persistent.Settings.HideNewBadge = Persistent.Settings.HideNewBadge == true
Persistent.Settings.HideUpgradeBadge = Persistent.Settings.HideUpgradeBadge == true
Persistent.Settings.HideProtectionBadge = Persistent.Settings.HideProtectionBadge == true
Persistent.Settings.DropNotifications = Persistent.Settings.DropNotifications ~= false
Persistent.Settings.WishlistNotifications = Persistent.Settings.WishlistNotifications ~= false
Persistent.Settings.GodpotNotifications = Persistent.Settings.GodpotNotifications ~= false
Persistent.Settings.SRollNotifications = Persistent.Settings.SRollNotifications == true
Persistent.Settings.LegendaryNotifications = Persistent.Settings.LegendaryNotifications == true
Persistent.Settings.AutoExportSession = Persistent.Settings.AutoExportSession == true
Persistent.Settings.ImportMode = Persistent.Settings.ImportMode == "Merge" and "Merge" or "Replace"
Persistent.Settings.GridScale = math.clamp(tonumber(Persistent.Settings.GridScale) or 100, 70, 140)
Persistent.Settings.GridColumns = math.clamp(math.floor(tonumber(Persistent.Settings.GridColumns) or 0), 0, 12)
Persistent.Settings.DropSoundId = tostring(Persistent.Settings.DropSoundId or "")
Persistent.Settings.GoldMilestone = math.max(0, tonumber(Persistent.Settings.GoldMilestone) or 0)
Persistent.Settings.LootMilestone = math.max(0, math.floor(tonumber(Persistent.Settings.LootMilestone) or 0))
Persistent.Settings.QOLTab = tostring(Persistent.Settings.QOLTab or "Overview")

local Controller = {
    Alive = true,

    ClassFilter = nil,
    SearchText = "",
    BestLoadout = false, 
    BestMode = "Off",
    JunkOnly = false,

    ActionBusy = false,
    ActionCancelRequested = false,
    ActionProgressText = "Idle",
    ActionLog = {},
    ActionQueue = {},
    QueueRunning = false,
    ReviewLootOnly = false,
    CompareSelection = {},
    PinnedUID = nil,
    RecentlyEquippedUIDs = {},
    RecentlyUpgradedUIDs = {},
    RecentlySoldUIDs = {},
    SessionStats = {Equipped = 0, Upgrades = 0, UpgradeGold = 0, Sold = 0, SellGold = 0},
    SessionSnapshot = nil,
    SessionSnapshotTime = nil,
    LastCapacityWarningCount = -1,
    LastGoldMilestone = nil,
    LastLootMilestone = nil,
    QueueStopRequested = false,
    EquippedBadgeObjects = {},
    EquippedConnections = {},
    PendingAutoUpgradeClass = nil,
    PendingAutoUpgradeRunning = false,

    GlobalConnections = {},
    AttachConnections = {},
    CardConnections = {},
    SellConnections = {},

    CurrentGui = nil,
    CurrentScroll = nil,
    CurrentClassBar = nil,
    CurrentToolbar = nil,
    CurrentActionBar = nil,
    CurrentActionProgress = nil,
    CurrentSortPopup = nil,
    CurrentFilterPopup = nil,
    CurrentConfirmPopup = nil,
    CurrentMorePopup = nil,
    CurrentDuplicatePopup = nil,
    ConfirmAction = nil,

    CurrentSellGui = nil,
    CurrentSellScroll = nil,
    SellHiddenByLock = {},

    OriginalScrollPosition = nil,
    OriginalScrollSize = nil,
    OriginalScrollZIndex = nil,
    OriginalGridSortOrder = nil,
    OriginalGridCellSize = nil,
    OriginalCardOrder = {},

    InventoryData = nil,
    InventoryInfos = {},
    InventoryInfoByUID = {},
    CardInfo = {},
    HoveredCard = nil,
    HoveredEquippedInfo = nil,
    TooltipExtra = nil,
    TooltipNativeState = {},
    BestByClassSlot = {},
    BestByMode = {
        Now = {},
        Potential = {},
        Budget = {},
    },

    SessionBaselineReady = false,
    SessionStartUIDs = {},
    SessionLootDrops = {},

    TargetLayoutOrder = {},
}

ENV[CONTROLLER_KEY] = Controller





local function canReadFiles()
    return type(isfile) == "function" and type(readfile) == "function"
end

local function canWriteFiles()
    return type(writefile) == "function"
end

local function loadDiskState()
    if not canReadFiles() then
        return
    end

    local okExists, exists = pcall(isfile, SAVE_FILE)
    if not okExists or not exists then
        return
    end

    local okRead, raw = pcall(readfile, SAVE_FILE)
    if not okRead or type(raw) ~= "string" then
        return
    end

    local okDecode, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not okDecode or type(data) ~= "table" then
        return
    end

    if type(data.Favorites) == "table" then
        Persistent.Favorites = data.Favorites
    end
    if type(data.Locked) == "table" then
        Persistent.Locked = data.Locked
    end
    if type(data.Loadouts) == "table" then
        Persistent.Loadouts = data.Loadouts
    end
    if type(data.Wishlist) == "table" then Persistent.Wishlist = data.Wishlist end
    if type(data.KeepRules) == "table" then Persistent.KeepRules = data.KeepRules end
    if type(data.ItemNotes) == "table" then Persistent.ItemNotes = data.ItemNotes end
    if type(data.ItemTags) == "table" then Persistent.ItemTags = data.ItemTags end
    if type(data.SavedSearches) == "table" then Persistent.SavedSearches = data.SavedSearches end
    if type(data.SettingsProfiles) == "table" then Persistent.SettingsProfiles = data.SettingsProfiles end
    if type(data.ClassProfiles) == "table" then Persistent.ClassProfiles = data.ClassProfiles end
    if type(data.ItemFirstSeen) == "table" then Persistent.ItemFirstSeen = data.ItemFirstSeen end
    if type(data.LootHistory) == "table" then Persistent.LootHistory = data.LootHistory end
    if type(data.Settings) == "table" then
        for key, value in pairs(data.Settings) do
            Persistent.Settings[key] = value
        end
    end

    if type(data.UIState) == "table" then
        Persistent.UIState = data.UIState
    end

    if type(data.KnownIDs) == "table" then
        Persistent.KnownIDs = data.KnownIDs
    end

    if type(data.NewIDs) == "table" then
        Persistent.NewIDs = data.NewIDs
    end

    if data.KnownInitialized == true then
        Persistent.KnownInitialized = true
    end

    Persistent.Loadouts = type(Persistent.Loadouts) == "table" and Persistent.Loadouts or {}
    Persistent.Wishlist = type(Persistent.Wishlist) == "table" and Persistent.Wishlist or {}
    Persistent.KeepRules = type(Persistent.KeepRules) == "table" and Persistent.KeepRules or {}
    Persistent.ItemNotes = type(Persistent.ItemNotes) == "table" and Persistent.ItemNotes or {}
    Persistent.ItemTags = type(Persistent.ItemTags) == "table" and Persistent.ItemTags or {}
    Persistent.SavedSearches = type(Persistent.SavedSearches) == "table" and Persistent.SavedSearches or {}
    Persistent.SettingsProfiles = type(Persistent.SettingsProfiles) == "table" and Persistent.SettingsProfiles or {}
    Persistent.ClassProfiles = type(Persistent.ClassProfiles) == "table" and Persistent.ClassProfiles or {}
    Persistent.ItemFirstSeen = type(Persistent.ItemFirstSeen) == "table" and Persistent.ItemFirstSeen or {}
    Persistent.LootHistory = type(Persistent.LootHistory) == "table" and Persistent.LootHistory or {}
    Persistent.UIState = Persistent.UIState or {
        ClassFilter = "",
        SearchText = "",
        BestLoadout = false,
        BestMode = "Off",
        JunkOnly = false,
        PendingAutoUpgradeClass = "",
    }

    Persistent.UIState.PendingAutoUpgradeClass =
        tostring(Persistent.UIState.PendingAutoUpgradeClass or "")

    local diskBestMode = tostring(Persistent.UIState.BestMode or "")
    if diskBestMode ~= "Now"
        and diskBestMode ~= "Potential"
        and diskBestMode ~= "Budget"
        and diskBestMode ~= "Off"
    then
        diskBestMode = Persistent.UIState.BestLoadout == true and "Potential" or "Off"
    end
    Persistent.UIState.BestMode = diskBestMode

    Persistent.Settings.SortMode = Persistent.Settings.SortMode or "Highest Pot"
    Persistent.Settings.MinLevel = math.max(0, tonumber(Persistent.Settings.MinLevel) or 0)
    Persistent.Settings.GoldReserve = math.max(0, tonumber(Persistent.Settings.GoldReserve) or 0)
    Persistent.Settings.SpendCap = math.max(0, tonumber(Persistent.Settings.SpendCap) or 0)
    Persistent.Settings.TargetUpgradePct = math.clamp(
        tonumber(Persistent.Settings.TargetUpgradePct) or 100, 0, 100
    )
    Persistent.Settings.AutoSellMaxValue =
        math.max(0, tonumber(Persistent.Settings.AutoSellMaxValue) or 0)
    Persistent.Settings.TooltipTextSize = math.clamp(
        math.floor(tonumber(Persistent.Settings.TooltipTextSize) or 13), 10, 22
    )
    Persistent.Settings.JunkMode = (Persistent.Settings.JunkMode == "Duplicates" or Persistent.Settings.JunkMode == "NonBest") and Persistent.Settings.JunkMode or "NonBest"
    Persistent.Settings.KeepCopies = math.clamp(math.floor(tonumber(Persistent.Settings.KeepCopies) or 1), 1, 20)
    Persistent.Settings.ProtectGodpot = Persistent.Settings.ProtectGodpot ~= false
    Persistent.Settings.ProtectSRolls = Persistent.Settings.ProtectSRolls ~= false
    Persistent.Settings.ProtectLegendary = Persistent.Settings.ProtectLegendary ~= false
    Persistent.Settings.WishlistAutoLock = Persistent.Settings.WishlistAutoLock ~= false
    Persistent.Settings.InventoryCapacity = math.max(1, math.floor(tonumber(Persistent.Settings.InventoryCapacity) or 300))
    Persistent.Settings.InventoryWarningPct = math.clamp(tonumber(Persistent.Settings.InventoryWarningPct) or 90, 1, 100)
    Persistent.Settings.MinImprovementPct = math.max(0, tonumber(Persistent.Settings.MinImprovementPct) or 0)
    Persistent.Settings.MinImprovementFlat = math.max(0, tonumber(Persistent.Settings.MinImprovementFlat) or 0)
    Persistent.Settings.RequireBetterNow = Persistent.Settings.RequireBetterNow == true
    Persistent.Settings.HighValueWarning = math.max(0, tonumber(Persistent.Settings.HighValueWarning) or 0)
    Persistent.Settings.HighSpendPct = math.clamp(tonumber(Persistent.Settings.HighSpendPct) or 50, 0, 100)
    Persistent.Settings.AdvancedSearch = Persistent.Settings.AdvancedSearch ~= false
    Persistent.Settings.AutoCleanupPrompt = Persistent.Settings.AutoCleanupPrompt ~= false
    Persistent.Settings.HideStatusBadge = Persistent.Settings.HideStatusBadge == true
    Persistent.Settings.HideNewBadge = Persistent.Settings.HideNewBadge == true
    Persistent.Settings.HideUpgradeBadge = Persistent.Settings.HideUpgradeBadge == true
    Persistent.Settings.HideProtectionBadge = Persistent.Settings.HideProtectionBadge == true
    Persistent.Settings.DropNotifications = Persistent.Settings.DropNotifications ~= false
    Persistent.Settings.WishlistNotifications = Persistent.Settings.WishlistNotifications ~= false
    Persistent.Settings.GodpotNotifications = Persistent.Settings.GodpotNotifications ~= false
    Persistent.Settings.SRollNotifications = Persistent.Settings.SRollNotifications == true
    Persistent.Settings.LegendaryNotifications = Persistent.Settings.LegendaryNotifications == true
    Persistent.Settings.AutoExportSession = Persistent.Settings.AutoExportSession == true
    Persistent.Settings.ImportMode = Persistent.Settings.ImportMode == "Merge" and "Merge" or "Replace"
    Persistent.Settings.GridScale = math.clamp(tonumber(Persistent.Settings.GridScale) or 100, 70, 140)
    Persistent.Settings.GridColumns = math.clamp(math.floor(tonumber(Persistent.Settings.GridColumns) or 0), 0, 12)
    Persistent.Settings.DropSoundId = tostring(Persistent.Settings.DropSoundId or "")
    Persistent.Settings.GoldMilestone = math.max(0, tonumber(Persistent.Settings.GoldMilestone) or 0)
    Persistent.Settings.LootMilestone = math.max(0, math.floor(tonumber(Persistent.Settings.LootMilestone) or 0))
    Persistent.Settings.QOLTab = tostring(Persistent.Settings.QOLTab or "Overview")
end


local function saveDiskState()
    if not canWriteFiles() then
        return
    end

    Persistent.UIState = {
        ClassFilter = Controller.ClassFilter or "",
        SearchText = tostring(Controller.SearchText or ""),
        BestLoadout = Controller.BestMode ~= "Off", 
        BestMode = Controller.BestMode or "Off",
        JunkOnly = Controller.JunkOnly == true,
        PendingAutoUpgradeClass =
            Controller.PendingAutoUpgradeClass or "",
    }

    local payload = {
        Favorites = Persistent.Favorites,
        Locked = Persistent.Locked,
        Loadouts = Persistent.Loadouts,
        Wishlist = Persistent.Wishlist,
        KeepRules = Persistent.KeepRules,
        ItemNotes = Persistent.ItemNotes,
        ItemTags = Persistent.ItemTags,
        SavedSearches = Persistent.SavedSearches,
        SettingsProfiles = Persistent.SettingsProfiles,
        ClassProfiles = Persistent.ClassProfiles,
        ItemFirstSeen = Persistent.ItemFirstSeen,
        LootHistory = Persistent.LootHistory,
        Settings = Persistent.Settings,
        UIState = Persistent.UIState,
        KnownIDs = Persistent.KnownIDs,
        NewIDs = Persistent.NewIDs,
        KnownInitialized = Persistent.KnownInitialized == true,
    }

    local okEncode, raw = pcall(HttpService.JSONEncode, HttpService, payload)
    if okEncode and type(raw) == "string" then
        pcall(writefile, SAVE_FILE, raw)
    end
end




local diskSaveGeneration = 0

local function scheduleDiskStateSave(delaySeconds)
    diskSaveGeneration += 1
    local generation = diskSaveGeneration

    task.delay(delaySeconds or 0.45, function()
        if Controller.Alive and generation == diskSaveGeneration then
            saveDiskState()
        end
    end)
end

loadDiskState()



if Persistent.Settings.SortMode == "Potential %" then
    Persistent.Settings.SortMode = "Upgrade %"
    saveDiskState()
end


do
    local saved = Persistent.UIState or {}

    local classFilter = tostring(saved.ClassFilter or "")
    if classFilter == "Mage"
        or classFilter == "Warrior"
        or classFilter == "Tank"
        or classFilter == "Skills"
    then
        Controller.ClassFilter = classFilter
    else
        Controller.ClassFilter = nil
    end

    Controller.SearchText = string.lower(tostring(saved.SearchText or ""))

    local mode = tostring(saved.BestMode or "")
    if mode ~= "Now" and mode ~= "Potential" and mode ~= "Budget" and mode ~= "Off" then
        mode = saved.BestLoadout == true and "Potential" or "Off"
    end
    if Controller.ClassFilter == "Skills" then
        mode = "Off"
    end

    Controller.BestMode = mode
    Controller.BestLoadout = mode ~= "Off"
    Controller.JunkOnly = saved.JunkOnly == true

    local pendingClass = tostring(saved.PendingAutoUpgradeClass or "")
    if pendingClass == "Mage"
        or pendingClass == "Warrior"
        or pendingClass == "Tank"
    then
        Controller.PendingAutoUpgradeClass = pendingClass
    else
        Controller.PendingAutoUpgradeClass = nil
    end
end






local PlaceManager = nil

do
    local utility = ReplicatedStorage:FindFirstChild("Utility")
    local module = utility and utility:FindFirstChild("PlaceManager")

    if module and module:IsA("ModuleScript") then
        local ok, result = pcall(require, module)
        if ok and type(result) == "table" then
            PlaceManager = result
        end
    end
end

local function getDQPlaceName()
    if PlaceManager and type(PlaceManager.GetPlaceName) == "function" then
        local ok, result = pcall(PlaceManager.GetPlaceName)
        if ok and type(result) == "string" then
            return result
        end
    end

    
    if game.PlaceId == 85776757589518 then
        return "Level"
    elseif game.PlaceId == 77649408247578 then
        return "Lobby"
    end

    return "Unknown"
end

local function isUpgradeCapablePlace()
    return getDQPlaceName() == "Lobby"
end





local function disconnectAll(list)
    for i = #list, 1, -1 do
        local connection = list[i]
        list[i] = nil
        pcall(function()
            connection:Disconnect()
        end)
    end
end

local function addConnection(list, connection)
    list[#list + 1] = connection
    return connection
end

local function lower(value)
    return string.lower(tostring(value or ""))
end

local function clampNumber(n, lo, hi)
    n = tonumber(n) or lo
    if n < lo then
        return lo
    elseif n > hi then
        return hi
    end
    return n
end

local function round(n, decimals)
    local p = 10 ^ (decimals or 0)
    return math.floor((tonumber(n) or 0) * p + 0.5) / p
end

local function formatInt(n)
    n = math.floor(tonumber(n) or 0)
    local sign = n < 0 and "-" or ""
    local s = tostring(math.abs(n))

    local reversed = string.reverse(s)
    reversed = reversed:gsub("(%d%d%d)", "%1,")
    local out = string.reverse(reversed)

    if string.sub(out, 1, 1) == "," then
        out = string.sub(out, 2)
    end

    return sign .. out
end

local function formatCompact(n)
    n = tonumber(n) or 0
    local a = math.abs(n)
    local sign = n < 0 and "-" or ""

    if a >= 1e9 then
        return sign .. string.format("%.2fB", a / 1e9)
    elseif a >= 1e6 then
        return sign .. string.format("%.2fM", a / 1e6)
    elseif a >= 1e3 then
        return sign .. string.format("%.1fK", a / 1e3)
    end

    return sign .. tostring(math.floor(a + 0.5))
end

local function uidForItem(item)
    if type(item) ~= "table" then
        return nil
    end

    local uid = item.UniqueItemID or item.uniqueItemID or item.uniqueItemId
    if uid ~= nil then
        return tostring(uid)
    end

    return nil
end

local function isItemEquipped(item)
    if type(item) ~= "table" then
        return false
    end

    if item.equipped == true then
        return true
    end

    if type(item.equipped) == "table" then
        for _, value in pairs(item.equipped) do
            if value == true then
                return true
            end
        end
    end

    return false
end





local DATA_TABLE_NAMES = {
    "weapons",
    "helmets",
    "chests",
    "abilities",
    "pets",
    "rings",
}

local DATA_PREFIXES = {
    weapons = "weapon_",
    helmets = "helmet_",
    chests = "chest_",
    abilities = "ability_",
    pets = "pet_",
    rings = "ring_",
}

local TYPE_INFO = {
    weapon =  {container = "weapons",   prefix = "weapon_"},
    helmet =  {container = "helmets",   prefix = "helmet_"},
    chest =   {container = "chests",    prefix = "chest_"},
    armor =   {container = "chests",    prefix = "chest_"},
    ability = {container = "abilities", prefix = "ability_"},
    pet =     {container = "pets",      prefix = "pet_"},
    ring =    {container = "rings",     prefix = "ring_"},
}

local function countValidInventoryRecords(container, prefix)
    if type(container) ~= "table" then
        return 0
    end

    local n = 0

    for key, value in pairs(container) do
        if type(key) == "string"
            and string.match(key, "^" .. prefix .. "%d+$")
            and type(value) == "table"
            and type(value.name) == "string"
            and (
                value.UniqueItemID ~= nil
                or value.maxUpgrades ~= nil
                or value.levelReq ~= nil
            )
        then
            n += 1
        end
    end

    return n
end

local function inventoryTableScore(t)
    if type(t) ~= "table" then
        return -1
    end

    local validWeapons = countValidInventoryRecords(
        rawget(t, "weapons"),
        DATA_PREFIXES.weapons
    )

    if validWeapons <= 0 then
        return -1
    end

    local score = 0

    for _, name in ipairs(DATA_TABLE_NAMES) do
        local prefix = DATA_PREFIXES[name]
        if prefix then
            score += countValidInventoryRecords(rawget(t, name), prefix)
        end
    end

    return score
end

local function findInventoryDataFromGC()
    if type(getgc) ~= "function" then
        return nil
    end

    local ok, objects = pcall(getgc, true)
    if not ok or type(objects) ~= "table" then
        return nil
    end

    local best
    local bestScore = -1

    for _, object in ipairs(objects) do
        if type(object) == "table" then
            local score = inventoryTableScore(object)
            if score > bestScore then
                bestScore = score
                best = object
            end
        end
    end

    return best
end

local function findInventoryDataFromModule()
    local playerScripts = player:FindFirstChild("PlayerScripts")
    local uiFolder = playerScripts and playerScripts:FindFirstChild("Ui")
    local inventoryModule = uiFolder and uiFolder:FindFirstChild("inventory")

    if not inventoryModule or not inventoryModule:IsA("ModuleScript") then
        return nil
    end

    local okRequire, module = pcall(require, inventoryModule)
    if not okRequire
        or type(module) ~= "table"
        or type(module.GetPlayerInvy) ~= "function"
    then
        return nil
    end

    local resultEvent = Instance.new("BindableEvent")
    local finished = false

    task.spawn(function()
        local ok, result = pcall(module.GetPlayerInvy)
        if not finished then
            resultEvent:Fire(ok, result)
        end
    end)

    task.delay(1.25, function()
        if not finished then
            resultEvent:Fire(false, nil)
        end
    end)

    local ok, result = resultEvent.Event:Wait()
    finished = true
    resultEvent:Destroy()

    if ok and type(result) == "table" then
        return result
    end

    return nil
end

local function refreshInventoryData()
    
    
    
    local found = findInventoryDataFromModule()

    if not found then
        found = findInventoryDataFromGC()
    end

    if found and type(found) == "table" then
        Controller.InventoryData = found
    end

    return Controller.InventoryData
end

local function iterateInventoryRecords(callback)
    local root = Controller.InventoryData
    if type(root) ~= "table" then
        return
    end

    for itemType, info in pairs(TYPE_INFO) do
        if itemType ~= "armor" then
            local container = root[info.container]
            if type(container) == "table" then
                for key, item in pairs(container) do
                    if type(item) == "table" and type(item.name) == "string" then
                        callback(itemType, key, item)
                    end
                end
            end
        end
    end
end

local function seedKnownIDs()
    if Persistent.SeededKnownIDs then
        return
    end

    local changed = false

    if Persistent.KnownInitialized then
        
        
        iterateInventoryRecords(function(_, _, item)
            local uid = uidForItem(item)
            if uid and not Persistent.KnownIDs[uid] then
                Persistent.KnownIDs[uid] = true
                Persistent.NewIDs[uid] = true
                changed = true
            end
        end)
    else
        
        
        iterateInventoryRecords(function(_, _, item)
            local uid = uidForItem(item)
            if uid and not Persistent.KnownIDs[uid] then
                Persistent.KnownIDs[uid] = true
                changed = true
            end
        end)

        Persistent.KnownInitialized = true
        changed = true
    end

    Persistent.SeededKnownIDs = true

    if changed then
        saveDiskState()
    end
end





local function getCardIdentity(card)
    if not card or not card.Parent then
        return nil
    end

    local itemTypeValue = card:FindFirstChild("itemType")
    if not itemTypeValue or not itemTypeValue:IsA("ValueBase") then
        return nil
    end

    local itemType = lower(itemTypeValue.Value)

    local numberValue =
        itemTypeValue:FindFirstChild("uniqueItemNum")
        or card:FindFirstChild("uniqueItemNum")

    local number = numberValue and tonumber(numberValue.Value)

    if not TYPE_INFO[itemType] or not number then
        return nil
    end

    return itemType, math.floor(number)
end

local function lookupItem(itemType, itemNumber)
    local root = Controller.InventoryData
    local info = TYPE_INFO[itemType]

    if type(root) ~= "table" or not info then
        return nil
    end

    local container = rawget(root, info.container)
    if type(container) ~= "table" then
        return nil
    end

    local item =
        rawget(container, info.prefix .. tostring(itemNumber))
        or rawget(container, tostring(itemNumber))
        or rawget(container, itemNumber)

    if type(item) == "table" then
        return item
    end

    return nil
end

local MAGE_WORDS = {
    "mage",
    "wizard",
    "sorcer",
    "spell",
    "arcane",
    "mystic",
    "magic",
}

local WARRIOR_WORDS = {
    "warrior",
    "fighter",
    "knight",
    "physical",
}

local function containsAny(text, words)
    for _, word in ipairs(words) do
        if string.find(text, word, 1, true) then
            return true
        end
    end
    return false
end

local function classifyItem(item)
    if type(item) ~= "table" then
        return nil
    end

    local name = lower(item.name)
    local description = lower(item.description)

    if string.find(name, "guardian", 1, true)
        or string.find(name, "tank", 1, true)
        or string.find(description, "guardian", 1, true)
        or string.find(description, "tank", 1, true)
    then
        return "Tank"
    end

    if string.find(description, "scales with spell power", 1, true) then
        return "Mage"
    elseif string.find(description, "scales with physical power", 1, true) then
        return "Warrior"
    end

    if containsAny(name, MAGE_WORDS)
        and not containsAny(name, WARRIOR_WORDS)
    then
        return "Mage"
    elseif containsAny(name, WARRIOR_WORDS)
        and not containsAny(name, MAGE_WORDS)
    then
        return "Warrior"
    end

    local spell = tonumber(item.spellPower) or 0
    local physical =
        tonumber(item.physicalDamage)
        or tonumber(item.physicalPower)
        or 0

    if spell > physical then
        return "Mage"
    elseif physical > spell then
        return "Warrior"
    end

    return "Warrior"
end

local function relevantField(item, className)
    if type(item) ~= "table" then
        return nil
    end

    if className == "Tank" and item.health ~= nil then
        return "health"
    end

    if className == "Mage" and item.spellPower ~= nil then
        return "spellPower"
    end

    if className == "Warrior" then
        if item.physicalDamage ~= nil then
            return "physicalDamage"
        elseif item.physicalPower ~= nil then
            return "physicalPower"
        end
    end

    local candidates = {
        "health",
        "spellPower",
        "physicalDamage",
        "physicalPower",
    }

    local bestField
    local bestValue = -math.huge

    for _, field in ipairs(candidates) do
        local value = tonumber(item[field])
        if value and value > bestValue then
            bestValue = value
            bestField = field
        end
    end

    return bestField
end

local function fieldDisplayName(field)
    if field == "physicalDamage" or field == "physicalPower" then
        return "Physical"
    elseif field == "spellPower" then
        return "Spell"
    elseif field == "health" then
        return "Health"
    end

    return "Stat"
end

local function nonNegativeInteger(value, fallback)
    local n = tonumber(value)
    if not n or n ~= n or n == math.huge or n == -math.huge then
        n = tonumber(fallback) or 0
    end
    if n ~= n or n == math.huge or n == -math.huge then
        n = 0
    end
    return math.max(0, math.floor(n))
end

local function upgradeBounds(item)
    if type(item) ~= "table" then
        return 0, 0
    end
    local current = nonNegativeInteger(item.currentUpgrade)
    local maximum = math.max(current, nonNegativeInteger(item.maxUpgrades, current))
    return current, maximum
end

local function remainingUpgrades(item)
    local current, maximum = upgradeBounds(item)
    return maximum - current
end

local function gainPerUpgrade(currentStat)
    currentStat = tonumber(currentStat) or 0
    return math.clamp(math.floor(currentStat * 0.05 + 1), 1, 10)
end

local function potentialAfterUpgrades(currentStat, count)
    local value = tonumber(currentStat)
    if not value or value ~= value or value == math.huge or value == -math.huge then
        return nil
    end
    count = nonNegativeInteger(count)
    while count > 0 do
        local gain = gainPerUpgrade(value)
        if gain >= 10 then
            return math.floor(value + count * 10)
        end
        
        if value < 0 then
            local amount = math.min(count, math.ceil(-value))
            value = value + amount
            count = count - amount
        else
            value = value + gain
            count = count - 1
        end
    end
    return math.floor(value)
end

local function maxPotential(item, field)
    if type(item) ~= "table" or not field then
        return nil
    end
    return potentialAfterUpgrades(item[field], remainingUpgrades(item))
end

local function formatUpgradeProgress(current, maximum, decimals)
    current = nonNegativeInteger(current)
    maximum = nonNegativeInteger(maximum)
    decimals = math.clamp(nonNegativeInteger(decimals), 0, 2)
    if maximum <= 0 then
        return "N/A"
    end
    if current >= maximum then
        return "100%"
    end
    local scale = 10 ^ decimals
    local format = "%." .. tostring(decimals) .. "f%%"
    if current == 0 then
        return string.format(format, 0)
    end
    local value = math.floor((current / maximum) * 100 * scale) / scale
    if value <= 0 then
        return "<" .. string.format(format, 1 / scale)
    end
    
    return string.format(format, math.min(value, 100 - 1 / scale))
end

local function assignDuplicateGrades(list)
    table.sort(list, function(a, b)
        if a.Potential ~= b.Potential then
            return a.Potential > b.Potential
        end
        if a.Current ~= b.Current then
            return a.Current > b.Current
        end
        return a.ItemNumber < b.ItemNumber
    end)

    local distinct = 0
    local previous
    for _, info in ipairs(list) do
        if distinct == 0 or info.Potential ~= previous then
            distinct = distinct + 1
            previous = info.Potential
        end
        info.RollRank = distinct
    end

    local count = #list
    for index, info in ipairs(list) do
        info.DuplicateCount = count
        info.DuplicateIndex = index
        info.RollRankCount = distinct
        info.BestDuplicate = count > 1 and info.RollRank == 1
        if not info.RollGrade then
            if count > 1 then
                local fraction = distinct > 1 and (info.RollRank - 1) / (distinct - 1) or 0
                if fraction <= 0.20 then
                    info.RollGrade = "S"
                elseif fraction <= 0.45 then
                    info.RollGrade = "A"
                elseif fraction <= 0.75 then
                    info.RollGrade = "B"
                else
                    info.RollGrade = "C"
                end
            end
        end
    end
end







----------------------------------------------------------------
-- Authoritative Godpot & Roll Quality Database
----------------------------------------------------------------

local GODPOT_DATABASE = {
    -- Format per tier: { minUps, maxUps, minBase, maxBase, minPot, maxPot, dungeonCode, lowestHp, highestHp }
    ["alien"] = {{18050, 19950, 180500, 199500, 361000, 399000, "OO", 3705000, 4095000}, {19000, 21000, 190000, 210000, 380000, 420000, "OO", 4085000, 4515000}, {19950, 22050, 199500, 220500, 399000, 441000, "OO", 4465000, 4935000}, {20900, 23100, 209000, 231000, 418000, 462000, "OO", 4750000, 5250000}},
    ["alien guardian"] = {{18050, 19950, 5225000, 5775000, 5405500, 5974500, "OO", 0, 0}, {19000, 21000, 5795000, 6405000, 5985000, 6615000, "OO", 0, 0}, {19950, 22050, 6365000, 7035000, 6564500, 7255500, "OO", 0, 0}, {20900, 23100, 6887500, 7612500, 7096500, 7843500, "OO", 0, 0}},
    ["amethyst crescent spellblade"] = {{1472, 1628, 28500, 31500, 43220, 47780, "SP", 0, 0}, {1529, 1691, 30875, 34125, 46165, 51035, "SP", 0, 0}, {1586, 1754, 33250, 36750, 49110, 54290, "SP", 0, 0}, {1643, 1817, 35625, 39375, 52055, 57545, "SP", 0, 0}},
    ["amethyst spelldagger"] = {{1377, 1523, 25650, 28350, 39420, 43580, "SP", 0, 0}, {1434, 1586, 27550, 30450, 41890, 46310, "SP", 0, 0}, {1491, 1649, 29450, 32550, 44360, 49040, "SP", 0, 0}, {1548, 1712, 31350, 34650, 46830, 51770, "SP", 0, 0}},
    ["amethyst spellscythe"] = {{2232, 2468, 65550, 72450, 87870, 97130, "TC", 0, 0}, {2375, 2625, 70300, 77700, 94050, 103950, "TC", 0, 0}, {2517, 2783, 75050, 82950, 100220, 110780, "TC", 0, 0}, {2660, 2940, 79800, 88200, 106400, 117600, "TC", 0, 0}},
    ["ancestral"] = {{617, 683, 2850, 3150, 9020, 9980, "SP", 30400, 33600}, {655, 725, 3135, 3465, 9685, 10715, "SP", 33250, 36750}, {693, 767, 3420, 3780, 10350, 11450, "SP", 36100, 39900}, {731, 809, 3705, 4095, 11015, 12185, "SP", 38950, 43050}},
    ["ancestral guardian"] = {{617, 683, 51300, 56700, 57470, 63530, "SP", 0, 0}, {655, 725, 56050, 61950, 62600, 69200, "SP", 0, 0}, {693, 767, 61750, 68250, 68680, 75920, "SP", 0, 0}, {731, 809, 67450, 74550, 74760, 82640, "SP", 0, 0}},
    ["ancient elder staff"] = {{1092, 1208, 18050, 19950, 28970, 32030, "UW", 0, 0}, {1121, 1239, 18715, 20685, 29925, 33075, "UW", 0, 0}, {1149, 1271, 19380, 21420, 30870, 34130, "UW", 0, 0}, {1178, 1302, 20045, 22155, 31825, 35175, "UW", 0, 0}},
    ["ancient lava axe"] = {{101650, 112350, 4465000, 4935000, 5481500, 6058500, "VC", 0, 0}, {104025, 114975, 4655000, 5145000, 5695250, 6294750, "VC", 0, 0}, {106400, 117600, 4845000, 5355000, 5909000, 6531000, "VC", 0, 0}, {108300, 119700, 5035000, 5565000, 6118000, 6762000, "VC", 0, 0}},
    ["ancient plate"] = {{24, 28, 807, 893, 1047, 1173, "WO", 0, 0}, {26, 30, 902, 998, 1162, 1298, "WO", 0, 0}, {28, 32, 997, 1103, 1277, 1423, "WO", 0, 0}, {30, 34, 1092, 1208, 1392, 1548, "WO", 0, 0}},
    ["angelic staff"] = {{190, 210, 1624, 1796, 3524, 3896, "PI", 0, 0}, {201, 223, 1748, 1932, 3758, 4162, "PI", 0, 0}, {212, 236, 1871, 2069, 3991, 4429, "PI", 0, 0}, {224, 248, 1995, 2205, 4235, 4685, "PI", 0, 0}},
    ["angelic/infernal"] = {{70, 78, 80, 90, 780, 870, "PI", 1710, 1890}, {80, 90, 99, 111, 899, 1011, "PI", 1900, 2100}, {91, 101, 118, 132, 1028, 1142, "PI", 2090, 2310}, {101, 113, 137, 153, 1147, 1283, "PI", 2280, 2520}},
    ["apothecary staff"] = {{380, 420, 4180, 4620, 7980, 8820, "KC", 0, 0}, {418, 462, 4655, 5145, 8835, 9765, "KC", 0, 0}, {456, 504, 5130, 5670, 9690, 10710, "KC", 0, 0}, {494, 546, 5605, 6195, 10545, 11655, "KC", 0, 0}},
    ["apprentice staff"] = {{3, 5, 14, 16, 17, 21, "DT", 0, 0}, {4, 6, 15, 17, 19, 23, "DT", 0, 0}, {5, 7, 17, 19, 22, 26, "DT", 0, 0}, {6, 8, 19, 21, 25, 29, "DT", 0, 0}},
    ["aquatic"] = {{34200, 37800, 503500, 556500, 845500, 934500, "AT", 11400000, 12600000}, {35625, 39375, 579500, 640500, 935750, 1034250, "AT", 12350000, 13650000}, {37050, 40950, 655500, 724500, 1026000, 1134000, "AT", 13775000, 15225000}, {38475, 42525, 731500, 808500, 1116250, 1233750, "AT", 15200000, 16800000}},
    ["aquatic defender"] = {{129200, 142800, 7790000, 8610000, 9082000, 10038000, "AT", 0, 0}, {131100, 144900, 8122500, 8977500, 9433500, 10426500, "AT", 0, 0}, {133000, 147000, 8455000, 9345000, 9785000, 10815000, "AT", 0, 0}, {134900, 149100, 8816000, 9744000, 10165000, 11235000, "AT", 0, 0}},
    ["aquatic executioner"] = {{123500, 136500, 6412500, 7087500, 7647500, 8452500, "AT", 0, 0}, {125400, 138600, 6887500, 7612500, 8141500, 8998500, "AT", 0, 0}, {127300, 140700, 7315000, 8085000, 8588000, 9492000, "AT", 0, 0}, {129200, 142800, 7790000, 8610000, 9082000, 10038000, "AT", 0, 0}},
    ["aquatic guardian"] = {{34200, 37800, 17100000, 18900000, 17442000, 19278000, "AT", 0, 0}, {35625, 39375, 19000000, 21000000, 19356250, 21393750, "AT", 0, 0}, {37050, 40950, 20900000, 23100000, 21270500, 23509500, "AT", 0, 0}, {38475, 42525, 22800000, 25200000, 23184750, 25625250, "AT", 0, 0}},
    ["aquatic scimitars"] = {{129200, 142800, 7790000, 8610000, 9082000, 10038000, "AT", 0, 0}, {131100, 144900, 8122500, 8977500, 9433500, 10426500, "AT", 0, 0}, {133000, 147000, 8455000, 9345000, 9785000, 10815000, "AT", 0, 0}, {134900, 149100, 8816000, 9744000, 10165000, 11235000, "AT", 0, 0}},
    ["aquatic spear"] = {{140600, 155400, 9975000, 11025000, 11381000, 12579000, "AT", 0, 0}, {142500, 157500, 10450000, 11550000, 11875000, 13125000, "AT", 0, 0}, {144400, 159600, 10925000, 12075000, 12369000, 13671000, "AT", 0, 0}, {146300, 161700, 11400000, 12600000, 12863000, 14217000, "AT", 0, 0}},
    ["arcane greatstaff"] = {{57, 63, 304, 336, 874, 966, "WO", 0, 0}, {60, 68, 332, 368, 932, 1048, "WO", 0, 0}, {64, 72, 361, 399, 1001, 1119, "WO", 0, 0}, {68, 76, 389, 431, 1069, 1191, "WO", 0, 0}},
    ["arcane orb staff"] = {{140, 156, 1073, 1187, 2473, 2747, "PI", 0, 0}, {147, 163, 1149, 1271, 2619, 2901, "PI", 0, 0}, {153, 171, 1235, 1365, 2765, 3075, "PI", 0, 0}, {160, 178, 1320, 1460, 2920, 3240, "PI", 0, 0}},
    ["arclight battlestaff"] = {{555, 615, 7030, 7770, 12580, 13920, "KC", 0, 0}, {584, 646, 7695, 8505, 13535, 14965, "KC", 0, 0}, {612, 678, 8360, 9240, 14480, 16020, "KC", 0, 0}, {636, 704, 9025, 9975, 15385, 17015, "KC", 0, 0}},
    ["azerite greatstaff"] = {{107, 119, 802, 888, 1872, 2078, "WO", 0, 0}, {112, 124, 845, 935, 1965, 2175, "WO", 0, 0}, {116, 130, 888, 982, 2048, 2282, "WO", 0, 0}, {121, 135, 940, 1040, 2150, 2390, "WO", 0, 0}},
    ["barbaric"] = {{109, 121, 190, 210, 1280, 1420, "KC", 2660, 2940}, {128, 142, 228, 252, 1508, 1672, "KC", 3135, 3465}, {147, 163, 266, 294, 1736, 1924, "KC", 3515, 3885}, {166, 184, 304, 336, 1964, 2176, "KC", 3895, 4305}},
    ["barbaric guardian"] = {{109, 121, 5890, 6510, 6980, 7720, "KC", 0, 0}, {128, 142, 6555, 7245, 7835, 8665, "KC", 0, 0}, {147, 163, 7220, 7980, 8690, 9610, "KC", 0, 0}, {166, 184, 7885, 8715, 9545, 10555, "KC", 0, 0}},
    ["beast cleaver"] = {{299, 331, 3040, 3360, 6030, 6670, "KC", 0, 0}, {313, 347, 3372, 3728, 6502, 7198, "KC", 0, 0}, {332, 368, 3610, 3990, 6930, 7670, "KC", 0, 0}, {351, 389, 3942, 4358, 7452, 8248, "KC", 0, 0}},
    ["beast master spell scythe"] = {{807, 893, 13300, 14700, 21370, 23630, "KC", 0, 0}},
    ["beast master war scythe"] = {{807, 893, 13300, 14700, 21370, 23630, "KC", 0, 0}},
    ["beastly / arch-mage"] = {{171, 189, 332, 368, 2042, 2258, "KC", 4085, 4515}, {190, 210, 370, 410, 2270, 2510, "KC", 4322, 4778}, {209, 231, 418, 462, 2508, 2772, "KC", 4560, 5040}, {228, 252, 465, 515, 2745, 3035, "KC", 4940, 5460}},
    ["beastly guardian"] = {{171, 189, 7980, 8820, 9690, 10710, "KC", 0, 0}, {190, 210, 8930, 9870, 10830, 11970, "KC", 0, 0}, {209, 231, 9880, 10920, 11970, 13230, "KC", 0, 0}, {228, 252, 10830, 11970, 13110, 14490, "KC", 0, 0}},
    ["bioforged greataxe"] = {{15960, 17640, 332500, 367500, 492100, 543900, "SS", 0, 0}, {16910, 18690, 351500, 388500, 520600, 575400, "SS", 0, 0}, {17860, 19740, 370500, 409500, 549100, 606900, "SS", 0, 0}, {18810, 20790, 389500, 430500, 577600, 638400, "SS", 0, 0}},
    ["bioforged greatsword"] = {{10925, 12075, 247000, 273000, 356250, 393750, "SS", 0, 0}, {11875, 13125, 266000, 294000, 384750, 425250, "SS", 0, 0}, {12825, 14175, 285000, 315000, 413250, 456750, "SS", 0, 0}, {13775, 15225, 304000, 336000, 441750, 488250, "SS", 0, 0}},
    ["bioforged reinforced slicer"] = {{13680, 15120, 304000, 336000, 440800, 487200, "SS", 0, 0}, {14535, 16065, 323000, 357000, 468350, 517650, "SS", 0, 0}, {15390, 17010, 342000, 378000, 495900, 548100, "SS", 0, 0}, {16245, 17955, 361000, 399000, 523450, 578550, "SS", 0, 0}},
    ["blacksteel greatsword"] = {{741, 819, 10260, 11340, 17670, 19530, "UW", 0, 0}, {779, 861, 11210, 12390, 19000, 21000, "UW", 0, 0}, {817, 903, 12160, 13440, 20330, 22470, "UW", 0, 0}, {855, 945, 13110, 14490, 21660, 23940, "UW", 0, 0}},
    ["blazing star"] = {{46550, 51450, 1197000, 1323000, 1662500, 1837500, "OO", 0, 0}, {47500, 52500, 1216000, 1344000, 1691000, 1869000, "OO", 0, 0}, {48450, 53550, 1282500, 1417500, 1767000, 1953000, "OO", 0, 0}, {49400, 54600, 1349000, 1491000, 1843000, 2037000, "OO", 0, 0}},
    ["bloodthrister"] = {{3040, 3360, 90250, 99750, 120650, 133350, "TC", 0, 0}, {3211, 3549, 95950, 106050, 128060, 141540, "TC", 0, 0}, {3382, 3738, 101650, 112350, 135470, 149730, "TC", 0, 0}, {3553, 3927, 107350, 118650, 142880, 157920, "TC", 0, 0}},
    ["bluefire staff"] = {{33, 37, 175, 195, 501, 564, "WO", 0, 0}, {36, 40, 190, 210, 548, 610, "WO", 0, 0}, {39, 45, 204, 226, 594, 676, "WO", 0, 0}, {42, 48, 218, 242, 638, 722, "WO", 0, 0}},
    ["bone scythe"] = {{1140, 1260, 18525, 20475, 29925, 33075, "SP", 0, 0}, {1178, 1302, 19475, 21525, 31255, 34545, "SP", 0, 0}, {1216, 1344, 20425, 22575, 32585, 36015, "SP", 0, 0}, {1254, 1386, 21375, 23625, 33915, 37485, "SP", 0, 0}},
    ["bronze dagger"] = {{1, 3, 5, 7, 6, 10, "DT", 0, 0}, {2, 4, 6, 8, 8, 12, "DT", 0, 0}, {3, 5, 7, 9, 10, 14, "DT", 0, 0}, {4, 6, 8, 10, 12, 16, "DT", 0, 0}},
    ["bronze longsword"] = {{2, 4, 9, 11, 11, 15, "DT", 0, 0}, {3, 5, 10, 12, 13, 17, "DT", 0, 0}, {4, 6, 11, 13, 15, 19, "DT", 0, 0}, {5, 7, 12, 14, 17, 21, "DT", 0, 0}},
    ["burned"] = {{20900, 23100, 209000, 231000, 418000, 462000, "VC", 4750000, 5250000}, {21850, 24150, 247000, 273000, 465500, 514500, "VC", 5225000, 5775000}, {22800, 25200, 285000, 315000, 513000, 567000, "VC", 5700000, 6300000}, {23750, 26250, 323000, 357000, 560500, 619500, "VC", 6270000, 6930000}},
    ["burned guardian"] = {{20900, 23100, 6887500, 7612500, 7096500, 7843500, "VC", 0, 0}, {21850, 24150, 7695000, 8505000, 7913500, 8746500, "VC", 0, 0}, {22800, 25200, 8645000, 9555000, 8873000, 9807000, "VC", 0, 0}, {23750, 26250, 9500000, 10500000, 9737500, 10762500, "VC", 0, 0}},
    ["captain's anchor"] = {{4465, 4935, 126350, 139650, 171000, 189000, "GH", 0, 0}, {4940, 5460, 134900, 149100, 184300, 203700, "GH", 0, 0}, {5320, 5880, 143450, 158550, 196650, 217350, "GH", 0, 0}, {5890, 6510, 152000, 168000, 210900, 233100, "GH", 0, 0}},
    ["celestial fire staff"] = {{513, 567, 6270, 6930, 11400, 12600, "KC", 0, 0}, {541, 599, 6745, 7455, 12155, 13445, "KC", 0, 0}, {570, 630, 7220, 7980, 12920, 14280, "KC", 0, 0}, {598, 662, 7695, 8505, 13675, 15125, "KC", 0, 0}},
    ["coldstone sword"] = {{16, 18, 114, 128, 235, 283, "WO", 0, 0}, {18, 20, 125, 139, 277, 320, "WO", 0, 0}, {19, 23, 134, 150, 303, 367, "WO", 0, 0}, {21, 25, 142, 158, 335, 398, "WO", 0, 0}},
    ["commanders"] = {{13965, 15435, 133000, 147000, 272650, 301350, "OO", 2660000, 2940000}, {15105, 16695, 145350, 160650, 296400, 327600, "OO", 3040000, 3360000}, {16245, 17955, 158650, 175350, 321100, 354900, "OO", 3420000, 3780000}, {17480, 19320, 171000, 189000, 345800, 382200, "OO", 3705000, 4095000}},
    ["commanders guardian"] = {{13965, 15435, 3990000, 4410000, 4129650, 4564350, "OO", 0, 0}, {15105, 16695, 4465000, 4935000, 4616050, 5101950, "OO", 0, 0}, {16245, 17955, 4845000, 5355000, 5007450, 5534550, "OO", 0, 0}, {17480, 19320, 5225000, 5775000, 5399800, 5968200, "OO", 0, 0}},
    ["cracked tooth cleaver"] = {{3277, 3623, 95000, 105000, 127770, 141230, "GH", 0, 0}, {3420, 3780, 100700, 111300, 134900, 149100, "GH", 0, 0}, {3657, 4043, 106400, 117600, 142970, 158030, "GH", 0, 0}, {3800, 4200, 112100, 123900, 150100, 165900, "GH", 0, 0}},
    ["crimson kris"] = {{1567, 1733, 32300, 35700, 47970, 53030, "SP", 0, 0}, {1624, 1796, 34675, 38325, 50915, 56285, "SP", 0, 0}, {1681, 1859, 37050, 40950, 53860, 59540, "SP", 0, 0}, {1738, 1922, 39425, 43575, 56805, 62795, "SP", 0, 0}},
    ["crimson spell blade"] = {{37, 41, 194, 216, 563, 626, "WO", 0, 0}, {40, 46, 209, 231, 609, 691, "WO", 0, 0}, {44, 50, 223, 247, 663, 747, "WO", 0, 0}, {46, 52, 237, 263, 697, 783, "WO", 0, 0}},
    ["crusader's"] = {{3, 5, 118, 132, 135, 165, "DT", 0, 0}, {4, 6, 131, 145, 157, 191, "DT", 0, 0}, {5, 7, 144, 160, 181, 222, "DT", 0, 0}, {6, 8, 161, 179, 213, 255, "DT", 0, 0}},
    ["crystalised greatsword"] = {{128, 142, 1092, 1208, 2372, 2628, "WO", 0, 0}},
    ["crystalline"] = {{58425, 64575, 1667250, 1842750, 2251500, 2488500, "EF", 36100000, 39900000}, {63175, 69825, 1826850, 2019150, 2458600, 2717400, "EF", 41163500, 45496500}, {67925, 75075, 1986450, 2195550, 2665700, 2946300, "EF", 46227000, 51093000}, {72675, 80325, 2147000, 2373000, 2873750, 3176250, "EF", 51300000, 56700000}},
    ["crystalline guadian"] = {{58425, 64575, 54150000, 59850000, 54734250, 60495750, "EF", 0, 0}, {63175, 69825, 63175000, 69825000, 63806750, 70523250, "EF", 0, 0}, {67925, 75075, 72200000, 79800000, 72879250, 80550750, "EF", 0, 0}, {72675, 80325, 81225000, 89775000, 81951750, 90578250, "EF", 0, 0}},
    ["crystalline shard staff"] = {{247000, 273000, 24320000, 26880000, 26790000, 29610000, "EF", 0, 0}, {253650, 280350, 25203500, 27856500, 27740000, 30660000, "EF", 0, 0}, {260300, 287700, 26087000, 28833000, 28690000, 31710000, "EF", 0, 0}, {266000, 294000, 26980000, 29820000, 29640000, 32760000, "EF", 0, 0}},
    ["cultist blade"] = {{146, 162, 1159, 1281, 2619, 2901, "PI", 0, 0}, {152, 170, 1225, 1355, 2745, 3055, "PI", 0, 0}, {158, 176, 1292, 1428, 2872, 3188, "PI", 0, 0}, {163, 181, 1358, 1502, 2988, 3312, "PI", 0, 0}},
    ["dark ice blades"] = {{2470, 2730, 73150, 80850, 97850, 108150, "TC", 0, 0}, {2631, 2909, 77900, 86100, 104210, 115190, "TC", 0, 0}, {2793, 3087, 82650, 91350, 110580, 122220, "TC", 0, 0}, {2954, 3266, 87400, 96600, 116940, 129260, "TC", 0, 0}},
    ["dark priest staff"] = {{207, 229, 1843, 2037, 3913, 4327, "PI", 0, 0}, {218, 242, 2004, 2216, 4184, 4636, "PI", 0, 0}, {229, 255, 2166, 2394, 4456, 4944, "PI", 0, 0}, {241, 267, 2337, 2583, 4747, 5253, "PI", 0, 0}},
    ["darkstone greatsword"] = {{76000, 84000, 2992500, 3307500, 3752500, 4147500, "VC", 0, 0}, {79325, 87675, 3135000, 3465000, 3928250, 4341750, "VC", 0, 0}, {82650, 91350, 3277500, 3622500, 4104000, 4536000, "VC", 0, 0}, {85500, 94500, 3420000, 3780000, 4275000, 4725000, "VC", 0, 0}},
    ["daybreak and gildensong"] = {{807500, 892500, 132525000, 146475000, 140600000, 155400000, "GS", 0, 0}},
    ["demon lord's greatstaff"] = {{1130, 1250, 18810, 20790, 30110, 33290, "UW", 0, 0}, {1159, 1281, 19475, 21525, 31065, 34335, "UW", 0, 0}, {1187, 1313, 20140, 22260, 32010, 35390, "UW", 0, 0}, {1216, 1344, 20805, 22995, 32965, 36435, "UW", 0, 0}},
    ["demonic greatsword"] = {{102, 114, 769, 851, 1789, 1991, "WO", 0, 0}, {106, 118, 807, 893, 1867, 2073, "WO", 0, 0}, {110, 122, 845, 935, 1945, 2155, "WO", 0, 0}, {114, 126, 883, 977, 2023, 2237, "WO", 0, 0}},
    ["demonic spellblade"] = {{85, 95, 598, 662, 1448, 1612, "WO", 0, 0}, {90, 100, 641, 709, 1541, 1709, "WO", 0, 0}, {95, 105, 684, 756, 1634, 1806, "WO", 0, 0}, {99, 111, 726, 804, 1716, 1914, "WO", 0, 0}},
    ["desert fury"] = {{22, 26, 114, 126, 295, 358, "DT", 0, 0}},
    ["devilish greataxe"] = {{197, 219, 1824, 2016, 3794, 4206, "PI", 0, 0}, {207, 229, 1938, 2142, 4008, 4432, "PI", 0, 0}, {216, 240, 2071, 2289, 4231, 4689, "PI", 0, 0}, {226, 250, 2204, 2436, 4464, 4936, "PI", 0, 0}},
    ["diamond encrusted blade"] = {{36, 40, 185, 205, 543, 605, "WO", 0, 0}, {38, 44, 196, 218, 575, 658, "WO", 0, 0}, {40, 46, 208, 230, 608, 690, "WO", 0, 0}, {42, 48, 218, 242, 638, 722, "WO", 0, 0}},
    ["dracani"] = {{133000, 147000, 5510000, 6090000, 6840000, 7560000, "GS", 152950000, 169050000}, {152000, 168000, 6080000, 6720000, 7600000, 8400000, "GS", 170050000, 187950000}, {171000, 189000, 6650000, 7350000, 8360000, 9240000, "GS", 187150000, 206850000}, {190000, 210000, 7220000, 7980000, 9120000, 10080000, "GS", 204250000, 225750000}},
    ["dracani flanged mace"] = {{411350, 454650, 66500000, 73500000, 70613500, 78046500, "GS", 0, 0}, {421800, 466200, 70300000, 77700000, 74518000, 82362000, "GS", 0, 0}, {432250, 477750, 73150000, 80850000, 77472500, 85627500, "GS", 0, 0}, {442700, 489300, 76000000, 84000000, 80427000, 88893000, "GS", 0, 0}},
    ["dracani gilded lance"] = {{442700, 489300, 76000000, 84000000, 80427000, 88893000, "GS", 0, 0}, {453150, 500850, 79800000, 88200000, 84331500, 93208500, "GS", 0, 0}, {463600, 512400, 82650000, 91350000, 87286000, 96474000, "GS", 0, 0}, {475000, 525000, 85500000, 94500000, 90250000, 99750000, "GS", 0, 0}},
    ["dracani gilded staff"] = {{475000, 525000, 85500000, 94500000, 90250000, 99750000, "GS", 0, 0}, {513000, 567000, 89194550, 98583450, 94324550, 104253450, "GS", 0, 0}, {541500, 598500, 92889100, 102666900, 98304100, 108651900, "GS", 0, 0}, {570000, 630000, 96583650, 106750350, 102283650, 113050350, "GS", 0, 0}},
    ["dracani gilded sword"] = {{380000, 420000, 57000000, 63000000, 60800000, 67200000, "GS", 0, 0}, {390450, 431550, 60800000, 67200000, 64704500, 71515500, "GS", 0, 0}, {400900, 443100, 63650000, 70350000, 67659000, 74781000, "GS", 0, 0}, {411350, 454650, 66500000, 73500000, 70613500, 78046500, "GS", 0, 0}},
    ["dracani guardian"] = {{133000, 147000, 244720000, 270480000, 246050000, 271950000, "GS", 0, 0}, {152000, 168000, 271446350, 300019650, 272966350, 301699650, "GS", 0, 0}, {171000, 189000, 298172700, 329559300, 299882700, 331449300, "GS", 0, 0}, {190000, 210000, 324900000, 359100000, 326800000, 361200000, "GS", 0, 0}},
    ["dracani royal glaive"] = {{442700, 489300, 76000000, 84000000, 80427000, 88893000, "GS", 0, 0}, {453150, 500850, 79800000, 88200000, 84331500, 93208500, "GS", 0, 0}, {463600, 512400, 82650000, 91350000, 87286000, 96474000, "GS", 0, 0}, {475000, 525000, 85500000, 94500000, 90250000, 99750000, "GS", 0, 0}},
    ["dracani spellclaws"] = {{380000, 420000, 57000000, 63000000, 60800000, 67200000, "GS", 0, 0}, {390450, 431550, 60800000, 67200000, 64704500, 71515500, "GS", 0, 0}, {400900, 443100, 63650000, 70350000, 67659000, 74781000, "GS", 0, 0}, {411350, 454650, 66500000, 73500000, 70613500, 78046500, "GS", 0, 0}},
    ["dragon slayer"] = {{39, 45, 204, 226, 594, 676, "WO", 0, 0}, {42, 48, 215, 239, 635, 719, "WO", 0, 0}, {44, 50, 227, 251, 667, 751, "WO", 0, 0}, {46, 52, 237, 263, 697, 783, "WO", 0, 0}},
    ["dragon's claw scythe"] = {{893, 987, 14060, 15540, 22990, 25410, "UW", 0, 0}, {931, 1029, 15010, 16590, 24320, 26880, "UW", 0, 0}, {969, 1071, 15960, 17640, 25650, 28350, "UW", 0, 0}, {1007, 1113, 16910, 18690, 26980, 29820, "UW", 0, 0}},
    ["dual ancient daggers"] = {{969, 1071, 15960, 17640, 25650, 28350, "UW", 0, 0}, {997, 1103, 16435, 18165, 26405, 29195, "UW", 0, 0}, {1026, 1134, 16910, 18690, 27170, 30030, "UW", 0, 0}, {1054, 1166, 17385, 19215, 27925, 30875, "UW", 0, 0}},
    ["dual arcane daggers"] = {{1007, 1113, 16625, 18375, 26695, 29505, "UW", 0, 0}, {1035, 1145, 17100, 18900, 27450, 30350, "UW", 0, 0}, {1064, 1176, 17575, 19425, 28215, 31185, "UW", 0, 0}, {1092, 1208, 18050, 19950, 28970, 32030, "UW", 0, 0}},
    ["dual arcane slicers"] = {{2470, 2730, 73150, 80850, 97850, 108150, "TC", 0, 0}, {2631, 2909, 77900, 86100, 104210, 115190, "TC", 0, 0}, {2793, 3087, 82650, 91350, 110580, 122220, "TC", 0, 0}, {2954, 3266, 87400, 96600, 116940, 129260, "TC", 0, 0}},
    ["dual bioforged spelldaggers"] = {{9880, 10920, 218500, 241500, 317300, 350700, "SS", 0, 0}, {10450, 11550, 237500, 262500, 342000, 378000, "SS", 0, 0}, {11020, 12180, 256500, 283500, 366700, 405300, "SS", 0, 0}, {11590, 12810, 275500, 304500, 391400, 432600, "SS", 0, 0}},
    ["dual bladed mage daggers"] = {{3895, 4305, 114000, 126000, 152950, 169050, "GH", 0, 0}, {4227, 4673, 121600, 134400, 163870, 181130, "GH", 0, 0}, {4560, 5040, 129200, 142800, 174800, 193200, "GH", 0, 0}, {4892, 5408, 136800, 151200, 185720, 205280, "GH", 0, 0}},
    ["dual crimson daggers"] = {{1881, 2079, 47500, 52500, 66310, 73290, "TC", 0, 0}, {1947, 2153, 51300, 56700, 70770, 78230, "TC", 0, 0}, {2014, 2226, 55100, 60900, 75240, 83160, "TC", 0, 0}, {2080, 2300, 58900, 65100, 79700, 88100, "TC", 0, 0}},
    ["dual crystalized knives"] = {{56050, 61950, 1586500, 1753500, 2147000, 2373000, "OO", 0, 0}, {57000, 63000, 1653000, 1827000, 2223000, 2457000, "OO", 0, 0}, {57950, 64050, 1710000, 1890000, 2289500, 2530500, "OO", 0, 0}, {58900, 65100, 1805000, 1995000, 2394000, 2646000, "OO", 0, 0}},
    ["dual cutlasses"] = {{256, 284, 2584, 2856, 5144, 5696, "KC", 0, 0}, {285, 315, 2850, 3150, 5700, 6300, "KC", 0, 0}, {304, 336, 3116, 3444, 6156, 6804, "KC", 0, 0}, {323, 357, 3382, 3738, 6612, 7308, "KC", 0, 0}},
    ["dual elegant fans"] = {{1738, 1922, 40375, 44625, 57755, 63845, "SP", 0, 0}, {1795, 1985, 43225, 47775, 61175, 67625, "SP", 0, 0}, {1852, 2048, 46075, 50925, 64595, 71405, "SP", 0, 0}, {1909, 2111, 48925, 54075, 68015, 75185, "SP", 0, 0}},
    ["dual fist blades"] = {{66500, 73500, 2565000, 2835000, 3230000, 3570000, "VC", 0, 0}, {69825, 77175, 2707500, 2992500, 3405750, 3764250, "VC", 0, 0}, {73150, 80850, 2850000, 3150000, 3581500, 3958500, "VC", 0, 0}, {76000, 84000, 2992500, 3307500, 3752500, 4147500, "VC", 0, 0}},
    ["dual flatblade slicers"] = {{817, 903, 12160, 13440, 20330, 22470, "UW", 0, 0}, {855, 945, 13110, 14490, 21660, 23940, "UW", 0, 0}, {893, 987, 14060, 15540, 22990, 25410, "UW", 0, 0}, {931, 1029, 15010, 16590, 24320, 26880, "UW", 0, 0}},
    ["dual frozen blades"] = {{513, 567, 6270, 6930, 11400, 12600, "KC", 0, 0}, {541, 599, 6745, 7455, 12155, 13445, "KC", 0, 0}, {570, 630, 7220, 7980, 12920, 14280, "KC", 0, 0}, {598, 662, 7695, 8505, 13675, 15125, "KC", 0, 0}},
    ["dual fusion blades"] = {{9025, 9975, 203300, 224700, 293550, 324450, "SS", 0, 0}, {9595, 10605, 212800, 235200, 308750, 341250, "SS", 0, 0}, {10165, 11235, 222300, 245700, 323950, 358050, "SS", 0, 0}, {10735, 11865, 231800, 256200, 339150, 374850, "SS", 0, 0}},
    ["dual hellfire blades"] = {{108300, 119700, 5035000, 5565000, 6118000, 6762000, "VC", 0, 0}, {110675, 122325, 5225000, 5775000, 6331750, 6998250, "VC", 0, 0}, {112100, 123900, 5415000, 5985000, 6536000, 7224000, "VC", 0, 0}, {114000, 126000, 5747500, 6352500, 6887500, 7612500, "VC", 0, 0}},
    ["dual hextech spelldaggers"] = {{9025, 9975, 203300, 224700, 293550, 324450, "SS", 0, 0}, {9595, 10605, 212800, 235200, 308750, 341250, "SS", 0, 0}, {10165, 11235, 222300, 245700, 323950, 358050, "SS", 0, 0}, {10735, 11865, 231800, 256200, 339150, 374850, "SS", 0, 0}},
    ["dual infernal daggers"] = {{1377, 1523, 25650, 28350, 39420, 43580, "SP", 0, 0}, {1434, 1586, 27550, 30450, 41890, 46310, "SP", 0, 0}, {1491, 1649, 29450, 32550, 44360, 49040, "SP", 0, 0}, {1548, 1712, 31350, 34650, 46830, 51770, "SP", 0, 0}},
    ["dual infernal scimitars"] = {{2755, 3045, 81700, 90300, 109250, 120750, "TC", 0, 0}, {1976, 2184, 87400, 96600, 107160, 118440, "TC", 0, 0}, {3097, 3423, 93100, 102900, 124070, 137130, "TC", 0, 0}, {3268, 3612, 98800, 109200, 131480, 145320, "TC", 0, 0}},
    ["dual infernal slicers"] = {{555, 615, 7030, 7770, 12580, 13920, "KC", 0, 0}, {584, 646, 7695, 8505, 13535, 14965, "KC", 0, 0}, {612, 678, 8360, 9240, 14480, 16020, "KC", 0, 0}, {636, 704, 9025, 9975, 15385, 17015, "KC", 0, 0}},
    ["dual jade daggers"] = {{608, 672, 8265, 9135, 14345, 15855, "KC", 0, 0}, {641, 709, 9025, 9975, 15435, 17065, "KC", 0, 0}, {674, 746, 9975, 11025, 16715, 18485, "KC", 0, 0}, {712, 788, 10925, 12075, 18045, 19955, "KC", 0, 0}},
    ["dual magma fangs"] = {{2232, 2468, 65550, 72450, 87870, 97130, "TC", 0, 0}, {2375, 2625, 70300, 77700, 94050, 103950, "TC", 0, 0}, {2517, 2783, 75050, 82950, 100220, 110780, "TC", 0, 0}, {2660, 2940, 79800, 88200, 106400, 117600, "TC", 0, 0}},
    ["dual magma shields"] = {{95000, 105000, 3895000, 4305000, 4845000, 5355000, "VC", 0, 0}, {97375, 107625, 4085000, 4515000, 5058750, 5591250, "VC", 0, 0}, {99750, 110250, 4275000, 4725000, 5272500, 5827500, "VC", 0, 0}, {101650, 112350, 4465000, 4935000, 5481500, 6058500, "VC", 0, 0}},
    ["dual ocean fists"] = {{4465, 4935, 126350, 139650, 171000, 189000, "GH", 0, 0}, {4940, 5460, 134900, 149100, 184300, 203700, "GH", 0, 0}, {5320, 5880, 143450, 158550, 196650, 217350, "GH", 0, 0}, {5890, 6510, 152000, 168000, 210900, 233100, "GH", 0, 0}},
    ["dual phantom axes"] = {{6840, 7560, 167200, 184800, 235600, 260400, "GH", 0, 0}, {7410, 8190, 175750, 194250, 249850, 276150, "GH", 0, 0}, {7980, 8820, 184300, 203700, 264100, 291900, "GH", 0, 0}, {8550, 9450, 192850, 213150, 278350, 307650, "GH", 0, 0}},
    ["dual phantom daggers"] = {{7695, 8505, 180500, 199500, 257450, 284550, "GH", 0, 0}, {8265, 9135, 189050, 208950, 271700, 300300, "GH", 0, 0}, {8835, 9765, 197600, 218400, 285950, 316050, "GH", 0, 0}, {9405, 10395, 206150, 227850, 300200, 331800, "GH", 0, 0}},
    ["dual phantom defenders"] = {{5890, 6510, 153900, 170100, 212800, 235200, "GH", 0, 0}, {6460, 7140, 162450, 179550, 227050, 250950, "GH", 0, 0}, {7030, 7770, 171000, 189000, 241300, 266700, "GH", 0, 0}, {7600, 8400, 179550, 198450, 255550, 282450, "GH", 0, 0}},
    ["dual phoenix daggers"] = {{1330, 1470, 22800, 25200, 36100, 39900, "UW", 0, 0}},
    ["dual pirate cutlasses"] = {{3895, 4305, 114000, 126000, 152950, 169050, "GH", 0, 0}, {4227, 4673, 121600, 134400, 163870, 181130, "GH", 0, 0}, {4560, 5040, 129200, 142800, 174800, 193200, "GH", 0, 0}, {4892, 5408, 136800, 151200, 185720, 205280, "GH", 0, 0}},
    ["dual razor slicers"] = {{1995, 2205, 53200, 58800, 73150, 80850, "TC", 0, 0}, {2071, 2289, 57000, 63000, 77710, 85890, "TC", 0, 0}, {2147, 2373, 60800, 67200, 82270, 90930, "TC", 0, 0}, {2223, 2457, 64600, 71400, 86830, 95970, "TC", 0, 0}},
    ["dual royal axes"] = {{323, 357, 3467, 3833, 6697, 7403, "KC", 0, 0}, {342, 378, 3895, 4305, 7315, 8085, "KC", 0, 0}, {361, 399, 4275, 4725, 7885, 8715, "KC", 0, 0}, {380, 420, 4655, 5145, 8455, 9345, "KC", 0, 0}},
    ["dual samurai sickles"] = {{1472, 1628, 28500, 31500, 43220, 47780, "SP", 0, 0}, {1529, 1691, 30875, 34125, 46165, 51035, "SP", 0, 0}, {1586, 1754, 33250, 36750, 49110, 54290, "SP", 0, 0}, {1643, 1817, 35625, 39375, 52055, 57545, "SP", 0, 0}},
    ["dual samurai stars"] = {{1358, 1502, 24700, 27300, 38280, 42320, "SP", 0, 0}, {1415, 1565, 26600, 29400, 40750, 45050, "SP", 0, 0}, {1472, 1628, 28500, 31500, 43220, 47780, "SP", 0, 0}, {1529, 1691, 30400, 33600, 45690, 50510, "SP", 0, 0}},
    ["dual sapphire slicers"] = {{665, 735, 9215, 10185, 15865, 17535, "UW", 0, 0}, {703, 777, 9690, 10710, 16720, 18480, "UW", 0, 0}, {741, 819, 10165, 11235, 17575, 19425, "UW", 0, 0}, {779, 861, 10640, 11760, 18430, 20370, "UW", 0, 0}},
    ["dual serrated knives"] = {{3610, 3990, 104500, 115500, 140600, 155400, "GH", 0, 0}, {3800, 4200, 110200, 121800, 148200, 163800, "GH", 0, 0}, {3990, 4410, 115900, 128100, 155800, 172200, "GH", 0, 0}, {4180, 4620, 121600, 134400, 163400, 180600, "GH", 0, 0}},
    ["dual solar blades"] = {{51300, 56700, 1330000, 1470000, 1843000, 2037000, "OO", 0, 0}, {52250, 57750, 1396500, 1543500, 1919000, 2121000, "OO", 0, 0}, {53200, 58800, 1463000, 1617000, 1995000, 2205000, "OO", 0, 0}, {54150, 59850, 1529500, 1690500, 2071000, 2289000, "OO", 0, 0}},
    ["dual toxic daggers"] = {{3610, 3990, 104500, 115500, 140600, 155400, "GH", 0, 0}, {3800, 4200, 110200, 121800, 148200, 163800, "GH", 0, 0}, {3990, 4410, 115900, 128100, 155800, 172200, "GH", 0, 0}, {4180, 4620, 121600, 134400, 163400, 180600, "GH", 0, 0}},
    ["eagle staff"] = {{256, 284, 2584, 2856, 5144, 5696, "KC", 0, 0}, {285, 315, 2850, 3150, 5700, 6300, "KC", 0, 0}, {304, 336, 3116, 3444, 6156, 6804, "KC", 0, 0}, {323, 357, 3382, 3738, 6612, 7308, "KC", 0, 0}},
    ["earth wand"] = {{163, 181, 1339, 1481, 2969, 3291, "PI", 0, 0}, {171, 189, 1425, 1575, 3135, 3465, "PI", 0, 0}, {178, 198, 1510, 1670, 3290, 3650, "PI", 0, 0}, {186, 206, 1596, 1764, 3456, 3824, "PI", 0, 0}},
    ["eden's reaper"] = {{0, 0, 0, 0, 0, 0, "EF", 0, 0}},
    ["eden's vengeance"] = {{0, 0, 0, 0, 0, 0, "EF", 0, 0}},
    ["eldenbark"] = {{72675, 80325, 2147000, 2373000, 2873750, 3176250, "EF", 51300000, 56700000}, {77425, 85575, 2275250, 2514750, 3049500, 3370500, "EF", 55727000, 61593000}, {82175, 90825, 2403500, 2656500, 3225250, 3564750, "EF", 60154000, 66486000}, {86925, 96075, 2531750, 2798250, 3401000, 3759000, "EF", 64600000, 71400000}},
    ["eldenbark greatstaff"] = {{285000, 315000, 30020000, 33180000, 32870000, 36330000, "EF", 0, 0}},
    ["eldenbark greatsword"] = {{285000, 315000, 30020000, 33180000, 32870000, 36330000, "EF", 0, 0}},
    ["eldenbark guardian"] = {{72675, 80325, 81225000, 89775000, 81951750, 90578250, "EF", 0, 0}, {77425, 85575, 88350000, 97650000, 89124250, 98505750, "EF", 0, 0}, {82175, 90825, 95475000, 105525000, 96296750, 106433250, "EF", 0, 0}, {86925, 96075, 102600000, 113400000, 103469250, 114360750, "EF", 0, 0}},
    ["elder void wand"] = {{99, 111, 726, 804, 1716, 1914, "WO", 0, 0}, {104, 116, 769, 851, 1809, 2011, "WO", 0, 0}, {109, 121, 812, 898, 1902, 2108, "WO", 0, 0}, {114, 126, 859, 951, 1999, 2211, "WO", 0, 0}},
    ["electron spelldagger"] = {{46550, 51450, 1197000, 1323000, 1662500, 1837500, "OO", 0, 0}, {47500, 52500, 1216000, 1344000, 1691000, 1869000, "OO", 0, 0}, {48450, 53550, 1282500, 1417500, 1767000, 1953000, "OO", 0, 0}, {49400, 54600, 1349000, 1491000, 1843000, 2037000, "OO", 0, 0}},
    ["elementalist staff"] = {{1995, 2205, 53200, 58800, 73150, 80850, "TC", 0, 0}, {2071, 2289, 57000, 63000, 77710, 85890, "TC", 0, 0}, {2147, 2373, 60800, 67200, 82270, 90930, "TC", 0, 0}, {2223, 2457, 64600, 71400, 86830, 95970, "TC", 0, 0}},
    ["elite (warlord/mage) plate"] = {{32, 36, 53, 59, 213, 283, "WO", 437, 483}, {35, 39, 57, 65, 263, 338, "WO", 475, 525}, {38, 42, 62, 70, 318, 383, "WO", 513, 567}, {40, 46, 67, 75, 353, 440, "WO", 551, 609}},
    ["elite ancient plate"] = {{32, 36, 1140, 1260, 1460, 1620, "WO", 0, 0}, {35, 39, 1282, 1418, 1632, 1808, "WO", 0, 0}, {38, 42, 1425, 1575, 1805, 1995, "WO", 0, 0}, {40, 46, 1567, 1733, 1967, 2193, "WO", 0, 0}},
    ["elven staff"] = {{323, 357, 3467, 3833, 6697, 7403, "KC", 0, 0}, {342, 378, 3895, 4305, 7315, 8085, "KC", 0, 0}, {361, 399, 4275, 4725, 7885, 8715, "KC", 0, 0}, {380, 420, 4655, 5145, 8455, 9345, "KC", 0, 0}},
    ["empowered crystal blade"] = {{156, 174, 1263, 1397, 2823, 3137, "PI", 0, 0}, {163, 181, 1330, 1470, 2960, 3280, "PI", 0, 0}, {170, 188, 1406, 1554, 3106, 3434, "PI", 0, 0}, {176, 196, 1482, 1638, 3242, 3598, "PI", 0, 0}},
    ["enchanted demon greataxe"] = {{1130, 1250, 18810, 20790, 30110, 33290, "UW", 0, 0}, {1159, 1281, 19475, 21525, 31065, 34335, "UW", 0, 0}, {1187, 1313, 20140, 22260, 32010, 35390, "UW", 0, 0}, {1216, 1344, 20805, 22995, 32965, 36435, "UW", 0, 0}},
    ["enchanted sea axes"] = {{123500, 136500, 6412500, 7087500, 7647500, 8452500, "AT", 0, 0}, {125400, 138600, 6887500, 7612500, 8141500, 8998500, "AT", 0, 0}, {127300, 140700, 7315000, 8085000, 8588000, 9492000, "AT", 0, 0}, {129200, 142800, 7790000, 8610000, 9082000, 10038000, "AT", 0, 0}},
    ["enchanted sea daggers"] = {{134900, 149100, 8816000, 9744000, 10165000, 11235000, "AT", 0, 0}, {136800, 151200, 9196000, 10164000, 10564000, 11676000, "AT", 0, 0}, {138700, 153300, 9576000, 10584000, 10963000, 12117000, "AT", 0, 0}, {140600, 155400, 9975000, 11025000, 11381000, 12579000, "AT", 0, 0}},
    ["enchanted serpent daggers"] = {{146300, 161700, 11400000, 12600000, 12863000, 14217000, "AT", 0, 0}, {148200, 163800, 11875000, 13125000, 13357000, 14763000, "AT", 0, 0}, {150100, 165900, 12350000, 13650000, 13851000, 15309000, "AT", 0, 0}, {152000, 168000, 12777500, 14122500, 14297500, 15802500, "AT", 0, 0}},
    ["enchanted shard dual blade"] = {{190000, 210000, 16919500, 18700500, 18819500, 20800500, "EF", 0, 0}, {196650, 217350, 17613000, 19467000, 19579500, 21640500, "EF", 0, 0}, {203300, 224700, 18306500, 20233500, 20339500, 22480500, "EF", 0, 0}, {209000, 231000, 19000000, 21000000, 21090000, 23310000, "EF", 0, 0}},
    ["enchanted shard spell dagger"] = {{190000, 210000, 16919500, 18700500, 18819500, 20800500, "EF", 0, 0}, {196650, 217350, 17613000, 19467000, 19579500, 21640500, "EF", 0, 0}, {203300, 224700, 18306500, 20233500, 20339500, 22480500, "EF", 0, 0}, {209000, 231000, 19000000, 21000000, 21090000, 23310000, "EF", 0, 0}},
    ["enchanted shard staff"] = {{209000, 231000, 19000000, 21000000, 21090000, 23310000, "EF", 0, 0}, {215650, 238350, 19883500, 21976500, 22040000, 24360000, "EF", 0, 0}, {222300, 245700, 20767000, 22953000, 22990000, 25410000, "EF", 0, 0}, {228000, 252000, 21660000, 23940000, 23940000, 26460000, "EF", 0, 0}},
    ["enchanted shard waraxe"] = {{209000, 231000, 19000000, 21000000, 21090000, 23310000, "EF", 0, 0}, {215650, 238350, 19883500, 21976500, 22040000, 24360000, "EF", 0, 0}, {222300, 245700, 20767000, 22953000, 22990000, 25410000, "EF", 0, 0}, {228000, 252000, 21660000, 23940000, 23940000, 26460000, "EF", 0, 0}},
    ["enchanted sword"] = {{7, 9, 43, 49, 57, 70, "DT", 0, 0}, {8, 10, 48, 54, 66, 81, "DT", 0, 0}, {9, 11, 55, 61, 79, 98, "DT", 0, 0}, {10, 12, 61, 69, 94, 116, "DT", 0, 0}},
    ["energized spelldagger"] = {{57950, 64050, 1852500, 2047500, 2432000, 2688000, "OO", 0, 0}, {59850, 66150, 1995000, 2205000, 2593500, 2866500, "OO", 0, 0}, {61750, 68250, 2137500, 2362500, 2755000, 3045000, "OO", 0, 0}, {63650, 70350, 2280000, 2520000, 2916500, 3223500, "OO", 0, 0}},
    ["etheral greataxe"] = {{484, 536, 5510, 6090, 10350, 11450, "KC", 0, 0}, {508, 562, 5985, 6615, 11065, 12235, "KC", 0, 0}, {527, 583, 6460, 7140, 11730, 12970, "KC", 0, 0}, {546, 604, 6935, 7665, 12395, 13705, "KC", 0, 0}},
    ["fire ice staff"] = {{608, 672, 8265, 9135, 14345, 15855, "KC", 0, 0}, {641, 709, 9025, 9975, 15435, 17065, "KC", 0, 0}, {674, 746, 9975, 11025, 16715, 18485, "KC", 0, 0}, {712, 788, 10925, 12075, 18045, 19955, "KC", 0, 0}},
    ["flame staff"] = {{5, 7, 32, 36, 37, 46, "DT", 0, 0}, {6, 8, 36, 40, 44, 56, "DT", 0, 0}, {7, 9, 41, 47, 55, 67, "DT", 0, 0}, {8, 10, 48, 54, 66, 81, "DT", 0, 0}},
    ["forest vine axe"] = {{236550, 261450, 21660000, 23940000, 24025500, 26554500, "EF", 0, 0}, {234650, 259350, 22543500, 24916500, 24890000, 27510000, "EF", 0, 0}, {241300, 266700, 23427000, 25893000, 25840000, 28560000, "EF", 0, 0}, {247000, 273000, 24320000, 26880000, 26790000, 29610000, "EF", 0, 0}},
    ["forest vine spellblade"] = {{236550, 261450, 21660000, 23940000, 24025500, 26554500, "EF", 0, 0}, {234650, 259350, 22543500, 24916500, 24890000, 27510000, "EF", 0, 0}, {241300, 266700, 23427000, 25893000, 25840000, 28560000, "EF", 0, 0}, {247000, 273000, 24320000, 26880000, 26790000, 29610000, "EF", 0, 0}},
    ["forgotten"] = {{17, 19, 28, 32, 50, 63, "WO", 247, 273}, {19, 21, 32, 36, 63, 81, "WO", 266, 294}, {20, 24, 36, 40, 78, 111, "WO", 285, 315}, {22, 26, 39, 45, 97, 134, "WO", 304, 336}},
    ["forgotten guardian"] = {{17, 19, 570, 630, 740, 820, "WO", 0, 0}, {19, 21, 627, 693, 817, 903, "WO", 0, 0}, {20, 24, 684, 756, 884, 996, "WO", 0, 0}, {22, 26, 741, 819, 961, 1079, "WO", 0, 0}},
    ["frost giant greataxe"] = {{361000, 399000, 51680000, 57120000, 55290000, 61110000, "NL", 0, 0}, {367650, 406350, 53485000, 59115000, 57161500, 63178500, "NL", 0, 0}, {374300, 413700, 55290000, 61110000, 59033000, 65247000, "NL", 0, 0}, {380000, 420000, 57000000, 63000000, 60800000, 67200000, "NL", 0, 0}},
    ["frozen greatsword"] = {{32, 36, 172, 192, 487, 551, "WO", 0, 0}, {35, 39, 180, 200, 527, 590, "WO", 0, 0}, {37, 41, 190, 210, 558, 620, "WO", 0, 0}, {38, 44, 199, 221, 578, 661, "WO", 0, 0}},
    ["frozen lord's greatsword"] = {{108, 120, 826, 914, 1906, 2114, "WO", 0, 0}, {112, 124, 864, 956, 1984, 2196, "WO", 0, 0}, {115, 129, 902, 998, 2052, 2288, "WO", 0, 0}, {119, 133, 940, 1040, 2130, 2370, "WO", 0, 0}},
    ["fungal"] = {{47025, 51975, 1216000, 1344000, 1686250, 1863750, "EF", 27170000, 30030000}, {50825, 56175, 1366100, 1509900, 1874350, 2071650, "EF", 30210000, 33390000}, {54625, 60375, 1516200, 1675800, 2062450, 2279550, "EF", 33250000, 36750000}, {58425, 64575, 1667250, 1842750, 2251500, 2488500, "EF", 36100000, 39900000}},
    ["fungal guardian"] = {{47025, 51975, 40755000, 45045000, 41225250, 45564750, "EF", 0, 0}, {50825, 56175, 45220000, 49980000, 45728250, 50541750, "EF", 0, 0}, {54625, 60375, 49685000, 54915000, 50231250, 55518750, "EF", 0, 0}, {58425, 64575, 54150000, 59850000, 54734250, 60495750, "EF", 0, 0}},
    ["fungal lance"] = {{171000, 189000, 14848500, 16411500, 16558500, 18301500, "EF", 0, 0}, {177650, 196350, 15542000, 17178000, 17318500, 19141500, "EF", 0, 0}, {184300, 203700, 16235500, 17944500, 18078500, 19981500, "EF", 0, 0}, {190000, 210000, 16919500, 18700500, 18819500, 20800500, "EF", 0, 0}},
    ["fungal pike"] = {{152000, 168000, 12777500, 14122500, 14297500, 15802500, "EF", 0, 0}, {158650, 175350, 13471000, 14889000, 15057500, 16642500, "EF", 0, 0}, {165300, 182700, 14164500, 15655500, 15817500, 17482500, "EF", 0, 0}, {171000, 189000, 14848500, 16411500, 16558500, 18301500, "EF", 0, 0}},
    ["fungal staff"] = {{171000, 189000, 14848500, 16411500, 16558500, 18301500, "EF", 0, 0}, {177650, 196350, 15542000, 17178000, 17318500, 19141500, "EF", 0, 0}, {184300, 203700, 16235500, 17944500, 18078500, 19981500, "EF", 0, 0}, {190000, 210000, 16919500, 18700500, 18819500, 20800500, "EF", 0, 0}},
    ["fungal warhammer"] = {{152000, 168000, 12777500, 14122500, 14297500, 15802500, "EF", 0, 0}, {158650, 175350, 13471000, 14889000, 15057500, 16642500, "EF", 0, 0}, {165300, 182700, 14164500, 15655500, 15817500, 17482500, "EF", 0, 0}, {171000, 189000, 14848500, 16411500, 16558500, 18301500, "EF", 0, 0}},
    ["fusion greatsword"] = {{9880, 10920, 218500, 241500, 317300, 350700, "SS", 0, 0}, {10450, 11550, 237500, 262500, 342000, 378000, "SS", 0, 0}, {11020, 12180, 256500, 283500, 366700, 405300, "SS", 0, 0}, {11590, 12810, 275500, 304500, 391400, 432600, "SS", 0, 0}},
    ["galactic dual blades"] = {{75525, 83475, 2992500, 3307500, 3747750, 4142250, "OO", 0, 0}},
    ["galactic pike"] = {{75525, 83475, 2992500, 3307500, 3747750, 4142250, "OO", 0, 0}},
    ["ghostly greataxe"] = {{8, 10, 72, 80, 101, 126, "DT", 0, 0}, {9, 11, 79, 89, 117, 145, "DT", 0, 0}, {10, 12, 86, 96, 134, 165, "DT", 0, 0}, {12, 14, 94, 104, 161, 196, "DT", 0, 0}},
    ["ghoul slayer"] = {{13, 15, 81, 91, 145, 178, "DT", 0, 0}, {15, 17, 88, 98, 173, 213, "DT", 0, 0}, {17, 19, 95, 105, 204, 248, "DT", 0, 0}, {19, 23, 103, 115, 244, 308, "DT", 0, 0}},
    ["giant royal axe"] = {{2128, 2352, 59850, 66150, 81130, 89670, "TC", 0, 0}, {2213, 2447, 63650, 70350, 85780, 94820, "TC", 0, 0}, {2299, 2541, 67450, 74550, 90440, 99960, "TC", 0, 0}, {2384, 2636, 71250, 78750, 95090, 105110, "TC", 0, 0}},
    ["gildenscale"] = {{285000, 315000, 8835000, 9765000, 11685000, 12915000, "GS", 290700000, 321300000}, {301150, 332850, 9467700, 10464300, 12479200, 13792800, "GS", 315713500, 348946500}, {317300, 350700, 10100400, 11163600, 13273400, 14670600, "GS", 340727000, 376593000}, {332500, 367500, 10735000, 11865000, 14060000, 15540000, "GS", 365750000, 404250000}},
    ["gildenscale guardian"] = {{285000, 315000, 462080000, 510720000, 464930000, 513870000, "GS", 0, 0}, {301150, 332850, 501790000, 554610000, 504801500, 557938500, "GS", 0, 0}, {317300, 350700, 541500000, 598500000, 544673000, 602007000, "GS", 0, 0}, {332500, 367500, 581210000, 642390000, 584535000, 646065000, "GS", 0, 0}},
    ["gildenscale oath and aegis"] = {{807500, 892500, 132525000, 146475000, 140600000, 155400000, "GS", 0, 0}},
    ["glacial greatsword"] = {{68, 76, 413, 457, 1093, 1217, "WO", 0, 0}, {71, 79, 441, 489, 1151, 1279, "WO", 0, 0}, {74, 82, 470, 520, 1210, 1340, "WO", 0, 0}, {76, 86, 498, 552, 1258, 1412, "WO", 0, 0}},
    ["glorious"] = {{380, 420, 1330, 1470, 5130, 5670, "UW", 4275, 4725}, {399, 441, 1425, 1575, 5415, 5985, "UW", 4560, 5040}, {418, 462, 1520, 1680, 5700, 6300, "UW", 4940, 5460}, {437, 483, 1615, 1785, 5985, 6615, "UW", 5320, 5880}},
    ["glorious guardian"] = {{380, 420, 25175, 27825, 28975, 32025, "UW", 0, 0}, {399, 441, 27075, 29925, 31065, 34335, "UW", 0, 0}, {418, 462, 28975, 32025, 33155, 36645, "UW", 0, 0}, {437, 483, 30875, 34125, 35245, 38955, "UW", 0, 0}},
    ["goblin cleaver"] = {{232, 258, 2299, 2541, 4619, 5121, "KC", 0, 0}, {247, 275, 2489, 2751, 4959, 5501, "KC", 0, 0}, {263, 291, 2679, 2961, 5309, 5871, "KC", 0, 0}, {280, 310, 2869, 3171, 5669, 6271, "KC", 0, 0}},
    ["godly"] = {{95, 105, 142, 158, 1075, 1198, "PI", 2470, 2730}, {104, 116, 161, 179, 1193, 1335, "PI", 2660, 2940}, {114, 126, 180, 200, 1317, 1460, "PI", 2850, 3150}, {123, 137, 199, 221, 1428, 1591, "PI", 3040, 3360}},
    ["godly guardian"] = {{95, 105, 5415, 5985, 6365, 7035, "PI", 0, 0}, {104, 116, 5890, 6510, 6930, 7670, "PI", 0, 0}, {114, 126, 6365, 7035, 7505, 8295, "PI", 0, 0}, {123, 137, 6935, 7665, 8165, 9035, "PI", 0, 0}},
    ["godsword"] = {{91, 101, 655, 725, 1565, 1735, "WO", 0, 0}, {95, 105, 693, 767, 1643, 1817, "WO", 0, 0}, {98, 110, 731, 809, 1711, 1909, "WO", 0, 0}, {102, 114, 769, 851, 1789, 1991, "WO", 0, 0}},
    ["grand claymore"] = {{8, 10, 52, 58, 72, 89, "DT", 0, 0}, {9, 11, 57, 63, 82, 101, "DT", 0, 0}, {10, 12, 63, 71, 97, 120, "DT", 0, 0}, {12, 14, 70, 78, 117, 145, "DT", 0, 0}},
    ["granite maul"] = {{4, 6, 26, 30, 30, 36, "DT", 0, 0}, {5, 7, 31, 35, 36, 44, "DT", 0, 0}, {6, 8, 36, 40, 44, 56, "DT", 0, 0}, {7, 9, 41, 47, 55, 67, "DT", 0, 0}},
    ["greater dark scythe"] = {{151, 167, 1197, 1323, 2707, 2993, "PI", 0, 0}, {159, 177, 1292, 1428, 2882, 3198, "PI", 0, 0}, {168, 186, 1387, 1533, 3067, 3393, "PI", 0, 0}, {176, 196, 1482, 1638, 3242, 3598, "PI", 0, 0}},
    ["greater prophet staff"] = {{228, 252, 2147, 2373, 4427, 4893, "PI", 0, 0}, {244, 270, 2375, 2625, 4815, 5325, "PI", 0, 0}, {258, 286, 2584, 2856, 5164, 5716, "PI", 0, 0}, {275, 305, 2812, 3108, 5562, 6158, "PI", 0, 0}},
    ["guardian"] = {{5, 7, 190, 210, 238, 280, "DT", 0, 0}, {6, 8, 223, 247, 283, 327, "DT", 0, 0}, {8, 10, 256, 284, 336, 384, "DT", 0, 0}, {9, 11, 323, 357, 413, 467, "DT", 0, 0}},
    ["gungnir"] = {{418000, 462000, 63270000, 69930000, 67450000, 74550000, "NL", 0, 0}},
    ["hardened ice sword"] = {{50, 56, 247, 273, 747, 833, "WO", 0, 0}, {52, 58, 266, 294, 786, 874, "WO", 0, 0}, {54, 60, 285, 315, 825, 915, "WO", 0, 0}, {56, 62, 304, 336, 864, 956, "WO", 0, 0}},
    ["heavenly greatsword"] = {{380, 420, 4180, 4620, 7980, 8820, "KC", 0, 0}, {418, 462, 4655, 5145, 8835, 9765, "KC", 0, 0}, {456, 504, 5130, 5670, 9690, 10710, "KC", 0, 0}, {494, 546, 5605, 6195, 10545, 11655, "KC", 0, 0}},
    ["hellstone greataxe"] = {{85500, 94500, 3420000, 3780000, 4275000, 4725000, "VC", 0, 0}, {88825, 98175, 3562500, 3937500, 4450750, 4919250, "VC", 0, 0}, {92150, 101850, 3705000, 4095000, 4626500, 5113500, "VC", 0, 0}, {95000, 105000, 3895000, 4305000, 4845000, 5355000, "VC", 0, 0}},
    ["hextech greataxe"] = {{12350, 13650, 275500, 304500, 399000, 441000, "SS", 0, 0}, {13110, 14490, 294500, 325500, 425600, 470400, "SS", 0, 0}, {13870, 15330, 313500, 346500, 452200, 499800, "SS", 0, 0}, {14630, 16170, 332500, 367500, 478800, 529200, "SS", 0, 0}},
    ["hextech katana"] = {{8265, 9135, 190000, 210000, 272650, 301350, "SS", 0, 0}, {8740, 9660, 198550, 219450, 285950, 316050, "SS", 0, 0}, {9215, 10185, 207100, 228900, 299250, 330750, "SS", 0, 0}, {9690, 10710, 215650, 238350, 312550, 345450, "SS", 0, 0}},
    ["hextech polearm"] = {{10925, 12075, 247000, 273000, 356250, 393750, "SS", 0, 0}, {11875, 13125, 266000, 294000, 384750, 425250, "SS", 0, 0}, {12825, 14175, 285000, 315000, 413250, 456750, "SS", 0, 0}, {13775, 15225, 304000, 336000, 441750, 488250, "SS", 0, 0}},
    ["hextech wired spellblade"] = {{13680, 15120, 304000, 336000, 440800, 487200, "SS", 0, 0}, {14535, 16065, 323000, 357000, 468350, 517650, "SS", 0, 0}, {15390, 17010, 342000, 378000, 495900, 548100, "SS", 0, 0}, {16245, 17955, 361000, 399000, 523450, 578550, "SS", 0, 0}},
    ["high priest battleaxe"] = {{437, 483, 4940, 5460, 9310, 10290, "KC", 0, 0}, {475, 525, 5320, 5880, 10070, 11130, "KC", 0, 0}, {494, 546, 5700, 6300, 10640, 11760, "KC", 0, 0}, {513, 567, 6080, 6720, 11210, 12390, "KC", 0, 0}},
    ["hofund"] = {{462000, 498960, 69930000, 75524400, 74550000, 80514000, "NL", 0, 0}},
    ["holy grail"] = {{17, 19, 99, 111, 214, 260, "WO", 0, 0}, {19, 23, 109, 121, 255, 320, "WO", 0, 0}, {22, 26, 118, 132, 304, 368, "WO", 0, 0}, {25, 29, 128, 142, 353, 415, "WO", 0, 0}},
    ["holy staff"] = {{12, 14, 81, 91, 139, 170, "DT", 0, 0}, {14, 16, 89, 99, 166, 204, "DT", 0, 0}, {16, 18, 96, 108, 181, 244, "DT", 0, 0}, {19, 23, 108, 120, 254, 318, "DT", 0, 0}},
    ["holy wand"] = {{128, 142, 969, 1071, 2249, 2491, "PI", 0, 0}, {135, 151, 1035, 1145, 2385, 2655, "PI", 0, 0}, {142, 158, 1102, 1218, 2522, 2798, "PI", 0, 0}, {149, 165, 1168, 1292, 2658, 2942, "PI", 0, 0}},
    ["honorable greatsword"] = {{1301, 1439, 22800, 25200, 35810, 39590, "SP", 0, 0}, {1358, 1502, 24700, 27300, 38280, 42320, "SP", 0, 0}, {1415, 1565, 26600, 29400, 40750, 45050, "SP", 0, 0}, {1472, 1628, 28500, 31500, 43220, 47780, "SP", 0, 0}},
    ["hope's triumph"] = {{817, 903, 12160, 13440, 20330, 22470, "UW", 0, 0}, {855, 945, 13110, 14490, 21660, 23940, "UW", 0, 0}, {893, 987, 14060, 15540, 22990, 25410, "UW", 0, 0}, {931, 1029, 15010, 16590, 24320, 26880, "UW", 0, 0}},
    ["hunter's"] = {{1814, 2006, 10450, 11550, 28590, 31610, "GH", 124450, 137550}, {1966, 2174, 11400, 12600, 31060, 34340, "GH", 141550, 156450}, {2128, 2352, 12350, 13650, 33630, 37170, "GH", 158650, 175350}, {2280, 2520, 13300, 14700, 36100, 39900, "GH", 175750, 194250}},
    ["hunter's guardian"] = {{1814, 2006, 186200, 205800, 204340, 225860, "GH", 0, 0}, {1966, 2174, 206150, 227850, 225810, 249590, "GH", 0, 0}, {2128, 2352, 226100, 249900, 247380, 273420, "GH", 0, 0}, {2280, 2520, 246050, 271950, 268850, 297150, "GH", 0, 0}},
    ["ice"] = {{10, 12, 17, 19, 31, 27, "WO", 128, 142}, {12, 14, 19, 23, 37, 31, "WO", 161, 179}, {14, 16, 22, 26, 44, 36, "WO", 194, 216}, {16, 18, 25, 29, 54, 42, "WO", 228, 252}},
    ["ice enhanced sword"] = {{22, 26, 130, 144, 325, 388, "WO", 0, 0}, {24, 28, 137, 153, 357, 422, "WO", 0, 0}, {26, 30, 147, 163, 393, 455, "WO", 0, 0}, {28, 32, 156, 174, 425, 490, "WO", 0, 0}},
    ["ice greatspear"] = {{323000, 357000, 40850000, 45150000, 44080000, 48720000, "NL", 0, 0}, {329650, 364350, 42655000, 47145000, 45951500, 50788500, "NL", 0, 0}, {336300, 371700, 44460000, 49140000, 47823000, 52857000, "NL", 0, 0}, {342000, 378000, 46265000, 51135000, 49685000, 54915000, "NL", 0, 0}},
    ["ice guardian"] = {{10, 12, 380, 420, 480, 540, "WO", 0, 0}, {12, 14, 427, 473, 547, 613, "WO", 0, 0}, {14, 16, 475, 525, 615, 685, "WO", 0, 0}, {16, 18, 522, 578, 682, 758, "WO", 0, 0}},
    ["ice infused slicer"] = {{96, 108, 712, 788, 1672, 1868, "WO", 0, 0}, {100, 112, 750, 830, 1750, 1950, "WO", 0, 0}, {104, 116, 788, 872, 1828, 2032, "WO", 0, 0}, {108, 120, 826, 914, 1906, 2114, "WO", 0, 0}},
    ["ice king's"] = {{42, 48, 71, 79, 388, 473, "WO", 570, 630}, {46, 52, 76, 84, 443, 528, "WO", 617, 683}, {50, 56, 80, 90, 498, 583, "WO", 665, 735}, {54, 60, 85, 95, 550, 634, "WO", 712, 788}},
    ["ice king's guardian"] = {{42, 48, 1662, 1838, 2082, 2318, "WO", 0, 0}, {46, 52, 1852, 2048, 2312, 2568, "WO", 0, 0}, {50, 56, 2042, 2258, 2542, 2818, "WO", 0, 0}, {54, 60, 2232, 2468, 2772, 3068, "WO", 0, 0}},
    ["ice queen wand"] = {{77, 87, 484, 536, 1254, 1406, "WO", 0, 0}, {81, 91, 532, 588, 1342, 1498, "WO", 0, 0}, {85, 95, 579, 641, 1429, 1591, "WO", 0, 0}, {89, 99, 627, 693, 1517, 1683, "WO", 0, 0}},
    ["ice reaver"] = {{93, 103, 660, 730, 1590, 1760, "WO", 0, 0}, {97, 109, 703, 777, 1673, 1867, "WO", 0, 0}, {102, 114, 745, 825, 1765, 1965, "WO", 0, 0}, {107, 119, 788, 872, 1858, 2062, "WO", 0, 0}},
    ["ice spellblade"] = {{304000, 336000, 36290000, 40110000, 39330000, 43470000, "NL", 0, 0}, {310650, 343350, 37810000, 41790000, 40916500, 45223500, "NL", 0, 0}, {317300, 350700, 39330000, 43470000, 42503000, 46977000, "NL", 0, 0}, {323000, 357000, 40850000, 45150000, 44080000, 48720000, "NL", 0, 0}},
    ["industrial"] = {{3230, 3570, 24700, 27300, 57000, 63000, "SS", 297350, 328650}, {3610, 3990, 26125, 28875, 62225, 68775, "SS", 332500, 367500}, {3990, 4410, 27550, 30450, 67450, 74550, "SS", 380000, 420000}, {4370, 4830, 28500, 31500, 72200, 79800, "SS", 419900, 464100}},
    ["industrial guardian"] = {{3230, 3570, 446500, 493500, 478800, 529200, "SS", 0, 0}, {3610, 3990, 494000, 546000, 530100, 585900, "SS", 0, 0}, {3990, 4410, 541500, 598500, 581400, 642600, "SS", 0, 0}, {4370, 4830, 589000, 651000, 632700, 699300, "SS", 0, 0}},
    ["industrial spellscythe"] = {{1216, 1344, 20425, 22575, 32585, 36015, "SP", 0, 0}, {1263, 1397, 21850, 24150, 34480, 38120, "SP", 0, 0}, {1311, 1449, 23275, 25725, 36385, 40215, "SP", 0, 0}, {1358, 1502, 24700, 27300, 38280, 42320, "SP", 0, 0}},
    ["infernal"] = {{541, 599, 2280, 2520, 7690, 8510, "SP", 21850, 24150}, {579, 641, 2565, 2835, 8355, 9245, "SP", 24700, 27300}, {617, 683, 2850, 3150, 9020, 9980, "SP", 27550, 30450}, {655, 725, 3135, 3465, 9685, 10715, "SP", 30400, 33600}},
    ["infernal elemental sword"] = {{22, 26, 142, 158, 345, 408, "WO", 0, 0}, {24, 28, 152, 168, 380, 442, "WO", 0, 0}, {26, 30, 161, 179, 413, 475, "WO", 0, 0}, {27, 31, 169, 187, 433, 495, "WO", 0, 0}},
    ["infernal guardian"] = {{541, 599, 39900, 44100, 45310, 50090, "SP", 0, 0}, {579, 641, 44650, 49350, 50440, 55760, "SP", 0, 0}, {617, 683, 49400, 54600, 55570, 61430, "SP", 0, 0}, {655, 725, 54150, 59850, 60700, 67100, "SP", 0, 0}},
    ["infernal sun staff"] = {{299, 331, 3040, 3360, 6030, 6670, "KC", 0, 0}, {313, 347, 3372, 3728, 6502, 7198, "KC", 0, 0}, {332, 368, 3610, 3990, 6930, 7670, "KC", 0, 0}, {351, 389, 3942, 4358, 7452, 8248, "KC", 0, 0}},
    ["inventor's greatsword"] = {{22800, 25200, 460750, 509250, 688750, 761250, "SS", 0, 0}},
    ["inventor's spellblade"] = {{22800, 25200, 460750, 509250, 688750, 761250, "SS", 0, 0}},
    ["iron armor"] = {{1, 3, 57, 63, 59, 72, "DT", 0, 0}, {2, 4, 68, 76, 74, 70, "DT", 0, 0}, {3, 5, 80, 90, 92, 112, "DT", 0, 0}, {4, 6, 95, 105, 113, 138, "DT", 0, 0}},
    ["iron longsword"] = {{3, 5, 15, 17, 18, 22, "DT", 0, 0}, {4, 6, 18, 20, 22, 26, "DT", 0, 0}, {5, 7, 20, 24, 25, 31, "DT", 0, 0}, {6, 8, 23, 27, 29, 35, "DT", 0, 0}},
    ["jade spelldagger"] = {{1567, 1733, 32300, 35700, 47970, 53030, "SP", 0, 0}, {1624, 1796, 34675, 38325, 50915, 56285, "SP", 0, 0}, {1681, 1859, 37050, 40950, 53860, 59540, "SP", 0, 0}, {1738, 1922, 39425, 43575, 56805, 62795, "SP", 0, 0}},
    ["jotunn"] = {{95000, 105000, 3591000, 3969000, 4541000, 5019000, "NL", 85500000, 94500000}, {104500, 115500, 3914000, 4326000, 4959000, 5481000, "NL", 97565000, 107835000}, {114000, 126000, 4237000, 4683000, 5377000, 5943000, "NL", 109630000, 121170000}, {123500, 136500, 4560000, 5040000, 5795000, 6405000, "NL", 121600000, 134400000}},
    ["jotunn guardian"] = {{95000, 105000, 136800000, 151200000, 137750000, 152250000, "NL", 0, 0}, {104500, 115500, 156053332, 172480000, 157098332, 173635000, "NL", 0, 0}, {114000, 126000, 175306665, 193759999, 176446665, 195019999, "NL", 0, 0}, {123500, 136500, 194560000, 215040000, 195795000, 216405000, "NL", 0, 0}},
    ["king's greatsword"] = {{76, 84, 498, 552, 1258, 1392, "WO", 0, 0}, {78, 88, 527, 583, 1307, 1463, "WO", 0, 0}, {81, 91, 555, 615, 1365, 1525, "WO", 0, 0}, {84, 94, 584, 646, 1424, 1586, "WO", 0, 0}},
    ["king's spellblade"] = {{66, 74, 370, 410, 1030, 1150, "WO", 0, 0}, {70, 78, 408, 452, 1108, 1232, "WO", 0, 0}, {74, 82, 446, 494, 1186, 1314, "WO", 0, 0}, {77, 87, 484, 536, 1254, 1406, "WO", 0, 0}},
    ["kraken slayer"] = {{10450, 11550, 228000, 252000, 332500, 367500, "GH", 0, 0}},
    ["laevateinn"] = {{462000, 498960, 69930000, 75524400, 74550000, 80514000, "NL", 0, 0}},
    ["lava  king's warscythe"] = {{123500, 136500, 6412500, 7087500, 7647500, 8452500, "VC", 0, 0}},
    ["lava king's"] = {{28025, 30975, 432250, 477750, 712500, 787500, "VC", 8930000, 9870000}, {30400, 33600, 456000, 504000, 760000, 840000, "VC", 9690000, 10710000}, {32300, 35700, 479750, 530250, 802750, 887250, "VC", 10450000, 11550000}, {34200, 37800, 503500, 556500, 845500, 934500, "VC", 11400000, 12600000}},
    ["lava king's guardian"] = {{28025, 30975, 14250000, 15750000, 14530250, 16059750, "VC", 0, 0}, {30400, 33600, 15200000, 16800000, 15504000, 17136000, "VC", 0, 0}, {32300, 35700, 16150000, 17850000, 16473000, 18207000, "VC", 0, 0}, {34200, 37800, 17100000, 18900000, 17442000, 19278000, "VC", 0, 0}},
    ["lava king's spell daggers"] = {{123500, 136500, 6412500, 7087500, 7647500, 8452500, "VC", 0, 0}},
    ["lava shard staff"] = {{66500, 73500, 2565000, 2835000, 3230000, 3570000, "VC", 0, 0}, {69825, 77175, 2707500, 2992500, 3405750, 3764250, "VC", 0, 0}, {73150, 80850, 2850000, 3150000, 3581500, 3958500, "VC", 0, 0}, {76000, 84000, 2992500, 3307500, 3752500, 4147500, "VC", 0, 0}},
    ["lava spellblade"] = {{85500, 94500, 3420000, 3780000, 4275000, 4725000, "VC", 0, 0}, {88825, 98175, 3562500, 3937500, 4450750, 4919250, "VC", 0, 0}, {92150, 101850, 3705000, 4095000, 4626500, 5113500, "VC", 0, 0}, {95000, 105000, 3895000, 4305000, 4845000, 5355000, "VC", 0, 0}},
    ["lava tendril pike"] = {{76000, 84000, 2992500, 3307500, 3752500, 4147500, "VC", 0, 0}, {79325, 87675, 3135000, 3465000, 3928250, 4341750, "VC", 0, 0}, {82650, 91350, 3277500, 3622500, 4104000, 4536000, "VC", 0, 0}, {85500, 94500, 3420000, 3780000, 4275000, 4725000, "VC", 0, 0}},
    ["luminous greatstaff"] = {{741, 819, 10260, 11340, 17670, 19530, "UW", 0, 0}, {779, 861, 11210, 12390, 19000, 21000, "UW", 0, 0}, {817, 903, 12160, 13440, 20330, 22470, "UW", 0, 0}, {855, 945, 13110, 14490, 21660, 23940, "UW", 0, 0}},
    ["mage spellbook"] = {{6, 8, 49, 55, 61, 76, "DT", 0, 0}, {7, 9, 56, 62, 75, 92, "DT", 0, 0}, {8, 10, 64, 72, 90, 111, "DT", 0, 0}, {9, 11, 74, 82, 110, 134, "DT", 0, 0}},
    ["magic mallet"] = {{4, 6, 20, 24, 24, 30, "DT", 0, 0}, {5, 7, 22, 26, 27, 33, "DT", 0, 0}, {6, 8, 26, 30, 32, 38, "DT", 0, 0}, {7, 9, 30, 34, 37, 46, "DT", 0, 0}},
    ["magic trident"] = {{5130, 5670, 140600, 155400, 191900, 212100, "GH", 0, 0}, {5557, 6143, 148200, 163800, 203770, 225230, "GH", 0, 0}, {5985, 6615, 155800, 172200, 215650, 238350, "GH", 0, 0}, {6412, 7088, 163400, 180600, 227520, 251480, "GH", 0, 0}},
    ["magma infused staff"] = {{28, 32, 156, 174, 425, 490, "WO", 0, 0}, {31, 35, 171, 189, 475, 537, "WO", 0, 0}, {34, 38, 185, 205, 523, 585, "WO", 0, 0}, {37, 41, 199, 221, 568, 631, "WO", 0, 0}},
    ["magma infused waraxe"] = {{95000, 105000, 3895000, 4305000, 4845000, 5355000, "VC", 0, 0}, {97375, 107625, 4085000, 4515000, 5058750, 5591250, "VC", 0, 0}, {99750, 110250, 4275000, 4725000, 5272500, 5827500, "VC", 0, 0}, {101650, 112350, 4465000, 4935000, 5481500, 6058500, "VC", 0, 0}},
    ["mana infused spellblade"] = {{3040, 3360, 90250, 99750, 120650, 133350, "TC", 0, 0}, {3211, 3549, 95950, 106050, 128060, 141540, "TC", 0, 0}, {3382, 3738, 101650, 112350, 135470, 149730, "TC", 0, 0}, {3553, 3927, 107350, 118650, 142880, 157920, "TC", 0, 0}},
    ["mercenary/elemental"] = {{3, 5, 6, 8, 9, 13, "DT", 42, 48}, {4, 6, 7, 9, 11, 15, "DT", 52, 58}, {5, 7, 8, 10, 13, 17, "DT", 61, 69}, {6, 8, 9, 11, 15, 19, "DT", 71, 79}},
    ["midgardian"] = {{86925, 96075, 2531750, 2798250, 3401000, 3759000, "NL", 64600000, 71400000}, {89300, 98700, 2883250, 3186750, 3776250, 4173750, "NL", 71535000, 79065000}, {92150, 101850, 3234750, 3575250, 4156250, 4593750, "NL", 78470000, 86730000}, {95000, 105000, 3591000, 3969000, 4541000, 5019000, "NL", 85500000, 94500000}},
    ["midgardian guardian"] = {{86925, 96075, 102600000, 113400000, 103469250, 114360750, "NL", 0, 0}, {89300, 98700, 114000000, 126000000, 114893000, 126987000, "NL", 0, 0}, {92150, 101850, 125400000, 138600000, 126321500, 139618500, "NL", 0, 0}, {95000, 105000, 136800000, 151200000, 137750000, 152250000, "NL", 0, 0}},
    ["mighty flatblade"] = {{131, 145, 997, 1103, 2307, 2553, "PI", 0, 0}, {136, 152, 1045, 1155, 2405, 2675, "PI", 0, 0}, {142, 158, 1092, 1208, 2512, 2788, "PI", 0, 0}, {148, 164, 1140, 1260, 2620, 2900, "PI", 0, 0}},
    ["mighty frozen greatsword"] = {{85, 95, 598, 662, 1448, 1612, "WO", 0, 0}, {89, 99, 636, 704, 1526, 1694, "WO", 0, 0}, {93, 103, 674, 746, 1604, 1776, "WO", 0, 0}, {96, 108, 712, 788, 1672, 1868, "WO", 0, 0}},
    ["mighty fusion maul"] = {{17480, 19320, 361000, 399000, 535800, 592200, "SS", 0, 0}, {18430, 20370, 380000, 420000, 564300, 623700, "SS", 0, 0}, {19380, 21420, 399000, 441000, 592800, 655200, "SS", 0, 0}, {20330, 22470, 418000, 462000, 621300, 686700, "SS", 0, 0}},
    ["mighty fusion spellblade"] = {{17480, 19320, 361000, 399000, 535800, 592200, "SS", 0, 0}, {18430, 20370, 380000, 420000, 564300, 623700, "SS", 0, 0}, {19380, 21420, 399000, 441000, 592800, 655200, "SS", 0, 0}, {20330, 22470, 418000, 462000, 621300, 686700, "SS", 0, 0}},
    ["mjolnir"] = {{418000, 462000, 63270000, 69930000, 67450000, 74550000, "NL", 0, 0}},
    ["molten blade"] = {{138, 154, 1073, 1187, 2453, 2727, "PI", 0, 0}, {144, 160, 1130, 1250, 2570, 2850, "PI", 0, 0}, {150, 166, 1187, 1313, 2687, 2973, "PI", 0, 0}, {155, 173, 1244, 1376, 2794, 3106, "PI", 0, 0}},
    ["molten forged"] = {{23750, 26250, 323000, 357000, 560500, 619500, "VC", 6270000, 6930000}, {25175, 27825, 361000, 399000, 612750, 677250, "VC", 7125000, 7875000}, {26600, 29400, 399000, 441000, 665000, 735000, "VC", 7980000, 8820000}, {28025, 30975, 432250, 477750, 712500, 787500, "VC", 8930000, 9870000}},
    ["molten forged guardian"] = {{23750, 26250, 9500000, 10500000, 9737500, 10762500, "VC", 0, 0}, {25175, 27825, 11162500, 12337500, 11414250, 12615750, "VC", 0, 0}, {26600, 29400, 12825000, 14175000, 13091000, 14469000, "VC", 0, 0}, {28025, 30975, 14250000, 15750000, 14530250, 16059750, "VC", 0, 0}},
    ["molten greataxe"] = {{231, 257, 2242, 2478, 4552, 5048, "PI", 0, 0}, {247, 273, 2432, 2688, 4902, 5418, "PI", 0, 0}, {261, 289, 2622, 2898, 5232, 5788, "PI", 0, 0}, {275, 305, 2812, 3108, 5562, 6158, "PI", 0, 0}},
    ["molten maul"] = {{58, 66, 332, 368, 912, 1028, "WO", 0, 0}, {60, 68, 351, 389, 951, 1069, "WO", 0, 0}, {63, 71, 370, 410, 1000, 1120, "WO", 0, 0}, {66, 74, 389, 431, 1049, 1171, "WO", 0, 0}},
    ["moon crystal spellblade"] = {{56050, 61950, 1586500, 1753500, 2147000, 2373000, "OO", 0, 0}, {57000, 63000, 1653000, 1827000, 2223000, 2457000, "OO", 0, 0}, {57950, 64050, 1710000, 1890000, 2289500, 2530500, "OO", 0, 0}, {58900, 65100, 1805000, 1995000, 2394000, 2646000, "OO", 0, 0}},
    ["moonlight staff"] = {{437, 483, 4940, 5460, 9310, 10290, "KC", 0, 0}, {475, 525, 5320, 5880, 10070, 11130, "KC", 0, 0}, {494, 546, 5700, 6300, 10640, 11760, "KC", 0, 0}, {513, 567, 6080, 6720, 11210, 12390, "KC", 0, 0}},
    ["mossy greatsword"] = {{60, 68, 223, 247, 823, 927, "WO", 0, 0}, {64, 72, 237, 263, 877, 983, "WO", 0, 0}, {68, 76, 256, 284, 936, 1044, "WO", 0, 0}, {72, 80, 275, 305, 995, 1105, "WO", 0, 0}},
    ["mythical"] = {{2280, 2520, 13300, 14700, 36100, 39900, "GH", 175750, 194250}, {2403, 2657, 14250, 15750, 38280, 42320, "GH", 192850, 213150}, {2527, 2793, 15200, 16800, 40470, 44730, "GH", 209950, 232050}, {2660, 2940, 16150, 17850, 42750, 47250, "GH", 227050, 250950}},
    ["mythical guardian"] = {{2280, 2520, 247000, 273000, 269800, 298200, "GH", 0, 0}, {2403, 2657, 273125, 301875, 297155, 328445, "GH", 0, 0}, {2527, 2793, 299250, 330750, 324520, 358680, "GH", 0, 0}, {2660, 2940, 323000, 357000, 349600, 386400, "GH", 0, 0}},
    ["nature scythe"] = {{1092, 1208, 18050, 19950, 28970, 32030, "UW", 0, 0}, {1121, 1239, 18715, 20685, 29925, 33075, "UW", 0, 0}, {1149, 1271, 19380, 21420, 30870, 34130, "UW", 0, 0}, {1178, 1302, 20045, 22155, 31825, 35175, "UW", 0, 0}},
    ["norse blade"] = {{266000, 294000, 26980000, 29820000, 29640000, 32760000, "NL", 0, 0}, {272650, 301350, 28500000, 31500000, 31226500, 34513500, "NL", 0, 0}, {279300, 308700, 30020000, 33180000, 32813000, 36267000, "NL", 0, 0}, {285000, 315000, 31635000, 34965000, 34485000, 38115000, "NL", 0, 0}},
    ["norse greataxe"] = {{342000, 378000, 46265000, 51135000, 49685000, 54915000, "NL", 0, 0}, {348650, 385350, 48070000, 53130000, 51556500, 56983500, "NL", 0, 0}, {355300, 392700, 49875000, 55125000, 53428000, 59052000, "NL", 0, 0}, {361000, 399000, 51680000, 57120000, 55290000, 61110000, "NL", 0, 0}},
    ["northen runic blade"] = {{285000, 315000, 31635000, 34965000, 34485000, 38115000, "NL", 0, 0}, {291650, 322350, 33155000, 36645000, 36071500, 39868500, "NL", 0, 0}, {298300, 329700, 34675000, 38325000, 37658000, 41622000, "NL", 0, 0}, {304000, 336000, 36290000, 40110000, 39330000, 43470000, "NL", 0, 0}},
    ["northern spellstaff"] = {{266000, 294000, 26980000, 29820000, 29640000, 32760000, "NL", 0, 0}, {272650, 301350, 28500000, 31500000, 31226500, 34513500, "NL", 0, 0}, {279300, 308700, 30020000, 33180000, 32813000, 36267000, "NL", 0, 0}, {285000, 315000, 31635000, 34965000, 34485000, 38115000, "NL", 0, 0}},
    ["novice wand"] = {{2, 4, 11, 13, 13, 17, "DT", 0, 0}, {3, 5, 12, 14, 15, 19, "DT", 0, 0}, {4, 6, 13, 15, 17, 21, "DT", 0, 0}, {5, 7, 14, 16, 19, 23, "DT", 0, 0}},
    ["novice | blue wizard"] = {{1, 3, 3, 5, 4, 8, "DT", 19, 21}, {2, 4, 4, 6, 6, 10, "DT", 28, 32}, {3, 5, 5, 7, 8, 12, "DT", 38, 42}, {4, 6, 6, 8, 10, 14, "DT", 47, 53}},
    ["oathsworn"] = {{190000, 210000, 7220000, 7980000, 9120000, 10080000, "GS", 204250000, 225750000}, {223250, 246750, 7757700, 8574300, 9990200, 11041800, "GS", 233066350, 257599650}, {256500, 283500, 8295400, 9168600, 10860400, 12003600, "GS", 261882700, 289449300}, {285000, 315000, 8835000, 9765000, 11685000, 12915000, "GS", 290700000, 321300000}},
    ["oathsworn guardian"] = {{190000, 210000, 324900000, 359100000, 326800000, 361200000, "GS", 0, 0}, {223250, 246750, 370626350, 409639650, 372858850, 412107150, "GS", 0, 0}, {256500, 283500, 416352700, 460179300, 418917700, 463014300, "GS", 0, 0}, {285000, 315000, 462080000, 510720000, 464930000, 513870000, "GS", 0, 0}},
    ["oathsworn halberd"] = {{665000, 735000, 107665400, 118998600, 114315400, 126348600, "GS", 0, 0}, {703000, 777000, 111359950, 123082050, 118389950, 130852050, "GS", 0, 0}, {731500, 808500, 115054500, 127165500, 122369500, 135250500, "GS", 0, 0}, {760000, 840000, 118750000, 131250000, 126350000, 139650000, "GS", 0, 0}},
    ["oathsworn hammer"] = {{475000, 525000, 85500000, 94500000, 90250000, 99750000, "GS", 0, 0}, {513000, 567000, 89194550, 98583450, 94324550, 104253450, "GS", 0, 0}, {541500, 598500, 92889100, 102666900, 98304100, 108651900, "GS", 0, 0}, {570000, 630000, 96583650, 106750350, 102283650, 113050350, "GS", 0, 0}},
    ["oathsworn spellblade"] = {{411350, 454650, 66500000, 73500000, 70613500, 78046500, "GS", 0, 0}, {421800, 466200, 70300000, 77700000, 74518000, 82362000, "GS", 0, 0}, {432250, 477750, 73150000, 80850000, 77472500, 85627500, "GS", 0, 0}, {442700, 489300, 76000000, 84000000, 80427000, 88893000, "GS", 0, 0}},
    ["oathsworn spellscythe"] = {{570000, 630000, 96583650, 106750350, 102283650, 113050350, "GS", 0, 0}, {608000, 672000, 100278200, 110833800, 106358200, 117553800, "GS", 0, 0}, {636500, 703500, 103972750, 114917250, 110337750, 121952250, "GS", 0, 0}, {665000, 735000, 107665400, 118998600, 114315400, 126348600, "GS", 0, 0}},
    ["oathsworn staff and tome"] = {{665000, 735000, 107665400, 118998600, 114315400, 126348600, "GS", 0, 0}, {703000, 777000, 111359950, 123082050, 118389950, 130852050, "GS", 0, 0}, {731500, 808500, 115054500, 127165500, 122369500, 135250500, "GS", 0, 0}, {760000, 840000, 118750000, 131250000, 126350000, 139650000, "GS", 0, 0}},
    ["oathsworn sword and shield"] = {{570000, 630000, 96583650, 106750350, 102283650, 113050350, "GS", 0, 0}, {608000, 672000, 100278200, 110833800, 106358200, 117553800, "GS", 0, 0}, {636500, 703500, 103972750, 114917250, 110337750, 121952250, "GS", 0, 0}, {665000, 735000, 107665400, 118998600, 114315400, 126348600, "GS", 0, 0}},
    ["ocean dweller's mageblade"] = {{6840, 7560, 167200, 184800, 235600, 260400, "GH", 0, 0}, {7410, 8190, 175750, 194250, 249850, 276150, "GH", 0, 0}, {7980, 8820, 184300, 203700, 264100, 291900, "GH", 0, 0}, {8550, 9450, 192850, 213150, 278350, 307650, "GH", 0, 0}},
    ["ocean pearl staff"] = {{140600, 155400, 9975000, 11025000, 11381000, 12579000, "AT", 0, 0}, {142500, 157500, 10450000, 11550000, 11875000, 13125000, "AT", 0, 0}, {144400, 159600, 10925000, 12075000, 12369000, 13671000, "AT", 0, 0}, {146300, 161700, 11400000, 12600000, 12863000, 14217000, "AT", 0, 0}},
    ["ocean splitter"] = {{172, 192, 1472, 1628, 3192, 3548, "PI", 0, 0}, {180, 200, 1586, 1754, 3386, 3754, "PI", 0, 0}, {188, 208, 1700, 1880, 3580, 3960, "PI", 0, 0}, {195, 217, 1814, 2006, 3764, 4176, "PI", 0, 0}},
    ["oceanic greatsword"] = {{146300, 161700, 11400000, 12600000, 12863000, 14217000, "AT", 0, 0}, {148200, 163800, 11875000, 13125000, 13357000, 14763000, "AT", 0, 0}, {150100, 165900, 12350000, 13650000, 13851000, 15309000, "AT", 0, 0}, {152000, 168000, 12777500, 14122500, 14297500, 15802500, "AT", 0, 0}},
    ["onyx empowered greatsword"] = {{185, 205, 1634, 1806, 3484, 3856, "PI", 0, 0}, {193, 215, 1748, 1932, 3678, 4082, "PI", 0, 0}, {202, 224, 1862, 2058, 3882, 4298, "PI", 0, 0}, {210, 234, 1976, 2184, 4076, 4524, "PI", 0, 0}},
    ["onyx hammer"] = {{56, 62, 304, 336, 864, 956, "WO", 0, 0}, {57, 65, 323, 357, 893, 1007, "WO", 0, 0}, {59, 67, 342, 378, 932, 1048, "WO", 0, 0}, {62, 70, 361, 399, 981, 1099, "WO", 0, 0}},
    ["onyx spell scythe"] = {{45, 51, 228, 252, 678, 762, "WO", 0, 0}, {49, 55, 247, 273, 737, 823, "WO", 0, 0}, {53, 59, 275, 305, 805, 895, "WO", 0, 0}, {57, 63, 304, 336, 874, 966, "WO", 0, 0}},
    ["onyx staff"] = {{8, 10, 61, 69, 86, 106, "DT", 0, 0}, {9, 11, 70, 78, 102, 127, "DT", 0, 0}, {10, 12, 78, 88, 121, 151, "DT", 0, 0}, {12, 14, 89, 99, 152, 186, "DT", 0, 0}},
    ["overgrown warscythe"] = {{247000, 273000, 24320000, 26880000, 26790000, 29610000, "EF", 0, 0}, {253650, 280350, 25203500, 27856500, 27740000, 30660000, "EF", 0, 0}, {260300, 287700, 26087000, 28833000, 28690000, 31710000, "EF", 0, 0}, {266000, 294000, 26980000, 29820000, 29640000, 32760000, "EF", 0, 0}},
    ["overlord's"] = {{1092, 1208, 5985, 6615, 16905, 18695, "TC", 73625, 81375}, {1178, 1302, 6460, 7140, 18240, 20160, "TC", 80750, 89250}, {1073, 1187, 6935, 7665, 17665, 19535, "TC", 87875, 97125}, {1349, 1491, 7410, 8190, 20900, 23100, "TC", 95000, 105000}},
    ["overlord's guardian (chest)"] = {{1092, 1208, 118750, 131250, 129670, 143330, "TC", 0, 0}, {1178, 1302, 129200, 142800, 140980, 155820, "TC", 0, 0}, {1073, 1187, 139650, 154350, 150380, 166220, "TC", 0, 0}, {1349, 1491, 150100, 165900, 163590, 180810, "TC", 0, 0}},
    ["overlord's guardian (hat)"] = {{1092, 1208, 118750, 131250, 129670, 143330, "TC", 0, 0}, {1178, 1302, 133000, 147000, 144780, 160020, "TC", 0, 0}, {1073, 1187, 147250, 162750, 157980, 174620, "TC", 0, 0}, {1349, 1491, 161500, 178500, 174990, 193410, "TC", 0, 0}},
    ["overlord's manablade"] = {{4180, 4620, 115900, 128100, 157700, 174300, "TC", 0, 0}},
    ["overlord's rageblade"] = {{4180, 4620, 115900, 128100, 157700, 174300, "TC", 0, 0}},
    ["phoenix greatstaff"] = {{1330, 1470, 22800, 25200, 36100, 39900, "UW", 0, 0}},
    ["pink pearl spellscythe"] = {{1653, 1827, 36100, 39900, 52630, 58170, "SP", 0, 0}, {1710, 1890, 38950, 43050, 56050, 61950, "SP", 0, 0}, {1767, 1953, 41800, 46200, 59470, 65730, "SP", 0, 0}, {1824, 2016, 44650, 49350, 62890, 69510, "SP", 0, 0}},
    ["pirate king's"] = {{57, 63, 80, 90, 650, 720, "PI", 1045, 1155}, {64, 72, 90, 100, 730, 820, "PI", 1140, 1260}, {72, 80, 99, 111, 819, 911, "PI", 1235, 1365}, {79, 89, 109, 121, 899, 1011, "PI", 1330, 1470}},
    ["pirate king's guardian"] = {{32, 36, 2850, 3150, 3170, 3510, "PI", 0, 0}, {57, 63, 3135, 3465, 3705, 4095, "PI", 0, 0}, {64, 72, 3420, 3780, 4060, 4500, "PI", 0, 0}, {72, 80, 3705, 4095, 4425, 4895, "PI", 0, 0}},
    ["plasma infused cutlass"] = {{15960, 17640, 332500, 367500, 492100, 543900, "SS", 0, 0}, {16910, 18690, 351500, 388500, 520600, 575400, "SS", 0, 0}, {17860, 19740, 370500, 409500, 549100, 606900, "SS", 0, 0}, {18810, 20790, 389500, 430500, 577600, 638400, "SS", 0, 0}},
    ["plasma spellblade"] = {{8265, 9135, 190000, 210000, 272650, 301350, "SS", 0, 0}, {8740, 9660, 198550, 219450, 285950, 316050, "SS", 0, 0}, {9215, 10185, 207100, 228900, 299250, 330750, "SS", 0, 0}, {9690, 10710, 215650, 238350, 312550, 345450, "SS", 0, 0}},
    ["plasma twin spellblade"] = {{12350, 13650, 275500, 304500, 399000, 441000, "SS", 0, 0}, {13110, 14490, 294500, 325500, 425600, 470400, "SS", 0, 0}, {13870, 15330, 313500, 346500, 452200, 499800, "SS", 0, 0}, {14630, 16170, 332500, 367500, 478800, 529200, "SS", 0, 0}},
    ["plate"] = {{24, 28, 41, 47, 112, 154, "WO", 323, 357}, {26, 30, 45, 51, 134, 185, "WO", 351, 389}, {28, 32, 49, 55, 161, 223, "WO", 380, 420}, {30, 34, 51, 57, 185, 253, "WO", 408, 452}},
    ["poison spear"] = {{3277, 3623, 95000, 105000, 127770, 141230, "GH", 0, 0}, {3420, 3780, 100700, 111300, 134900, 149100, "GH", 0, 0}, {3657, 4043, 106400, 117600, 142970, 158030, "GH", 0, 0}, {3800, 4200, 112100, 123900, 150100, 165900, "GH", 0, 0}},
    ["pulverizer"] = {{8, 10, 61, 69, 86, 106, "DT", 0, 0}, {9, 11, 68, 76, 100, 122, "DT", 0, 0}, {10, 12, 75, 83, 116, 141, "DT", 0, 0}, {12, 14, 82, 92, 140, 173, "DT", 0, 0}},
    ["raider's"] = {{1330, 1470, 7600, 8400, 20900, 23100, "GH", 90250, 99750}, {1491, 1649, 8550, 9450, 23460, 25940, "GH", 101650, 112350}, {1653, 1827, 9500, 10500, 26030, 28770, "GH", 113050, 124950}, {1814, 2006, 10450, 11550, 28590, 31610, "GH", 124450, 137550}},
    ["raider's guardian"] = {{1330, 1470, 152000, 168000, 165300, 182700, "GH", 0, 0}, {1491, 1649, 163400, 180600, 178310, 197090, "GH", 0, 0}, {1653, 1827, 174800, 193200, 191330, 211470, "GH", 0, 0}, {1814, 2006, 186200, 205800, 204340, 225860, "GH", 0, 0}},
    ["red knight/templar"] = {{5, 7, 9, 11, 14, 18, "DT", 80, 90}, {6, 8, 11, 13, 17, 21, "DT", 90, 100}, {8, 10, 14, 16, 22, 26, "DT", 99, 111}, {9, 11, 16, 18, 25, 29, "DT", 109, 121}},
    ["reinforced guardian"] = {{270, 300, 15000, 6510, 17700, 9510, "UW", 0, 0}, {294, 326, 17000, 7245, 19940, 10505, "UW", 0, 0}, {318, 352, 19000, 7980, 22180, 11500, "UW", 0, 0}, {332, 368, 21000, 8715, 24320, 12395, "UW", 0, 0}},
    ["reinforced ice blade"] = {{64, 72, 370, 410, 1010, 1130, "WO", 0, 0}, {67, 75, 399, 441, 1069, 1191, "WO", 0, 0}, {70, 78, 427, 473, 1127, 1253, "WO", 0, 0}, {73, 81, 456, 504, 1186, 1314, "WO", 0, 0}},
    ["reinforced steel sword"] = {{27, 31, 156, 174, 415, 480, "WO", 0, 0}, {29, 33, 166, 184, 450, 512, "WO", 0, 0}, {32, 36, 175, 195, 491, 554, "WO", 0, 0}, {34, 38, 185, 205, 523, 585, "WO", 0, 0}},
    ["riptide"] = {{38475, 42525, 731500, 808500, 1116250, 1233750, "AT", 15200000, 16800000}, {39900, 44100, 819850, 906150, 1218850, 1347150, "AT", 17290000, 19110000}, {41325, 45675, 909150, 1004850, 1322400, 1461600, "AT", 19380000, 21420000}, {42750, 47250, 997500, 1102500, 1425000, 1575000, "AT", 21470000, 23730000}},
    ["riptide guardian"] = {{38475, 42525, 22800000, 25200000, 23184750, 25625250, "AT", 0, 0}, {39900, 44100, 26410000, 29190000, 26809000, 29631000, "AT", 0, 0}, {41325, 45675, 30020000, 33180000, 30433250, 33636750, "AT", 0, 0}, {42750, 47250, 32205000, 35595000, 32632500, 36067500, "AT", 0, 0}},
    ["rouge"] = {{940, 1040, 5225, 5775, 14625, 16175, "TC", 52250, 57750}, {1016, 1124, 5605, 6195, 15765, 17435, "TC", 59375, 65625}, {1092, 1208, 5985, 6615, 16905, 18695, "TC", 66500, 73500}, {1168, 1292, 6365, 7035, 18045, 19955, "TC", 73625, 81375}},
    ["rouge guardian"] = {{940, 1040, 85500, 94500, 94900, 104900, "TC", 0, 0}, {1016, 1124, 95000, 105000, 105160, 116240, "TC", 0, 0}, {1092, 1208, 104500, 115500, 115420, 127580, "TC", 0, 0}, {1168, 1292, 114000, 126000, 125680, 138920, "TC", 0, 0}},
    ["rouge's rapier"] = {{5, 7, 35, 39, 40, 52, "DT", 0, 0}, {6, 8, 38, 44, 48, 60, "DT", 0, 0}, {7, 9, 43, 49, 57, 70, "DT", 0, 0}, {8, 10, 48, 54, 66, 81, "DT", 0, 0}},
    ["royal crimson greatsword"] = {{893, 987, 14060, 15540, 22990, 25410, "UW", 0, 0}, {931, 1029, 15010, 16590, 24320, 26880, "UW", 0, 0}, {969, 1071, 15960, 17640, 25650, 28350, "UW", 0, 0}, {1007, 1113, 16910, 18690, 26980, 29820, "UW", 0, 0}},
    ["royal katana"] = {{1216, 1344, 20425, 22575, 32585, 36015, "SP", 0, 0}, {1263, 1397, 21850, 24150, 34480, 38120, "SP", 0, 0}, {1311, 1449, 23275, 25725, 36385, 40215, "SP", 0, 0}, {1358, 1502, 24700, 27300, 38280, 42320, "SP", 0, 0}},
    ["royal slicer"] = {{87, 97, 456, 504, 1326, 1474, "WO", 0, 0}, {72, 80, 484, 536, 1204, 1336, "WO", 0, 0}, {75, 83, 513, 567, 1263, 1397, "WO", 0, 0}, {77, 87, 541, 599, 1311, 1469, "WO", 0, 0}},
    ["ruby greatsword"] = {{1738, 1922, 40375, 44625, 57755, 63845, "SP", 0, 0}, {1795, 1985, 43225, 47775, 61175, 67625, "SP", 0, 0}, {1852, 2048, 46075, 50925, 64595, 71405, "SP", 0, 0}, {1909, 2111, 48925, 54075, 68015, 75185, "SP", 0, 0}},
    ["ruby staff"] = {{117, 131, 883, 977, 2053, 2287, "PI", 0, 0}, {124, 138, 940, 1040, 2180, 2420, "PI", 0, 0}, {131, 145, 997, 1103, 2307, 2553, "PI", 0, 0}, {137, 153, 1054, 1166, 2424, 2696, "PI", 0, 0}},
    ["runic hammer"] = {{79, 89, 541, 599, 1331, 1489, "WO", 0, 0}, {82, 92, 570, 630, 1390, 1550, "WO", 0, 0}, {85, 95, 598, 662, 1448, 1612, "WO", 0, 0}, {88, 98, 627, 693, 1507, 1673, "WO", 0, 0}},
    ["runic mace"] = {{342000, 378000, 46265000, 51135000, 49685000, 54915000, "NL", 0, 0}, {348650, 385350, 48070000, 53130000, 51556500, 56983500, "NL", 0, 0}, {355300, 392700, 49875000, 55125000, 53428000, 59052000, "NL", 0, 0}, {361000, 399000, 51680000, 57120000, 55290000, 61110000, "NL", 0, 0}},
    ["runic pike"] = {{1881, 2079, 47500, 52500, 66310, 73290, "TC", 0, 0}, {1947, 2153, 51300, 56700, 70770, 78230, "TC", 0, 0}, {2014, 2226, 55100, 60900, 75240, 83160, "TC", 0, 0}, {2080, 2300, 58900, 65100, 79700, 88100, "TC", 0, 0}},
    ["runic spellscythe"] = {{2755, 3045, 81700, 90300, 109250, 120750, "TC", 0, 0}, {1976, 2184, 87400, 96600, 107160, 118440, "TC", 0, 0}, {3097, 3423, 93100, 102900, 124070, 137130, "TC", 0, 0}, {3268, 3612, 98800, 109200, 131480, 145320, "TC", 0, 0}},
    ["sakura greatstaff"] = {{2137, 2363, 53200, 58800, 74570, 82430, "SP", 0, 0}},
    ["sakura katana"] = {{2137, 2363, 53200, 58800, 74570, 82430, "SP", 0, 0}},
    ["salvaged"] = {{712, 788, 3800, 4200, 10920, 12080, "TC", 38000, 42000}, {788, 872, 4275, 4725, 12155, 13445, "TC", 42750, 47250}, {864, 956, 4750, 5250, 13390, 14810, "TC", 47500, 52500}, {940, 1040, 5225, 5775, 14625, 16175, "TC", 52250, 57750}},
    ["salvaged guardian"] = {{712, 788, 68400, 75600, 75520, 83480, "TC", 0, 0}, {788, 872, 74100, 81900, 81980, 90620, "TC", 0, 0}, {864, 956, 79800, 88200, 88440, 97760, "TC", 0, 0}, {940, 1040, 85500, 94500, 94900, 104900, "TC", 0, 0}},
    ["samurai"] = {{427, 473, 1567, 1733, 5837, 6463, "SP", 15200, 16800}, {465, 515, 1805, 1995, 6455, 7145, "SP", 17100, 18900}, {503, 557, 2042, 2258, 7072, 7828, "SP", 19000, 21000}, {541, 599, 2280, 2520, 7690, 8510, "SP", 20900, 23100}},
    ["samurai guardian"] = {{427, 473, 28500, 31500, 32770, 36230, "SP", 0, 0}, {465, 515, 32300, 35700, 36950, 40850, "SP", 0, 0}, {503, 557, 36100, 39900, 41130, 45470, "SP", 0, 0}, {541, 599, 39900, 44100, 45310, 50090, "SP", 0, 0}},
    ["sapphire greatstaff"] = {{665, 735, 9215, 10185, 15865, 17535, "UW", 0, 0}, {703, 777, 9690, 10710, 16720, 18480, "UW", 0, 0}, {741, 819, 10165, 11235, 17575, 19425, "UW", 0, 0}, {779, 861, 10640, 11760, 18430, 20370, "UW", 0, 0}},
    ["sapphire spell dagger"] = {{20, 24, 114, 126, 275, 338, "WO", 0, 0}, {23, 27, 126, 140, 328, 393, "WO", 0, 0}, {26, 30, 137, 153, 377, 442, "WO", 0, 0}, {29, 33, 152, 168, 430, 492, "WO", 0, 0}},
    ["sapphire spellspear"] = {{1301, 1439, 22800, 25200, 35810, 39590, "SP", 0, 0}, {1358, 1502, 24700, 27300, 38280, 42320, "SP", 0, 0}, {1415, 1565, 26600, 29400, 40750, 45050, "SP", 0, 0}, {1472, 1628, 28500, 31500, 43220, 47780, "SP", 0, 0}},
    ["sapphire stone wand"] = {{1786, 1974, 42750, 47250, 60610, 66990, "TC", 0, 0}, {1843, 2037, 45600, 50400, 64030, 70770, "TC", 0, 0}, {1900, 2100, 48450, 53550, 67450, 74550, "TC", 0, 0}, {1957, 2163, 51300, 56700, 70870, 78330, "TC", 0, 0}},
    ["sea king's greatstaff"] = {{161500, 178500, 14250000, 15750000, 15865000, 17535000, "AT", 0, 0}},
    ["sea king's trident"] = {{161500, 178500, 14250000, 15750000, 15865000, 17535000, "AT", 0, 0}},
    ["sea serpent wings"] = {{10450, 11550, 228000, 252000, 332500, 367500, "GH", 0, 0}},
    ["sea staff"] = {{114000, 126000, 5747500, 6352500, 6887500, 7612500, "AT", 0, 0}, {116850, 129150, 5975500, 6604500, 7144000, 7896000, "AT", 0, 0}, {120650, 133350, 6194000, 6846000, 7400500, 8179500, "AT", 0, 0}, {123500, 136500, 6412500, 7087500, 7647500, 8452500, "AT", 0, 0}},
    ["(glitched) seafarer's lost blade"] = {{5890, 6510, 15390, 17010, 74290, 82110, "GH", 0, 0}, {6460, 7140, 16245, 17955, 80845, 89355, "GH", 0, 0}, {7030, 7770, 17100, 18900, 87400, 96600, "GH", 0, 0}, {7600, 8400, 17955, 19845, 93955, 103845, "GH", 0, 0}},
["seafarer's lost blade"] = {{5890, 6510, 153900, 170100, 212800, 235200, "GH", 0, 0}, {6460, 7140, 162450, 179550, 227050, 250950, "GH", 0, 0}, {7030, 7770, 171000, 189000, 241300, 266700, "GH", 0, 0}, {7600, 8400, 179550, 198450, 255550, 282450, "GH", 0, 0}},
    ["seafarer's magic device"] = {{7695, 8505, 180500, 199500, 257450, 284550, "GH", 0, 0}, {8265, 9135, 189050, 208950, 271700, 300300, "GH", 0, 0}, {8835, 9765, 197600, 218400, 285950, 316050, "GH", 0, 0}, {9405, 10395, 206150, 227850, 300200, 331800, "GH", 0, 0}},
    ["serpent pike"] = {{134900, 149100, 8816000, 9744000, 10165000, 11235000, "AT", 0, 0}, {136800, 151200, 9196000, 10164000, 10564000, 11676000, "AT", 0, 0}, {138700, 153300, 9576000, 10584000, 10963000, 12117000, "AT", 0, 0}, {140600, 155400, 9975000, 11025000, 11381000, 12579000, "AT", 0, 0}},
    ["serpent scimitars"] = {{114000, 126000, 5747500, 6352500, 6887500, 7612500, "AT", 0, 0}, {116850, 129150, 5975500, 6604500, 7144000, 7896000, "AT", 0, 0}, {120650, 133350, 6194000, 6846000, 7400500, 8179500, "AT", 0, 0}, {123500, 136500, 6412500, 7087500, 7647500, 8452500, "AT", 0, 0}},
    ["sharktooth blade"] = {{5130, 5670, 140600, 155400, 191900, 212100, "GH", 0, 0}, {5557, 6143, 148200, 163800, 203770, 225230, "GH", 0, 0}, {5985, 6615, 155800, 172200, 215650, 238350, "GH", 0, 0}, {6412, 7088, 163400, 180600, 227520, 251480, "GH", 0, 0}},
    ["shattered magma blade"] = {{101650, 112350, 4465000, 4935000, 5481500, 6058500, "VC", 0, 0}, {104025, 114975, 4655000, 5145000, 5695250, 6294750, "VC", 0, 0}, {106400, 117600, 4845000, 5355000, 5909000, 6531000, "VC", 0, 0}, {108300, 119700, 5035000, 5565000, 6118000, 6762000, "VC", 0, 0}},
    ["snow elemental staff"] = {{72, 80, 427, 473, 1147, 1273, "WO", 0, 0}, {76, 84, 465, 515, 1225, 1355, "WO", 0, 0}, {79, 89, 503, 557, 1293, 1447, "WO", 0, 0}, {83, 93, 541, 599, 1371, 1529, "WO", 0, 0}},
    ["snowy greatstaff"] = {{24, 28, 135, 151, 354, 418, "WO", 0, 0}, {27, 31, 150, 166, 407, 470, "WO", 0, 0}, {30, 34, 158, 176, 448, 512, "WO", 0, 0}, {33, 37, 169, 187, 493, 555, "WO", 0, 0}},
    ["solar essence staff"] = {{60800, 67200, 2090000, 2310000, 2698000, 2982000, "OO", 0, 0}, {62700, 69300, 2251500, 2488500, 2878500, 3181500, "OO", 0, 0}, {64600, 71400, 2413000, 2667000, 3059000, 3381000, "OO", 0, 0}, {66500, 73500, 2565000, 2835000, 3230000, 3570000, "OO", 0, 0}},
    ["solar greatsword"] = {{60800, 67200, 2090000, 2310000, 2698000, 2982000, "OO", 0, 0}, {62700, 69300, 2251500, 2488500, 2878500, 3181500, "OO", 0, 0}, {64600, 71400, 2413000, 2667000, 3059000, 3381000, "OO", 0, 0}, {66500, 73500, 2565000, 2835000, 3230000, 3570000, "OO", 0, 0}},
    ["solar katana"] = {{54150, 59850, 1520000, 1680000, 2061500, 2278500, "OO", 0, 0}, {55100, 60900, 1586500, 1753500, 2137500, 2362500, "OO", 0, 0}, {56050, 61950, 1653000, 1827000, 2213500, 2446500, "OO", 0, 0}, {57000, 63000, 1710000, 1890000, 2280000, 2520000, "OO", 0, 0}},
    ["solar staff"] = {{175, 195, 1472, 1628, 3222, 3578, "PI", 0, 0}, {185, 205, 1577, 1743, 3427, 3793, "PI", 0, 0}, {194, 216, 1681, 1859, 3621, 4019, "PI", 0, 0}, {204, 226, 1786, 1974, 3826, 4234, "PI", 0, 0}},
    ["soulstealer greatsword"] = {{332, 368, 3277, 3623, 6597, 7303, "PI", 0, 0}},
    ["space"] = {{11400, 12600, 90250, 99750, 204250, 225750, "OO", 1995000, 2205000}, {12255, 13545, 104500, 115500, 227050, 250950, "OO", 2204000, 2436000}, {13110, 14490, 118750, 131250, 249850, 276150, "OO", 2413000, 2667000}, {13965, 15435, 133000, 147000, 272650, 301350, "OO", 2612500, 2887500}},
    ["space guardian"] = {{11400, 12600, 2850000, 3150000, 2964000, 3276000, "OO", 0, 0}, {12255, 13545, 3230000, 3570000, 3352550, 3705450, "OO", 0, 0}, {13110, 14490, 3610000, 3990000, 3741100, 4134900, "OO", 0, 0}, {13965, 15435, 3990000, 4410000, 4129650, 4564350, "OO", 0, 0}},
    ["spiked club"] = {{2, 4, 12, 14, 14, 18, "DT", 0, 0}, {3, 5, 13, 15, 16, 20, "DT", 0, 0}, {4, 6, 15, 17, 19, 23, "DT", 0, 0}, {5, 7, 18, 20, 23, 27, "DT", 0, 0}},
    ["staff of heat"] = {{1140, 1260, 18525, 20475, 29925, 33075, "SP", 0, 0}, {1178, 1302, 19475, 21525, 31255, 34545, "SP", 0, 0}, {1216, 1344, 20425, 22575, 32585, 36015, "SP", 0, 0}, {1254, 1386, 21375, 23625, 33915, 37485, "SP", 0, 0}},
    ["staff of the gods"] = {{332, 368, 3277, 3623, 6597, 7303, "PI", 0, 0}},
    ["staff of the north"] = {{361000, 399000, 51680000, 57120000, 55290000, 61110000, "NL", 0, 0}, {367650, 406350, 53485000, 59115000, 57161500, 63178500, "NL", 0, 0}, {374300, 413700, 55290000, 61110000, 59033000, 65247000, "NL", 0, 0}, {380000, 420000, 57000000, 63000000, 60800000, 67200000, "NL", 0, 0}},
    ["steel serrated sword"] = {{4, 6, 19, 23, 23, 29, "DT", 0, 0}, {5, 7, 22, 26, 27, 33, "DT", 0, 0}, {6, 8, 27, 31, 33, 39, "DT", 0, 0}, {7, 9, 32, 36, 39, 50, "DT", 0, 0}},
    ["steel strongsword"] = {{16, 18, 95, 105, 195, 238, "WO", 0, 0}, {19, 21, 104, 116, 245, 290, "WO", 0, 0}, {20, 24, 114, 128, 275, 343, "WO", 0, 0}, {22, 26, 123, 137, 314, 377, "WO", 0, 0}},
    ["stone scythe"] = {{1786, 1974, 42750, 47250, 60610, 66990, "TC", 0, 0}, {1843, 2037, 45600, 50400, 64030, 70770, "TC", 0, 0}, {1900, 2100, 48450, 53550, 67450, 74550, "TC", 0, 0}, {1957, 2163, 51300, 56700, 70870, 78330, "TC", 0, 0}},
    ["stone strongsword"] = {{117, 131, 883, 977, 2053, 2287, "PI", 0, 0}, {123, 137, 931, 1029, 2161, 2399, "PI", 0, 0}, {129, 143, 978, 1082, 2268, 2512, "PI", 0, 0}, {134, 150, 1026, 1134, 2366, 2634, "Pi", 0, 0}},
    ["sunight staff"] = {{484, 536, 5510, 6090, 10350, 11450, "KC", 0, 0}, {508, 562, 5985, 6615, 11065, 12235, "KC", 0, 0}, {527, 583, 6460, 7140, 11730, 12970, "KC", 0, 0}, {546, 604, 6935, 7665, 12395, 13705, "KC", 0, 0}},
    ["tenplar blade"] = {{164, 182, 1330, 1470, 2970, 3290, "PI", 0, 0}, {170, 188, 1415, 1565, 3115, 3445, "PI", 0, 0}, {176, 196, 1501, 1659, 3261, 3619, "PI", 0, 0}, {182, 202, 1586, 1754, 3406, 3774, "PI", 0, 0}},
    ["timelost"] = {{342, 378, 1140, 1260, 4560, 5040, "UW", 9025, 9975}, {361, 399, 1235, 1365, 4845, 5355, "UW", 9975, 11025}, {380, 420, 1330, 1470, 5130, 5670, "UW", 10925, 12075}, {399, 441, 1425, 1575, 5415, 5985, "UW", 11875, 13125}},
    ["timelost greatsword"] = {{1007, 1113, 16625, 18375, 26695, 29505, "UW", 0, 0}, {1035, 1145, 17100, 18900, 27450, 30350, "UW", 0, 0}, {1064, 1176, 17575, 19425, 28215, 31185, "UW", 0, 0}, {1092, 1208, 18050, 19950, 28970, 32030, "UW", 0, 0}},
    ["timelost guardian"] = {{342, 378, 19000, 21000, 22420, 24780, "UW", 0, 0}, {361, 399, 21375, 23625, 24985, 27615, "UW", 0, 0}, {380, 420, 23750, 26250, 27550, 30450, "UW", 0, 0}, {399, 441, 26125, 28875, 30115, 33285, "UW", 0, 0}},
    ["timelost spellblade"] = {{969, 1071, 15960, 17640, 25650, 28350, "UW", 0, 0}, {997, 1103, 16435, 18165, 26405, 29195, "UW", 0, 0}, {1026, 1134, 16910, 18690, 27170, 30030, "UW", 0, 0}, {1054, 1166, 17385, 19215, 27925, 30875, "UW", 0, 0}},
    ["timelost warhammer"] = {{1054, 1166, 17385, 19215, 27925, 30875, "UW", 0, 0}, {1083, 1197, 17955, 19845, 28785, 31815, "UW", 0, 0}, {1111, 1229, 18525, 20475, 29635, 32765, "UW", 0, 0}, {1140, 1260, 19095, 21105, 30495, 33705, "UW", 0, 0}},
    ["titan's greataxe"] = {{212, 236, 1995, 2205, 4115, 4565, "PI", 0, 0}, {224, 248, 2147, 2373, 4387, 4853, "PI", 0, 0}, {235, 261, 2299, 2541, 4649, 5151, "PI", 0, 0}, {247, 273, 2451, 2709, 4921, 5439, "PI", 0, 0}},
    ["titan-forged"] = {{209, 231, 427, 473, 2517, 2783, "KC", 4275, 4725}, {232, 258, 503, 557, 2823, 3137, "KC", 4560, 5040}, {256, 284, 579, 641, 3139, 3481, "KC", 4940, 5460}, {285, 315, 655, 725, 3505, 3875, "KC", 5320, 5880}},
    ["titan-forged guardian"] = {{209, 231, 10355, 11445, 12445, 13755, "KC", 0, 0}, {232, 258, 11685, 12915, 14005, 15495, "KC", 0, 0}, {256, 284, 13300, 14700, 15860, 17540, "KC", 0, 0}, {285, 315, 15200, 16800, 18050, 19950, "KC", 0, 0}},
    ["titanium"] = {{2850, 3150, 19000, 21000, 47500, 52500, "SS", 228000, 252000}, {2968, 3282, 20900, 23100, 50580, 55920, "SS", 251750, 278250}, {3087, 3413, 22800, 25200, 53670, 59330, "SS", 275500, 304500}, {3230, 3570, 24700, 27300, 57000, 63000, "SS", 297350, 328650}},
    ["titanium guardian"] = {{2850, 3150, 361000, 399000, 389500, 430500, "SS", 0, 0}, {2968, 3282, 389500, 430500, 419180, 463320, "SS", 0, 0}, {3087, 3413, 418000, 462000, 448870, 496130, "SS", 0, 0}, {3230, 3570, 446500, 493500, 478800, 529200, "SS", 0, 0}},
    ["toxic spellscythe"] = {{2128, 2352, 59850, 66150, 81130, 89670, "TC", 0, 0}, {2213, 2447, 63650, 70350, 85780, 94820, "TC", 0, 0}, {2299, 2541, 67450, 74550, 90440, 99960, "TC", 0, 0}, {2384, 2636, 71250, 78750, 95090, 105110, "TC", 0, 0}},
    ["toxic warspear"] = {{1653, 1827, 36100, 39900, 52630, 58170, "SP", 0, 0}, {1710, 1890, 38950, 43050, 56050, 61950, "SP", 0, 0}, {1767, 1953, 41800, 46200, 59470, 65730, "SP", 0, 0}, {1824, 2016, 44650, 49350, 62890, 69510, "SP", 0, 0}},
    ["tribal"] = {{270, 300, 855, 945, 3555, 3945, "UW", 6460, 7140}, {294, 326, 950, 1050, 3890, 4310, "UW", 7315, 8085}, {318, 352, 1045, 1155, 4225, 4675, "UW", 8170, 9030}, {332, 368, 1140, 1260, 4460, 4940, "UW", 9025, 9975}},
    ["tribal staff"] = {{232, 258, 2299, 2541, 4619, 5121, "KC", 0, 0}, {247, 275, 2489, 2751, 4959, 5501, "KC", 0, 0}, {263, 291, 2679, 2961, 5309, 5871, "KC", 0, 0}, {280, 310, 2869, 3171, 5669, 6271, "KC", 0, 0}},
    ["triton"] = {{42750, 47250, 997500, 1102500, 1425000, 1575000, "AT", 21470000, 23730000}, {44175, 48825, 1069700, 1182300, 1511450, 1670550, "AT", 23370000, 25830000}, {45600, 50400, 1142850, 1263150, 1598850, 1767150, "AT", 24700000, 27300000}, {47025, 51975, 1216000, 1344000, 1686250, 1863750, "AT", 27170000, 30030000}},
    ["triton guardian"] = {{42750, 47250, 32205000, 35595000, 32632500, 36067500, "AT", 0, 0}, {44175, 48825, 35055000, 38745000, 35496750, 39233250, "AT", 0, 0}, {45600, 50400, 37905000, 41895000, 38361000, 42399000, "AT", 0, 0}, {47025, 51975, 40755000, 45045000, 41225250, 45564750, "AT", 0, 0}},
    ["twin blade slicer"] = {{53, 59, 275, 305, 805, 895, "WO", 0, 0}, {55, 61, 294, 326, 844, 936, "WO", 0, 0}, {57, 63, 313, 347, 883, 977, "WO", 0, 0}, {58, 66, 332, 368, 912, 1028, "WO", 0, 0}},
    ["valhalla"] = {{123500, 136500, 4560000, 5040000, 5795000, 6405000, "NL", 121600000, 134400000}, {126350, 139650, 4873500, 5386500, 6137000, 6783000, "NL", 132050000, 145950000}, {130150, 143850, 5187000, 5733000, 6488500, 7171500, "NL", 142500000, 157500000}, {133000, 147000, 5510000, 6090000, 6840000, 7560000, "NL", 152950000, 169050000}},
    ["valhalla guardian"] = {{123500, 136500, 194560000, 215040000, 195795000, 216405000, "NL", 0, 0}, {126350, 139650, 211280000, 233520000, 212543500, 234916500, "NL", 0, 0}, {130150, 143850, 228000000, 252000000, 229301500, 253438500, "NL", 0, 0}, {133000, 147000, 244720000, 270480000, 246050000, 271950000, "NL", 0, 0}},
    ["vampiric greatstaff"] = {{1054, 1166, 17385, 19215, 27925, 30875, "UW", 0, 0}, {1083, 1197, 17955, 19845, 28785, 31815, "UW", 0, 0}, {1111, 1229, 18525, 20475, 29635, 32765, "UW", 0, 0}, {1140, 1260, 19095, 21105, 30495, 33705, "UW", 0, 0}},
    ["viking hatchets"] = {{304000, 336000, 36290000, 40110000, 39330000, 43470000, "NL", 0, 0}, {310650, 343350, 37810000, 41790000, 40916500, 45223500, "NL", 0, 0}, {317300, 350700, 39330000, 43470000, 42503000, 46977000, "NL", 0, 0}, {323000, 357000, 40850000, 45150000, 44080000, 48720000, "NL", 0, 0}},
    ["viking sceptre"] = {{323000, 357000, 40850000, 45150000, 44080000, 48720000, "NL", 0, 0}, {329650, 364350, 42655000, 47145000, 45951500, 50788500, "NL", 0, 0}, {336300, 371700, 44460000, 49140000, 47823000, 52857000, "NL", 0, 0}, {342000, 378000, 46265000, 51135000, 49685000, 54915000, "NL", 0, 0}},
    ["viking shield"] = {{285000, 315000, 31635000, 34965000, 34485000, 38115000, "NL", 0, 0}, {291650, 322350, 33155000, 36645000, 36071500, 39868500, "NL", 0, 0}, {298300, 329700, 34675000, 38325000, 37658000, 41622000, "NL", 0, 0}, {304000, 336000, 36290000, 40110000, 39330000, 43470000, "NL", 0, 0}},
    ["violet spellblade"] = {{1358, 1502, 24700, 27300, 38280, 42320, "SP", 0, 0}, {1415, 1565, 26600, 29400, 40750, 45050, "SP", 0, 0}, {1472, 1628, 28500, 31500, 43220, 47780, "SP", 0, 0}, {1529, 1691, 30400, 33600, 45690, 50510, "SP", 0, 0}},
    ["void greatsword"] = {{57950, 64050, 1852500, 2047500, 2432000, 2688000, "OO", 0, 0}, {59850, 66150, 1995000, 2205000, 2593500, 2866500, "OO", 0, 0}, {61750, 68250, 2137500, 2362500, 2755000, 3045000, "OO", 0, 0}, {63650, 70350, 2280000, 2520000, 2916500, 3223500, "OO", 0, 0}},
    ["void plate"] = {{70, 78, 3800, 4200, 4500, 4980, "PI", 0, 0}, {80, 90, 4275, 4725, 5075, 5625, "PI", 0, 0}, {91, 101, 4750, 5250, 5660, 6260, "PI", 0, 0}, {101, 113, 5225, 5775, 6235, 6905, "PI", 0, 0}},
    ["void spell blade"] = {{54150, 59850, 1520000, 1680000, 2061500, 2278500, "OO", 0, 0}, {55100, 60900, 1586500, 1753500, 2137500, 2362500, "OO", 0, 0}, {56050, 61950, 1653000, 1827000, 2213500, 2446500, "OO", 0, 0}, {57000, 63000, 1710000, 1890000, 2280000, 2520000, "OO", 0, 0}},
    ["void spelldaggers"] = {{51300, 56700, 1330000, 1470000, 1843000, 2037000, "OO", 0, 0}, {52250, 57750, 1396500, 1543500, 1919000, 2121000, "OO", 0, 0}, {53200, 58800, 1463000, 1617000, 1995000, 2205000, "OO", 0, 0}, {54150, 59850, 1529500, 1690500, 2071000, 2289000, "OO", 0, 0}},
    ["volcanic greatsword"] = {{108300, 119700, 5035000, 5565000, 6118000, 6762000, "VC", 0, 0}, {110675, 122325, 5225000, 5775000, 6331750, 6998250, "VC", 0, 0}, {112100, 123900, 5415000, 5985000, 6536000, 7224000, "VC", 0, 0}, {114000, 126000, 5747500, 6352500, 6887500, 7612500, "VC", 0, 0}},
    ["war-forged"] = {{4370, 4830, 28500, 31500, 72200, 79800, "SS", 418000, 462000}, {4465, 4935, 32300, 35700, 76950, 85050, "SS", 456000, 504000}, {4560, 5040, 36100, 39900, 81700, 90300, "SS", 494000, 546000}, {4655, 5145, 38950, 43050, 85500, 94500, "SS", 541500, 598500}},
    ["war-forged guardian"] = {{4370, 4830, 589000, 651000, 632700, 699300, "SS", 0, 0}, {4465, 4935, 646000, 714000, 690650, 763350, "SS", 0, 0}, {4560, 5040, 703000, 777000, 748600, 827400, "SS", 0, 0}, {4655, 5145, 769500, 850500, 816050, 901950, "SS", 0, 0}},
    ["water spellblade"] = {{51, 57, 261, 289, 771, 859, "WO", 0, 0}, {55, 61, 289, 321, 839, 931, "WO", 0, 0}, {58, 66, 318, 352, 898, 1012, "WO", 0, 0}, {62, 70, 346, 384, 966, 1084, "WO", 0, 0}},
}

local DUNGEON_FULL_NAMES = {
    DT = "Desert Temple",
    WO = "Winter Outpost",
    PI = "Pirate Island",
    KC = "King's Castle",
    UW = "The Underworld",
    SP = "Samurai Palace",
    TC = "The Canals",
    GH = "Ghastly Harbor",
    SS = "Steampunk Sewers",
    OO = "Orbital Outpost",
    VC = "Volcanic Chambers",
    NL = "Northern Lands",
    EF = "Enchanted Forest",
    GS = "Gilded Skies",
    AT = "Aquamaris Temple",
}

local ARMOR_SUFFIXES = {
    " guardian helmet", " guardian hat", " guardian hood", " guardian mask", " guardian crown", " guardian helm",
    " guardian armor", " guardian chestplate", " guardian chest", " guardian plate", " guardian robe",
    " mage helmet", " mage hat", " mage hood", " mage cap", " mage robe", " mage tunic", " mage armor",
    " warrior helmet", " warrior helm", " warrior armor", " warrior chestplate", " warrior plate",
    " helmet", " hat", " hood", " cap", " mask", " crown", " helm",
    " armor", " chestplate", " chest", " robe", " robes", " tunic", " plate", " set"
}

local SPECIAL_ARMOR_MAPPINGS = {
    ["novice"] = "novice | blue wizard",
    ["blue wizard"] = "novice | blue wizard",
    ["mercenary"] = "mercenary/elemental",
    ["elemental"] = "mercenary/elemental",
    ["elementalist"] = "mercenary/elemental",
    ["red knight"] = "red knight/templar",
    ["templar"] = "red knight/templar",
    ["crusader"] = "crusader's",
    ["iron"] = "iron armor",
    ["warlord plate"] = "plate",
    ["mage plate"] = "plate",
    ["elite warlord plate"] = "elite (warlord/mage) plate",
    ["elite mage plate"] = "elite (warlord/mage) plate",
    ["angelic plate"] = "angelic/infernal",
    ["inferno plate"] = "angelic/infernal",
    ["beastly"] = "beastly / arch-mage",
    ["arch-mage"] = "beastly / arch-mage",
    ["arch mage"] = "beastly / arch-mage",
    ["rogue"] = "rouge",
    ["rogue guardian"] = "rouge guardian",
    ["commander"] = "commanders",
    ["commander guardian"] = "commanders guardian",
    ["commander's"] = "commanders",
    ["commander's guardian"] = "commanders guardian",
    ["crystalline guardian"] = "crystalline guadian",
}

local function resolveItemDbName(rawName, itemType)
    if not rawName then return nil end
    local raw = string.lower(string.gsub(string.gsub(tostring(rawName), "^%s+", ""), "%s+$", ""))
    if GODPOT_DATABASE[raw] then
        return raw
    end

    if string.find(raw, "overlord", 1, true) and string.find(raw, "guardian", 1, true) then
        if string.find(raw, "hat", 1, true) or string.find(raw, "helmet", 1, true) or string.find(raw, "hood", 1, true) or itemType == "helmet" then
            if GODPOT_DATABASE["overlord's guardian (hat)"] then
                return "overlord's guardian (hat)"
            end
        end
        if string.find(raw, "chest", 1, true) or string.find(raw, "armor", 1, true) or string.find(raw, "plate", 1, true) or itemType == "chest" or itemType == "armor" then
            if GODPOT_DATABASE["overlord's guardian (chest)"] then
                return "overlord's guardian (chest)"
            end
        end
    end

    local isGuardian = string.find(raw, "guardian", 1, true) ~= nil

    for _, suffix in ipairs(ARMOR_SUFFIXES) do
        if string.sub(raw, -#suffix) == suffix then
            local cand = string.sub(raw, 1, -#suffix - 1)
            cand = string.gsub(string.gsub(cand, "^%s+", ""), "%s+$", "")
            
            if isGuardian then
                local gcand = (string.sub(cand, -8) == "guardian") and cand or (cand .. " guardian")
                if GODPOT_DATABASE[gcand] then
                    return gcand
                end
                if SPECIAL_ARMOR_MAPPINGS[gcand] and GODPOT_DATABASE[SPECIAL_ARMOR_MAPPINGS[gcand]] then
                    return SPECIAL_ARMOR_MAPPINGS[gcand]
                end
            end
            
            if GODPOT_DATABASE[cand] then
                return cand
            end
            if SPECIAL_ARMOR_MAPPINGS[cand] and GODPOT_DATABASE[SPECIAL_ARMOR_MAPPINGS[cand]] then
                return SPECIAL_ARMOR_MAPPINGS[cand]
            end
            
            if isGuardian then
                local baseMapped = SPECIAL_ARMOR_MAPPINGS[cand] or cand
                local mg = baseMapped .. " guardian"
                if GODPOT_DATABASE[mg] then
                    return mg
                end
                if SPECIAL_ARMOR_MAPPINGS[mg] and GODPOT_DATABASE[SPECIAL_ARMOR_MAPPINGS[mg]] then
                    return SPECIAL_ARMOR_MAPPINGS[mg]
                end
            end
        end
    end

    for k in pairs(GODPOT_DATABASE) do
        if #k >= 5 and string.find(raw, k, 1, true) then
            return k
        end
    end

    return nil
end

local function getGodpotRollInfo(name, potential, currentStat, maxUpgrades, currentUpgrade, itemType)
    if not name or not potential or potential <= 0 then
        return nil
    end
    local resolvedKey = resolveItemDbName(name, itemType)
    if not resolvedKey then
        return nil
    end
    local tiers = GODPOT_DATABASE[resolvedKey]
    if not tiers or #tiers == 0 then
        return nil
    end

    local numTiers = #tiers
    local globalMaxPot = 0
    local globalMinPot = math.huge
    for _, t in ipairs(tiers) do
        if t[6] > globalMaxPot then globalMaxPot = t[6] end
        if t[5] < globalMinPot then globalMinPot = t[5] end
    end

    local bestIdx = 1
    if numTiers == 1 then
        bestIdx = 1
    else
        local bestScore = math.huge
        for i, t in ipairs(tiers) do
            local minUps, maxUps, minBase, maxBase, minPot, maxPot, dung, lowHp, highHp = t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9]
            local potDist = 0
            if potential >= minPot and potential <= maxPot then
                potDist = 0
            elseif potential < minPot then
                potDist = minPot - potential
            else
                potDist = potential - maxPot
            end

            local upsDist = 0
            if maxUpgrades and maxUpgrades > 0 and maxUps > 0 then
                if maxUpgrades >= minUps and maxUpgrades <= maxUps then
                    upsDist = 0
                elseif maxUpgrades < minUps then
                    upsDist = (minUps - maxUpgrades) * (maxPot / math.max(1, maxUps))
                else
                    upsDist = (maxUpgrades - maxUps) * (maxPot / math.max(1, maxUps))
                end
            end

            local score = potDist + upsDist * 2.5
            if score < bestScore then
                bestScore = score
                bestIdx = i
            end
        end
    end

    local chosen = tiers[bestIdx]
    local minUps, maxUps, minBase, maxBase, minPot, maxPot, dungCode = chosen[1], chosen[2], chosen[3], chosen[4], chosen[5], chosen[6], chosen[7]
    local span = math.max(1, maxPot - minPot)
    local rawPct = ((potential - minPot) / span) * 100
    local rollPct = math.clamp(math.floor(rawPct * 10 + 0.5) / 10, 0, 100)

    local isGlobalGodpot = potential >= globalMaxPot
    local isTierGodpot = potential >= maxPot or rollPct >= 99.0
    local isGodpot = isGlobalGodpot or isTierGodpot

    local grade
    if isGodpot then
        grade = "GODPOT"
    elseif rollPct >= 90.0 then
        grade = "S"
    elseif rollPct >= 75.0 then
        grade = "A"
    elseif rollPct >= 50.0 then
        grade = "B"
    else
        grade = "C"
    end

    return {
        Tier = bestIdx,
        TotalTiers = numTiers,
        MinPot = minPot,
        MaxPot = maxPot,
        GlobalMaxPot = globalMaxPot,
        GlobalMinPot = globalMinPot,
        RollPct = rollPct,
        RollGrade = grade,
        IsGodpot = isGodpot,
        IsGlobalGodpot = isGlobalGodpot,
        DungeonCode = dungCode,
        DungeonName = DUNGEON_FULL_NAMES[dungCode] or dungCode,
    }
end


local UPGRADE_COST = {}
local UPGRADE_PREFIX = {[0] = 0}

do
    local runningCost = 100
    local runningTotal = 0

    for index = 0, 466 do
        local cost

        if index == 0 then
            cost = 100
        else
            local nextCost = runningCost * 1.06 + 50

            if nextCost - runningCost > 220 then
                runningCost += 220
            else
                runningCost = nextCost
            end

            cost = math.floor(math.min(runningCost, 100000))
        end

        UPGRADE_COST[index] = cost
        runningTotal += cost
        UPGRADE_PREFIX[index + 1] = runningTotal
    end
end

local function calculateUpgradeCost(upgradeIndex)
    upgradeIndex = nonNegativeInteger(upgradeIndex)

    if upgradeIndex > 466 then
        return 100000
    end

    return UPGRADE_COST[upgradeIndex] or 100
end

local function totalUpgradeCost(item)
    if type(item) ~= "table" then
        return 0
    end

    local current, maximum = upgradeBounds(item)

    if maximum <= current then
        return 0
    end

    local total = 0

    
    local formulaStopExclusive = math.min(maximum, 467)

    if current < formulaStopExclusive then
        total +=
            (UPGRADE_PREFIX[formulaStopExclusive] or 0)
            - (UPGRADE_PREFIX[current] or 0)
    end

    
    local cappedStart = math.max(current, 467)

    if maximum > cappedStart then
        total += (maximum - cappedStart) * 100000
    end

    return total
end



local function upgradeCostForCount(item, count)
    if type(item) ~= "table" then
        return 0
    end

    local current, maximum = upgradeBounds(item)

    local remaining = math.max(0, maximum - current)
    count = math.min(nonNegativeInteger(count), remaining)

    if count <= 0 then
        return 0
    end

    local stopExclusive = current + count
    local total = 0

    local formulaStart = math.min(current, 467)
    local formulaStop = math.min(stopExclusive, 467)

    if formulaStart < formulaStop then
        total +=
            (UPGRADE_PREFIX[formulaStop] or 0)
            - (UPGRADE_PREFIX[formulaStart] or 0)
    end

    local cappedStart = math.max(current, 467)

    if stopExclusive > cappedStart then
        total += (stopExclusive - cappedStart) * 100000
    end

    return total
end



local function maxAffordableUpgradeCount(item, goldBudget)
    if type(item) ~= "table" then
        return 0, 0
    end

    goldBudget = nonNegativeInteger(goldBudget)

    local remaining = remainingUpgrades(item)
    if remaining <= 0 or goldBudget <= 0 then
        return 0, 0
    end

    
    local fullCost = upgradeCostForCount(item, remaining)
    if fullCost <= goldBudget then
        return remaining, fullCost
    end

    
    local firstCost = upgradeCostForCount(item, 1)
    if firstCost > goldBudget then
        return 0, 0
    end

    local lo = 1
    local hi = remaining
    local best = 1

    while lo <= hi do
        local mid = math.floor((lo + hi) / 2)
        local cost = upgradeCostForCount(item, mid)

        if cost <= goldBudget then
            best = mid
            lo = mid + 1
        else
            hi = mid - 1
        end
    end

    return best, upgradeCostForCount(item, best)
end




local function allocateUpgradeBudget(entries, goldBudget)
    local budget = nonNegativeInteger(goldBudget)
    local states = {}
    local fullMaxCost = 0
    local totalRemaining = 0

    for order, entry in ipairs(entries) do
        local current, actualMaximum = upgradeBounds(entry.Item)
        local allowedMaximum = math.min(
            actualMaximum,
            nonNegativeInteger(entry.MaxAllowedUpgrade, actualMaximum)
        )
        local value = tonumber(entry.Item and entry.Item[entry.Field])

        if value and value == value and math.abs(value) ~= math.huge
            and allowedMaximum > current
        then
            local state = {
                Entry = entry,
                Order = order,
                Current = current,
                StartCurrent = current,
                ActualMaximum = actualMaximum,
                Maximum = allowedMaximum,
                Value = value,
                StartValue = value,
                Amount = 0,
                Cost = 0,
                Gain = 0,
            }
            states[#states + 1] = state

            local allowedCount = allowedMaximum - current
            fullMaxCost += upgradeCostForCount(entry.Item, allowedCount)
            totalRemaining += allowedCount
        end
    end

    local firstSelections = {}
    while budget > 0 do
        local best
        local bestGain, bestCost
        local affordableChoices = 0

        for _, state in ipairs(states) do
            if state.Current < state.Maximum then
                local cost = calculateUpgradeCost(state.Current)
                local gain = gainPerUpgrade(state.Value)

                if cost <= budget then
                    affordableChoices += 1
                    local better = not best

                    if best then
                        local left = gain * bestCost
                        local right = bestGain * cost
                        better = left > right
                            or (left == right and cost < bestCost)
                            or (
                                left == right
                                and cost == bestCost
                                and state.Order < best.Order
                            )
                    end

                    if better then
                        best, bestGain, bestCost = state, gain, cost
                    end
                end
            end
        end

        if not best then
            break
        end

        local virtualItem = {
            currentUpgrade = best.Current,
            maxUpgrades = best.Maximum,
        }

        local amount = 1
        if affordableChoices == 1 then
            amount = maxAffordableUpgradeCount(virtualItem, budget)
        elseif bestGain == 10 and bestCost == 100000 then
            amount = math.min(
                best.Maximum - best.Current,
                math.floor(budget / bestCost)
            )
        end

        if amount <= 0 then
            break
        end

        local cost = upgradeCostForCount(virtualItem, amount)
        local nextValue = potentialAfterUpgrades(best.Value, amount)

        if best.Amount == 0 then
            firstSelections[#firstSelections + 1] = best
        end

        best.Amount += amount
        best.Cost += cost
        best.Gain += nextValue - best.Value
        best.Value = nextValue
        best.Current += amount
        budget -= cost
    end

    local result = {
        Entries = {},
        GoldBudget = nonNegativeInteger(goldBudget),
        EstimatedSpend = 0,
        PlannedUpgrades = 0,
        PlannedGain = 0,
        FullMaxCost = fullMaxCost,
        TotalRemaining = totalRemaining,
        UnspentBudget = budget,
    }

    for _, state in ipairs(firstSelections) do
        local entry = state.Entry
        result.Entries[#result.Entries + 1] = {
            UID = entry.UID,
            ItemType = entry.ItemType,
            ItemNumber = entry.ItemNumber,
            Slot = entry.Slot,
            Name = entry.Name,
            Field = entry.Field,
            Stat = entry.Stat,

            CurrentUpgrade = state.StartCurrent,
            MaxUpgrades = state.ActualMaximum,
            TargetMaxUpgrades = state.Maximum,
            CurrentStat = state.StartValue,

            Amount = state.Amount,
            PlannedCost = state.Cost,
            PlannedGain = state.Gain,
        }
        result.EstimatedSpend += state.Cost
        result.PlannedUpgrades += state.Amount
        result.PlannedGain += state.Gain
    end

    return result
end

local RARITY_RANK = {
    common = 1,
    uncommon = 2,
    rare = 3,
    epic = 4,
    legendary = 5,
    mythic = 6,
    mythical = 6,
}

local function slotForType(itemType)
    if itemType == "armor" then
        return "chest"
    end

    if itemType == "weapon"
        or itemType == "chest"
        or itemType == "helmet"
        or itemType == "pet"
        or itemType == "ring"
    then
        return itemType
    end

    return nil
end





local function itemNumberFromKey(itemType, key)
    local typeInfo = TYPE_INFO[itemType]
    if not typeInfo then
        return nil
    end

    local number = tonumber(key)
    if not number and type(key) == "string" then
        number = tonumber(string.match(key, "^" .. typeInfo.prefix .. "(%d+)$"))
    end

    return number and nonNegativeInteger(number) or nil
end

local function currentPlayerLevel()
    local leaderstats = player:FindFirstChild("leaderstats")
    local level = leaderstats and leaderstats:FindFirstChild("Level")
    local value = level and level:IsA("ValueBase") and tonumber(level.Value) or nil
    if not value or value ~= value or math.abs(value) == math.huge then
        return 0
    end
    return nonNegativeInteger(value)
end

local function currentGoldValue()
    local leaderstats = player:FindFirstChild("leaderstats")
    local gold = leaderstats and leaderstats:FindFirstChild("Gold")
    local value = gold and gold:IsA("ValueBase") and tonumber(gold.Value) or nil
    if not value or value ~= value or math.abs(value) == math.huge then
        return nil
    end
    return nonNegativeInteger(value)
end

local function configuredSpendBudget(gold)
    gold = nonNegativeInteger(gold)
    local reserve = nonNegativeInteger(Persistent.Settings.GoldReserve)
    local available = math.max(0, gold - reserve)
    local cap = nonNegativeInteger(Persistent.Settings.SpendCap)
    if cap > 0 then
        available = math.min(available, cap)
    end
    return available
end

local function detectInventoryCapacity()
    local gui = Controller.CurrentGui
    local count = #(Controller.InventoryInfos or {})
    if gui then
        local bestMax
        for _, obj in ipairs(gui:GetDescendants()) do
            if obj:IsA("TextLabel") then
                local a, b = tostring(obj.Text):match("^%s*([%d,]+)%s*/%s*([%d,]+)%s*$")
                if a and b then
                    local current = tonumber((a:gsub(",", "")))
                    local maximum = tonumber((b:gsub(",", "")))
                    if current and maximum and maximum >= count and maximum <= 2000 and current <= maximum then
                        if not bestMax or maximum < bestMax then bestMax = maximum end
                    end
                end
            end
        end
        if bestMax then Persistent.Settings.InventoryCapacity = bestMax end
    end
    return math.max(1, nonNegativeInteger(Persistent.Settings.InventoryCapacity, 300))
end

local function inventoryCapacityText()
    local count = #(Controller.InventoryInfos or {})
    local capacity = detectInventoryCapacity()
    local pct = count / math.max(1, capacity) * 100
    return count, capacity, pct
end

local function uidInAnyLoadout(uid)
    if not uid then
        return false
    end
    uid = tostring(uid)

    for _, preset in pairs(Persistent.Loadouts or {}) do
        if type(preset) == "table" then
            local slots = type(preset.Slots) == "table" and preset.Slots or preset
            for _, slot in ipairs({"weapon", "chest", "helmet"}) do
                if slots[slot] ~= nil and tostring(slots[slot]) == uid then
                    return true
                end
            end
        end
    end

    return false
end

local function slotUpgradeEnabled(slot)
    if slot == "weapon" then
        return Persistent.Settings.UpgradeWeapon ~= false
    elseif slot == "chest" then
        return Persistent.Settings.UpgradeChest ~= false
    elseif slot == "helmet" then
        return Persistent.Settings.UpgradeHelmet ~= false
    end
    return false
end

local function wishlistKey(name)
    return lower(name):gsub("^%s+", ""):gsub("%s+$", "")
end

local function isWishlistName(name)
    local key = wishlistKey(name)
    return key ~= "" and Persistent.Wishlist[key] ~= nil
end

local function keepCopiesForName(name)
    local key = wishlistKey(name)
    local specific = tonumber(Persistent.KeepRules[key])
    if specific then return math.clamp(math.floor(specific), 1, 20) end
    return math.max(1, math.floor(tonumber(Persistent.Settings.KeepCopies) or 1))
end

local function qolNotify(titleText, bodyText)
    if not Persistent.Settings.DropNotifications then return end
    pcall(function()
        StarterGui:SetCore("SendNotification", {
            Title = tostring(titleText or "Dungeon Quest QOL"),
            Text = tostring(bodyText or ""),
            Duration = 5,
        })
    end)
    local raw = tostring(Persistent.Settings.DropSoundId or "")
    local digits = raw:match("(%d+)")
    if digits then
        pcall(function()
            local sound = Instance.new("Sound")
            sound.SoundId = "rbxassetid://" .. digits
            sound.Volume = 0.8
            sound.Parent = SoundService
            sound:Play()
            game:GetService("Debris"):AddItem(sound, 8)
        end)
    end
end

local function protectionReasons(info)
    local reasons = {}
    if not info then return reasons end
    if info.IsEquipped then reasons[#reasons + 1] = "Equipped" end
    if info.UID and Persistent.Favorites[info.UID] then reasons[#reasons + 1] = "Favorite" end
    if info.UID and Persistent.Locked[info.UID] then reasons[#reasons + 1] = "Locked" end
    if info.IsLoadoutProtected then reasons[#reasons + 1] = "Loadout" end
    if info.IsWishlist then reasons[#reasons + 1] = "Wishlist" end
    if (Persistent.Settings.ProtectGodpot ~= false) and (info.IsGodpot or info.RollGrade == "GODPOT") then reasons[#reasons + 1] = "Godpot" end
    if Persistent.Settings.ProtectSRolls and (info.RollGrade == "S" or info.RollGrade == "GODPOT") then reasons[#reasons + 1] = "S Roll" end
    if Persistent.Settings.ProtectLegendary and (info.RarityRank or 0) >= (RARITY_RANK.legendary or 5) then reasons[#reasons + 1] = "Legendary+" end
    return reasons
end

local function isProtectedInfo(info)
    return #protectionReasons(info) > 0
end

local function breakEvenUpgradeInfo(info, targetValue)
    if not info or not info.Field or (info.RemainingUpgrades or 0) <= 0 then
        return nil, nil
    end
    local start = tonumber(info.Current) or 0
    targetValue = tonumber(targetValue) or 0
    if start > targetValue then
        return 0, 0
    end
    local lo, hi, best = 1, info.RemainingUpgrades, nil
    while lo <= hi do
        local mid = math.floor((lo + hi) / 2)
        local value = potentialAfterUpgrades(start, mid) or start
        if value > targetValue then
            best = mid
            hi = mid - 1
        else
            lo = mid + 1
        end
    end
    if not best then return nil, nil end
    return best, upgradeCostForCount(info.Item, best)
end





local function findEquippedBySlot()
    local equipped = {}

    if type(Controller.InventoryInfos) == "table" and #Controller.InventoryInfos > 0 then
        for _, info in ipairs(Controller.InventoryInfos) do
            local slot = slotForType(info.ItemType)
            if slot and info.IsEquipped then
                equipped[slot] = info.Item
            end
        end
        return equipped
    end

    iterateInventoryRecords(function(itemType, _, item)
        local slot = slotForType(itemType)
        if slot and isItemEquipped(item) then
            equipped[slot] = item
        end
    end)

    return equipped
end

local function copyMetricFields(target, source)
    
    local card = target.Card
    for key in pairs(target) do
        if key ~= "Card" then
            target[key] = nil
        end
    end
    for key, value in pairs(source) do
        if key ~= "Card" then
            target[key] = value
        end
    end
    target.Card = card or source.Card
end

local function rebuildMetrics()
    local existingByUID = {}
    for card, info in pairs(Controller.CardInfo) do
        if card and card.Parent and info then
            local uid = uidForItem(info.Item)
            if uid then
                existingByUID[uid] = info
            end
        end
    end

    local allInfos = {}
    local byUID = {}
    local groups = {}
    local junkGroups = {}
    local playerLevel = currentPlayerLevel()
    local gold = currentGoldValue() or 0
    local budget = configuredSpendBudget(gold)

    iterateInventoryRecords(function(itemType, key, item)
        local uid = uidForItem(item)
        local itemNumber = itemNumberFromKey(itemType, key)

        
        
        
        local info = uid and existingByUID[uid] or nil
        if not info then
            info = {}
        end

        info.ItemType = itemType
        info.ItemNumber = itemNumber
        info.Item = item
        info.UID = uid

        local className = classifyItem(item)
        local field = relevantField(item, className)

        info.Class = className
        info.Field = field
        info.Name = tostring(item.name or "Unknown")
        info.NameLower = lower(info.Name)
        info.Rarity = lower(item.rarity)
        info.RarityRank = RARITY_RANK[info.Rarity] or 0
        info.Level = tonumber(item.levelReq) or 0
        info.CurrentUpgrade, info.MaxUpgrades = upgradeBounds(item)
        info.RemainingUpgrades = remainingUpgrades(item)
        info.IsEquipped = isItemEquipped(item)
        info.IsEquipable = info.IsEquipped or info.Level <= playerLevel

        info.Current = field and tonumber(item[field]) or 0
        info.Potential = field and maxPotential(item, field) or 0
        info.Gain = math.max(0, (info.Potential or 0) - (info.Current or 0))
        info.SellValue = tonumber(item.sellPrice) or 0
        info.UpgradeCost = totalUpgradeCost(item)
        info.FinishGainPerGold =
            info.UpgradeCost > 0 and info.Gain / info.UpgradeCost or 0
        info.NextUpgradeCost = info.RemainingUpgrades > 0
            and calculateUpgradeCost(info.CurrentUpgrade) or 0
        info.NextUpgradeGain = field and info.RemainingUpgrades > 0
            and gainPerUpgrade(info.Current) or 0
        info.GainPerGold = info.NextUpgradeCost > 0
            and info.NextUpgradeGain / info.NextUpgradeCost or 0

        if info.MaxUpgrades > 0 then
            info.UpgradePct = clampNumber(
                (info.CurrentUpgrade / info.MaxUpgrades) * 100,
                0,
                100
            )
        else
            info.UpgradePct = 0
        end
        info.PotentialPct = info.UpgradePct

        local affordableCount = 0
        if field and info.RemainingUpgrades > 0 and budget > 0 then
            affordableCount = maxAffordableUpgradeCount(item, budget)
        end
        info.BudgetUpgradeCount = affordableCount
        info.BudgetPotential = field
            and (potentialAfterUpgrades(info.Current, affordableCount) or info.Current)
            or 0
        info.BudgetCost = affordableCount > 0
            and upgradeCostForCount(item, affordableCount)
            or 0

        info.IsBestLoadout = false
        info.IsBestNow = false
        info.IsBestPotential = false
        info.IsBestBudget = false
        info.DuplicateCount = 1
        info.DuplicateIndex = 1
        info.BestDuplicate = false

        local gp = getGodpotRollInfo(info.Name, info.Potential, info.Current, info.MaxUpgrades, info.CurrentUpgrade, info.ItemType)
        if gp then
            info.GodpotInfo = gp
            info.RollGrade = gp.RollGrade
            info.RollPct = gp.RollPct
            info.RollPercentile = gp.RollPct
            info.IsGodpot = gp.IsGodpot
            info.IsGlobalGodpot = gp.IsGlobalGodpot
        else
            info.GodpotInfo = nil
            info.RollGrade = nil
            info.RollPct = nil
            info.RollPercentile = nil
            info.IsGodpot = false
            info.IsGlobalGodpot = false
        end
        info.RollRank = nil
        info.RollRankCount = nil
        info.IsJunk = false
        info.IsLoadoutProtected = uid and uidInAnyLoadout(uid) or false
        info.IsWishlist = isWishlistName(info.Name)
        if uid and not Persistent.ItemFirstSeen[uid] then
            Persistent.ItemFirstSeen[uid] = os.time()
        end
        info.FirstSeen = uid and tonumber(Persistent.ItemFirstSeen[uid]) or 0
        info.Note = uid and tostring(Persistent.ItemNotes[uid] or "") or ""
        info.CustomTag = uid and tostring(Persistent.ItemTags[uid] or "") or ""
        if info.IsWishlist and uid and Persistent.Settings.WishlistAutoLock then
            Persistent.Locked[uid] = true
        end

        allInfos[#allInfos + 1] = info
        if uid then
            byUID[uid] = info
        end

        local groupKey =
            itemType .. "\0" .. info.NameLower .. "\0" .. info.Rarity
        groups[groupKey] = groups[groupKey] or {}
        groups[groupKey][#groups[groupKey] + 1] = info

        local junkKey = itemType .. "\0" .. info.NameLower
        junkGroups[junkKey] = junkGroups[junkKey] or {}
        junkGroups[junkKey][#junkGroups[junkKey] + 1] = info

        if uid and Persistent.SeededKnownIDs and not Persistent.KnownIDs[uid] then
            Persistent.KnownIDs[uid] = true
            Persistent.NewIDs[uid] = true
            scheduleDiskStateSave(0.45)
        end
    end)

    Controller.InventoryInfos = allInfos
    Controller.InventoryInfoByUID = byUID

    
    local equippedInfo = {}
    for _, info in ipairs(allInfos) do
        local slot = slotForType(info.ItemType)
        if slot and info.IsEquipped then
            equippedInfo[slot] = info
        end
    end

    for _, info in ipairs(allInfos) do
        local slot = slotForType(info.ItemType)
        local eqInfo = slot and equippedInfo[slot] or nil
        local equippedItem = eqInfo and eqInfo.Item or nil
        info.EquippedItem = equippedItem
        info.DiffCurrent = nil
        info.DiffPotential = nil
        info.BetterThanEquipped = false

        if equippedItem and info.Field then
            local eqCurrent = tonumber(equippedItem[info.Field]) or 0
            local eqPotential = maxPotential(equippedItem, info.Field) or eqCurrent
            info.DiffCurrent = (info.Current or 0) - eqCurrent
            info.DiffPotential = (info.Potential or 0) - eqPotential
            if not info.IsEquipped and (info.Potential or 0) > eqPotential then
                info.BetterThanEquipped = true
            end
            local base = math.max(1, math.abs(eqCurrent))
            info.CurrentChangePct = ((info.Current or 0) - eqCurrent) / base * 100
            info.PotentialChangePct = ((info.Potential or 0) - eqPotential) / math.max(1, math.abs(eqPotential)) * 100
            info.IsSidegrade = not info.IsEquipped and math.abs(info.CurrentChangePct or 0) < 0.5 and math.abs(info.PotentialChangePct or 0) < 0.5
            info.IsDowngradeNow = not info.IsEquipped and (info.Current or 0) < eqCurrent
            info.BreakEvenCount, info.BreakEvenCost = breakEvenUpgradeInfo(info, eqCurrent)
        end
        info.ProtectionReasons = protectionReasons(info)
        info.IsProtected = #info.ProtectionReasons > 0
    end

    for _, list in pairs(groups) do
        assignDuplicateGrades(list)
        local total = #list
        for index, info in ipairs(list) do
            if not info.RollPercentile then
                if total <= 1 then
                    info.RollPercentile = 100
                else
                    info.RollPercentile = math.floor(((total - index) / (total - 1)) * 100 + 0.5)
                end
            end
        end
    end

    local function betterForMode(candidate, currentBest, mode)
        if not currentBest then
            return true
        end

        local left
        local right
        if mode == "Now" then
            left, right = candidate.Current or 0, currentBest.Current or 0
        elseif mode == "Budget" then
            left, right = candidate.BudgetPotential or 0, currentBest.BudgetPotential or 0
        else
            left, right = candidate.Potential or 0, currentBest.Potential or 0
        end

        if left ~= right then
            return left > right
        end
        if (candidate.Current or 0) ~= (currentBest.Current or 0) then
            return (candidate.Current or 0) > (currentBest.Current or 0)
        end
        if (candidate.Potential or 0) ~= (currentBest.Potential or 0) then
            return (candidate.Potential or 0) > (currentBest.Potential or 0)
        end
        return (candidate.ItemNumber or math.huge) < (currentBest.ItemNumber or math.huge)
    end

    local bestByMode = {
        Now = {},
        Potential = {},
        Budget = {},
    }
    local bestOverallPotential = {}

    for _, info in ipairs(allInfos) do
        local slot = slotForType(info.ItemType)
        if slot == "weapon" or slot == "chest" or slot == "helmet" then
            local key = tostring(info.Class) .. ":" .. slot
            if info.IsEquipable then
                for _, mode in ipairs({"Now", "Potential", "Budget"}) do
                    local currentBest = bestByMode[mode][key]
                    if betterForMode(info, currentBest, mode) then
                        bestByMode[mode][key] = info
                    end
                end
            end
            local currOverall = bestOverallPotential[key]
            if not currOverall or (info.Potential or 0) > (currOverall.Potential or 0) then
                bestOverallPotential[key] = info
            end
        end
    end

    Controller.BestByMode = bestByMode
    local actionMode = Controller.BestMode ~= "Off" and Controller.BestMode or "Potential"
    Controller.BestByClassSlot = bestByMode[actionMode] or bestByMode.Potential

    for _, info in pairs(bestByMode.Now) do
        info.IsBestNow = true
    end
    for _, info in pairs(bestByMode.Potential) do
        info.IsBestPotential = true
    end
    for _, info in pairs(bestByMode.Budget) do
        info.IsBestBudget = true
    end
    for _, info in pairs(bestOverallPotential) do
        info.IsBestOverallPotential = true
    end
    if Controller.BestMode ~= "Off" then
        for _, info in pairs(bestByMode[Controller.BestMode] or {}) do
            info.IsBestLoadout = true
        end
    end

    for _, info in ipairs(allInfos) do
        info.ProtectionReasons = protectionReasons(info)
        info.IsProtected = #info.ProtectionReasons > 0
    end

    local junkMode = tostring(Persistent.Settings.JunkMode or "NonBest")
    if junkMode == "NonBest" then
        for _, info in ipairs(allInfos) do
            local slot = slotForType(info.ItemType)
            if slot == "weapon" or slot == "chest" or slot == "helmet" then
                local isBest = info.IsBestNow or info.IsBestPotential or info.IsBestBudget or info.IsBestOverallPotential
                local isAboveLevel = (info.Level or 0) > playerLevel
                if not info.IsProtected and not isBest and not isAboveLevel then
                    info.IsJunk = true
                    info.JunkReason = "Not best in slot"
                end
            end
        end

        for _, list in pairs(junkGroups) do
            if list[1] and list[1].ItemType == "ability" then
                local keepCopies = keepCopiesForName(list[1].Name or "")
                if #list > keepCopies then
                    table.sort(list, function(a, b)
                        if a.Potential ~= b.Potential then return a.Potential > b.Potential end
                        if a.Current ~= b.Current then return a.Current > b.Current end
                        if a.RarityRank ~= b.RarityRank then return a.RarityRank > b.RarityRank end
                        if a.Level ~= b.Level then return a.Level > b.Level end
                        return (a.ItemNumber or math.huge) < (b.ItemNumber or math.huge)
                    end)
                    local kept = {}
                    for index = 1, math.min(keepCopies, #list) do
                        kept[list[index]] = true
                    end
                    for index = #list, 1, -1 do
                        local candidate = list[index]
                        if not kept[candidate] and not candidate.IsProtected then
                            candidate.IsJunk = true
                            candidate.JunkReason = "Duplicate ability outside top " .. tostring(keepCopies)
                            break
                        end
                    end
                end
            end
        end
    else
        for _, list in pairs(junkGroups) do
            local keepCopies = keepCopiesForName(list[1] and list[1].Name or "")
            if #list > keepCopies then
                table.sort(list, function(a, b)
                    if a.Potential ~= b.Potential then return a.Potential > b.Potential end
                    if a.Current ~= b.Current then return a.Current > b.Current end
                    if a.RarityRank ~= b.RarityRank then return a.RarityRank > b.RarityRank end
                    if a.Level ~= b.Level then return a.Level > b.Level end
                    return (a.ItemNumber or math.huge) < (b.ItemNumber or math.huge)
                end)
                local kept = {}
                for index = 1, math.min(keepCopies, #list) do
                    kept[list[index]] = true
                end
                local worstCandidate = nil
                for index = #list, 1, -1 do
                    local candidate = list[index]
                    if not kept[candidate] and not isProtectedInfo(candidate) then
                        worstCandidate = candidate
                        break
                    end
                end
                if worstCandidate then
                    worstCandidate.IsJunk = true
                    worstCandidate.JunkReason = "Outside top " .. tostring(keepCopies) .. " copies"
                end
            end
        end
    end

    
    
    if not Controller.SessionBaselineReady then
        for _, info in ipairs(allInfos) do
            if info.UID then
                Controller.SessionStartUIDs[info.UID] = true
            end
        end
        Controller.SessionBaselineReady = true
    else
        for _, info in ipairs(allInfos) do
            if info.UID
                and not Controller.SessionStartUIDs[info.UID]
                and not Controller.SessionLootDrops[info.UID]
            then
                local slot = slotForType(info.ItemType)
                local eqInfo = slot and equippedInfo[slot] or nil
                local improvement = false
                if slot and eqInfo and not info.IsEquipped and info.Field then
                    local eqPotential = maxPotential(eqInfo.Item, info.Field)
                        or tonumber(eqInfo.Item[info.Field]) or 0
                    improvement = (info.Potential or 0) > eqPotential
                end

                local drop = {
                    UID = info.UID,
                    Name = info.Name,
                    ItemType = info.ItemType,
                    Class = info.Class,
                    Rarity = info.Rarity,
                    RollGrade = info.RollGrade,
                    Current = info.Current,
                    Potential = info.Potential,
                    IsDuplicate = (info.DuplicateCount or 1) > 1,
                    IsImprovement = improvement,
                    IsWishlist = info.IsWishlist == true,
                    AcquiredAt = os.time(),
                }
                Controller.SessionLootDrops[info.UID] = drop
                table.insert(Persistent.LootHistory, 1, drop)
                while #Persistent.LootHistory > 100 do table.remove(Persistent.LootHistory) end
                scheduleDiskStateSave(0.35)
                if (info.IsGodpot or info.RollGrade == "GODPOT") and Persistent.Settings.GodpotNotifications ~= false then
                    qolNotify("GODPOT DROP!", tostring(info.Name) .. " • " .. formatInt(info.Potential or 0) .. " Max Pot!")
                elseif info.IsWishlist and Persistent.Settings.WishlistNotifications then
                    qolNotify("Wishlist Drop", tostring(info.Name) .. " • " .. tostring(info.RollGrade or info.Rarity or "drop"))
                elseif (info.RollGrade == "S" or info.RollGrade == "GODPOT") and Persistent.Settings.SRollNotifications then
                    qolNotify("S-Roll Drop", tostring(info.Name) .. " • " .. (info.RollPct and string.format("%.0f%%", info.RollPct) or "S"))
                elseif (info.RarityRank or 0) >= (RARITY_RANK.legendary or 5) and Persistent.Settings.LegendaryNotifications then
                    qolNotify("Legendary+ Drop", tostring(info.Name))
                elseif improvement and Persistent.Settings.DropNotifications then
                    qolNotify("Potential Improvement", tostring(info.Name) .. " • " .. formatCompact(info.Potential or 0))
                end
            end
        end
    end

    local count, capacity, pct = inventoryCapacityText()
    if pct >= (tonumber(Persistent.Settings.InventoryWarningPct) or 90)
        and Controller.LastCapacityWarningCount ~= count
    then
        Controller.LastCapacityWarningCount = count
        qolNotify("Inventory Capacity", tostring(count) .. "/" .. tostring(capacity) .. " slots used (" .. string.format("%.0f%%", pct) .. ")")
    end
end






local SORT_MODES = {
    "Highest Pot",
    "Upgrade %",
    "Upgrade Gain",
    "Gain / Gold",
    "Sell Value",
    "Upgrade Cost",
    "Current",
    "Rarity",
    "Level",
    "Upgrades",
    "Roll Percentile",
    "Recently Acquired",
    "Recently Upgraded",
    "Recently Equipped",
    "Name",
}

local function hasExtraFilters()
    return Persistent.Settings.HideCommon
        or Persistent.Settings.HideAbilities
        or Persistent.Settings.OnlyUpgradable
        or Persistent.Settings.OnlyEquipable
        or Persistent.Settings.GroupDupes
        or Persistent.Settings.HideJunk
        or (tonumber(Persistent.Settings.MinLevel) or 0) > 0
end

local function hasVisibilityFilter()
    return Controller.ClassFilter ~= nil
        or Controller.SearchText ~= ""
        or Persistent.Settings.HideCommon
        or Persistent.Settings.HideAbilities
        or Persistent.Settings.OnlyUpgradable
        or Persistent.Settings.OnlyEquipable
        or Persistent.Settings.HideJunk
        or (tonumber(Persistent.Settings.MinLevel) or 0) > 0
        or Controller.BestMode ~= "Off"
        or Controller.JunkOnly
        or Controller.ReviewLootOnly
end

local function searchMatches(info)
    if Controller.SearchText == "" then
        return true
    end

    local query = lower(Controller.SearchText)
    if not Persistent.Settings.AdvancedSearch then
        local haystack = table.concat({
            info.NameLower or "",
            info.Rarity or "",
            lower(info.Class),
            lower(info.ItemType),
            info.IsJunk and "junk" or "",
            info.IsEquipped and "equipped" or "",
            info.IsLoadoutProtected and "loadout preset" or "",
            info.IsWishlist and "wishlist" or "",
            (info.IsGodpot or info.RollGrade == "GODPOT") and "godpot" or "",
            info.RollGrade and lower(info.RollGrade) or "",
            info.CustomTag and lower(info.CustomTag) or "",
        }, " ")
        return string.find(haystack, query, 1, true) ~= nil
    end

    local plain = {}
    local function boolValue(v)
        v = lower(v)
        return v == "true" or v == "1" or v == "yes" or v == "on"
    end

    for token in string.gmatch(query, "%S+") do
        local key, value = token:match("^([%w_]+):(.+)$")
        if key then
            if key == "rarity" and info.Rarity ~= value then return false end
            if key == "type" and lower(info.ItemType) ~= value then return false end
            if key == "class" and lower(info.Class) ~= value then return false end
            if key == "roll" and lower(info.RollGrade or "") ~= value then return false end
            if key == "godpot" and (info.IsGodpot == true) ~= boolValue(value) then return false end
            if key == "is" and value == "godpot" and not info.IsGodpot then return false end
            if key == "uid" and not string.find(lower(info.UID or ""), value, 1, true) then return false end
            if key == "tag" and not string.find(lower(info.CustomTag or ""), value, 1, true) then return false end
            if key == "level" and nonNegativeInteger(info.Level) ~= nonNegativeInteger(value) then return false end
            if key == "minlevel" and nonNegativeInteger(info.Level) < nonNegativeInteger(value) then return false end
            if key == "maxlevel" and nonNegativeInteger(info.Level) > nonNegativeInteger(value) then return false end
            if key == "new" and ((info.UID and Persistent.NewIDs[info.UID]) == true) ~= boolValue(value) then return false end
            if key == "equipped" and (info.IsEquipped == true) ~= boolValue(value) then return false end
            if key == "locked" and ((info.UID and Persistent.Locked[info.UID]) == true) ~= boolValue(value) then return false end
            if key == "favorite" and ((info.UID and Persistent.Favorites[info.UID]) == true) ~= boolValue(value) then return false end
            if key == "wishlist" and (info.IsWishlist == true) ~= boolValue(value) then return false end
            if key == "junk" and (info.IsJunk == true) ~= boolValue(value) then return false end
            if key == "loadout" and (info.IsLoadoutProtected == true) ~= boolValue(value) then return false end
            if key == "protected" and (info.IsProtected == true) ~= boolValue(value) then return false end
            if key == "improvement" and (info.BetterThanEquipped == true) ~= boolValue(value) then return false end
        else
            local opKey, op, raw = token:match("^([%w_]+)([<>]=?)(%-?[%d%.]+)$")
            if opKey then
                local left
                if opKey == "stat" or opKey == "current" then left = tonumber(info.Current) or 0 end
                if opKey == "pot" or opKey == "potential" then left = tonumber(info.Potential) or 0 end
                if opKey == "sell" or opKey == "value" then left = tonumber(info.SellValue) or 0 end
                if opKey == "upgrade" then left = tonumber(info.UpgradePct) or 0 end
                if opKey == "roi" then left = tonumber(info.GainPerGold) or 0 end
                if opKey == "roll" then left = tonumber(info.RollPct) or 0 end
                if left ~= nil then
                    local right = tonumber(raw) or 0
                    if op == ">" and not (left > right) then return false end
                    if op == ">=" and not (left >= right) then return false end
                    if op == "<" and not (left < right) then return false end
                    if op == "<=" and not (left <= right) then return false end
                else
                    plain[#plain + 1] = token
                end
            else
                plain[#plain + 1] = token
            end
        end
    end

    if #plain == 0 then return true end
    local haystack = table.concat({
        info.NameLower or "",
        info.Rarity or "",
        lower(info.Class),
        lower(info.ItemType),
        info.IsJunk and "junk" or "",
        info.IsEquipped and "equipped" or "",
        info.IsLoadoutProtected and "loadout preset" or "",
        info.IsWishlist and "wishlist" or "",
        info.RollGrade and lower(info.RollGrade) or "",
        info.CustomTag and lower(info.CustomTag) or "",
        info.Note and lower(info.Note) or "",
    }, " ")
    for _, word in ipairs(plain) do
        if not string.find(haystack, word, 1, true) then return false end
    end
    return true
end

local function shouldInfoBeVisible(info)
    if not info then
        return true
    end

    if Controller.ClassFilter == "Skills" then
        if info.ItemType ~= "ability" then
            return false
        end
    elseif Controller.ClassFilter then
        if info.ItemType == "ability" then
            return false
        end

        if info.Class ~= Controller.ClassFilter then
            return false
        end
    end

    if not searchMatches(info) then
        return false
    end

    if Persistent.Settings.HideCommon and info.Rarity == "common" then
        return false
    end

    if Persistent.Settings.HideAbilities
        and Controller.ClassFilter ~= "Skills"
        and info.ItemType == "ability"
    then
        return false
    end

    if Persistent.Settings.OnlyUpgradable and info.RemainingUpgrades <= 0 then
        return false
    end

    if Persistent.Settings.OnlyEquipable and not info.IsEquipable then
        return false
    end

    if Persistent.Settings.HideJunk and info.IsJunk then
        return false
    end

    if Controller.JunkOnly and not info.IsJunk then
        return false
    end

    if Controller.ReviewLootOnly and not (info.UID and Controller.SessionLootDrops[info.UID]) then
        return false
    end

    local minLevel = tonumber(Persistent.Settings.MinLevel) or 0
    if minLevel > 0 and info.Level < minLevel then
        return false
    end

    if Controller.BestMode ~= "Off" and Controller.ClassFilter ~= "Skills" then
        if not info.IsBestLoadout then
            return false
        end

        if Controller.ClassFilter and info.Class ~= Controller.ClassFilter then
            return false
        end
    end

    return true
end


local applyingVisibility = false

local function forceCardVisibility(card)
    if applyingVisibility or not card or not card.Parent then
        return
    end

    local info = Controller.CardInfo[card]
    local target = shouldInfoBeVisible(info)

    if card.Visible ~= target then
        applyingVisibility = true
        card.Visible = target
        applyingVisibility = false
    end
end

local function sortValue(info)
    local mode = Persistent.Settings.SortMode

    if mode == "Highest Pot" then
        return info.Potential or 0
    elseif mode == "Upgrade %" then
        return info.UpgradePct or 0
    elseif mode == "Upgrade Gain" then
        return info.Gain or 0
    elseif mode == "Gain / Gold" then
        return info.GainPerGold or 0
    elseif mode == "Sell Value" then
        return info.SellValue or 0
    elseif mode == "Upgrade Cost" then
        if (info.RemainingUpgrades or 0) <= 0 then
            return math.huge
        end

        return info.UpgradeCost or math.huge
    elseif mode == "Current" then
        return info.Current or 0
    elseif mode == "Rarity" then
        return info.RarityRank or 0
    elseif mode == "Level" then
        return info.Level or 0
    elseif mode == "Upgrades" then
        return info.CurrentUpgrade or 0
    elseif mode == "Roll Percentile" then
        return info.RollPercentile or 0
    elseif mode == "Recently Acquired" then
        return (info.UID and Controller.SessionLootDrops[info.UID] and Controller.SessionLootDrops[info.UID].AcquiredAt) or info.FirstSeen or 0
    elseif mode == "Recently Upgraded" then
        return (info.UID and Controller.RecentlyUpgradedUIDs[info.UID]) or 0
    elseif mode == "Recently Equipped" then
        return (info.UID and Controller.RecentlyEquippedUIDs[info.UID]) or 0
    end

    return 0
end

local function sortCards()
    local cards = {}

    for card, info in pairs(Controller.CardInfo) do
        if card and card.Parent and info then
            cards[#cards + 1] = {
                Card = card,
                Info = info,
            }
        end
    end

    table.sort(cards, function(a, b)
        local ai = a.Info
        local bi = b.Info

        
        local af = ai.UID and Persistent.Favorites[ai.UID] == true or false
        local bf = bi.UID and Persistent.Favorites[bi.UID] == true or false
        if af ~= bf then
            return af
        end

        
        local al = ai.UID and Persistent.Locked[ai.UID] == true or false
        local bl = bi.UID and Persistent.Locked[bi.UID] == true or false
        if al ~= bl then
            return al
        end

        if Controller.ClassFilter == "Skills" then
            
            if ai.ItemType == "ability" and bi.ItemType ~= "ability" then
                return true
            elseif ai.ItemType ~= "ability" and bi.ItemType == "ability" then
                return false
            end

            if ai.Level ~= bi.Level then
                return ai.Level > bi.Level
            end

            if ai.RarityRank ~= bi.RarityRank then
                return ai.RarityRank > bi.RarityRank
            end

            if ai.NameLower ~= bi.NameLower then
                return ai.NameLower < bi.NameLower
            end
        elseif Persistent.Settings.GroupDupes then
            if ai.NameLower ~= bi.NameLower then
                return ai.NameLower < bi.NameLower
            end

            if ai.Potential ~= bi.Potential then
                return ai.Potential > bi.Potential
            end
        else
            local mode = Persistent.Settings.SortMode

            if mode == "Name" then
                if ai.NameLower ~= bi.NameLower then
                    return ai.NameLower < bi.NameLower
                end
            else
                local av = sortValue(ai)
                local bv = sortValue(bi)

                if av ~= bv then
                    if mode == "Upgrade Cost" then
                        
                        return av < bv
                    end

                    return av > bv
                end
            end
        end

        if ai.RarityRank ~= bi.RarityRank then
            return ai.RarityRank > bi.RarityRank
        end

        if ai.Potential ~= bi.Potential then
            return ai.Potential > bi.Potential
        end

        if ai.NameLower ~= bi.NameLower then
            return ai.NameLower < bi.NameLower
        end

        return ai.ItemNumber < bi.ItemNumber
    end)

    table.clear(Controller.TargetLayoutOrder)

    for index, entry in ipairs(cards) do
        Controller.TargetLayoutOrder[entry.Card] = index

        if entry.Card.LayoutOrder ~= index then
            entry.Card.LayoutOrder = index
        end
    end
end





local NATIVE_ROUND_IMAGE = "rbxassetid://2512840830"

local CLASS_COLORS = {
    Mage = Color3.fromRGB(55, 125, 230),
    Warrior = Color3.fromRGB(220, 65, 65),
    Tank = Color3.fromRGB(55, 175, 95),
    Skills = Color3.fromRGB(142, 82, 176),
}

local function makeImagePlate(parent, name, size, position, color, zIndex)
    local plate = Instance.new("ImageLabel")
    plate.Name = name
    plate.Size = size
    plate.Position = position
    plate.BackgroundTransparency = 1
    plate.Image = NATIVE_ROUND_IMAGE
    plate.ImageColor3 = color
    plate.ZIndex = zIndex
    plate.Parent = parent
    return plate
end

local function makeSquarePlate(parent, name, size, position, color, zIndex)
    local plate = Instance.new("Frame")
    plate.Name = name
    plate.Size = size
    plate.Position = position
    plate.BackgroundTransparency = 0
    plate.BackgroundColor3 = color
    plate.BorderSizePixel = 0
    plate.ZIndex = zIndex
    plate.Parent = parent
    return plate
end

local function setPlateColor(plate, color)
    if not plate then
        return
    end
    if plate:IsA("ImageLabel") or plate:IsA("ImageButton") then
        plate.ImageColor3 = color
    elseif plate:IsA("Frame") or plate:IsA("TextLabel") or plate:IsA("TextButton") then
        plate.BackgroundColor3 = color
    end
end

local function getPlateColor(plate)
    if not plate then
        return Color3.fromRGB(31, 31, 31)
    end
    if plate:IsA("ImageLabel") or plate:IsA("ImageButton") then
        return plate.ImageColor3
    end
    return plate.BackgroundColor3
end

local function makeNativeButton(parent, config)
    local zIndex = config.ZIndex or 33
    local button = Instance.new("TextButton")
    button.Name = config.Name
    button.LayoutOrder = config.LayoutOrder or 1
    button.Size = config.Size
    button.BackgroundTransparency = 1
    button.BorderSizePixel = 0
    button.Text = config.Text or ""
    button.TextColor3 = config.TextColor or Color3.fromRGB(254, 254, 254)
    button.TextScaled = true
    button.TextWrapped = false
    button.TextTruncate = Enum.TextTruncate.AtEnd
    button.TextSize = 14
    button.Font = Enum.Font.GothamBlack
    button.TextStrokeColor3 = Color3.new(0, 0, 0)
    button.TextStrokeTransparency = 0
    button.AutoButtonColor = false
    button.ClipsDescendants = false
    button.ZIndex = zIndex
    button.Parent = parent

    
    local outer = makeSquarePlate(
        button,
        "DQOuter",
        UDim2.fromScale(1, 1),
        UDim2.fromScale(0, 0),
        config.OuterColor or Color3.fromRGB(31, 31, 31),
        zIndex - 2
    )

    local inner = makeSquarePlate(
        button,
        "DQInner",
        UDim2.fromScale(0.92, 0.78),
        UDim2.fromScale(0.04, 0.08),
        config.InnerColor or Color3.fromRGB(78, 78, 78),
        zIndex - 1
    )

    local faceStroke = Instance.new("UIStroke")
    faceStroke.Name = "DQFaceStroke"
    faceStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    faceStroke.Color = Color3.fromRGB(12, 12, 12)
    faceStroke.Thickness = 1
    faceStroke.Transparency = 0.25
    faceStroke.Parent = inner

    local constraint = Instance.new("UITextSizeConstraint")
    constraint.MinTextSize = config.MinTextSize or 10
    constraint.MaxTextSize = config.MaxTextSize or 18
    constraint.Parent = button

    
    
    local outerBase = getPlateColor(outer)
    local normalInnerPosition = UDim2.fromScale(0.04, 0.08)
    local pressedInnerPosition = UDim2.fromScale(0.04, 0.11)

    addConnection(Controller.AttachConnections, button.MouseEnter:Connect(function()
        if outer.Parent then
            setPlateColor(outer, outerBase:Lerp(Color3.new(1, 1, 1), 0.08))
        end
    end))
    addConnection(Controller.AttachConnections, button.MouseLeave:Connect(function()
        if outer.Parent then setPlateColor(outer, outerBase) end
        if inner.Parent then inner.Position = normalInnerPosition end
    end))
    addConnection(Controller.AttachConnections, button.MouseButton1Down:Connect(function()
        if inner.Parent then inner.Position = pressedInnerPosition end
    end))
    addConnection(Controller.AttachConnections, button.MouseButton1Up:Connect(function()
        if inner.Parent then inner.Position = normalInnerPosition end
    end))

    return button, inner, outer
end

local function makeNativeInput(parent, config)
    local zIndex = config.ZIndex or 33
    local holder = Instance.new("Frame")
    holder.Name = config.Name
    holder.LayoutOrder = config.LayoutOrder or 1
    holder.Size = config.Size
    holder.BackgroundTransparency = 1
    holder.ClipsDescendants = false
    holder.ZIndex = zIndex
    holder.Parent = parent

    makeSquarePlate(
        holder,
        "DQOuter",
        UDim2.fromScale(1, 1),
        UDim2.fromScale(0, 0),
        Color3.fromRGB(31, 31, 31),
        zIndex - 2
    )

    local inputFace = makeSquarePlate(
        holder,
        "DQInner",
        UDim2.fromScale(0.94, 0.78),
        UDim2.fromScale(0.03, 0.08),
        Color3.fromRGB(73, 73, 73),
        zIndex - 1
    )

    local inputStroke = Instance.new("UIStroke")
    inputStroke.Name = "DQFaceStroke"
    inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    inputStroke.Color = Color3.fromRGB(12, 12, 12)
    inputStroke.Thickness = 1
    inputStroke.Transparency = 0.25
    inputStroke.Parent = inputFace

    local box = Instance.new("TextBox")
    box.Name = "TextBox"
    box.AnchorPoint = Vector2.new(0.5, 0.5)
    box.Position = UDim2.fromScale(0.5, 0.5)
    box.Size = UDim2.fromScale(0.88, 0.68)
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = false
    box.Text = config.Text or ""
    box.PlaceholderText = config.Placeholder or ""
    box.PlaceholderColor3 = Color3.fromRGB(185, 185, 185)
    box.TextColor3 = Color3.fromRGB(255, 255, 255)
    box.TextScaled = true
    box.TextWrapped = false
    box.TextTruncate = Enum.TextTruncate.AtEnd
    box.TextSize = 14
    box.Font = Enum.Font.Highway
    box.TextStrokeColor3 = Color3.new(0, 0, 0)
    box.TextStrokeTransparency = 0
    box.TextXAlignment = config.TextXAlignment or Enum.TextXAlignment.Left
    box.ZIndex = zIndex
    box.Parent = holder

    local constraint = Instance.new("UITextSizeConstraint")
    constraint.MinTextSize = 10
    constraint.MaxTextSize = 17
    constraint.Parent = box

    addConnection(Controller.AttachConnections, box.Focused:Connect(function()
        if inputFace.Parent then setPlateColor(inputFace, Color3.fromRGB(86, 86, 86)) end
    end))
    addConnection(Controller.AttachConnections, box.FocusLost:Connect(function()
        if inputFace.Parent then setPlateColor(inputFace, Color3.fromRGB(73, 73, 73)) end
    end))

    return holder, box
end





local function getOrCreateOverlay(card)
    local existing = card:FindFirstChild("DQInventoryQOL")
    if existing and existing:IsA("Frame") then
        return existing
    end

    local overlay = Instance.new("Frame")
    overlay.Name = "DQInventoryQOL"
    overlay.Size = UDim2.fromScale(1, 1)
    overlay.BackgroundTransparency = 1
    overlay.BorderSizePixel = 0
    overlay.ClipsDescendants = false
    overlay.ZIndex = 50
    overlay.Parent = card

    local status = Instance.new("TextButton")
    status.Name = "Status"
    status.Position = UDim2.fromScale(0.02, 0.02)
    status.Size = UDim2.fromScale(0.66, 0.19)
    status.BackgroundTransparency = 1
    status.BorderSizePixel = 0
    status.AutoButtonColor = false
    status.Font = Enum.Font.GothamBlack
    status.TextScaled = true
    status.TextColor3 = Color3.fromRGB(255, 232, 85)
    status.TextStrokeColor3 = Color3.new(0, 0, 0)
    status.TextStrokeTransparency = 0
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.ZIndex = 53
    status.Parent = overlay

    local newBadge = Instance.new("TextLabel")
    newBadge.Name = "New"
    newBadge.Position = UDim2.fromScale(0.02, 0.76)
    newBadge.Size = UDim2.fromScale(0.36, 0.19)
    newBadge.BackgroundTransparency = 1
    newBadge.Font = Enum.Font.GothamBlack
    newBadge.Text = ""
    newBadge.TextScaled = true
    newBadge.TextColor3 = Color3.fromRGB(105, 220, 255)
    newBadge.TextStrokeColor3 = Color3.new(0, 0, 0)
    newBadge.TextStrokeTransparency = 0
    newBadge.TextXAlignment = Enum.TextXAlignment.Left
    newBadge.ZIndex = 53
    newBadge.Parent = overlay

    local pct = Instance.new("TextLabel")
    pct.Name = "PotentialPct"
    pct.AnchorPoint = Vector2.new(1, 1)
    pct.Position = UDim2.fromScale(0.98, 0.95)
    pct.Size = UDim2.fromScale(0.42, 0.19)
    pct.BackgroundTransparency = 1
    pct.Font = Enum.Font.GothamBlack
    pct.TextScaled = true
    pct.TextColor3 = Color3.fromRGB(245, 245, 245)
    pct.TextStrokeColor3 = Color3.new(0, 0, 0)
    pct.TextStrokeTransparency = 0
    pct.TextXAlignment = Enum.TextXAlignment.Right
    pct.ZIndex = 53
    pct.Parent = overlay

    local better = Instance.new("TextLabel")
    better.Name = "Better"
    better.AnchorPoint = Vector2.new(0.5, 1)
    better.Position = UDim2.fromScale(0.50, 0.95)
    better.Size = UDim2.fromScale(0.24, 0.20)
    better.BackgroundTransparency = 1
    better.Font = Enum.Font.GothamBlack
    better.Text = ""
    better.TextScaled = true
    better.TextColor3 = Color3.fromRGB(90, 235, 120)
    better.TextStrokeColor3 = Color3.new(0, 0, 0)
    better.TextStrokeTransparency = 0
    better.ZIndex = 53
    better.Parent = overlay

    local lock = Instance.new("TextLabel")
    lock.Name = "Lock"
    lock.AnchorPoint = Vector2.new(1, 0)
    lock.Position = UDim2.fromScale(0.98, 0.25)
    lock.Size = UDim2.fromScale(0.32, 0.16)
    lock.BackgroundTransparency = 1
    lock.Font = Enum.Font.GothamBlack
    lock.Text = ""
    lock.TextScaled = true
    lock.TextColor3 = Color3.fromRGB(255, 210, 85)
    lock.TextStrokeColor3 = Color3.new(0, 0, 0)
    lock.TextStrokeTransparency = 0
    lock.TextXAlignment = Enum.TextXAlignment.Right
    lock.ZIndex = 53
    lock.Parent = overlay

    local star = Instance.new("TextButton")
    star.Name = "Favorite"
    star.AnchorPoint = Vector2.new(1, 0)
    star.Position = UDim2.fromScale(0.99, 0.01)
    star.Size = UDim2.fromScale(0.28, 0.27)
    star.BackgroundTransparency = 1
    star.BorderSizePixel = 0
    star.Text = "☆"
    star.TextScaled = true
    star.TextColor3 = Color3.fromRGB(245, 245, 245)
    star.TextStrokeColor3 = Color3.new(0, 0, 0)
    star.TextStrokeTransparency = 0
    star.Font = Enum.Font.GothamBlack
    star.ZIndex = 56
    star.Parent = overlay

    local upgrade = Instance.new("Frame")
    upgrade.Name = "UpgradeStatus"
    upgrade.AnchorPoint = Vector2.new(0.5, 1)
    upgrade.Position = UDim2.fromScale(0.5, 1)
    upgrade.Size = UDim2.new(0.88, 0, 0, 3)
    upgrade.BorderSizePixel = 0
    upgrade.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
    upgrade.ZIndex = 52
    upgrade.Parent = overlay

    return overlay
end

local function updateOverlay(card, info)
    local overlay = getOrCreateOverlay(card)

    local status = overlay:FindFirstChild("Status")
    local newBadge = overlay:FindFirstChild("New")
    local pct = overlay:FindFirstChild("PotentialPct")
    local better = overlay:FindFirstChild("Better")
    local lock = overlay:FindFirstChild("Lock")
    local star = overlay:FindFirstChild("Favorite")
    local upgrade = overlay:FindFirstChild("UpgradeStatus")
    local showBadges = not Persistent.Settings.HideBadges

    if status then
        status.Visible = showBadges and not Persistent.Settings.HideStatusBadge
        if info.IsGodpot or info.RollGrade == "GODPOT" then
            status.Text = "GODPOT"
            status.TextColor3 = Color3.fromRGB(255, 215, 0)
        elseif info.IsJunk then
            status.Text = info.RollGrade
                and ("JUNK • " .. info.RollGrade)
                or "JUNK"
            status.TextColor3 = Color3.fromRGB(255, 92, 92)
        elseif info.BestDuplicate then
            status.Text = "BEST x" .. tostring(info.DuplicateCount)
            if info.RollGrade then
                status.Text ..= " • " .. info.RollGrade
            end
            status.TextColor3 = Color3.fromRGB(255, 232, 85)
        elseif info.IsWishlist then
            status.Text = "WISH" .. (info.RollGrade and (" • " .. info.RollGrade) or "")
            status.TextColor3 = Color3.fromRGB(120, 235, 255)
        elseif info.RollGrade == "S" then
            status.Text = info.RollPct and string.format("%.0f%% S", info.RollPct) or "S"
            status.TextColor3 = Color3.fromRGB(110, 245, 175)
        elseif info.RollGrade == "A" then
            status.Text = info.RollPct and string.format("%.0f%% A", info.RollPct) or "A"
            status.TextColor3 = Color3.fromRGB(130, 215, 255)
        elseif info.RollGrade then
            status.Text = info.RollPct and string.format("%.0f%% %s", info.RollPct, info.RollGrade) or info.RollGrade
            status.TextColor3 = Color3.fromRGB(220, 220, 220)
        else
            status.Text = ""
            status.TextColor3 = Color3.fromRGB(255, 232, 85)
        end
    end

    if newBadge then
        newBadge.Visible = showBadges and not Persistent.Settings.HideNewBadge
        newBadge.Text =
            (info.UID and Persistent.NewIDs[info.UID])
            and "NEW"
            or ""
    end

    if pct then
        pct.Visible = showBadges and not Persistent.Settings.HideUpgradeBadge
        if info.Field and info.MaxUpgrades > 0 then
            pct.Text = "U" .. formatUpgradeProgress(info.CurrentUpgrade, info.MaxUpgrades, 0)
        else
            pct.Text = ""
        end
    end

    if better then
        better.Visible = showBadges
        better.Text = info.BetterThanEquipped and "▲" or ""
    end

    if lock then
        lock.Visible = showBadges and not Persistent.Settings.HideProtectionBadge
        local tags = {}
        if info.UID and Persistent.Locked[info.UID] then
            tags[#tags + 1] = "LOCK"
        end
        if info.IsLoadoutProtected then tags[#tags + 1] = "SET" end
        if info.IsWishlist then tags[#tags + 1] = "WISH" end
        if info.IsGodpot or info.RollGrade == "GODPOT" then tags[#tags + 1] = "GODPOT" end
        if Persistent.Settings.ProtectSRolls and info.RollGrade == "S" then tags[#tags + 1] = "S" end
        lock.Text = table.concat(tags, " • ")
    end

    if star and star:IsA("TextButton") then
        local favorite = info.UID and Persistent.Favorites[info.UID]
        star.Text = favorite and "★" or "☆"
        star.TextColor3 = favorite
            and Color3.fromRGB(255, 223, 70)
            or Color3.fromRGB(245, 245, 245)
    end

    if upgrade then
        upgrade.Visible = showBadges and info.MaxUpgrades > 0
        if upgrade.Visible then
            if info.CurrentUpgrade >= info.MaxUpgrades then
                upgrade.BackgroundColor3 = Color3.fromRGB(80, 205, 100)
            elseif info.CurrentUpgrade <= 0 then
                upgrade.BackgroundColor3 = Color3.fromRGB(90, 90, 90)
            else
                upgrade.BackgroundColor3 = Color3.fromRGB(235, 188, 75)
            end
        end
    end
end

local function refreshAllOverlays()
    for card, info in pairs(Controller.CardInfo) do
        if card and card.Parent and info then
            updateOverlay(card, info)
        end
    end
end





local function getTooltipMain(gui, itemType)
    local statFrame = gui and gui:FindFirstChild("itemStatFrame")
    if not statFrame then
        return nil
    end

    if itemType == "weapon" then
        return statFrame:FindFirstChild("weaponMain")
    elseif itemType == "helmet"
        or itemType == "chest"
        or itemType == "armor"
        or itemType == "ring"
    then
        return statFrame:FindFirstChild("armorMain")
    elseif itemType == "pet" then
        return statFrame:FindFirstChild("petMain")
    end

    return nil
end










local TOOLTIP_GLOBAL_BASE_Z = 60

local function rememberNativeTooltipZ(obj)
    if not obj or not obj:IsA("GuiObject") then
        return nil
    end

    Controller.TooltipNativeState = Controller.TooltipNativeState or {}

    local saved = Controller.TooltipNativeState[obj]
    if not saved then
        saved = {ZIndex = obj.ZIndex}
        Controller.TooltipNativeState[obj] = saved
    end

    return saved
end

local function promoteNativeTooltipStack(gui)
    local statFrame = gui and gui:FindFirstChild("itemStatFrame")
    if not statFrame or not statFrame:IsA("GuiObject") then
        return
    end

    local mainBackground = gui:FindFirstChild("mainBackground")
    local behavior = gui:IsA("ScreenGui") and gui.ZIndexBehavior
        or Enum.ZIndexBehavior.Sibling

    local statSaved = rememberNativeTooltipZ(statFrame)

    if behavior == Enum.ZIndexBehavior.Sibling then
        
        
        local inventoryRootZ = 0
        if mainBackground and mainBackground:IsA("GuiObject") then
            inventoryRootZ = mainBackground.ZIndex
        end
        statFrame.ZIndex = math.max(
            (statSaved and statSaved.ZIndex or 1),
            inventoryRootZ + 1
        )
    else
        
        
        statFrame.ZIndex = TOOLTIP_GLOBAL_BASE_Z

        local extraRoot = statFrame:FindFirstChild("DQInventoryExtra")

        for _, descendant in ipairs(statFrame:GetDescendants()) do
            local belongsToExtra = extraRoot
                and (descendant == extraRoot or descendant:IsDescendantOf(extraRoot))

            if descendant:IsA("GuiObject") and not belongsToExtra then
                local saved = rememberNativeTooltipZ(descendant)
                local originalZ = saved and saved.ZIndex or descendant.ZIndex
                descendant.ZIndex = TOOLTIP_GLOBAL_BASE_Z
                    + math.clamp(originalZ, 1, 12)
            end
        end
    end
end

local function restoreNativeTooltipStack()
    for obj, saved in pairs(Controller.TooltipNativeState or {}) do
        if obj and obj.Parent and saved then
            pcall(function()
                obj.ZIndex = saved.ZIndex
            end)
        end
    end

    Controller.TooltipNativeState = {}
end

local function setPotentialText(label, item, field)
    if not label or not label:IsA("TextLabel") then
        return
    end

    local current = tonumber(item[field])
    local potential = maxPotential(item, field)

    if current ~= nil and potential ~= nil then
        label.Text =
            formatInt(current)
            .. " ("
            .. formatInt(potential)
            .. ")"
    end
end

local function ensureTooltipExtra(gui)
    local statFrame = gui and gui:FindFirstChild("itemStatFrame")
    if not statFrame then
        return nil
    end

    local oldExtra = statFrame:FindFirstChild("DQInventoryExtra")
    if oldExtra then
        Controller.TooltipExtra = oldExtra
        return oldExtra
    end

    local extra = Instance.new("ImageLabel")
    extra.Name = "DQInventoryExtra"
    extra.AnchorPoint = Vector2.new(0, 0)
    extra.Position = UDim2.new(0, 0, 1, 4)
    extra.Size = UDim2.new(1, 0, 0, 42)
    extra.BackgroundTransparency = 1
    extra.Image = NATIVE_ROUND_IMAGE
    extra.ImageColor3 = Color3.fromRGB(38, 38, 38)
    extra.ClipsDescendants = false
    extra.ZIndex = 75
    extra.Visible = false
    extra.Parent = statFrame

    local inner = Instance.new("ImageLabel")
    inner.Name = "Inner"
    inner.AnchorPoint = Vector2.new(0.5, 0.5)
    inner.Position = UDim2.fromScale(0.5, 0.5)
    inner.Size = UDim2.fromScale(0.94, 0.84)
    inner.BackgroundTransparency = 1
    inner.Image = NATIVE_ROUND_IMAGE
    inner.ImageColor3 = Color3.fromRGB(67, 67, 67)
    inner.ClipsDescendants = false
    inner.ZIndex = 76
    inner.Parent = extra

    local text = Instance.new("TextLabel")
    text.Name = "Text"
    text.AnchorPoint = Vector2.new(0.5, 0.5)
    text.Position = UDim2.fromScale(0.5, 0.5)
    text.Size = UDim2.fromScale(0.91, 0.78)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.Highway
    text.TextSize = 13
    text.TextScaled = false
    text.TextWrapped = true
    text.TextColor3 = Color3.fromRGB(255, 255, 255)
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.TextStrokeTransparency = 0
    text.TextXAlignment = Enum.TextXAlignment.Left
    text.TextYAlignment = Enum.TextYAlignment.Center
    text.ZIndex = 77
    text.Parent = extra

    Controller.TooltipExtra = extra
    return extra
end



local scheduleInventoryRefresh
local showDuplicateComparison

local function updateHoveredTooltip()
    local card = Controller.HoveredCard
    local gui = Controller.CurrentGui
    local info = card and Controller.CardInfo[card] or Controller.HoveredEquippedInfo

    if not gui or not gui.Parent or not info or not info.Item then
        if Controller.TooltipExtra then Controller.TooltipExtra.Visible = false end
        return
    end

    if card and not card.Parent then
        if Controller.TooltipExtra then Controller.TooltipExtra.Visible = false end
        return
    end

    local liveType, liveNumber
    if card then
        liveType, liveNumber = getCardIdentity(card)
    else
        liveType, liveNumber = info.ItemType, info.ItemNumber
    end

    if liveType ~= info.ItemType or liveNumber ~= info.ItemNumber then
        if Controller.TooltipExtra then
            Controller.TooltipExtra.Visible = false
        end

        if scheduleInventoryRefresh then
            scheduleInventoryRefresh(0.03)
        end

        return
    end

    local item = info.Item

    
    
    promoteNativeTooltipStack(gui)

    local main = getTooltipMain(gui, info.ItemType)

    if not main then
        local extra = ensureTooltipExtra(gui)
        if extra then
            extra.Visible = false
        end
        return
    end

    
    
    
    local upgradesLabel = main:FindFirstChild("upgrades")

    if upgradesLabel and upgradesLabel:IsA("TextLabel") then
        local shownCurrent, shownMax = string.match(
            upgradesLabel.Text,
            "([%d,]+)%s*/%s*([%d,]+)"
        )

        if shownCurrent and shownMax then
            shownCurrent = tonumber((shownCurrent:gsub(",", "")))
            shownMax = tonumber((shownMax:gsub(",", "")))

            local dataCurrent = tonumber(item.currentUpgrade) or 0
            local dataMax = tonumber(item.maxUpgrades) or dataCurrent

            if shownCurrent ~= dataCurrent or shownMax ~= dataMax then
                if Controller.TooltipExtra then
                    Controller.TooltipExtra.Visible = false
                end

                if scheduleInventoryRefresh then
                    scheduleInventoryRefresh(0.03)
                end

                return
            end
        end
    end

    local physicalLabel = main:FindFirstChild("physicalDamage")
    local spellLabel = main:FindFirstChild("spellPower")
    local healthLabel = main:FindFirstChild("health")

    if physicalLabel then
        if item.physicalDamage ~= nil then
            setPotentialText(physicalLabel, item, "physicalDamage")
        elseif item.physicalPower ~= nil then
            setPotentialText(physicalLabel, item, "physicalPower")
        end
    end

    if spellLabel and item.spellPower ~= nil then
        setPotentialText(spellLabel, item, "spellPower")
    end

    if healthLabel and item.health ~= nil then
        setPotentialText(healthLabel, item, "health")
    end

    local extra = ensureTooltipExtra(gui)
    if not extra then
        return
    end

    
    
    
    
    extra.Position = UDim2.new(
        main.Position.X.Scale,
        main.Position.X.Offset,
        main.Position.Y.Scale + main.Size.Y.Scale,
        main.Position.Y.Offset + main.Size.Y.Offset + 4
    )

    extra.Size = UDim2.new(
        main.Size.X.Scale,
        main.Size.X.Offset,
        0,
        42
    )

    local text = extra:FindFirstChild("Text")

    if not info.Field or not text then
        extra.Visible = false
        return
    end

    local statName = fieldDisplayName(info.Field)
    text.TextSize = math.clamp(
        math.floor(tonumber(Persistent.Settings.TooltipTextSize) or 13),
        10,
        18
    )

    local line1
    if Persistent.Settings.CompactTooltip then
        line1 =
            statName
            .. ": "
            .. formatCompact(info.Current)
            .. " → "
            .. formatCompact(info.Potential)
        if info.MaxUpgrades > 0 then
            line1 ..= "  •  U" .. formatUpgradeProgress(
                info.CurrentUpgrade,
                info.MaxUpgrades,
                0
            )
        end
    elseif info.MaxUpgrades <= 0 then
        line1 = statName .. ": not upgradable"
    elseif info.RemainingUpgrades <= 0 then
        line1 = string.format(
            "%s: MAXED  •  100%% upgraded",
            statName
        )
    else
        line1 = string.format(
            "%s: +%s remaining  •  %s upgraded",
            statName,
            formatCompact(info.Gain),
            formatUpgradeProgress(info.CurrentUpgrade, info.MaxUpgrades, 1)
        )
    end

    local details = {}

    if not info.IsEquipable then
        details[#details + 1] =
            "Requires Lv " .. formatInt(info.Level)
            .. " (you: " .. formatInt(currentPlayerLevel()) .. ")"
    elseif info.DiffPotential ~= nil then
        if info.IsEquipped then
            details[#details + 1] = "Equipped"
        elseif not Persistent.Settings.CompactTooltip then
            local currentPrefix = info.DiffCurrent >= 0 and "+" or ""
            local potPrefix = info.DiffPotential >= 0 and "+" or ""

            details[#details + 1] =
                "vs Eq "
                .. currentPrefix
                .. formatCompact(info.DiffCurrent)
                .. " now / "
                .. potPrefix
                .. formatCompact(info.DiffPotential)
                .. " pot"
        end
    end

    if not Persistent.Settings.CompactTooltip and info.RollGrade then
        if info.GodpotInfo then
            local gp = info.GodpotInfo
            local rollStr = (info.IsGodpot and "[GODPOT] " or "Roll Quality: ") .. tostring(info.RollGrade)
            if info.RollPct then
                rollStr ..= string.format(" (%.1f%%)", info.RollPct)
            end
            if gp.TotalTiers and gp.TotalTiers > 1 then
                rollStr ..= string.format(" • Tier %d/%d", gp.Tier, gp.TotalTiers)
            end
            details[#details + 1] = rollStr
            details[#details + 1] = string.format("Pot Range: %s — %s Max Pot", formatInt(gp.MinPot), formatInt(gp.MaxPot))
            if gp.DungeonName then
                details[#details + 1] = "Dungeon: " .. tostring(gp.DungeonName)
            end
        else
            details[#details + 1] =
                "Roll "
                .. info.RollGrade
                .. " ("
                .. tostring(info.RollRank or info.DuplicateIndex)
                .. "/"
                .. tostring(info.RollRankCount or info.DuplicateCount)
                .. ")"
            if info.RollPercentile then
                details[#details + 1] = "Roll %ile " .. tostring(info.RollPercentile)
            end
        end
    end

    if info.IsJunk then
        details[#details + 1] = "Smart Junk" .. (info.JunkReason and (": " .. info.JunkReason) or "")
    end
    if info.IsWishlist then details[#details + 1] = "Wishlist" end
    if not Persistent.Settings.CompactTooltip and info.RollPercentile then
        details[#details + 1] = "Roll %ile " .. tostring(info.RollPercentile)
    end
    if not Persistent.Settings.CompactTooltip and info.BreakEvenCount and info.BreakEvenCount > 0 then
        details[#details + 1] = "+" .. formatInt(info.BreakEvenCount) .. " / " .. formatCompact(info.BreakEvenCost or 0) .. "g to beat equipped now"
    end

    if info.UID and Persistent.Favorites[info.UID] then
        details[#details + 1] = "Favorite"
    end

    if info.UID and Persistent.Locked[info.UID] then
        details[#details + 1] = "Locked"
    end

    if info.IsLoadoutProtected then details[#details + 1] = "Loadout" end
    if info.CustomTag and info.CustomTag ~= "" then details[#details + 1] = "Tag: " .. info.CustomTag end
    if not Persistent.Settings.CompactTooltip and info.Note and info.Note ~= "" then details[#details + 1] = "Note: " .. info.Note end

    if not Persistent.Settings.CompactTooltip
        and info.BudgetUpgradeCount
        and info.BudgetUpgradeCount > 0
    then
        details[#details + 1] =
            "Budget +" .. formatInt(info.BudgetUpgradeCount)
            .. " → " .. formatCompact(info.BudgetPotential)
    end

    local line2 = table.concat(details, "  •  ")

    text.Text = line2 ~= "" and (line1 .. "\n" .. line2) or line1
    extra.Visible = true
end

local function clearEquippedBindings()
    disconnectAll(Controller.EquippedConnections)
    for obj in pairs(Controller.EquippedBadgeObjects) do
        if obj and obj.Parent then
            pcall(function() obj.Parent:SetAttribute("DQEquippedQOLBound", nil) end)
            pcall(function() obj:Destroy() end)
        end
    end
    table.clear(Controller.EquippedBadgeObjects)
    Controller.HoveredEquippedInfo = nil
end

local function bindEquippedGuiObject(guiObject, info)
    if not guiObject or not guiObject:IsA("GuiObject") or not info or not info.IsEquipped then return end
    local existing = guiObject:FindFirstChild("DQEquippedPot")
    local badge = existing
    if not badge then
        badge = Instance.new("TextLabel")
        badge.Name = "DQEquippedPot"
        badge.AnchorPoint = Vector2.new(1, 1)
        badge.Position = UDim2.fromScale(0.98, 0.98)
        badge.Size = UDim2.new(0.76, 0, 0.22, 0)
        badge.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
        badge.BackgroundTransparency = 0.12
        badge.BorderSizePixel = 1
        badge.BorderColor3 = Color3.fromRGB(8, 8, 8)
        badge.Font = Enum.Font.GothamBlack
        badge.TextScaled = true
        badge.TextColor3 = Color3.fromRGB(245, 245, 245)
        badge.TextStrokeColor3 = Color3.new(0, 0, 0)
        badge.TextStrokeTransparency = 0
        badge.ZIndex = math.max(60, guiObject.ZIndex + 10)
        badge.Parent = guiObject
        Controller.EquippedBadgeObjects[badge] = true
    end
    badge.Text = "P " .. formatCompact(info.Potential or info.Current or 0)
    badge.Visible = not Persistent.Settings.HideBadges and not Persistent.Settings.HideUpgradeBadge

    if not guiObject:GetAttribute("DQEquippedQOLBound") then
        guiObject:SetAttribute("DQEquippedQOLBound", true)
        addConnection(Controller.EquippedConnections, guiObject.MouseEnter:Connect(function()
            Controller.HoveredEquippedInfo = info
            Controller.PinnedUID = Controller.PinnedUID or nil
            task.defer(updateHoveredTooltip)
            task.delay(0.05, updateHoveredTooltip)
        end))
        addConnection(Controller.EquippedConnections, guiObject.MouseLeave:Connect(function()
            if Controller.HoveredEquippedInfo == info then Controller.HoveredEquippedInfo = nil end
            if not Controller.HoveredCard and Controller.TooltipExtra then Controller.TooltipExtra.Visible = false end
        end))
    end
end

local function refreshEquippedUI()
    local gui = Controller.CurrentGui
    if not gui or not gui.Parent then return end
    local main = gui:FindFirstChild("mainBackground")
    local inner = main and main:FindFirstChild("innerBackground")
    if not inner then return end
    local direct = {}
    for _, obj in ipairs(inner:GetDescendants()) do
        if obj:IsA("GuiObject") and not (Controller.CurrentScroll and obj:IsDescendantOf(Controller.CurrentScroll)) then
            local t, n = getCardIdentity(obj)
            if t and n then
                local item = lookupItem(t, n)
                local uid = item and uidForItem(item)
                local info = uid and Controller.InventoryInfoByUID[uid]
                if info and info.IsEquipped then
                    direct[info.UID or tostring(t) .. ":" .. tostring(n)] = true
                    bindEquippedGuiObject(obj, info)
                end
            end
        end
    end
end

local function cleanupSellShop()
    disconnectAll(Controller.SellConnections)

    
    for card in pairs(Controller.SellHiddenByLock) do
        if card and card.Parent then
            pcall(function()
                card.Visible = true
            end)
        end
    end

    table.clear(Controller.SellHiddenByLock)
    Controller.CurrentSellGui = nil
    Controller.CurrentSellScroll = nil
end

local function findSellScroll(gui)
    local frame = gui and gui:FindFirstChild("Frame")
    local inner = frame and frame:FindFirstChild("innerFrame")
    local right = inner and inner:FindFirstChild("rightSideFrame")
    local scroll = right and right:FindFirstChild("ScrollingFrame")

    if scroll and scroll:IsA("ScrollingFrame") then
        return scroll
    end

    return nil
end

local function applySellCardLock(card)
    if not card or not card.Parent then
        return
    end

    local itemType, itemNumber = getCardIdentity(card)
    local item = itemType and lookupItem(itemType, itemNumber) or nil
    local uid = item and uidForItem(item) or nil

    if uid and Persistent.Locked[uid] then
        if card.Visible then
            Controller.SellHiddenByLock[card] = true
            card.Visible = false
        end
    elseif Controller.SellHiddenByLock[card] then
        
        Controller.SellHiddenByLock[card] = nil
        card.Visible = true
    end
end

local function bindSellCard(card)
    if not card:IsA("GuiObject") or not card:FindFirstChild("itemType") then
        return
    end

    applySellCardLock(card)

    local guard = false

    addConnection(Controller.SellConnections, card:GetPropertyChangedSignal("Visible"):Connect(function()
        if guard or not card.Parent then
            return
        end

        local itemType, itemNumber = getCardIdentity(card)
        local item = itemType and lookupItem(itemType, itemNumber) or nil
        local uid = item and uidForItem(item) or nil

        if uid and Persistent.Locked[uid] and card.Visible then
            guard = true
            Controller.SellHiddenByLock[card] = true
            card.Visible = false
            guard = false
        end
    end))
end

local function refreshSellShopLocks()
    local scroll = Controller.CurrentSellScroll
    if not scroll or not scroll.Parent then
        return
    end

    for _, child in ipairs(scroll:GetChildren()) do
        if child:IsA("GuiObject") and child:FindFirstChild("itemType") then
            applySellCardLock(child)
        end
    end
end

local function attachSellShop(gui)
    cleanupSellShop()

    local scroll = findSellScroll(gui)
    if not scroll then
        return
    end

    Controller.CurrentSellGui = gui
    Controller.CurrentSellScroll = scroll

    for _, child in ipairs(scroll:GetChildren()) do
        bindSellCard(child)
    end

    addConnection(Controller.SellConnections, scroll.ChildAdded:Connect(function(child)
        task.defer(function()
            if Controller.Alive and Controller.CurrentSellScroll == scroll then
                bindSellCard(child)
            end
        end)
    end))

    addConnection(Controller.SellConnections, gui.AncestryChanged:Connect(function(_, parent)
        if not parent and Controller.CurrentSellGui == gui then
            cleanupSellShop()
        end
    end))

    refreshSellShopLocks()
end





local function clearNewMarker(info)
    if info and info.UID and Persistent.NewIDs[info.UID] then
        Persistent.NewIDs[info.UID] = nil
        updateOverlay(info.Card, info)
    end
end

local function unbindCards(removeOverlays)
    disconnectAll(Controller.CardConnections)

    if removeOverlays then
        for card in pairs(Controller.CardInfo) do
            if card and card.Parent then
                local overlay = card:FindFirstChild("DQInventoryQOL")
                if overlay then
                    overlay:Destroy()
                end
            end
        end
    end

    table.clear(Controller.CardInfo)
    Controller.HoveredCard = nil
end

local function bindFavoriteButton(card, info)
    local overlay = getOrCreateOverlay(card)
    local star = overlay:FindFirstChild("Favorite")

    if not star or not star:IsA("TextButton") then
        return
    end

    addConnection(Controller.CardConnections, star.MouseButton1Click:Connect(function()
        if not info.UID then
            return
        end

        Persistent.Favorites[info.UID] =
            not Persistent.Favorites[info.UID]

        if not Persistent.Favorites[info.UID] then
            Persistent.Favorites[info.UID] = nil
        end

        saveDiskState()
        sortCards()
        refreshAllOverlays()
        updateHoveredTooltip()
    end))

    addConnection(Controller.CardConnections, star.MouseButton2Click:Connect(function()
        if not info.UID then
            return
        end

        Persistent.Locked[info.UID] =
            not Persistent.Locked[info.UID]

        if not Persistent.Locked[info.UID] then
            Persistent.Locked[info.UID] = nil
        end

        saveDiskState()
        sortCards()
        refreshAllOverlays()
        refreshSellShopLocks()
        updateHoveredTooltip()
    end))
end

local function bindCard(card)
    if not Controller.Alive or Controller.CardInfo[card] then
        return
    end

    if not card:IsA("GuiObject") then
        return
    end

    local itemType, itemNumber = getCardIdentity(card)
    if not itemType then
        return
    end

    local item = lookupItem(itemType, itemNumber)
    if not item then
        return
    end

    if Controller.OriginalCardOrder[card] == nil then
        Controller.OriginalCardOrder[card] = card.LayoutOrder
    end

    local info = {
        Card = card,
        ItemType = itemType,
        ItemNumber = itemNumber,
        Item = item,
    }

    Controller.CardInfo[card] = info
    local overlay = getOrCreateOverlay(card)
    bindFavoriteButton(card, info)

    local duplicateButton = overlay and overlay:FindFirstChild("Status")
    if duplicateButton and duplicateButton:IsA("TextButton") then
        addConnection(Controller.CardConnections, duplicateButton.MouseButton1Click:Connect(function()
            local currentInfo = Controller.CardInfo[card]
            if currentInfo and (currentInfo.DuplicateCount or 1) > 1
                and type(showDuplicateComparison) == "function"
            then
                showDuplicateComparison(currentInfo)
            end
        end))
    end

    local itemTypeValue = card:FindFirstChild("itemType")
    local numberValue = itemTypeValue
        and itemTypeValue:FindFirstChild("uniqueItemNum")

    if itemTypeValue and itemTypeValue:IsA("ValueBase") then
        addConnection(
            Controller.CardConnections,
            itemTypeValue:GetPropertyChangedSignal("Value"):Connect(function()
                if scheduleInventoryRefresh then
                    scheduleInventoryRefresh(0.05)
                end
            end)
        )
    end

    if numberValue and numberValue:IsA("ValueBase") then
        addConnection(
            Controller.CardConnections,
            numberValue:GetPropertyChangedSignal("Value"):Connect(function()
                if scheduleInventoryRefresh then
                    scheduleInventoryRefresh(0.05)
                end
            end)
        )
    end

    local visibilityGuard = false

    addConnection(Controller.CardConnections, card:GetPropertyChangedSignal("Visible"):Connect(function()
        if visibilityGuard or not card.Parent or not hasVisibilityFilter() then
            return
        end

        local target = shouldInfoBeVisible(Controller.CardInfo[card])

        if card.Visible ~= target then
            visibilityGuard = true
            card.Visible = target
            visibilityGuard = false
        end
    end))

    local layoutGuard = false

    addConnection(Controller.CardConnections, card:GetPropertyChangedSignal("LayoutOrder"):Connect(function()
        if layoutGuard or not card.Parent then
            return
        end

        local target = Controller.TargetLayoutOrder[card]
        if target and card.LayoutOrder ~= target then
            layoutGuard = true
            card.LayoutOrder = target
            layoutGuard = false
        end
    end))

    addConnection(Controller.CardConnections, card.MouseEnter:Connect(function()
        Controller.HoveredCard = card

        local currentInfo = Controller.CardInfo[card]
        if currentInfo and currentInfo.UID and Persistent.NewIDs[currentInfo.UID] then
            Persistent.NewIDs[currentInfo.UID] = nil
            saveDiskState()
            updateOverlay(card, currentInfo)
        end

        task.defer(updateHoveredTooltip)
        task.delay(0.03, updateHoveredTooltip)
        task.delay(0.10, updateHoveredTooltip)
    end))

    addConnection(Controller.CardConnections, card.MouseLeave:Connect(function()
        if Controller.HoveredCard == card then
            Controller.HoveredCard = nil
        end

        if Controller.TooltipExtra then
            Controller.TooltipExtra.Visible = false
        end
    end))
end

local function bindAllCards(scroll)
    for _, child in ipairs(scroll:GetChildren()) do
        bindCard(child)
    end
end





local function updateClassButtonVisuals()
    local bar = Controller.CurrentClassBar
    if not bar then
        return
    end

    for className, color in pairs(CLASS_COLORS) do
        local button = bar:FindFirstChild(className .. "Button")
        if button and button:IsA("TextButton") then
            local active = Controller.ClassFilter == className
            local inner = button:FindFirstChild("DQInner")

            button.TextColor3 = active
                and Color3.fromRGB(254, 254, 254)
                or Color3.fromRGB(121, 121, 121)

            if inner then
                setPlateColor(
                    inner,
                    active and color or color:Lerp(Color3.new(0, 0, 0), 0.35)
                )
            end
        end
    end
end

local bestModeButtonText

local function updateToolbarVisuals()
    local toolbar = Controller.CurrentToolbar
    if not toolbar then
        return
    end

    local sortButton = toolbar:FindFirstChild("SortButton")
    if sortButton and sortButton:IsA("TextButton") then
        if Controller.ClassFilter == "Skills" then
            sortButton.Text = "Level (Skills)"
        else
            sortButton.Text = Persistent.Settings.SortMode .. " ▼"
        end
    end

    local filterButton = toolbar:FindFirstChild("FilterButton")
    if filterButton and filterButton:IsA("TextButton") then
        local inner = filterButton:FindFirstChild("DQInner")
        if inner then
            setPlateColor(
                inner,
                hasExtraFilters() and Color3.fromRGB(92, 118, 165)
                    or Color3.fromRGB(75, 75, 75)
            )
        end
        filterButton.TextColor3 = hasExtraFilters()
            and Color3.fromRGB(254, 254, 254)
            or Color3.fromRGB(210, 210, 210)
    end

    local bestButton = toolbar:FindFirstChild("BestButton")
    if bestButton and bestButton:IsA("TextButton") then
        local inner = bestButton:FindFirstChild("DQInner")
        local active = Controller.BestMode ~= "Off"
        bestButton.Text = bestModeButtonText()
        if inner then
            local modeColor = Color3.fromRGB(75, 75, 75)
            if Controller.BestMode == "Now" then
                modeColor = Color3.fromRGB(65, 128, 160)
            elseif Controller.BestMode == "Potential" then
                modeColor = Color3.fromRGB(188, 145, 43)
            elseif Controller.BestMode == "Budget" then
                modeColor = Color3.fromRGB(79, 145, 92)
            end
            setPlateColor(inner, modeColor)
        end
        bestButton.TextColor3 = active
            and Color3.fromRGB(255, 255, 255)
            or Color3.fromRGB(210, 210, 210)
    end

    local actionBar = Controller.CurrentActionBar
    if actionBar then
        local queuedUpgrade = actionBar:FindFirstChild("AutoUpgradeButton")
        if queuedUpgrade and queuedUpgrade:IsA("TextButton") then
            if Controller.PendingAutoUpgradeClass then
                queuedUpgrade.Text =
                    "Queued: " .. Controller.PendingAutoUpgradeClass
            elseif getDQPlaceName() == "Level" then
                queuedUpgrade.Text = "Queue Upgrade"
            else
                queuedUpgrade.Text = "Auto Upgrade Best"
            end
        end

        local junkButton = actionBar:FindFirstChild("JunkOnlyButton")
        if junkButton and junkButton:IsA("TextButton") then
            local junkInner = junkButton:FindFirstChild("DQInner")
            junkButton.Text = Controller.JunkOnly and "Junk: ON" or "Junk"
            if junkInner then
                setPlateColor(
                    junkInner,
                    Controller.JunkOnly and Color3.fromRGB(166, 63, 63)
                        or Color3.fromRGB(82, 70, 70)
                )
            end
        end
    end
end

local function applyGridLayoutSettings()
    local scroll = Controller.CurrentScroll
    local grid = scroll and scroll:FindFirstChildOfClass("UIGridLayout")
    if not grid then return end
    local base = Controller.OriginalGridCellSize or grid.CellSize
    local factor = math.clamp(tonumber(Persistent.Settings.GridScale) or 100, 70, 140) / 100
    local columns = math.clamp(math.floor(tonumber(Persistent.Settings.GridColumns) or 0), 0, 12)
    local xScale = base.X.Scale * factor
    local xOffset = math.floor(base.X.Offset * factor)
    if columns > 0 then
        xScale = math.max(0.02, (1 / columns) - 0.012)
        xOffset = -4
    end
    grid.CellSize = UDim2.new(xScale, xOffset, base.Y.Scale * factor, math.floor(base.Y.Offset * factor))
end

local function applyAll()
    rebuildMetrics()
    applyGridLayoutSettings()
    sortCards()

    for card in pairs(Controller.CardInfo) do
        if card and card.Parent then
            forceCardVisibility(card)
        end
    end

    refreshAllOverlays()
    refreshEquippedUI()
    updateClassButtonVisuals()
    updateToolbarVisuals()
    updateHoveredTooltip()
end

local function makeClassButton(parent, className, order)
    local button, inner = makeNativeButton(parent, {
        Name = className .. "Button",
        LayoutOrder = order,
        Size = UDim2.new(0.222, 0, 0.82, 0),
        Text = className,
        InnerColor = CLASS_COLORS[className]:Lerp(
            Color3.new(0, 0, 0),
            0.35
        ),
        ZIndex = 23,
        MinTextSize = 11,
        MaxTextSize = 20,
    })

    addConnection(Controller.AttachConnections, button.MouseButton1Click:Connect(function()
        if Controller.ClassFilter == className then
            Controller.ClassFilter = nil
        else
            Controller.ClassFilter = className
        end

        if Controller.ClassFilter == "Skills" then
            Controller.BestMode = "Off"
            Controller.BestLoadout = false
        end

        saveDiskState()
        applyAll()
    end))

    return button
end

local function makeClassBar(rightSide)
    local old = rightSide:FindFirstChild("DQClassSortBar")
    if old then
        old:Destroy()
    end

    local bar = Instance.new("Frame")
    bar.Name = "DQClassSortBar"
    bar.AnchorPoint = Vector2.new(0.5, 0)
    bar.Position = UDim2.new(0.5, 0, 0.012, 0)
    bar.Size = UDim2.new(0.96, 0, 0.085, 0)
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel = 0
    bar.ClipsDescendants = false
    bar.ZIndex = 20
    bar.Parent = rightSide

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0.015, 0)
    padding.PaddingRight = UDim.new(0.015, 0)
    padding.Parent = bar

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0.018, 0)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = bar

    makeClassButton(bar, "Mage", 1)
    makeClassButton(bar, "Warrior", 2)
    makeClassButton(bar, "Tank", 3)
    makeClassButton(bar, "Skills", 4)

    return bar
end

local function closePopups()
    if Controller.CurrentSortPopup then
        Controller.CurrentSortPopup.Visible = false
    end
    if Controller.CurrentFilterPopup then
        Controller.CurrentFilterPopup.Visible = false
    end
    if Controller.CurrentConfirmPopup then
        Controller.CurrentConfirmPopup.Visible = false
    end
    if Controller.CurrentMorePopup then
        Controller.CurrentMorePopup.Visible = false
    end
    if Controller.CurrentDuplicatePopup then
        Controller.CurrentDuplicatePopup.Visible = false
    end
end

local function makePopupPlate(parent, name, position, size)
    
    
    
    
    local popup = Instance.new("Frame")
    popup.Name = name
    popup.Position = position
    popup.Size = size
    popup.BackgroundTransparency = 0
    popup.BackgroundColor3 = Color3.fromRGB(27, 27, 27)
    popup.BorderSizePixel = 0
    popup.ClipsDescendants = false
    popup.ZIndex = 80
    popup.Visible = false
    popup.Parent = parent

    local popupStroke = Instance.new("UIStroke")
    popupStroke.Name = "DQPopupStroke"
    popupStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    popupStroke.Color = Color3.fromRGB(10, 10, 10)
    popupStroke.Thickness = 2
    popupStroke.Transparency = 0.05
    popupStroke.Parent = popup

    local inner = Instance.new("Frame")
    inner.Name = "Inner"
    inner.AnchorPoint = Vector2.new(0.5, 0.5)
    inner.Position = UDim2.fromScale(0.5, 0.5)
    inner.Size = UDim2.fromScale(0.96, 0.94)
    inner.BackgroundTransparency = 0
    inner.BackgroundColor3 = Color3.fromRGB(54, 54, 54)
    inner.BorderSizePixel = 0
    inner.ClipsDescendants = false
    inner.ZIndex = 81
    inner.Parent = popup

    local innerStroke = Instance.new("UIStroke")
    innerStroke.Name = "DQInnerStroke"
    innerStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    innerStroke.Color = Color3.fromRGB(18, 18, 18)
    innerStroke.Thickness = 1
    innerStroke.Transparency = 0.15
    innerStroke.Parent = inner

    return popup, inner
end

local function buildSortPopup(rightSide)
    local popup, inner = makePopupPlate(
        rightSide,
        "DQSortPopup",
        UDim2.new(0.40, 0, 0.225, 0),
        UDim2.new(0.32, 0, 0.46, 0)
    )

    local content = Instance.new("ScrollingFrame")
    content.Name = "Content"
    content.AnchorPoint = Vector2.new(0.5, 0.5)
    content.Position = UDim2.fromScale(0.5, 0.5)
    content.Size = UDim2.fromScale(0.90, 0.92)
    content.BackgroundTransparency = 1
    content.BorderSizePixel = 0
    content.ClipsDescendants = true
    content.ScrollBarThickness = 4
    content.CanvasSize = UDim2.new(0, 0, 0, 0)
    content.AutomaticCanvasSize = Enum.AutomaticSize.Y
    content.ZIndex = 82
    content.Parent = inner

    local list = Instance.new("UIListLayout")
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.VerticalAlignment = Enum.VerticalAlignment.Top
    list.Padding = UDim.new(0, 3)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = content

    for index, mode in ipairs(SORT_MODES) do
        local selected = Persistent.Settings.SortMode == mode
        local button = makeNativeButton(content, {
            Name = "Sort_" .. mode:gsub("[^%w]", ""),
            LayoutOrder = index,
            Size = UDim2.new(0.94, 0, 0, 29),
            Text = mode,
            InnerColor = selected and Color3.fromRGB(89, 105, 130) or Color3.fromRGB(72, 72, 72),
            ZIndex = 84,
            MinTextSize = 9,
            MaxTextSize = 14,
        })

        addConnection(Controller.AttachConnections, button.MouseButton1Click:Connect(function()
            Persistent.Settings.SortMode = mode
            saveDiskState()
            popup.Visible = false
            applyAll()
        end))
    end

    return popup
end

local function filterButtonText(name, enabled)
    return name .. ": " .. (enabled and "ON" or "OFF")
end

local function buildFilterPopup(rightSide)
    local popup, inner = makePopupPlate(
        rightSide,
        "DQFilterPopup",
        UDim2.new(0.58, 0, 0.225, 0),
        UDim2.new(0.40, 0, 0.52, 0)
    )

    local content = Instance.new("Frame")
    content.AnchorPoint = Vector2.new(0.5, 0.5)
    content.Position = UDim2.fromScale(0.5, 0.5)
    content.Size = UDim2.fromScale(0.90, 0.92)
    content.BackgroundTransparency = 1
    content.ClipsDescendants = false
    content.ZIndex = 82
    content.Parent = inner

    local list = Instance.new("UIListLayout")
    list.FillDirection = Enum.FillDirection.Vertical
    list.HorizontalAlignment = Enum.HorizontalAlignment.Center
    list.VerticalAlignment = Enum.VerticalAlignment.Center
    list.Padding = UDim.new(0.018, 0)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = content

    local definitions = {
        {"HideCommon", "Hide Common"},
        {"HideAbilities", "Hide Abilities"},
        {"OnlyUpgradable", "Only Upgradable"},
        {"OnlyEquipable", "Equipable Only"},
        {"GroupDupes", "Group Dupes"},
        {"HideJunk", "Hide Junk"},
    }

    local toggleButtons = {}

    local function refreshToggleText()
        for _, def in ipairs(definitions) do
            local key, label = def[1], def[2]
            local button = toggleButtons[key]

            if button then
                button.Text = filterButtonText(
                    label,
                    Persistent.Settings[key] == true
                )

                local bg = button:FindFirstChild("DQInner")
                if bg then
                    setPlateColor(
                        bg,
                        Persistent.Settings[key] and Color3.fromRGB(83, 105, 145)
                            or Color3.fromRGB(72, 72, 72)
                    )
                end
            end
        end
    end

    for index, def in ipairs(definitions) do
        local key, label = def[1], def[2]

        local button = makeNativeButton(content, {
            Name = key,
            LayoutOrder = index,
            Size = UDim2.new(0.96, 0, 0.095, 0),
            Text = filterButtonText(label, Persistent.Settings[key]),
            InnerColor = Persistent.Settings[key] == true
                and Color3.fromRGB(83, 105, 145)
                or Color3.fromRGB(72, 72, 72),
            ZIndex = 84,
            MinTextSize = 9,
            MaxTextSize = 14,
        })

        toggleButtons[key] = button

        addConnection(Controller.AttachConnections, button.MouseButton1Click:Connect(function()
            Persistent.Settings[key] = not Persistent.Settings[key]

            if key == "HideJunk" and Persistent.Settings.HideJunk then
                Controller.JunkOnly = false
            end

            saveDiskState()
            refreshToggleText()
            applyAll()
        end))
    end

    local levelHolder, levelBox = makeNativeInput(content, {
        Name = "MinLevel",
        LayoutOrder = 7,
        Size = UDim2.new(0.96, 0, 0.095, 0),
        Text = (Persistent.Settings.MinLevel or 0) > 0
            and tostring(math.floor(Persistent.Settings.MinLevel))
            or "",
        Placeholder = "Min Level",
        ZIndex = 84,
        TextXAlignment = Enum.TextXAlignment.Center,
    })

    addConnection(Controller.AttachConnections, levelBox.FocusLost:Connect(function()
        local value = math.max(0, math.floor(tonumber(levelBox.Text) or 0))
        Persistent.Settings.MinLevel = value
        levelBox.Text = value > 0 and tostring(value) or ""
        saveDiskState()
        applyAll()
    end))

    local hint = Instance.new("TextLabel")
    hint.Name = "Hint"
    hint.LayoutOrder = 8
    hint.Size = UDim2.new(0.96, 0, 0.09, 0)
    hint.BackgroundTransparency = 1
    hint.Font = Enum.Font.Highway
    hint.TextScaled = true
    hint.TextWrapped = true
    hint.Text = "Click = Favorite   •   Right-click = Lock"
    hint.TextColor3 = Color3.fromRGB(210, 210, 210)
    hint.TextStrokeColor3 = Color3.new(0, 0, 0)
    hint.TextStrokeTransparency = 0
    hint.ZIndex = 84
    hint.Parent = content

    refreshToggleText()

    return popup
end

local searchSaveGeneration = 0

local function scheduleSearchSave()
    searchSaveGeneration += 1
    local generation = searchSaveGeneration

    task.delay(0.35, function()
        if Controller.Alive and generation == searchSaveGeneration then
            saveDiskState()
        end
    end)
end

local toggleMorePopup
local refreshMorePopup

local BEST_MODE_ORDER = {"Off", "Now", "Potential", "Budget"}

local function cycleBestMode()
    local current = Controller.BestMode or "Off"
    local nextMode = "Off"
    for index, mode in ipairs(BEST_MODE_ORDER) do
        if mode == current then
            nextMode = BEST_MODE_ORDER[(index % #BEST_MODE_ORDER) + 1]
            break
        end
    end
    Controller.BestMode = nextMode
    Controller.BestLoadout = nextMode ~= "Off"
end

bestModeButtonText = function()
    if Controller.BestMode == "Now" then
        return "Best: Now"
    elseif Controller.BestMode == "Potential" then
        return "Best: Pot"
    elseif Controller.BestMode == "Budget" then
        return "Best: $"
    end
    return "Best: Off"
end

local function makeToolbar(rightSide)
    local old = rightSide:FindFirstChild("DQInventoryToolbar")
    if old then
        old:Destroy()
    end

    local toolbar = Instance.new("Frame")
    toolbar.Name = "DQInventoryToolbar"
    toolbar.AnchorPoint = Vector2.new(0.5, 0)
    toolbar.Position = UDim2.new(0.5, 0, 0.102, 0)
    toolbar.Size = UDim2.new(0.96, 0, 0.062, 0)
    toolbar.BackgroundTransparency = 1
    toolbar.BorderSizePixel = 0
    toolbar.ClipsDescendants = false
    toolbar.ZIndex = 30
    toolbar.Parent = rightSide

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0.010, 0)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = toolbar

    local _, searchBox = makeNativeInput(toolbar, {
        Name = "Search",
        LayoutOrder = 1,
        Size = UDim2.new(0.275, 0, 0.96, 0),
        Text = Controller.SearchText,
        Placeholder = "Search items...",
        ZIndex = 35,
        TextXAlignment = Enum.TextXAlignment.Left,
    })

    addConnection(Controller.AttachConnections, searchBox:GetPropertyChangedSignal("Text"):Connect(function()
        Controller.SearchText = lower(searchBox.Text)
        scheduleSearchSave()
        applyAll()
    end))

    local sortButton = makeNativeButton(toolbar, {
        Name = "SortButton",
        LayoutOrder = 2,
        Size = UDim2.new(0.215, 0, 0.96, 0),
        Text = Persistent.Settings.SortMode .. " ▼",
        InnerColor = Color3.fromRGB(75, 75, 75),
        ZIndex = 35,
        MinTextSize = 8,
        MaxTextSize = 14,
    })

    local filterButton = makeNativeButton(toolbar, {
        Name = "FilterButton",
        LayoutOrder = 3,
        Size = UDim2.new(0.145, 0, 0.96, 0),
        Text = "Filters",
        InnerColor = Color3.fromRGB(75, 75, 75),
        ZIndex = 35,
        MinTextSize = 8,
        MaxTextSize = 15,
    })

    local bestButton = makeNativeButton(toolbar, {
        Name = "BestButton",
        LayoutOrder = 4,
        Size = UDim2.new(0.175, 0, 0.96, 0),
        Text = bestModeButtonText(),
        InnerColor = Color3.fromRGB(75, 75, 75),
        ZIndex = 35,
        MinTextSize = 8,
        MaxTextSize = 14,
    })

    local moreButton = makeNativeButton(toolbar, {
        Name = "MoreButton",
        LayoutOrder = 5,
        Size = UDim2.new(0.095, 0, 0.96, 0),
        Text = "More",
        InnerColor = Color3.fromRGB(75, 75, 75),
        ZIndex = 35,
        MinTextSize = 8,
        MaxTextSize = 14,
    })

    addConnection(Controller.AttachConnections, sortButton.MouseButton1Click:Connect(function()
        if Controller.ClassFilter == "Skills" then
            closePopups()
            return
        end

        local popup = Controller.CurrentSortPopup
        local opening = popup and not popup.Visible
        closePopups()
        if popup then
            popup.Visible = opening == true
        end
    end))

    addConnection(Controller.AttachConnections, filterButton.MouseButton1Click:Connect(function()
        local popup = Controller.CurrentFilterPopup
        local opening = popup and not popup.Visible
        closePopups()
        if popup then
            popup.Visible = opening == true
        end
    end))

    addConnection(Controller.AttachConnections, bestButton.MouseButton1Click:Connect(function()
        if Controller.ClassFilter == "Skills" then
            Controller.BestMode = "Off"
            Controller.BestLoadout = false
        else
            cycleBestMode()
        end
        saveDiskState()
        closePopups()
        applyAll()
    end))

    addConnection(Controller.AttachConnections, moreButton.MouseButton1Click:Connect(function()
        if type(toggleMorePopup) == "function" then
            toggleMorePopup()
        end
    end))

    return toolbar
end






local reindexCards
local clearPendingAutoUpgrade
local updateActionVisuals

local function nativeAlert(message)
    local ui = ReplicatedStorage:FindFirstChild("ui")
    local template = ui and ui:FindFirstChild("alert")
    local alertBox = playerGui:FindFirstChild("alertBox")

    if template and alertBox then
        local frame = alertBox:FindFirstChild("Frame")
        if frame then
            local clone = template:Clone()
            local label = clone:FindFirstChild("TextLabel")

            if label and label:IsA("TextLabel") then
                label.Text = tostring(message)
            end

            clone.Parent = frame
            game:GetService("Debris"):AddItem(clone, 3)
            return
        end
    end

    print("[DQ Inventory QOL] " .. tostring(message))
end

local function setActionProgress(textValue)
    Controller.ActionProgressText = tostring(textValue or "Idle")
    local strip = Controller.CurrentActionProgress
    local label = strip and strip:FindFirstChild("Status")
    if label and label:IsA("TextLabel") then
        label.Text = Controller.ActionProgressText
    end
end

local function logAction(kind, requested, confirmed, details)
    local entry = {
        Time = os.date("%H:%M:%S"),
        Kind = tostring(kind or "Action"),
        Requested = requested,
        Confirmed = confirmed,
        Details = tostring(details or ""),
    }
    table.insert(Controller.ActionLog, 1, entry)
    while #Controller.ActionLog > 30 do
        table.remove(Controller.ActionLog)
    end
    if type(refreshMorePopup) == "function" then
        pcall(refreshMorePopup)
    end
end

local function requestStopAction()
    if not Controller.ActionBusy then
        setActionProgress("Idle")
        nativeAlert("No inventory action is currently running.")
        return
    end

    Controller.ActionCancelRequested = true
    setActionProgress("Stop requested — current request will finish first.")
    nativeAlert("Stop requested. No new requests will be sent after the current one.")
end

local function selectedBestTargets()
    local className = Controller.ClassFilter

    if className ~= "Mage"
        and className ~= "Warrior"
        and className ~= "Tank"
    then
        return nil, "Select Mage, Warrior, or Tank first."
    end

    rebuildMetrics()

    local mode = Controller.BestMode ~= "Off" and Controller.BestMode or "Potential"
    local modeMap = Controller.BestByMode[mode] or Controller.BestByMode.Potential or {}
    local targets = {}
    local order = {"weapon", "chest", "helmet"}

    local equippedBySlot = {}
    for _, candidate in ipairs(Controller.InventoryInfos or {}) do
        local slot = slotForType(candidate.ItemType)
        if slot and candidate.IsEquipped then equippedBySlot[slot] = candidate end
    end

    for _, slot in ipairs(order) do
        local info = modeMap[className .. ":" .. slot]
        local equipped = equippedBySlot[slot]
        if info and info.IsEquipable then
            local accepted = true
            if equipped and info ~= equipped and not info.IsEquipped then
                local candidateScore = mode == "Now" and (info.Current or 0) or mode == "Budget" and (info.BudgetPotential or 0) or (info.Potential or 0)
                local equippedScore = mode == "Now" and (equipped.Current or 0) or mode == "Budget" and (equipped.BudgetPotential or equipped.Current or 0) or (equipped.Potential or equipped.Current or 0)
                local gain = candidateScore - equippedScore
                local pct = gain / math.max(1, math.abs(equippedScore)) * 100
                if gain < (tonumber(Persistent.Settings.MinImprovementFlat) or 0) then accepted = false end
                if pct < (tonumber(Persistent.Settings.MinImprovementPct) or 0) then accepted = false end
                if Persistent.Settings.RequireBetterNow and (info.Current or 0) <= (equipped.Current or 0) then accepted = false end
            end
            targets[#targets + 1] = accepted and info or equipped or info
        end
    end

    if #targets == 0 then
        return nil, "No equipable best gear was found for " .. className .. "."
    end

    return targets
end

local function locateLiveCard(itemType, itemNumber)
    for card, info in pairs(Controller.CardInfo) do
        if card
            and card.Parent
            and info.ItemType == itemType
            and info.ItemNumber == itemNumber
        then
            return card
        end
    end

    local scroll = Controller.CurrentScroll
    if scroll then
        for _, card in ipairs(scroll:GetChildren()) do
            if card:IsA("GuiObject") and card:FindFirstChild("itemType") then
                local t, n = getCardIdentity(card)
                if t == itemType and n == itemNumber then
                    return card
                end
            end
        end
    end

    return nil
end

local function triggerNativeGearClick(info)
    local card = locateLiveCard(info.ItemType, info.ItemNumber)
    local button = card and card:FindFirstChild("button")

    if not button or not button:IsA("GuiButton") then
        return false
    end

    if type(firesignal) == "function" then
        local ok = pcall(firesignal, button.MouseButton1Click)
        if ok then
            return true
        end
    end

    if type(getconnections) == "function" then
        local ok, connections = pcall(getconnections, button.MouseButton1Click)

        if ok and type(connections) == "table" then
            for _, connection in ipairs(connections) do
                local fn = connection.Function
                if type(fn) == "function" then
                    local worked = pcall(fn)
                    if worked then
                        return true
                    end
                end
            end
        end
    end

    return false
end

local function autoEquipBest()
    if Controller.ActionBusy then
        return
    end

    if reindexCards then
        pcall(reindexCards)
    end

    local targets, err = selectedBestTargets()
    if not targets then
        nativeAlert(err)
        return
    end

    Controller.ActionBusy = true
    Controller.ActionCancelRequested = false
    setActionProgress("Auto Equip: preparing...")

    task.spawn(function()
        local equippedCount = 0
        local requestedCount = 0
        local requestedUIDs = {}

        for _, info in ipairs(targets) do
            if Controller.ActionCancelRequested then
                break
            end

            if not info.IsEquipped then
                requestedCount += 1
                requestedUIDs[#requestedUIDs + 1] = tostring(info.UID or "?")
                setActionProgress(
                    "Auto Equip: "
                    .. tostring(info.Name)
                    .. " ("
                    .. tostring(slotForType(info.ItemType) or info.ItemType)
                    .. ")"
                )

                if triggerNativeGearClick(info) then
                    equippedCount += 1
                    if info.UID then Controller.RecentlyEquippedUIDs[info.UID] = os.time() end
                    Controller.SessionStats.Equipped = (Controller.SessionStats.Equipped or 0) + 1
                end

                task.wait(0.18)
            end
        end

        task.wait(0.25)
        Controller.ActionBusy = false

        if Controller.Alive and reindexCards then
            pcall(reindexCards)
        end

        local stopped = Controller.ActionCancelRequested
        Controller.ActionCancelRequested = false
        setActionProgress("Idle")

        logAction(
            "Auto Equip",
            requestedCount,
            equippedCount,
            (#requestedUIDs > 0 and ("UIDs: " .. table.concat(requestedUIDs, ", ")) or "No changes")
                .. (stopped and " | stopped by user" or "")
        )

        if requestedCount == 0 then
            nativeAlert(
                "Auto Equip Best: your selected "
                .. tostring(Controller.BestMode ~= "Off" and Controller.BestMode or "Potential")
                .. " "
                .. tostring(Controller.ClassFilter or "")
                .. " gear is already equipped."
            )
        else
            nativeAlert(
                "Auto Equip Best: requested "
                .. tostring(requestedCount)
                .. ", native clicks sent "
                .. tostring(equippedCount)
                .. (stopped and ". Stopped before remaining pieces." or ".")
            )
        end
    end)
end

local function statChoiceForClass(className)
    if className == "Mage" then
        return "spell"
    elseif className == "Warrior" then
        return "physical"
    elseif className == "Tank" then
        return "health"
    end

    return nil
end

local function isAuthoritativeSnapshot(snapshot)
    if type(snapshot) ~= "table" then
        return false
    end
    
    for _, name in ipairs({"weapons", "chests", "helmets", "abilities"}) do
        if type(snapshot[name]) ~= "table" then
            return false
        end
    end
    return true
end

local function refreshActionInventory()
    local snapshot = findInventoryDataFromModule()
    if not isAuthoritativeSnapshot(snapshot) then
        return nil
    end
    Controller.InventoryData = snapshot
    return snapshot
end

local function snapshotItemByUID(snapshot, itemType, uid)
    local typeInfo = TYPE_INFO[itemType]
    local container = typeInfo and snapshot and snapshot[typeInfo.container]
    if type(container) ~= "table" or not uid then
        return nil
    end
    for key, item in pairs(container) do
        if type(item) == "table" and uidForItem(item) == uid then
            local number = tonumber(key)
            if not number and type(key) == "string" then
                number = tonumber(string.match(key, "^" .. typeInfo.prefix .. "(%d+)$"))
            end
            return item, number and nonNegativeInteger(number) or nil
        end
    end
    return nil
end

local function currentGold()
    return currentGoldValue()
end

local function synchronizeActionCards(snapshot)
    Controller.InventoryData = snapshot
    for card, info in pairs(Controller.CardInfo) do
        local liveType, liveNumber = getCardIdentity(card)
        local liveItem = liveType and lookupItem(liveType, liveNumber)
        if liveItem then
            info.ItemType, info.ItemNumber, info.Item = liveType, liveNumber, liveItem
        else
            Controller.CardInfo[card] = nil
            Controller.TargetLayoutOrder[card] = nil
            local overlay = card and card:FindFirstChild("DQInventoryQOL")
            if overlay then
                overlay:Destroy()
            end
        end
    end
end

local function waitForUpgradeOutcome(entry, beforeGold, timeout)
    local deadline = os.clock() + timeout
    local latestItem, latestGold
    while Controller.Alive and os.clock() < deadline do
        task.wait(0.25)
        local snapshot = refreshActionInventory()
        if snapshot then
            local item = snapshotItemByUID(snapshot, entry.ItemType, entry.UID)
            local gold = currentGold()
            if item then
                latestItem, latestGold = item, gold
                local current = upgradeBounds(item)
                if current >= entry.CurrentUpgrade + entry.Amount
                    and gold ~= nil
                    and gold == beforeGold - entry.PlannedCost
                then
                    return latestItem, latestGold, true
                end
            end
        end
    end
    return latestItem, latestGold, false
end

local function waitForSaleOutcome(entries, timeout)
    local deadline = os.clock() + timeout
    local confirmed = {}
    local confirmedCount = 0
    while Controller.Alive and os.clock() < deadline do
        task.wait(0.25)
        local snapshot = refreshActionInventory()
        if snapshot then
            for _, entry in ipairs(entries) do
                if not confirmed[entry.UID]
                    and not snapshotItemByUID(snapshot, entry.ItemType, entry.UID)
                then
                    confirmed[entry.UID] = true
                    confirmedCount = confirmedCount + 1
                end
            end
            if confirmedCount == #entries then
                return confirmed, true
            end
        end
    end
    return confirmed, false
end

local function buildUpgradePlan()
    local targets, err = selectedBestTargets()
    if not targets then
        return nil, err
    end

    local statChoice = statChoiceForClass(Controller.ClassFilter)
    if not statChoice then
        return nil, "Select a class first."
    end

    local targetPct = math.clamp(
        tonumber(Persistent.Settings.TargetUpgradePct) or 100,
        0,
        100
    )

    local entries = {}
    for _, info in ipairs(targets) do
        local slot = slotForType(info.ItemType)
        local current, maximum = upgradeBounds(info.Item)
        local targetMaximum = maximum

        if maximum > 0 and targetPct < 100 then
            targetMaximum = math.floor(maximum * targetPct / 100)
            targetMaximum = math.clamp(targetMaximum, 0, maximum)
        end

        if slot
            and slotUpgradeEnabled(slot)
            and current < targetMaximum
            and info.UID
            and info.Field
            and info.IsEquipable
            and not (statChoice == "health" and info.ItemType == "weapon")
        then
            local validField =
                (statChoice == "health" and info.Field == "health")
                or (statChoice == "spell" and info.Field == "spellPower")
                or (
                    statChoice == "physical"
                    and (
                        info.Field == "physicalDamage"
                        or info.Field == "physicalPower"
                    )
                )

            if validField then
                entries[#entries + 1] = {
                    UID = info.UID,
                    ItemType = info.ItemType,
                    ItemNumber = info.ItemNumber,
                    Slot = slot,
                    Name = info.Name,
                    Item = info.Item,
                    Field = info.Field,
                    Stat = statChoice,
                    MaxAllowedUpgrade = targetMaximum,
                }
            end
        end
    end

    if #entries == 0 then
        return nil,
            "No selected, equipable best gear has upgrades remaining under the "
            .. formatInt(targetPct)
            .. "% target."
    end

    return entries
end


local function executeUpgradePlan(plan)
    if Controller.ActionBusy then
        return
    end
    if not plan or not plan.Entries or #plan.Entries == 0 then
        return
    end

    local remotes = ReplicatedStorage:FindFirstChild("remotes")
    local upgradeRemote = remotes and remotes:FindFirstChild("upgradeItem")
    if not upgradeRemote or not upgradeRemote:IsA("RemoteEvent") then
        Controller.PendingAutoUpgradeRunning = false
        nativeAlert("upgradeItem remote was not found.")
        logAction("Auto Upgrade", plan.PlannedUpgrades or 0, 0, "upgradeItem remote missing")
        return
    end

    Controller.ActionBusy = true
    Controller.ActionCancelRequested = false
    setActionProgress("Auto Upgrade: validating quote...")

    task.spawn(function()
        local actualPurchased = 0
        local changedPieces = 0
        local stopReason
        local detailLines = {}

        local ok, err = pcall(function()
            if not isUpgradeCapablePlace() then
                stopReason = "Upgrading requires a recognized Lobby server."
                return
            end

            local snapshot = refreshActionInventory()
            if not snapshot then
                stopReason = "A fresh server inventory could not be verified."
                return
            end

            local confirmedGold = nonNegativeInteger(plan.ConfirmedGold or plan.GoldBudget)
            if currentGold() ~= confirmedGold then
                stopReason = "Gold changed since confirmation. Request a new plan."
                return
            end

            
            for _, entry in ipairs(plan.Entries) do
                local item, number = snapshotItemByUID(snapshot, entry.ItemType, entry.UID)
                local current, maximum = upgradeBounds(item)
                if not item
                    or not number
                    or current ~= entry.CurrentUpgrade
                    or maximum ~= entry.MaxUpgrades
                    or tonumber(item[entry.Field]) ~= entry.CurrentStat
                then
                    stopReason = "Gear changed since confirmation. Request a new plan."
                    return
                end
            end

            local expectedGold = confirmedGold

            for index, entry in ipairs(plan.Entries) do
                if not Controller.Alive then
                    stopReason = "The script was stopped."
                    break
                end
                if Controller.ActionCancelRequested then
                    stopReason = "Stopped by user before the next request."
                    break
                end

                setActionProgress(
                    "Upgrade "
                    .. tostring(index)
                    .. "/"
                    .. tostring(#plan.Entries)
                    .. ": "
                    .. tostring(entry.Name)
                    .. " +"
                    .. formatInt(entry.Amount)
                )

                snapshot = refreshActionInventory()
                local item, number = snapshotItemByUID(snapshot, entry.ItemType, entry.UID)
                local current, maximum = upgradeBounds(item)
                local beforeGold = currentGold()

                if not snapshot
                    or not item
                    or not number
                    or current ~= entry.CurrentUpgrade
                    or maximum ~= entry.MaxUpgrades
                    or tonumber(item[entry.Field]) ~= entry.CurrentStat
                    or beforeGold ~= expectedGold
                    or beforeGold < entry.PlannedCost
                then
                    stopReason = "Inventory or gold changed; remaining requests were cancelled."
                    break
                end

                
                upgradeRemote:FireServer(
                    entry.ItemType,
                    number,
                    entry.Stat,
                    entry.Amount
                )

                local afterItem, afterGold, settled =
                    waitForUpgradeOutcome(entry, beforeGold, 6)
                local afterCurrent =
                    afterItem and select(1, upgradeBounds(afterItem))
                    or entry.CurrentUpgrade
                local purchased = math.max(0, afterCurrent - entry.CurrentUpgrade)

                actualPurchased += purchased
                if purchased > 0 then
                    changedPieces += 1
                    if entry.UID then Controller.RecentlyUpgradedUIDs[entry.UID] = os.time() end
                    Controller.SessionStats.Upgrades = (Controller.SessionStats.Upgrades or 0) + purchased
                    Controller.SessionStats.UpgradeGold = (Controller.SessionStats.UpgradeGold or 0) + math.max(0, (beforeGold or 0) - (afterGold or beforeGold))
                end

                detailLines[#detailLines + 1] =
                    tostring(entry.Name)
                    .. " UID "
                    .. tostring(entry.UID)
                    .. ": requested "
                    .. formatInt(entry.Amount)
                    .. ", confirmed "
                    .. formatInt(purchased)

                if not settled or purchased ~= entry.Amount then
                    stopReason =
                        "Server result differed from the quote or was not confirmed; no retry was sent."
                    break
                end

                if tonumber(afterItem[entry.Field])
                    ~= entry.CurrentStat + entry.PlannedGain
                then
                    stopReason =
                        "The server's stat gain differed from the estimate; remaining requests were cancelled."
                    break
                end

                if afterGold ~= beforeGold - entry.PlannedCost then
                    stopReason =
                        "The gold change differed from the cost estimate; remaining requests were cancelled."
                    break
                end

                expectedGold = afterGold
            end
        end)

        Controller.ActionBusy = false
        Controller.PendingAutoUpgradeRunning = false

        if not ok then
            stopReason =
                "An error stopped the action; check the native inventory before trying again."
            warn("[DQ Inventory QOL v19.1] upgrade stopped:", err)
        end

        if actualPurchased > 0
            and Controller.PendingAutoUpgradeClass == plan.ClassName
        then
            pcall(clearPendingAutoUpgrade)
        end

        if Controller.Alive and reindexCards then
            pcall(reindexCards)
        end

        local stoppedByUser = Controller.ActionCancelRequested
        Controller.ActionCancelRequested = false
        setActionProgress("Idle")

        local logDetails = table.concat(detailLines, " | ")
        if stopReason then
            logDetails ..= (logDetails ~= "" and " | " or "") .. stopReason
        elseif stoppedByUser then
            logDetails ..= (logDetails ~= "" and " | " or "") .. "Stopped by user"
        end

        logAction(
            "Auto Upgrade",
            plan.PlannedUpgrades or 0,
            actualPurchased,
            logDetails
        )

        local message =
            "Auto Upgrade Best: confirmed "
            .. formatInt(actualPurchased)
            .. " upgrade"
            .. (actualPurchased == 1 and "" or "s")
            .. " across "
            .. tostring(changedPieces)
            .. " piece"
            .. (changedPieces == 1 and "." or "s.")

        if stopReason then
            message ..= " " .. stopReason
        end

        nativeAlert(message)
    end)
end

local function showConfirmation(titleText, bodyText, callback)
    local popup = Controller.CurrentConfirmPopup
    if not popup then
        return false
    end

    local title = popup:FindFirstChild("Title", true)
    local body = popup:FindFirstChild("Body", true)

    if title and title:IsA("TextLabel") then
        title.Text = titleText
    end

    if body and body:IsA("TextLabel") then
        body.Text = bodyText
    end

    if Controller.TooltipExtra then
        Controller.TooltipExtra.Visible = false
    end
    Controller.ConfirmAction = callback
    popup.Visible = true
    return true
end


local function queueAutoUpgradeForLobby(className)
    if className ~= "Mage"
        and className ~= "Warrior"
        and className ~= "Tank"
    then
        nativeAlert("Select Mage, Warrior, or Tank first.")
        return false
    end

    Controller.PendingAutoUpgradeClass = className
    saveDiskState()
    updateActionVisuals()

    nativeAlert(
        "Auto Upgrade Best: "
        .. className
        .. " upgrade queued for the lobby."
    )

    return true
end

clearPendingAutoUpgrade = function()
    Controller.PendingAutoUpgradeClass = nil
    saveDiskState()
    updateActionVisuals()
end

local function requestAutoUpgradeBest()
    if Controller.ActionBusy then
        return false
    end

    local selectedClass = Controller.ClassFilter
    if selectedClass ~= "Mage" and selectedClass ~= "Warrior" and selectedClass ~= "Tank" then
        nativeAlert("Select Mage, Warrior, or Tank first.")
        return false
    end

    if getDQPlaceName() == "Level" then
        queueAutoUpgradeForLobby(selectedClass)
        return false
    end

    if not isUpgradeCapablePlace() then
        nativeAlert("Cannot verify this server as a Lobby; no upgrade request was sent.")
        return false
    end

    if reindexCards then
        pcall(reindexCards)
    end

    local snapshot = refreshActionInventory()
    if not snapshot then
        nativeAlert("Cannot verify a fresh server inventory; no upgrade request was sent.")
        return false
    end

    synchronizeActionCards(snapshot)

    local entries, err = buildUpgradePlan()
    if not entries then
        nativeAlert(err)
        return false
    end

    local gold = currentGold()
    if not gold or gold <= 0 then
        nativeAlert("Gold could not be verified, or no gold is available.")
        return false
    end

    local budget = configuredSpendBudget(gold)
    if budget <= 0 then
        nativeAlert(
            "No upgrade budget is available after your gold reserve / spend cap. "
            .. "Current gold: " .. formatInt(gold)
            .. ", reserve: " .. formatInt(Persistent.Settings.GoldReserve)
            .. "."
        )
        return false
    end

    local plan = allocateUpgradeBudget(entries, budget)
    plan.ClassName = selectedClass
    plan.ConfirmedGold = gold
    plan.ConfiguredBudget = budget
    plan.BestMode = Controller.BestMode ~= "Off" and Controller.BestMode or "Potential"

    if plan.PlannedUpgrades <= 0 then
        nativeAlert("The configured budget cannot afford the next eligible upgrade.")
        return false
    end

    local bodyLines = {
        "Upgrade " .. selectedClass .. " gear using " .. plan.BestMode .. " stat selection?",
        "Budget " .. formatInt(budget)
            .. " | reserve " .. formatInt(Persistent.Settings.GoldReserve)
            .. " | cap " .. (Persistent.Settings.SpendCap > 0 and formatInt(Persistent.Settings.SpendCap) or "OFF"),
        "Target progress " .. tostring(nonNegativeInteger(Persistent.Settings.TargetUpgradePct)) .. "%.",
        "",
    }

    local remainingGold = gold
    for _, entry in ipairs(plan.Entries) do
        remainingGold = math.max(0, remainingGold - nonNegativeInteger(entry.PlannedCost))
        bodyLines[#bodyLines + 1] =
            string.upper(tostring(entry.Slot or entry.ItemType))
            .. " • " .. tostring(entry.Name)
            .. ": +" .. formatInt(entry.Amount) .. " upgrades"
            .. ", +" .. formatCompact(entry.PlannedGain) .. " " .. fieldDisplayName(entry.Field)
            .. ", cost " .. formatInt(entry.PlannedCost)
            .. ", gold left " .. formatInt(remainingGold)
    end

    local spendPct = gold > 0 and (plan.EstimatedSpend / gold * 100) or 0
    local warnPct = tonumber(Persistent.Settings.HighSpendPct) or 0
    if warnPct > 0 and spendPct >= warnPct then
        bodyLines[#bodyLines + 1] = "WARNING: this plan spends " .. string.format("%.1f%%", spendPct) .. " of current gold."
    end
    bodyLines[#bodyLines + 1] = ""
    bodyLines[#bodyLines + 1] =
        "Total: " .. formatInt(plan.PlannedUpgrades)
        .. " upgrades, +" .. formatCompact(plan.PlannedGain)
        .. " estimated stat, " .. formatInt(plan.EstimatedSpend) .. " gold."
    bodyLines[#bodyLines + 1] =
        "Stat comparison only — not a guaranteed DPS ranking. Counted requests stop on a mismatch."

    return showConfirmation(
        "AUTO UPGRADE BEST",
        table.concat(bodyLines, "\n"),
        function()
            executeUpgradePlan(plan)
        end
    )
end

local SELL_SUPPORTED_TYPES = {
    weapon = true,
    ability = true,
    chest = true,
    helmet = true,
}

local function buildJunkSellPlan()
    rebuildMetrics()

    local payload = {
        weapon = {},
        ability = {},
        chest = {},
        helmet = {},
    }

    local soldUIDs = {}
    local entries = {}
    local count = 0
    local totalValue = 0
    local seenUIDs = {}
    local maxAutoSellValue = nonNegativeInteger(Persistent.Settings.AutoSellMaxValue)

    
    
    
    for _, info in ipairs(Controller.InventoryInfos or {}) do
        local supported = SELL_SUPPORTED_TYPES[info.ItemType] == true
        local protected =
            info.IsEquipped
            or info.IsLoadoutProtected
            or (info.UID and Persistent.Favorites[info.UID] == true)
            or (info.UID and Persistent.Locked[info.UID] == true)

        local valueAllowed =
            maxAutoSellValue <= 0
            or nonNegativeInteger(info.SellValue) <= maxAutoSellValue

        if info.IsJunk
            and supported
            and not protected
            and valueAllowed
            and info.UID
            and not seenUIDs[info.UID]
        then
            seenUIDs[info.UID] = true
            table.insert(payload[info.ItemType], info.ItemNumber)

            count += 1
            totalValue += nonNegativeInteger(info.SellValue)
            soldUIDs[#soldUIDs + 1] = info.UID

            entries[#entries + 1] = {
                UID = info.UID,
                ItemType = info.ItemType,
                ItemNumber = info.ItemNumber,
                SellValue = nonNegativeInteger(info.SellValue),
                Name = info.Name,
            }
        end
    end

    return {
        Payload = payload,
        SoldUIDs = soldUIDs,
        Entries = entries,
        Count = count,
        TotalValue = totalValue,
    }
end

local function executeSellJunk(plan)
    if Controller.ActionBusy then
        return
    end

    if not plan or nonNegativeInteger(plan.Count) <= 0 then
        nativeAlert("No Smart Junk items are available to sell.")
        return
    end

    local remotes = ReplicatedStorage:FindFirstChild("remotes")
    local sellRemote = remotes and remotes:FindFirstChild("sellItemEvent")

    if not sellRemote or not sellRemote:IsA("RemoteEvent") then
        nativeAlert("sellItemEvent remote was not found.")
        return
    end

    Controller.ActionBusy = true
    Controller.ActionCancelRequested = false
    setActionProgress("Auto Sell: preparing...")

    task.spawn(function()
        local totalSold, estimatedValue, completedPasses = 0, 0, 0
        local attemptedUIDs, countedUIDs = {}, {}
        local removedUIDs = {}
        local requestedCount = 0
        local stopReason

        local ok, err = pcall(function()
            for pass = 1, 50 do
                if not Controller.Alive then
                    stopReason = "The script was stopped."
                    break
                end

                if Controller.ActionCancelRequested then
                    stopReason = "Stopped by user before the next sell request."
                    break
                end

                if reindexCards then
                    pcall(reindexCards)
                end

                local snapshot = refreshActionInventory()
                if not snapshot then
                    stopReason = "A fresh server inventory could not be verified."
                    break
                end

                synchronizeActionCards(snapshot)
                rebuildMetrics()
                local fresh = buildJunkSellPlan()

                if fresh.Count <= 0 then
                    break
                end

                local payload = {weapon = {}, ability = {}, chest = {}, helmet = {}}
                local sentEntries = {}
                local maxAutoSellValue = nonNegativeInteger(Persistent.Settings.AutoSellMaxValue)

                for _, entry in ipairs(fresh.Entries) do
                    local item, number = snapshotItemByUID(snapshot, entry.ItemType, entry.UID)
                    local sellValue = item and nonNegativeInteger(item.sellPrice) or 0
                    local valueAllowed = maxAutoSellValue <= 0 or sellValue <= maxAutoSellValue

                    if item and number and payload[entry.ItemType]
                        and not attemptedUIDs[entry.UID]
                        and (not plan.AllowedUIDs or plan.AllowedUIDs[entry.UID])
                        and not isItemEquipped(item)
                        and not Persistent.Favorites[entry.UID]
                        and not Persistent.Locked[entry.UID]
                        and not uidInAnyLoadout(entry.UID)
                        and valueAllowed
                    then
                        attemptedUIDs[entry.UID] = true
                        payload[entry.ItemType][#payload[entry.ItemType] + 1] = number
                        sentEntries[#sentEntries + 1] = {
                            UID = entry.UID,
                            ItemType = entry.ItemType,
                            SellValue = sellValue,
                        }
                    end
                end

                if #sentEntries == 0 then
                    break
                end

                if Controller.ActionCancelRequested then
                    stopReason = "Stopped by user before the next sell request."
                    break
                end

                requestedCount += #sentEntries
                setActionProgress(
                    "Auto Sell: pass " .. tostring(pass)
                    .. " • requesting " .. tostring(#sentEntries) .. " removal"
                    .. (#sentEntries == 1 and "" or "s")
                )

                
                
                sellRemote:FireServer(payload)

                local confirmed, complete = waitForSaleOutcome(sentEntries, 6)
                local removedThisPass = 0

                for _, entry in ipairs(sentEntries) do
                    if confirmed[entry.UID] and not countedUIDs[entry.UID] then
                        countedUIDs[entry.UID] = true
                        totalSold += 1
                        removedThisPass += 1
                        estimatedValue += entry.SellValue
                        Persistent.NewIDs[entry.UID] = nil
                        Controller.RecentlySoldUIDs[entry.UID] = os.time()
                        Controller.SessionStats.Sold = (Controller.SessionStats.Sold or 0) + 1
                        Controller.SessionStats.SellGold = (Controller.SessionStats.SellGold or 0) + nonNegativeInteger(entry.SellValue)
                        removedUIDs[#removedUIDs + 1] = entry.UID
                    end
                end

                if removedThisPass > 0 then
                    completedPasses += 1
                end

                if not complete then
                    stopReason = "Some removals were not confirmed; stopped without retrying those items."
                    break
                end
            end
        end)

        Controller.ActionBusy = false

        if not ok then
            stopReason = "An error stopped selling; unconfirmed removals were not counted or retried."
            warn("[DQ Inventory QOL v19.1] sell stopped:", err)
        end

        local stopped = Controller.ActionCancelRequested
        Controller.ActionCancelRequested = false
        setActionProgress("Idle")

        scheduleDiskStateSave(0.15)

        if Controller.Alive and reindexCards then
            pcall(reindexCards)
        end

        local details =
            "passes=" .. tostring(completedPasses)
            .. " | value=" .. formatInt(estimatedValue)
            .. (#removedUIDs > 0 and (" | removed UIDs: " .. table.concat(removedUIDs, ", ")) or "")
            .. (stopReason and (" | " .. stopReason) or "")
        logAction("Auto Sell Junk", requestedCount, totalSold, details)

        local message = "Auto Sell Junk: confirmed " .. tostring(totalSold)
            .. " removal" .. (totalSold == 1 and "" or "s")
            .. " in " .. tostring(completedPasses) .. " completed pass"
            .. (completedPasses == 1 and "" or "es")
            .. "; estimated sell value " .. formatCompact(estimatedValue) .. " gold."

        if stopReason then
            message = message .. " " .. stopReason
        elseif stopped then
            message = message .. " Stopped before sending another request."
        end

        nativeAlert(message)
    end)
end

local function requestAutoSellJunk()
    if Controller.ActionBusy then
        return
    end

    if reindexCards then
        pcall(reindexCards)
    end

    local snapshot = refreshActionInventory()
    if not snapshot then
        nativeAlert("Cannot verify a fresh server inventory; no sell request was sent.")
        return
    end

    synchronizeActionCards(snapshot)
    local plan = buildJunkSellPlan()

    
    
    plan.AllowedUIDs = {}
    iterateInventoryRecords(function(_, _, item)
        local uid = uidForItem(item)
        if uid then
            plan.AllowedUIDs[uid] = true
        end
    end)

    if plan.Count <= 0 then
        local maxValue = nonNegativeInteger(Persistent.Settings.AutoSellMaxValue)
        nativeAlert(
            "No unprotected Smart Junk items are available to sell"
            .. (maxValue > 0 and (" at or below " .. formatInt(maxValue) .. " sell value.") or ".")
        )
        return
    end

    local maxValue = nonNegativeInteger(Persistent.Settings.AutoSellMaxValue)
    local highValueThreshold = nonNegativeInteger(Persistent.Settings.HighValueWarning)
    local highValueCount = 0
    if highValueThreshold > 0 then
        for _, entry in ipairs(plan.Entries or {}) do
            if nonNegativeInteger(entry.SellValue) >= highValueThreshold then highValueCount += 1 end
        end
    end
    local isNonBest = Persistent.Settings.JunkMode == "NonBest"
    local body =
        (isNonBest
            and "Sell all obsolete gear until only your best and protected items remain?\n"
            or "Sell duplicate junk until only the best eligible copies remain?\n")
        .. tostring(plan.Count)
        .. " item" .. (plan.Count == 1 and "" or "s")
        .. " marked for removal; estimated value "
        .. formatCompact(plan.TotalValue) .. " gold.\n"
        .. (isNonBest
            and "Mode: NOT BEST. Keeps Equipped, Best-in-Slot for all classes, Loadouts, Favorites, Locks, Wishlist, S-rolls, and Legendary+.\n"
            or ("Mode: DUPLICATES. Keeping top " .. tostring(math.max(1, nonNegativeInteger(Persistent.Settings.KeepCopies, 1))) .. " copies plus protected items.\n"))
        .. (highValueCount > 0 and ("WARNING: " .. tostring(highValueCount) .. " marked item(s) meet the high-value warning threshold.\n") or "")
        .. (maxValue > 0
            and ("Auto-sell value ceiling: " .. formatInt(maxValue) .. ". Items above it are skipped.\n")
            or "Auto-sell value ceiling: OFF.\n")
        .. "Stop prevents later passes; it cannot undo a request already sent."

    showConfirmation(
        "AUTO SELL ALL JUNK",
        body,
        function()
            executeSellJunk(plan)
        end
    )
end

local function buildConfirmPopup(rightSide)
    local popup, inner = makePopupPlate(
        rightSide,
        "DQConfirmPopup",
        UDim2.new(0.22, 0, 0.29, 0),
        UDim2.new(0.56, 0, 0.30, 0)
    )

    popup.ZIndex = 130
    inner.ZIndex = 131

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.AnchorPoint = Vector2.new(0.5, 0)
    title.Position = UDim2.fromScale(0.5, 0.08)
    title.Size = UDim2.fromScale(0.90, 0.18)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBlack
    title.Text = "CONFIRM"
    title.TextScaled = true
    title.TextColor3 = Color3.fromRGB(255, 224, 115)
    title.TextStrokeColor3 = Color3.new(0, 0, 0)
    title.TextStrokeTransparency = 0
    title.ZIndex = 133
    title.Parent = inner

    local body = Instance.new("TextLabel")
    body.Name = "Body"
    body.AnchorPoint = Vector2.new(0.5, 0)
    body.Position = UDim2.fromScale(0.5, 0.28)
    body.Size = UDim2.fromScale(0.90, 0.42)
    body.BackgroundTransparency = 1
    body.Font = Enum.Font.Highway
    body.Text = ""
    body.TextScaled = true
    body.TextWrapped = true
    body.TextColor3 = Color3.fromRGB(245, 245, 245)
    body.TextStrokeColor3 = Color3.new(0, 0, 0)
    body.TextStrokeTransparency = 0
    body.ZIndex = 133
    body.Parent = inner

    local confirm = makeNativeButton(inner, {
        Name = "Confirm",
        Size = UDim2.fromScale(0.40, 0.18),
        Text = "Confirm",
        InnerColor = Color3.fromRGB(77, 153, 79),
        ZIndex = 135,
        MinTextSize = 10,
        MaxTextSize = 17,
    })
    confirm.AnchorPoint = Vector2.new(0, 1)
    confirm.Position = UDim2.fromScale(0.07, 0.94)

    local cancel = makeNativeButton(inner, {
        Name = "Cancel",
        Size = UDim2.fromScale(0.40, 0.18),
        Text = "Cancel",
        InnerColor = Color3.fromRGB(150, 67, 67),
        ZIndex = 135,
        MinTextSize = 10,
        MaxTextSize = 17,
    })
    cancel.AnchorPoint = Vector2.new(1, 1)
    cancel.Position = UDim2.fromScale(0.93, 0.94)

    addConnection(Controller.AttachConnections, confirm.MouseButton1Click:Connect(function()
        popup.Visible = false
        local callback = Controller.ConfirmAction
        Controller.ConfirmAction = nil

        if type(callback) == "function" then
            callback()
        end
    end))

    addConnection(Controller.AttachConnections, cancel.MouseButton1Click:Connect(function()
        Controller.ConfirmAction = nil
        popup.Visible = false
    end))

    return popup
end






local function sortedLoadoutNames()
    local names = {}
    for name, preset in pairs(Persistent.Loadouts or {}) do
        if type(name) == "string" and type(preset) == "table" then
            names[#names + 1] = name
        end
    end
    table.sort(names, function(a, b)
        return string.lower(a) < string.lower(b)
    end)
    return names
end

local function getEquippedInfoBySlot()
    rebuildMetrics()
    local out = {}
    for _, info in ipairs(Controller.InventoryInfos or {}) do
        local slot = slotForType(info.ItemType)
        if slot and info.IsEquipped then
            out[slot] = info
        end
    end
    return out
end

local function saveEquippedLoadout(name)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then
        nativeAlert("Enter a loadout name first.")
        return
    end

    if #name > 28 then
        name = string.sub(name, 1, 28)
    end

    if reindexCards then
        pcall(reindexCards)
    end

    local equipped = getEquippedInfoBySlot()
    local preset = {
        Class = Controller.ClassFilter or "",
        SavedAt = os.time(),
    }

    local count = 0
    for _, slot in ipairs({"weapon", "chest", "helmet"}) do
        local info = equipped[slot]
        if info and info.UID then
            preset[slot] = info.UID
            count += 1
        end
    end

    if count <= 0 then
        nativeAlert("No equipped weapon/chest/helmet could be verified.")
        return
    end

    Persistent.Loadouts[name] = preset
    saveDiskState()
    rebuildMetrics()
    applyAll()

    logAction("Save Loadout", count, count, name)
    nativeAlert("Saved loadout \"" .. name .. "\" with " .. tostring(count) .. " gear piece" .. (count == 1 and "" or "s") .. ".")

    if type(refreshMorePopup) == "function" then
        refreshMorePopup()
    end
end

local function deleteLoadout(name)
    if not Persistent.Loadouts[name] then
        return
    end

    showConfirmation(
        "DELETE LOADOUT",
        "Delete saved loadout \"" .. tostring(name) .. "\"?\nThis does not sell or unequip any item.",
        function()
            Persistent.Loadouts[name] = nil
            saveDiskState()
            rebuildMetrics()
            applyAll()
            logAction("Delete Loadout", 1, 1, tostring(name))
            if type(refreshMorePopup) == "function" then
                refreshMorePopup()
            end
        end
    )
end

local function executeLoadout(name, resolved)
    if Controller.ActionBusy then
        return
    end

    Controller.ActionBusy = true
    Controller.ActionCancelRequested = false
    setActionProgress("Loadout: preparing " .. tostring(name) .. "...")

    task.spawn(function()
        local requested, confirmed = 0, 0
        local details = {}

        for _, target in ipairs(resolved) do
            if Controller.ActionCancelRequested then
                break
            end

            if not target.AlreadyEquipped then
                requested += 1
                setActionProgress(
                    "Loadout " .. tostring(name) .. ": "
                    .. string.upper(tostring(target.Slot)) .. " • "
                    .. tostring(target.Info.Name)
                )

                if triggerNativeGearClick(target.Info) then
                    task.wait(0.22)
                    local snapshot = refreshActionInventory()
                    if snapshot then
                        local item = snapshotItemByUID(snapshot, target.Info.ItemType, target.Info.UID)
                        if item and isItemEquipped(item) then
                            confirmed += 1
                            details[#details + 1] = target.Slot .. "=" .. tostring(target.Info.UID)
                        else
                            details[#details + 1] = target.Slot .. " unconfirmed=" .. tostring(target.Info.UID)
                        end
                    else
                        details[#details + 1] = target.Slot .. " refresh failed"
                    end
                else
                    details[#details + 1] = target.Slot .. " native card unavailable"
                end
            end
        end

        Controller.ActionBusy = false
        local stopped = Controller.ActionCancelRequested
        Controller.ActionCancelRequested = false
        setActionProgress("Idle")

        if Controller.Alive and reindexCards then
            pcall(reindexCards)
        end

        logAction(
            "Apply Loadout",
            requested,
            confirmed,
            tostring(name)
                .. (#details > 0 and (" | " .. table.concat(details, " | ")) or "")
                .. (stopped and " | stopped by user" or "")
        )

        nativeAlert(
            "Loadout \"" .. tostring(name) .. "\": "
            .. tostring(confirmed) .. "/" .. tostring(requested)
            .. " requested gear changes confirmed"
            .. (stopped and " before Stop." or ".")
        )
    end)
end

local function requestApplyLoadout(name)
    if Controller.ActionBusy then
        return
    end

    local preset = Persistent.Loadouts[name]
    if type(preset) ~= "table" then
        nativeAlert("Loadout \"" .. tostring(name) .. "\" no longer exists.")
        return
    end

    if reindexCards then
        pcall(reindexCards)
    end

    rebuildMetrics()

    local equipped = getEquippedInfoBySlot()
    local resolved = {}
    local lines = {
        "Apply \"" .. tostring(name) .. "\"?",
        "",
    }
    local fatal = false
    local playerLevel = currentPlayerLevel()

    for _, slot in ipairs({"weapon", "chest", "helmet"}) do
        local uid = preset[slot]
        if uid then
            local info = Controller.InventoryInfoByUID[tostring(uid)]
            local current = equipped[slot]

            if not info then
                lines[#lines + 1] = string.upper(slot) .. ": MISSING UID " .. tostring(uid)
                fatal = true
            elseif (info.Level or 0) > playerLevel and not info.IsEquipped then
                lines[#lines + 1] =
                    string.upper(slot) .. ": " .. tostring(info.Name)
                    .. " • requires level " .. tostring(info.Level)
                    .. " (you are " .. tostring(playerLevel) .. ")"
                fatal = true
            else
                local already = info.IsEquipped
                lines[#lines + 1] =
                    string.upper(slot) .. ": "
                    .. (current and tostring(current.Name) or "none")
                    .. " → " .. tostring(info.Name)
                    .. (already and " (already equipped)" or "")
                resolved[#resolved + 1] = {
                    Slot = slot,
                    Info = info,
                    AlreadyEquipped = already,
                }
            end
        else
            lines[#lines + 1] = string.upper(slot) .. ": not saved in this preset"
        end
    end

    if fatal then
        lines[#lines + 1] = ""
        lines[#lines + 1] = "Cannot apply until every saved UID exists and meets its level requirement."
        showConfirmation("LOADOUT CHECK", table.concat(lines, "\n"), function() end)
        return
    end

    lines[#lines + 1] = ""
    lines[#lines + 1] = "Saved UIDs remain protected from Smart Junk / Auto Sell."

    showConfirmation(
        "APPLY LOADOUT",
        table.concat(lines, "\n"),
        function()
            executeLoadout(name, resolved)
        end
    )
end

local EXPORT_FILE = "DQ_Inventory_QOL_v19_export.json"

local function buildExportPayload()
    return {
        Version = 19,
        Settings = Persistent.Settings,
        UIState = {
            ClassFilter = Controller.ClassFilter or "",
            SearchText = tostring(Controller.SearchText or ""),
            BestMode = Controller.BestMode,
            JunkOnly = Controller.JunkOnly == true,
        },
        Favorites = Persistent.Favorites,
        Locked = Persistent.Locked,
        Loadouts = Persistent.Loadouts,
        Wishlist = Persistent.Wishlist,
        KeepRules = Persistent.KeepRules,
        ItemNotes = Persistent.ItemNotes,
        ItemTags = Persistent.ItemTags,
        SavedSearches = Persistent.SavedSearches,
        SettingsProfiles = Persistent.SettingsProfiles,
        ClassProfiles = Persistent.ClassProfiles,
    }
end

local function exportSettings()
    local ok, raw = pcall(HttpService.JSONEncode, HttpService, buildExportPayload())
    if not ok or type(raw) ~= "string" then
        nativeAlert("Could not encode settings export.")
        return
    end

    local destinations = {}
    if canWriteFiles() then
        local wrote = pcall(writefile, EXPORT_FILE, raw)
        if wrote then
            destinations[#destinations + 1] = EXPORT_FILE
        end
    end

    if type(setclipboard) == "function" then
        if pcall(setclipboard, raw) then
            destinations[#destinations + 1] = "clipboard"
        end
    end

    logAction("Export Settings", 1, #destinations > 0 and 1 or 0, table.concat(destinations, ", "))

    if #destinations > 0 then
        nativeAlert("Exported settings to " .. table.concat(destinations, " + ") .. ".")
    else
        nativeAlert("This executor does not expose writefile or setclipboard.")
    end
end

local IMPORTABLE_SETTINGS = {}
for key in pairs(Persistent.Settings) do IMPORTABLE_SETTINGS[key] = true end


local function readImportText()
    if type(getclipboard) == "function" then
        local ok, value = pcall(getclipboard)
        if ok and type(value) == "string" and value:match("^%s*{") then
            return value, "clipboard"
        end
    end

    if canReadFiles() then
        local okExists, exists = pcall(isfile, EXPORT_FILE)
        if okExists and exists then
            local okRead, raw = pcall(readfile, EXPORT_FILE)
            if okRead and type(raw) == "string" then
                return raw, EXPORT_FILE
            end
        end
    end

    return nil, nil
end

local function requestImportSettings()
    local raw, sourceName = readImportText()
    if not raw then
        nativeAlert("No JSON settings were found in the clipboard or " .. EXPORT_FILE .. ".")
        return
    end

    local ok, data = pcall(HttpService.JSONDecode, HttpService, raw)
    if not ok or type(data) ~= "table" then
        nativeAlert("Import data is not valid JSON.")
        return
    end

    local settings = type(data.Settings) == "table" and data.Settings or {}
    local favorites = type(data.Favorites) == "table" and data.Favorites or {}
    local locked = type(data.Locked) == "table" and data.Locked or {}
    local loadouts = type(data.Loadouts) == "table" and data.Loadouts or {}
    local wishlist = type(data.Wishlist) == "table" and data.Wishlist or {}
    local keepRules = type(data.KeepRules) == "table" and data.KeepRules or {}
    local itemNotes = type(data.ItemNotes) == "table" and data.ItemNotes or {}
    local itemTags = type(data.ItemTags) == "table" and data.ItemTags or {}
    local savedSearches = type(data.SavedSearches) == "table" and data.SavedSearches or {}
    local settingsProfiles = type(data.SettingsProfiles) == "table" and data.SettingsProfiles or {}
    local classProfiles = type(data.ClassProfiles) == "table" and data.ClassProfiles or {}

    local settingCount, favoriteCount, lockedCount, loadoutCount = 0, 0, 0, 0
    for key in pairs(settings) do
        if IMPORTABLE_SETTINGS[key] then settingCount += 1 end
    end
    for _ in pairs(favorites) do favoriteCount += 1 end
    for _ in pairs(locked) do lockedCount += 1 end
    for _ in pairs(loadouts) do loadoutCount += 1 end

    local preview =
        "Import from " .. tostring(sourceName) .. "?\n"
        .. tostring(settingCount) .. " recognized settings\n"
        .. tostring(favoriteCount) .. " favorites • "
        .. tostring(lockedCount) .. " locks • "
        .. tostring(loadoutCount) .. " loadouts\n"
        .. "Mode: " .. tostring(Persistent.Settings.ImportMode or "Replace") .. ". A preview is shown before applying."

    showConfirmation("IMPORT SETTINGS", preview, function()
        for key, value in pairs(settings) do
            if IMPORTABLE_SETTINGS[key] then
                Persistent.Settings[key] = value
            end
        end

        local mergeMode = Persistent.Settings.ImportMode == "Merge"
        local function mergeInto(target, incoming)
            if not mergeMode then return incoming end
            target = type(target) == "table" and target or {}
            for key, value in pairs(incoming) do target[key] = value end
            return target
        end
        Persistent.Favorites = mergeInto(Persistent.Favorites, favorites)
        Persistent.Locked = mergeInto(Persistent.Locked, locked)
        Persistent.Loadouts = mergeInto(Persistent.Loadouts, loadouts)
        Persistent.Wishlist = mergeInto(Persistent.Wishlist, wishlist)
        Persistent.KeepRules = mergeInto(Persistent.KeepRules, keepRules)
        Persistent.ItemNotes = mergeInto(Persistent.ItemNotes, itemNotes)
        Persistent.ItemTags = mergeInto(Persistent.ItemTags, itemTags)
        Persistent.SavedSearches = mergeInto(Persistent.SavedSearches, savedSearches)
        Persistent.SettingsProfiles = mergeInto(Persistent.SettingsProfiles, settingsProfiles)
        Persistent.ClassProfiles = mergeInto(Persistent.ClassProfiles, classProfiles)

        if type(data.UIState) == "table" then
            local mode = tostring(data.UIState.BestMode or "Off")
            if mode == "Off" or mode == "Now" or mode == "Potential" or mode == "Budget" then
                Controller.BestMode = mode
                Controller.BestLoadout = mode ~= "Off"
            end
        end

        
        Persistent.Settings.MinLevel = nonNegativeInteger(Persistent.Settings.MinLevel)
        Persistent.Settings.GoldReserve = nonNegativeInteger(Persistent.Settings.GoldReserve)
        Persistent.Settings.SpendCap = nonNegativeInteger(Persistent.Settings.SpendCap)
        Persistent.Settings.TargetUpgradePct =
            math.clamp(nonNegativeInteger(Persistent.Settings.TargetUpgradePct, 100), 0, 100)
        Persistent.Settings.AutoSellMaxValue = nonNegativeInteger(Persistent.Settings.AutoSellMaxValue)
        Persistent.Settings.TooltipTextSize =
            math.clamp(nonNegativeInteger(Persistent.Settings.TooltipTextSize, 14), 10, 22)

        saveDiskState()

        if reindexCards then
            pcall(reindexCards)
        end

        logAction("Import Settings", settingCount, settingCount, tostring(sourceName))
        if type(refreshMorePopup) == "function" then
            refreshMorePopup()
        end
        nativeAlert("Settings import applied.")
    end)
end

local function sessionLootSummaryText()
    local drops, dupes, improvements = 0, 0, 0
    local names = {}

    for _, drop in pairs(Controller.SessionLootDrops or {}) do
        drops += 1
        if drop.IsDuplicate then dupes += 1 end
        if drop.IsImprovement then improvements += 1 end
        if #names < 4 then
            names[#names + 1] = tostring(drop.Name)
        end
    end

    local result =
        "SESSION LOOT • " .. tostring(drops) .. " new"
        .. " • " .. tostring(dupes) .. " duplicate"
        .. " • " .. tostring(improvements) .. " potential improvement"
    if #names > 0 then
        result = result .. "\nRecent: " .. table.concat(names, ", ")
    end
    return result
end

local function actionLogText()
    if #Controller.ActionLog == 0 then
        return "RECENT ACTIONS • none this session"
    end

    local lines = {"RECENT ACTIONS"}
    for index = 1, math.min(6, #Controller.ActionLog) do
        local entry = Controller.ActionLog[index]
        lines[#lines + 1] =
            tostring(entry.Time) .. " " .. tostring(entry.Kind)
            .. " • requested " .. tostring(entry.Requested)
            .. " • confirmed " .. tostring(entry.Confirmed)
            .. (entry.Details ~= "" and ("\n  " .. entry.Details) or "")
    end
    return table.concat(lines, "\n")
end

local QOL = {}

function QOL.makePanelLabel(parent, name, textValue, height, layoutOrder)
    local label = Instance.new("TextLabel")
    label.Name = name
    label.LayoutOrder = layoutOrder or 1
    label.Size = UDim2.new(0.96, 0, 0, height or 30)
    label.AutomaticSize = Enum.AutomaticSize.Y
    label.BackgroundTransparency = 1
    label.Text = textValue or ""
    label.TextWrapped = true
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextYAlignment = Enum.TextYAlignment.Top
    label.Font = Enum.Font.Highway
    label.TextSize = 13
    label.TextColor3 = Color3.fromRGB(240, 240, 240)
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.TextStrokeTransparency = 0
    label.ZIndex = 94
    label.Parent = parent

    local minSize = Instance.new("UISizeConstraint")
    minSize.MinSize = Vector2.new(0, height or 30)
    minSize.Parent = label

    return label
end

function QOL.makePanelButton(parent, name, textValue, order, callback)
    local button = makeNativeButton(parent, {
        Name = name,
        LayoutOrder = order,
        Size = UDim2.new(0.96, 0, 0, 32),
        Text = textValue,
        InnerColor = Color3.fromRGB(72, 72, 72),
        ZIndex = 96,
        MinTextSize = 9,
        MaxTextSize = 15,
    })
    addConnection(Controller.AttachConnections, button.MouseButton1Click:Connect(callback))
    return button
end

function QOL.bindNumericSetting(box, key, lo, hi, suffix)
    addConnection(Controller.AttachConnections, box.FocusLost:Connect(function()
        local value = nonNegativeInteger(box.Text, Persistent.Settings[key])
        value = math.clamp(value, lo or 0, hi or math.huge)
        Persistent.Settings[key] = value
        box.Text = tostring(value)
        saveDiskState()
        rebuildMetrics()
        applyAll()
        if type(refreshMorePopup) == "function" then
            refreshMorePopup()
        end
        if suffix then
            nativeAlert(suffix .. tostring(value))
        end
    end))
end

function QOL.deepCopyTable(value)
    if type(value) ~= "table" then return value end
    local okEncode, raw = pcall(HttpService.JSONEncode, HttpService, value)
    if not okEncode then return {} end
    local okDecode, copy = pcall(HttpService.JSONDecode, HttpService, raw)
    return okDecode and copy or {}
end

function QOL.selectedMetaInfo()
    if Controller.PinnedUID and Controller.InventoryInfoByUID[Controller.PinnedUID] then
        return Controller.InventoryInfoByUID[Controller.PinnedUID]
    end
    if Controller.HoveredCard and Controller.CardInfo[Controller.HoveredCard] then
        return Controller.CardInfo[Controller.HoveredCard]
    end
    if Controller.HoveredEquippedInfo then return Controller.HoveredEquippedInfo end
    return nil
end

function QOL.pushCompareUID(uid)
    if not uid then return end
    uid = tostring(uid)
    for i = #Controller.CompareSelection, 1, -1 do
        if Controller.CompareSelection[i] == uid then table.remove(Controller.CompareSelection, i) end
    end
    Controller.CompareSelection[#Controller.CompareSelection + 1] = uid
    while #Controller.CompareSelection > 2 do table.remove(Controller.CompareSelection, 1) end
end

function QOL.compareSelectionText()
    local list = {}
    for _, uid in ipairs(Controller.CompareSelection) do
        local info = Controller.InventoryInfoByUID[uid]
        if info then list[#list + 1] = info end
    end
    if #list < 2 then return "COMPARE • right-click a duplicate badge or pin/hover two items to compare." end
    local a, b = list[1], list[2]
    local currentDelta = (b.Current or 0) - (a.Current or 0)
    local potDelta = (b.Potential or 0) - (a.Potential or 0)
    return "COMPARE\nA: " .. tostring(a.Name) .. " • " .. formatCompact(a.Current) .. " → " .. formatCompact(a.Potential)
        .. "\nB: " .. tostring(b.Name) .. " • " .. formatCompact(b.Current) .. " → " .. formatCompact(b.Potential)
        .. "\nB − A: " .. (currentDelta >= 0 and "+" or "") .. formatCompact(currentDelta)
        .. " now • " .. (potDelta >= 0 and "+" or "") .. formatCompact(potDelta) .. " potential"
end

function QOL.inventoryOverviewText()
    rebuildMetrics()
    local count, capacity, pct = inventoryCapacityText()
    local protected, junk, wish, sroll, improvement, equipable = 0, 0, 0, 0, 0, 0
    for _, info in ipairs(Controller.InventoryInfos or {}) do
        if info.IsProtected then protected += 1 end
        if info.IsJunk then junk += 1 end
        if info.IsWishlist then wish += 1 end
        if info.RollGrade == "S" then sroll += 1 end
        if info.BetterThanEquipped then improvement += 1 end
        if info.IsEquipable then equipable += 1 end
    end
    return "INVENTORY • " .. tostring(count) .. "/" .. tostring(capacity) .. " (" .. string.format("%.0f%%", pct) .. ")"
        .. " • equipable " .. tostring(equipable)
        .. "\nProtected " .. tostring(protected) .. " • Junk " .. tostring(junk)
        .. " • Wishlist " .. tostring(wish) .. " • S-roll " .. tostring(sroll)
        .. " • Potential improvements " .. tostring(improvement)
end

function QOL.cleanupPreviewText()
    local plan = buildJunkSellPlan()
    local protected = 0
    for _, info in ipairs(Controller.InventoryInfos or {}) do if info.IsProtected then protected += 1 end end
    local isNonBest = Persistent.Settings.JunkMode == "NonBest"
    return "CLEANUP PREVIEW • Mode: " .. (isNonBest and "Not Best" or "Duplicates")
        .. " • " .. tostring(plan.Count or 0) .. " removable"
        .. " • est. " .. formatCompact(plan.TotalValue or 0) .. " gold"
        .. (isNonBest and " • all obsolete gear" or (" • keep top " .. tostring(math.max(1, nonNegativeInteger(Persistent.Settings.KeepCopies, 1)))))
        .. " • protected " .. tostring(protected)
end

function QOL.fullLoadoutComparisonText()
    local className = Controller.ClassFilter
    if className ~= "Mage" and className ~= "Warrior" and className ~= "Tank" then
        return "LOADOUT COMPARISON • select Mage, Warrior, or Tank."
    end
    rebuildMetrics()
    local mode = Controller.BestMode ~= "Off" and Controller.BestMode or "Potential"
    local map = Controller.BestByMode[mode] or {}
    local lines = {"LOADOUT • " .. className .. " • " .. mode}
    for _, slot in ipairs({"weapon", "chest", "helmet"}) do
        local eq, best
        for _, info in ipairs(Controller.InventoryInfos or {}) do
            if slotForType(info.ItemType) == slot and info.IsEquipped then eq = info end
        end
        best = map[className .. ":" .. slot]
        if eq or best then
            local eqValue = eq and (mode == "Now" and eq.Current or mode == "Budget" and eq.BudgetPotential or eq.Potential) or 0
            local bestValue = best and (mode == "Now" and best.Current or mode == "Budget" and best.BudgetPotential or best.Potential) or 0
            local delta = bestValue - eqValue
            lines[#lines + 1] = string.upper(slot) .. " • " .. tostring(eq and eq.Name or "none") .. " → " .. tostring(best and best.Name or "none")
                .. " • " .. (delta >= 0 and "+" or "") .. formatCompact(delta)
        end
    end
    return table.concat(lines, "\n")
end

function QOL.topUpgradeTargetsText()
    rebuildMetrics()
    local list = {}
    for _, info in ipairs(Controller.InventoryInfos or {}) do
        local slot = slotForType(info.ItemType)
        if (slot == "weapon" or slot == "chest" or slot == "helmet") and info.RemainingUpgrades > 0 and info.IsEquipable then
            list[#list + 1] = info
        end
    end
    table.sort(list, function(a, b)
        if (a.GainPerGold or 0) ~= (b.GainPerGold or 0) then return (a.GainPerGold or 0) > (b.GainPerGold or 0) end
        return (a.NextUpgradeGain or 0) > (b.NextUpgradeGain or 0)
    end)
    local lines = {"BEST GOLD INVESTMENT"}
    for i = 1, math.min(3, #list) do
        local info = list[i]
        lines[#lines + 1] = tostring(i) .. ". " .. tostring(info.Name)
            .. " • +" .. formatCompact(info.NextUpgradeGain or 0)
            .. " / " .. formatCompact(info.NextUpgradeCost or 0) .. "g"
            .. (info.BreakEvenCount and (" • beat eq: +" .. formatInt(info.BreakEvenCount) .. " / " .. formatCompact(info.BreakEvenCost or 0) .. "g") or "")
    end
    if #list == 0 then lines[#lines + 1] = "No eligible upgrades." end
    return table.concat(lines, "\n")
end

function QOL.lootHistoryText()
    local lines = {"RECENT LOOT"}
    for i = 1, math.min(10, #(Persistent.LootHistory or {})) do
        local drop = Persistent.LootHistory[i]
        lines[#lines + 1] = os.date("%H:%M", tonumber(drop.AcquiredAt) or os.time()) .. " • " .. tostring(drop.Name)
            .. (drop.RollGrade and (" • " .. tostring(drop.RollGrade)) or "")
            .. (drop.IsWishlist and " • WISH" or "")
            .. (drop.IsImprovement and " • ▲" or "")
    end
    if #lines == 1 then lines[#lines + 1] = "No tracked drops yet." end
    return table.concat(lines, "\n")
end

function QOL.captureInventorySnapshot()
    rebuildMetrics()
    local snapshot = {}
    for _, info in ipairs(Controller.InventoryInfos or {}) do
        if info.UID then
            snapshot[info.UID] = {
                Name = info.Name,
                Current = info.Current,
                Potential = info.Potential,
                Upgrades = info.CurrentUpgrade,
                Equipped = info.IsEquipped,
            }
        end
    end
    Controller.SessionSnapshot = snapshot
    Controller.SessionSnapshotTime = os.time()
    nativeAlert("Inventory snapshot captured.")
end

function QOL.snapshotDiffText()
    if not Controller.SessionSnapshot then return "SNAPSHOT DIFF • no snapshot captured." end
    rebuildMetrics()
    local current = {}
    for _, info in ipairs(Controller.InventoryInfos or {}) do if info.UID then current[info.UID] = info end end
    local added, removed, changed = {}, {}, {}
    for uid, info in pairs(current) do
        local old = Controller.SessionSnapshot[uid]
        if not old then
            added[#added + 1] = info.Name
        elseif old.Current ~= info.Current or old.Upgrades ~= info.CurrentUpgrade or old.Equipped ~= info.IsEquipped then
            changed[#changed + 1] = info.Name
        end
    end
    for uid, old in pairs(Controller.SessionSnapshot) do if not current[uid] then removed[#removed + 1] = old.Name end end
    return "SNAPSHOT DIFF • +" .. tostring(#added) .. " added • -" .. tostring(#removed) .. " removed • " .. tostring(#changed) .. " changed"
        .. (#added > 0 and ("\nAdded: " .. table.concat(added, ", ", 1, math.min(6, #added))) or "")
        .. (#removed > 0 and ("\nRemoved: " .. table.concat(removed, ", ", 1, math.min(6, #removed))) or "")
        .. (#changed > 0 and ("\nChanged: " .. table.concat(changed, ", ", 1, math.min(6, #changed))) or "")
end

function QOL.setKeepRule(name, count)
    local key = wishlistKey(name)
    if key == "" then nativeAlert("Enter an item name first.") return end
    count = math.clamp(nonNegativeInteger(count, 1), 1, 20)
    Persistent.KeepRules[key] = count
    saveDiskState()
    rebuildMetrics()
    nativeAlert("Keep rule: " .. tostring(name) .. " → " .. tostring(count))
end

function QOL.clearKeepRule(name)
    local key = wishlistKey(name)
    if Persistent.KeepRules[key] then
        Persistent.KeepRules[key] = nil
        saveDiskState()
        rebuildMetrics()
        nativeAlert("Cleared keep rule: " .. tostring(name))
    end
end

function QOL.toggleWishlistByName(name)
    local key = wishlistKey(name)
    if key == "" then nativeAlert("Enter an item name first.") return end
    if Persistent.Wishlist[key] then
        Persistent.Wishlist[key] = nil
        nativeAlert("Removed from wishlist: " .. tostring(name))
    else
        Persistent.Wishlist[key] = tostring(name)
        nativeAlert("Added to wishlist: " .. tostring(name))
    end
    saveDiskState()
    rebuildMetrics()
    refreshAllOverlays()
end

function QOL.saveCurrentSearch(name)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" or Controller.SearchText == "" then nativeAlert("Enter a saved-search name and a search query first.") return end
    Persistent.SavedSearches[name] = Controller.SearchText
    saveDiskState()
    nativeAlert("Saved search: " .. name)
end

QOL.PROFILE_SETTING_KEYS = {
    "SortMode", "HideCommon", "HideAbilities", "OnlyUpgradable", "OnlyEquipable", "GroupDupes", "HideJunk", "MinLevel",
    "GoldReserve", "SpendCap", "TargetUpgradePct", "UpgradeWeapon", "UpgradeChest", "UpgradeHelmet", "AutoSellMaxValue",
    "JunkMode", "KeepCopies", "ProtectGodpot", "ProtectSRolls", "ProtectLegendary", "WishlistAutoLock", "GodpotNotifications", "InventoryWarningPct", "MinImprovementPct",
    "MinImprovementFlat", "RequireBetterNow", "HighValueWarning", "HighSpendPct", "AdvancedSearch", "HideBadges",
    "CompactTooltip", "TooltipTextSize", "GridScale", "GridColumns"
}

function QOL.captureProfileSettings()
    local out = {}
    for _, key in ipairs(QOL.PROFILE_SETTING_KEYS) do out[key] = QOL.deepCopyTable(Persistent.Settings[key]) end
    out.BestMode = Controller.BestMode
    out.SearchText = Controller.SearchText
    return out
end

function QOL.applyProfileSettings(profile)
    if type(profile) ~= "table" then return end
    for _, key in ipairs(QOL.PROFILE_SETTING_KEYS) do if profile[key] ~= nil then Persistent.Settings[key] = profile[key] end end
    if profile.BestMode == "Off" or profile.BestMode == "Now" or profile.BestMode == "Potential" or profile.BestMode == "Budget" then
        Controller.BestMode = profile.BestMode
        Controller.BestLoadout = profile.BestMode ~= "Off"
    end
    if profile.SearchText ~= nil then Controller.SearchText = lower(profile.SearchText) end
    saveDiskState()
    applyAll()
end

function QOL.saveSettingsProfile(name)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if name == "" then nativeAlert("Enter a settings-profile name.") return end
    Persistent.SettingsProfiles[name] = QOL.captureProfileSettings()
    saveDiskState()
    nativeAlert("Saved settings profile: " .. name)
end

function QOL.saveClassProfile()
    local className = Controller.ClassFilter
    if className ~= "Mage" and className ~= "Warrior" and className ~= "Tank" then nativeAlert("Select Mage, Warrior, or Tank first.") return end
    Persistent.ClassProfiles[className] = QOL.captureProfileSettings()
    saveDiskState()
    nativeAlert("Saved " .. className .. " profile.")
end

function QOL.loadClassProfile()
    local className = Controller.ClassFilter
    if className ~= "Mage" and className ~= "Warrior" and className ~= "Tank" then nativeAlert("Select Mage, Warrior, or Tank first.") return end
    local profile = Persistent.ClassProfiles[className]
    if not profile then nativeAlert("No saved " .. className .. " profile.") return end
    QOL.applyProfileSettings(profile)
    nativeAlert("Loaded " .. className .. " profile.")
end

function QOL.bulkVisible(kind, value)
    local changed = 0
    for card, info in pairs(Controller.CardInfo) do
        if card and card.Parent and card.Visible and info.UID then
            if kind == "favorite" then
                Persistent.Favorites[info.UID] = value and true or nil
                changed += 1
            elseif kind == "lock" then
                Persistent.Locked[info.UID] = value and true or nil
                changed += 1
            end
        end
    end
    saveDiskState()
    rebuildMetrics()
    refreshAllOverlays()
    refreshSellShopLocks()
    nativeAlert((value and "Applied " or "Cleared ") .. tostring(kind) .. " on " .. tostring(changed) .. " visible items.")
end

function QOL.protectionSummaryText()
    rebuildMetrics()
    local counts = {}
    for _, info in ipairs(Controller.InventoryInfos or {}) do
        for _, reason in ipairs(info.ProtectionReasons or {}) do counts[reason] = (counts[reason] or 0) + 1 end
    end
    local parts = {}
    for _, reason in ipairs({"Equipped", "Favorite", "Locked", "Loadout", "Wishlist", "S Roll", "Legendary+"}) do
        if counts[reason] then parts[#parts + 1] = reason .. " " .. tostring(counts[reason]) end
    end
    return "PROTECTION • " .. (#parts > 0 and table.concat(parts, " • ") or "none")
end

function QOL.pinHoveredItem()
    local info = QOL.selectedMetaInfo()
    if not info or not info.UID then nativeAlert("Hover an item first.") return end
    Controller.PinnedUID = info.UID
    QOL.pushCompareUID(info.UID)
    nativeAlert("Pinned: " .. tostring(info.Name))
end

function QOL.setPinnedMetadata(noteText, tagText)
    local info = QOL.selectedMetaInfo()
    if not info or not info.UID then nativeAlert("Pin or hover an item first.") return end
    if noteText ~= nil then Persistent.ItemNotes[info.UID] = tostring(noteText) ~= "" and tostring(noteText) or nil end
    if tagText ~= nil then Persistent.ItemTags[info.UID] = tostring(tagText) ~= "" and tostring(tagText) or nil end
    saveDiskState()
    rebuildMetrics()
    nativeAlert("Updated metadata for " .. tostring(info.Name) .. ".")
end

function QOL.requestUpgradeUntilBetter()
    if Controller.ActionBusy then return end
    local className = Controller.ClassFilter
    if className ~= "Mage" and className ~= "Warrior" and className ~= "Tank" then nativeAlert("Select Mage, Warrior, or Tank first.") return end
    if getDQPlaceName() == "Level" then nativeAlert("Upgrade-until-better requires the Lobby.") return end
    if reindexCards then pcall(reindexCards) end
    local snapshot = refreshActionInventory()
    if not snapshot then nativeAlert("Cannot verify a fresh inventory.") return end
    synchronizeActionCards(snapshot)
    rebuildMetrics()
    local gold = currentGold()
    if not gold then nativeAlert("Gold could not be verified.") return end
    local budget = configuredSpendBudget(gold)
    local modeMap = Controller.BestByMode.Potential or {}
    local entries, spend, totalUpgrades, totalGain = {}, 0, 0, 0
    for _, slot in ipairs({"weapon", "chest", "helmet"}) do
        if slotUpgradeEnabled(slot) then
            local info = modeMap[className .. ":" .. slot]
            if info and not info.IsEquipped and info.BreakEvenCount and info.BreakEvenCount > 0 then
                local cost = upgradeCostForCount(info.Item, info.BreakEvenCount)
                if spend + cost <= budget then
                    local nextValue = potentialAfterUpgrades(info.Current, info.BreakEvenCount) or info.Current
                    entries[#entries + 1] = {
                        UID = info.UID, ItemType = info.ItemType, ItemNumber = info.ItemNumber, Name = info.Name,
                        Field = info.Field, Stat = statChoiceForClass(className), Slot = slot,
                        CurrentUpgrade = info.CurrentUpgrade, MaxUpgrades = info.MaxUpgrades, CurrentStat = info.Current,
                        Amount = info.BreakEvenCount, PlannedCost = cost, PlannedGain = nextValue - info.Current,
                    }
                    spend += cost
                    totalUpgrades += info.BreakEvenCount
                    totalGain += nextValue - info.Current
                end
            end
        end
    end
    if #entries == 0 then nativeAlert("No affordable candidate needs upgrades to become better than equipped now.") return end
    local plan = {
        Entries = entries, PlannedUpgrades = totalUpgrades, PlannedGain = totalGain, EstimatedSpend = spend,
        ClassName = className, ConfirmedGold = gold, ConfiguredBudget = budget, BestMode = "Break-even",
    }
    local lines = {"Upgrade candidates only until they become stronger than equipped now?"}
    for _, entry in ipairs(entries) do lines[#lines + 1] = string.upper(entry.Slot) .. " • " .. entry.Name .. " • +" .. formatInt(entry.Amount) .. " • " .. formatInt(entry.PlannedCost) .. "g" end
    lines[#lines + 1] = "Total " .. formatInt(totalUpgrades) .. " upgrades • " .. formatInt(spend) .. " gold."
    showConfirmation("UPGRADE UNTIL BETTER", table.concat(lines, "\n"), function() executeUpgradePlan(plan) end)
end

function QOL.addQueueAction(kind)
    Controller.ActionQueue[#Controller.ActionQueue + 1] = kind
    nativeAlert("Queued: " .. tostring(kind))
end

function QOL.queueText()
    if #Controller.ActionQueue == 0 then return "ACTION QUEUE • empty" end
    return "ACTION QUEUE • " .. table.concat(Controller.ActionQueue, " → ") .. (Controller.QueueRunning and " • RUNNING" or "")
end

function QOL.runActionQueue()
    if Controller.QueueRunning or #Controller.ActionQueue == 0 then return end
    Controller.QueueRunning = true
    Controller.QueueStopRequested = false
    task.spawn(function()
        while #Controller.ActionQueue > 0 and Controller.Alive and not Controller.QueueStopRequested do
            local kind = table.remove(Controller.ActionQueue, 1)
            if kind == "Equip" then
                autoEquipBest()
            elseif kind == "Upgrade" then
                requestAutoUpgradeBest()
            elseif kind == "Upgrade to Better" then
                QOL.requestUpgradeUntilBetter()
            elseif kind == "Sell Junk" then
                requestAutoSellJunk()
            end
            task.wait(0.15)
            while Controller.Alive and Controller.ConfirmAction ~= nil and not Controller.QueueStopRequested do task.wait(0.1) end
            while Controller.Alive and Controller.ActionBusy and not Controller.QueueStopRequested do task.wait(0.1) end
            task.wait(0.15)
        end
        Controller.QueueRunning = false
        Controller.QueueStopRequested = false
        if type(refreshMorePopup) == "function" then pcall(refreshMorePopup) end
    end)
end

function QOL.exportSessionSummary()
    local text = sessionLootSummaryText() .. "\n\n" .. actionLogText() .. "\n\n" .. QOL.lootHistoryText()
    if canWriteFiles() then
        local name = "DQ_Inventory_Session_" .. os.date("%Y%m%d_%H%M%S") .. ".txt"
        local ok = pcall(writefile, name, text)
        nativeAlert(ok and ("Session summary exported to " .. name) or "Session export failed.")
    elseif type(setclipboard) == "function" then
        pcall(setclipboard, text)
        nativeAlert("Session summary copied to clipboard.")
    else
        nativeAlert("No file or clipboard API is available.")
    end
end

function QOL.applySavedSearch(name)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local query = Persistent.SavedSearches[name]
    if not query then nativeAlert("Saved search not found: " .. name) return end
    Controller.SearchText = lower(query)
    saveDiskState()
    applyAll()
end

function QOL.deleteSavedSearch(name)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if Persistent.SavedSearches[name] then
        Persistent.SavedSearches[name] = nil
        saveDiskState()
        nativeAlert("Deleted saved search: " .. name)
    end
end

function QOL.applySettingsProfileByName(name)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local profile = Persistent.SettingsProfiles[name]
    if not profile then nativeAlert("Settings profile not found: " .. name) return end
    QOL.applyProfileSettings(profile)
    nativeAlert("Loaded settings profile: " .. name)
end

function QOL.deleteSettingsProfileByName(name)
    name = tostring(name or ""):gsub("^%s+", ""):gsub("%s+$", "")
    if Persistent.SettingsProfiles[name] then Persistent.SettingsProfiles[name] = nil saveDiskState() nativeAlert("Deleted settings profile: " .. name) end
end

function QOL.renameLoadout(oldName, newName, duplicate)
    oldName = tostring(oldName or ""):gsub("^%s+", ""):gsub("%s+$", "")
    newName = tostring(newName or ""):gsub("^%s+", ""):gsub("%s+$", "")
    local preset = Persistent.Loadouts[oldName]
    if not preset then nativeAlert("Loadout not found: " .. oldName) return end
    if newName == "" then nativeAlert("Enter a new loadout name.") return end
    Persistent.Loadouts[newName] = QOL.deepCopyTable(preset)
    if not duplicate then Persistent.Loadouts[oldName] = nil end
    saveDiskState()
    rebuildMetrics()
    nativeAlert((duplicate and "Duplicated" or "Renamed") .. " loadout: " .. oldName .. " → " .. newName)
end

function QOL.applyUIMode(mode)
    if mode == "Minimal" then
        Persistent.Settings.HideBadges = true
        Persistent.Settings.CompactTooltip = true
    elseif mode == "Compact" then
        Persistent.Settings.HideBadges = false
        Persistent.Settings.HideStatusBadge = true
        Persistent.Settings.HideProtectionBadge = true
        Persistent.Settings.CompactTooltip = true
    else
        Persistent.Settings.HideBadges = false
        Persistent.Settings.HideStatusBadge = false
        Persistent.Settings.HideProtectionBadge = false
        Persistent.Settings.CompactTooltip = false
    end
    saveDiskState()
    applyAll()
end

function QOL.buildMorePopup(rightSide)
    local popup, inner = makePopupPlate(rightSide, "DQMorePopup", UDim2.fromScale(0.5, 0.56), UDim2.new(0.92, 0, 0.78, 0))
    popup.AnchorPoint = Vector2.new(0.5, 0.5)
    popup.ZIndex = 90
    popup.ClipsDescendants = true
    inner.ZIndex = 91
    inner.ClipsDescendants = true

    local tabBar = Instance.new("Frame")
    tabBar.Name = "Tabs"
    tabBar.Position = UDim2.fromScale(0.02, 0.025)
    tabBar.Size = UDim2.fromScale(0.96, 0.105)
    tabBar.BackgroundTransparency = 1
    tabBar.ZIndex = 94
    tabBar.Parent = inner

    local tabLayout = Instance.new("UIListLayout")
    tabLayout.FillDirection = Enum.FillDirection.Horizontal
    tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabLayout.Padding = UDim.new(0.006, 0)
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Parent = tabBar

    local body = Instance.new("Frame")
    body.Name = "Pages"
    body.Position = UDim2.fromScale(0.02, 0.145)
    body.Size = UDim2.fromScale(0.96, 0.825)
    body.BackgroundTransparency = 1
    body.ClipsDescendants = true
    body.ZIndex = 92
    body.Parent = inner

    local pages = {}
    local function makePage(name)
        local page = Instance.new("ScrollingFrame")
        page.Name = name
        page.Size = UDim2.fromScale(1, 1)
        page.BackgroundTransparency = 1
        page.BorderSizePixel = 0
        page.ClipsDescendants = true
        page.Active = true
        page.ScrollingEnabled = true
        page.ScrollingDirection = Enum.ScrollingDirection.Y
        page.ElasticBehavior = Enum.ElasticBehavior.Never
        page.ScrollBarThickness = 5
        page.ScrollBarImageColor3 = Color3.fromRGB(138, 138, 138)
        page.VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar
        page.AutomaticCanvasSize = Enum.AutomaticSize.None
        page.CanvasSize = UDim2.fromOffset(0, 1)
        page.Visible = false
        page.ZIndex = 92
        page.Parent = body
        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 5)
        pad.PaddingBottom = UDim.new(0, 20)
        pad.PaddingLeft = UDim.new(0, 4)
        pad.PaddingRight = UDim.new(0, 12)
        pad.Parent = page
        local layout = Instance.new("UIListLayout")
        layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        layout.VerticalAlignment = Enum.VerticalAlignment.Top
        layout.Padding = UDim.new(0, 5)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = page
        local function updateCanvas()
            page.CanvasSize = UDim2.fromOffset(0, math.max(math.ceil(layout.AbsoluteContentSize.Y + 32), math.ceil(page.AbsoluteWindowSize.Y)))
        end
        addConnection(Controller.AttachConnections, layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateCanvas))
        addConnection(Controller.AttachConnections, page:GetPropertyChangedSignal("AbsoluteWindowSize"):Connect(updateCanvas))
        task.defer(updateCanvas)
        pages[name] = page
        return page
    end

    local tabNames = {"Overview", "Loot", "Upgrade", "Loadouts", "Search", "Protect", "History", "UI"}
    for index, name in ipairs(tabNames) do
        local button = makeNativeButton(tabBar, {
            Name = "Tab_" .. name, LayoutOrder = index, Size = UDim2.new(0.116, 0, 0.88, 0), Text = name,
            InnerColor = Color3.fromRGB(68, 78, 92), ZIndex = 97, MinTextSize = 7, MaxTextSize = 13,
        })
        addConnection(Controller.AttachConnections, button.MouseButton1Click:Connect(function()
            Persistent.Settings.QOLTab = name
            saveDiskState()
            for pageName, page in pairs(pages) do page.Visible = pageName == name end
            refreshMorePopup()
        end))
    end

    local function row(parent, name, order)
        local frame = Instance.new("Frame")
        frame.Name = name
        frame.LayoutOrder = order
        frame.Size = UDim2.new(0.96, 0, 0, 34)
        frame.BackgroundTransparency = 1
        frame.ZIndex = 93
        frame.Parent = parent
        return frame
    end

    local function twoButtons(parent, order, leftName, leftText, leftFn, rightName, rightText, rightFn)
        local r = row(parent, "Row_" .. leftName .. "_" .. rightName, order)
        local a = makeNativeButton(r, {Name = leftName, Size = UDim2.new(0.485, 0, 1, 0), Text = leftText, InnerColor = Color3.fromRGB(72, 84, 98), ZIndex = 96, MinTextSize = 8, MaxTextSize = 14})
        local b = makeNativeButton(r, {Name = rightName, Size = UDim2.new(0.485, 0, 1, 0), Text = rightText, InnerColor = Color3.fromRGB(72, 84, 98), ZIndex = 96, MinTextSize = 8, MaxTextSize = 14})
        a.Position = UDim2.fromScale(0, 0)
        b.AnchorPoint = Vector2.new(1, 0)
        b.Position = UDim2.fromScale(1, 0)
        addConnection(Controller.AttachConnections, a.MouseButton1Click:Connect(leftFn))
        addConnection(Controller.AttachConnections, b.MouseButton1Click:Connect(rightFn))
        return a, b
    end

    local function numeric(parent, order, name, labelText, key, lo, hi)
        local r = row(parent, "Numeric_" .. name, order)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.57, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Highway
        label.TextSize = 13
        label.TextColor3 = Color3.fromRGB(240, 240, 240)
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0
        label.ZIndex = 94
        label.Parent = r
        local _, box = makeNativeInput(r, {Name = "SettingInput_" .. key, Size = UDim2.new(0.40, 0, 1, 0), Text = tostring(Persistent.Settings[key]), ZIndex = 96, TextXAlignment = Enum.TextXAlignment.Center})
        box.Parent.AnchorPoint = Vector2.new(1, 0)
        box.Parent.Position = UDim2.fromScale(1, 0)
        QOL.bindNumericSetting(box, key, lo, hi)
        return box
    end

    local function textSetting(parent, order, labelText, key)
        local r = row(parent, "TextSetting_" .. key, order)
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(0.42, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = labelText
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Font = Enum.Font.Highway
        label.TextSize = 13
        label.TextColor3 = Color3.fromRGB(240, 240, 240)
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0
        label.ZIndex = 94
        label.Parent = r
        local _, box = makeNativeInput(r, {Name = "SettingInput_" .. key, Size = UDim2.new(0.55, 0, 1, 0), Text = tostring(Persistent.Settings[key] or ""), ZIndex = 96})
        box.Parent.AnchorPoint = Vector2.new(1, 0)
        box.Parent.Position = UDim2.fromScale(1, 0)
        addConnection(Controller.AttachConnections, box.FocusLost:Connect(function()
            Persistent.Settings[key] = box.Text
            saveDiskState()
        end))
        return box
    end

    local function toggle(parent, order, key, labelText)
        return QOL.makePanelButton(parent, "Toggle_" .. key, "", order, function()
            Persistent.Settings[key] = not (Persistent.Settings[key] == true)
            saveDiskState()
            rebuildMetrics()
            applyAll()
            refreshMorePopup()
        end)
    end

    local overview = makePage("Overview")
    QOL.makePanelLabel(overview, "OverviewSummary", "", 52, 1)
    QOL.makePanelLabel(overview, "LoadoutCompare", "", 84, 2)
    QOL.makePanelLabel(overview, "CleanupPreview", "", 34, 3)
    twoButtons(overview, 4, "CaptureSnapshot", "Capture Snapshot", QOL.captureInventorySnapshot, "ToggleReview", "Review New Loot", function() Controller.ReviewLootOnly = not Controller.ReviewLootOnly applyAll() refreshMorePopup() end)
    QOL.makePanelLabel(overview, "QueueSummary", "", 30, 5)
    twoButtons(overview, 6, "QueueEquip", "+ Equip", function() QOL.addQueueAction("Equip") refreshMorePopup() end, "QueueUpgrade", "+ Upgrade", function() QOL.addQueueAction("Upgrade") refreshMorePopup() end)
    twoButtons(overview, 7, "QueueBetter", "+ Upgrade→Better", function() QOL.addQueueAction("Upgrade to Better") refreshMorePopup() end, "QueueSell", "+ Sell Junk", function() QOL.addQueueAction("Sell Junk") refreshMorePopup() end)
    twoButtons(overview, 8, "RunQueue", "Run Queue", QOL.runActionQueue, "ClearQueue", "Clear / Stop Queue", function() Controller.QueueStopRequested = true Controller.ActionQueue = {} refreshMorePopup() end)
    QOL.makePanelLabel(overview, "CompareSummary", "", 72, 9)
    twoButtons(overview, 10, "PinHovered", "Pin Hovered Item", function() QOL.pinHoveredItem() refreshMorePopup() end, "PushCompare", "Add Pinned to Compare", function() local info = QOL.selectedMetaInfo() if info then QOL.pushCompareUID(info.UID) end refreshMorePopup() end)

    local loot = makePage("Loot")
    QOL.makePanelLabel(loot, "LootSummary", "", 42, 1)
    local wishRow = row(loot, "WishlistRow", 2)
    local _, wishBox = makeNativeInput(wishRow, {Name = "WishlistInput", Size = UDim2.new(0.67, 0, 1, 0), Text = "", Placeholder = "Exact item name or hover/pin one", ZIndex = 96})
    local wishButton = makeNativeButton(wishRow, {Name = "WishlistToggle", Size = UDim2.new(0.30, 0, 1, 0), Text = "Add / Remove", InnerColor = Color3.fromRGB(62, 109, 120), ZIndex = 96, MinTextSize = 8, MaxTextSize = 14})
    wishButton.AnchorPoint = Vector2.new(1, 0) wishButton.Position = UDim2.fromScale(1, 0)
    addConnection(Controller.AttachConnections, wishButton.MouseButton1Click:Connect(function() local name = wishBox.Text local info = QOL.selectedMetaInfo() if name == "" and info then name = info.Name end QOL.toggleWishlistByName(name) refreshMorePopup() end))
    QOL.makePanelLabel(loot, "WishlistList", "", 60, 3)
    toggle(loot, 4, "DropNotifications", "Drop notifications")
    toggle(loot, 5, "WishlistNotifications", "Wishlist notifications")
    toggle(loot, 5, "GodpotNotifications", "Godpot drop notifications")
    toggle(loot, 6, "SRollNotifications", "S-roll notifications")
    toggle(loot, 7, "LegendaryNotifications", "Legendary+ notifications")
    textSetting(loot, 8, "Drop sound asset ID", "DropSoundId")
    numeric(loot, 9, "Capacity", "Inventory capacity fallback", "InventoryCapacity", 1, 2000)
    numeric(loot, 10, "CapacityWarn", "Capacity warning %", "InventoryWarningPct", 1, 100)
    numeric(loot, 11, "LootMilestone", "Loot milestone (0 = off)", "LootMilestone", 0, 10000)
    QOL.makePanelLabel(loot, "LootHistory", "", 150, 12)

    local upgrade = makePage("Upgrade")
    QOL.makePanelLabel(upgrade, "UpgradeAnalytics", "", 115, 1)
    numeric(upgrade, 2, "GoldReserve", "Keep this much gold", "GoldReserve", 0, 9e15)
    numeric(upgrade, 3, "SpendCap", "Spend at most (0 = off)", "SpendCap", 0, 9e15)
    numeric(upgrade, 4, "TargetPct", "Target upgrade progress %", "TargetUpgradePct", 0, 100)
    numeric(upgrade, 5, "MinImprovePct", "Minimum equip improvement %", "MinImprovementPct", 0, 100000)
    numeric(upgrade, 6, "MinImproveFlat", "Minimum equip improvement stat", "MinImprovementFlat", 0, 9e15)
    numeric(upgrade, 7, "HighSpend", "Large-spend warning %", "HighSpendPct", 0, 100)
    toggle(upgrade, 8, "RequireBetterNow", "Auto Equip must also be better now")
    toggle(upgrade, 9, "UpgradeWeapon", "Upgrade weapon")
    toggle(upgrade, 10, "UpgradeChest", "Upgrade chest")
    toggle(upgrade, 11, "UpgradeHelmet", "Upgrade helmet")
    twoButtons(upgrade, 12, "UpgradeUntilBetter", "Upgrade Until Better", QOL.requestUpgradeUntilBetter, "AutoUpgradeCenter", "Auto Upgrade Best", requestAutoUpgradeBest)

    local loadouts = makePage("Loadouts")
    QOL.makePanelLabel(loadouts, "LoadoutSummary", "", 88, 1)
    local loadoutRow = row(loadouts, "LoadoutRow", 2)
    local _, loadoutBox = makeNativeInput(loadoutRow, {Name = "LoadoutName", Size = UDim2.new(0.67, 0, 1, 0), Text = "", Placeholder = "Loadout name", ZIndex = 96})
    local saveLoadout = makeNativeButton(loadoutRow, {Name = "SaveLoadout", Size = UDim2.new(0.30, 0, 1, 0), Text = "Save Equipped", InnerColor = Color3.fromRGB(72, 118, 83), ZIndex = 96, MinTextSize = 8, MaxTextSize = 14})
    saveLoadout.AnchorPoint = Vector2.new(1, 0) saveLoadout.Position = UDim2.fromScale(1, 0)
    addConnection(Controller.AttachConnections, saveLoadout.MouseButton1Click:Connect(function() saveEquippedLoadout(loadoutBox.Text) refreshMorePopup() end))
    QOL.makePanelLabel(loadouts, "LoadoutList", "", 92, 3)
    local loadoutUseRow = row(loadouts, "LoadoutUseRow", 4)
    local _, loadoutUseBox = makeNativeInput(loadoutUseRow, {Name = "LoadoutUseName", Size = UDim2.new(0.56, 0, 1, 0), Text = "", Placeholder = "Existing loadout name", ZIndex = 96})
    local applyLoadoutButton = makeNativeButton(loadoutUseRow, {Name = "ApplyLoadout", Size = UDim2.new(0.20, 0, 1, 0), Text = "Apply", InnerColor = Color3.fromRGB(72, 118, 83), ZIndex = 96, MinTextSize = 8, MaxTextSize = 13})
    applyLoadoutButton.Position = UDim2.fromScale(0.58, 0)
    local deleteLoadoutButton = makeNativeButton(loadoutUseRow, {Name = "DeleteLoadout", Size = UDim2.new(0.20, 0, 1, 0), Text = "Delete", InnerColor = Color3.fromRGB(130, 66, 66), ZIndex = 96, MinTextSize = 8, MaxTextSize = 13})
    deleteLoadoutButton.AnchorPoint = Vector2.new(1, 0) deleteLoadoutButton.Position = UDim2.fromScale(1, 0)
    addConnection(Controller.AttachConnections, applyLoadoutButton.MouseButton1Click:Connect(function() requestApplyLoadout(loadoutUseBox.Text) end))
    addConnection(Controller.AttachConnections, deleteLoadoutButton.MouseButton1Click:Connect(function() deleteLoadout(loadoutUseBox.Text) refreshMorePopup() end))
    local loadoutRenameRow = row(loadouts, "LoadoutRenameRow", 5)
    local _, loadoutNewBox = makeNativeInput(loadoutRenameRow, {Name = "LoadoutNewName", Size = UDim2.new(0.56, 0, 1, 0), Text = "", Placeholder = "New loadout name", ZIndex = 96})
    local renameButton = makeNativeButton(loadoutRenameRow, {Name = "RenameLoadout", Size = UDim2.new(0.20, 0, 1, 0), Text = "Rename", InnerColor = Color3.fromRGB(75, 92, 116), ZIndex = 96, MinTextSize = 8, MaxTextSize = 13})
    renameButton.Position = UDim2.fromScale(0.58, 0)
    local duplicateButton2 = makeNativeButton(loadoutRenameRow, {Name = "DuplicateLoadout", Size = UDim2.new(0.20, 0, 1, 0), Text = "Duplicate", InnerColor = Color3.fromRGB(75, 92, 116), ZIndex = 96, MinTextSize = 7, MaxTextSize = 12})
    duplicateButton2.AnchorPoint = Vector2.new(1, 0) duplicateButton2.Position = UDim2.fromScale(1, 0)
    addConnection(Controller.AttachConnections, renameButton.MouseButton1Click:Connect(function() QOL.renameLoadout(loadoutUseBox.Text, loadoutNewBox.Text, false) refreshMorePopup() end))
    addConnection(Controller.AttachConnections, duplicateButton2.MouseButton1Click:Connect(function() QOL.renameLoadout(loadoutUseBox.Text, loadoutNewBox.Text, true) refreshMorePopup() end))
    twoButtons(loadouts, 6, "SaveClassProfile", "Save Class Profile", QOL.saveClassProfile, "LoadClassProfile", "Load Class Profile", QOL.loadClassProfile)
    local profileRow = row(loadouts, "ProfileRow", 7)
    local _, profileBox = makeNativeInput(profileRow, {Name = "ProfileName", Size = UDim2.new(0.67, 0, 1, 0), Text = "", Placeholder = "Settings profile name", ZIndex = 96})
    local saveProfile = makeNativeButton(profileRow, {Name = "SaveProfile", Size = UDim2.new(0.30, 0, 1, 0), Text = "Save Profile", InnerColor = Color3.fromRGB(75, 92, 116), ZIndex = 96, MinTextSize = 8, MaxTextSize = 14})
    saveProfile.AnchorPoint = Vector2.new(1, 0) saveProfile.Position = UDim2.fromScale(1, 0)
    addConnection(Controller.AttachConnections, saveProfile.MouseButton1Click:Connect(function() QOL.saveSettingsProfile(profileBox.Text) refreshMorePopup() end))
    QOL.makePanelLabel(loadouts, "ProfileList", "", 70, 8)
    local profileUseRow = row(loadouts, "ProfileUseRow", 9)
    local _, profileUseBox = makeNativeInput(profileUseRow, {Name = "ProfileUseName", Size = UDim2.new(0.56, 0, 1, 0), Text = "", Placeholder = "Settings profile name", ZIndex = 96})
    local applyProfileButton = makeNativeButton(profileUseRow, {Name = "ApplyProfile", Size = UDim2.new(0.20, 0, 1, 0), Text = "Load", InnerColor = Color3.fromRGB(72, 118, 83), ZIndex = 96, MinTextSize = 8, MaxTextSize = 13})
    applyProfileButton.Position = UDim2.fromScale(0.58, 0)
    local deleteProfileButton = makeNativeButton(profileUseRow, {Name = "DeleteProfile", Size = UDim2.new(0.20, 0, 1, 0), Text = "Delete", InnerColor = Color3.fromRGB(130, 66, 66), ZIndex = 96, MinTextSize = 8, MaxTextSize = 13})
    deleteProfileButton.AnchorPoint = Vector2.new(1, 0) deleteProfileButton.Position = UDim2.fromScale(1, 0)
    addConnection(Controller.AttachConnections, applyProfileButton.MouseButton1Click:Connect(function() QOL.applySettingsProfileByName(profileUseBox.Text) refreshMorePopup() end))
    addConnection(Controller.AttachConnections, deleteProfileButton.MouseButton1Click:Connect(function() QOL.deleteSettingsProfileByName(profileUseBox.Text) refreshMorePopup() end))

    local search = makePage("Search")
    QOL.makePanelLabel(search, "SearchHelp", "ADVANCED SEARCH • rarity:legendary type:helmet class:mage roll:s new:true equipped:true locked:true favorite:true wishlist:true junk:true protected:true improvement:true uid:... stat>1000 pot>=5000 sell<100000 upgrade>=50 roi>0", 66, 1)
    toggle(search, 2, "AdvancedSearch", "Advanced search syntax")
    twoButtons(search, 3, "QuickS", "S Rolls", function() Controller.SearchText = "roll:s" applyAll() end, "QuickNew", "New Gear", function() Controller.SearchText = "new:true" applyAll() end)
    twoButtons(search, 4, "QuickImprove", "Improvements", function() Controller.SearchText = "improvement:true" applyAll() end, "QuickLegend", "Legendary+", function() Controller.SearchText = "rarity:legendary" applyAll() end)
    twoButtons(search, 5, "QuickUnprotected", "Unprotected", function() Controller.SearchText = "protected:false" applyAll() end, "QuickLoadout", "Loadout Items", function() Controller.SearchText = "loadout:true" applyAll() end)
    local savedRow = row(search, "SavedSearchRow", 6)
    local _, savedBox = makeNativeInput(savedRow, {Name = "SavedSearchName", Size = UDim2.new(0.67, 0, 1, 0), Text = "", Placeholder = "Saved search name", ZIndex = 96})
    local saveSearch = makeNativeButton(savedRow, {Name = "SaveSearch", Size = UDim2.new(0.30, 0, 1, 0), Text = "Save Current", InnerColor = Color3.fromRGB(75, 92, 116), ZIndex = 96, MinTextSize = 8, MaxTextSize = 14})
    saveSearch.AnchorPoint = Vector2.new(1, 0) saveSearch.Position = UDim2.fromScale(1, 0)
    addConnection(Controller.AttachConnections, saveSearch.MouseButton1Click:Connect(function() QOL.saveCurrentSearch(savedBox.Text) refreshMorePopup() end))
    QOL.makePanelLabel(search, "SavedSearchList", "", 70, 7)
    local savedUseRow = row(search, "SavedSearchUseRow", 8)
    local _, savedUseBox = makeNativeInput(savedUseRow, {Name = "SavedSearchUseName", Size = UDim2.new(0.56, 0, 1, 0), Text = "", Placeholder = "Saved search name", ZIndex = 96})
    local applySavedButton = makeNativeButton(savedUseRow, {Name = "ApplySavedSearch", Size = UDim2.new(0.20, 0, 1, 0), Text = "Apply", InnerColor = Color3.fromRGB(72, 118, 83), ZIndex = 96, MinTextSize = 8, MaxTextSize = 13})
    applySavedButton.Position = UDim2.fromScale(0.58, 0)
    local deleteSavedButton = makeNativeButton(savedUseRow, {Name = "DeleteSavedSearch", Size = UDim2.new(0.20, 0, 1, 0), Text = "Delete", InnerColor = Color3.fromRGB(130, 66, 66), ZIndex = 96, MinTextSize = 8, MaxTextSize = 13})
    deleteSavedButton.AnchorPoint = Vector2.new(1, 0) deleteSavedButton.Position = UDim2.fromScale(1, 0)
    addConnection(Controller.AttachConnections, applySavedButton.MouseButton1Click:Connect(function() QOL.applySavedSearch(savedUseBox.Text) refreshMorePopup() end))
    addConnection(Controller.AttachConnections, deleteSavedButton.MouseButton1Click:Connect(function() QOL.deleteSavedSearch(savedUseBox.Text) refreshMorePopup() end))
    QOL.makePanelLabel(search, "PinnedMeta", "", 52, 9)
    local noteRow = row(search, "NoteRow", 10)
    local _, noteBox = makeNativeInput(noteRow, {Name = "NoteInput", Size = UDim2.new(0.67, 0, 1, 0), Text = "", Placeholder = "Note for pinned/hovered item", ZIndex = 96})
    local noteSave = makeNativeButton(noteRow, {Name = "SaveNote", Size = UDim2.new(0.30, 0, 1, 0), Text = "Save Note", InnerColor = Color3.fromRGB(75, 92, 116), ZIndex = 96, MinTextSize = 8, MaxTextSize = 14})
    noteSave.AnchorPoint = Vector2.new(1, 0) noteSave.Position = UDim2.fromScale(1, 0)
    addConnection(Controller.AttachConnections, noteSave.MouseButton1Click:Connect(function() QOL.setPinnedMetadata(noteBox.Text, nil) refreshMorePopup() end))
    local tagRow = row(search, "TagRow", 11)
    local _, tagBox = makeNativeInput(tagRow, {Name = "TagInput", Size = UDim2.new(0.67, 0, 1, 0), Text = "", Placeholder = "Custom tag", ZIndex = 96})
    local tagSave = makeNativeButton(tagRow, {Name = "SaveTag", Size = UDim2.new(0.30, 0, 1, 0), Text = "Save Tag", InnerColor = Color3.fromRGB(75, 92, 116), ZIndex = 96, MinTextSize = 8, MaxTextSize = 14})
    tagSave.AnchorPoint = Vector2.new(1, 0) tagSave.Position = UDim2.fromScale(1, 0)
    addConnection(Controller.AttachConnections, tagSave.MouseButton1Click:Connect(function() QOL.setPinnedMetadata(nil, tagBox.Text) refreshMorePopup() end))
    twoButtons(search, 12, "FavVisible", "Favorite Visible", function() QOL.bulkVisible("favorite", true) end, "LockVisible", "Lock Visible", function() QOL.bulkVisible("lock", true) end)
    twoButtons(search, 13, "UnfavVisible", "Unfavorite Visible", function() QOL.bulkVisible("favorite", false) end, "UnlockVisible", "Unlock Visible", function() QOL.bulkVisible("lock", false) end)

    local protect = makePage("Protect")
    QOL.makePanelLabel(protect, "ProtectionSummary", "", 52, 1)
    QOL.makePanelButton(protect, "ToggleJunkMode", "", 2, function()
        Persistent.Settings.JunkMode = Persistent.Settings.JunkMode == "NonBest" and "Duplicates" or "NonBest"
        saveDiskState()
        applyAll()
        refreshMorePopup()
    end)
    numeric(protect, 3, "KeepCopies", "Keep copies (Duplicates mode)", "KeepCopies", 1, 20)
    toggle(protect, 3, "ProtectGodpot", "Auto-protect Godpot (100% max rolls)")
    toggle(protect, 4, "ProtectSRolls", "Auto-protect S rolls")
    toggle(protect, 5, "ProtectLegendary", "Auto-protect Legendary+")
    toggle(protect, 6, "WishlistAutoLock", "Wishlist auto-lock")
    numeric(protect, 7, "SellMax", "Auto-sell value ceiling (0 = off)", "AutoSellMaxValue", 0, 9e15)
    numeric(protect, 8, "HighValue", "High-value sell warning (0 = off)", "HighValueWarning", 0, 9e15)
    toggle(protect, 9, "AutoCleanupPrompt", "Capacity cleanup prompt")
    local keepRuleRow = row(protect, "KeepRuleRow", 10)
    local _, keepRuleName = makeNativeInput(keepRuleRow, {Name = "KeepRuleName", Size = UDim2.new(0.53, 0, 1, 0), Text = "", Placeholder = "Per-item keep rule name", ZIndex = 96})
    local _, keepRuleCount = makeNativeInput(keepRuleRow, {Name = "KeepRuleCount", Size = UDim2.new(0.18, 0, 1, 0), Text = "2", Placeholder = "2", ZIndex = 96, TextXAlignment = Enum.TextXAlignment.Center})
    keepRuleCount.Parent.Position = UDim2.fromScale(0.55, 0)
    local setKeepButton = makeNativeButton(keepRuleRow, {Name = "SetKeepRule", Size = UDim2.new(0.12, 0, 1, 0), Text = "Set", InnerColor = Color3.fromRGB(72, 118, 83), ZIndex = 96, MinTextSize = 8, MaxTextSize = 12})
    setKeepButton.Position = UDim2.fromScale(0.75, 0)
    local clearKeepButton = makeNativeButton(keepRuleRow, {Name = "ClearKeepRule", Size = UDim2.new(0.11, 0, 1, 0), Text = "Clear", InnerColor = Color3.fromRGB(130, 66, 66), ZIndex = 96, MinTextSize = 8, MaxTextSize = 12})
    clearKeepButton.AnchorPoint = Vector2.new(1, 0) clearKeepButton.Position = UDim2.fromScale(1, 0)
    addConnection(Controller.AttachConnections, setKeepButton.MouseButton1Click:Connect(function() local name = keepRuleName.Text local info = QOL.selectedMetaInfo() if name == "" and info then name = info.Name end QOL.setKeepRule(name, keepRuleCount.Text) refreshMorePopup() end))
    addConnection(Controller.AttachConnections, clearKeepButton.MouseButton1Click:Connect(function() local name = keepRuleName.Text local info = QOL.selectedMetaInfo() if name == "" and info then name = info.Name end QOL.clearKeepRule(name) refreshMorePopup() end))
    QOL.makePanelLabel(protect, "KeepRuleList", "", 60, 11)
    QOL.makePanelLabel(protect, "ProtectionHelp", "JUNK MODES:\n• NOT BEST: Marks all gear as Junk unless it is Equipped, Best-in-Slot (Mage/Warrior/Tank), in a Loadout, or Protected.\n• DUPLICATES: Only marks inferior duplicate copies of the same item name.\nEquipped, Favorites, Locks, Loadouts, Wishlist, S-Rolls, and Legendary+ items are ALWAYS protected in both modes.", 84, 12)

    local history = makePage("History")
    QOL.makePanelLabel(history, "SessionSummary", "", 60, 1)
    QOL.makePanelLabel(history, "SessionStats", "", 48, 2)
    QOL.makePanelLabel(history, "SnapshotDiff", "", 90, 3)
    twoButtons(history, 4, "CaptureSnapshot2", "Capture Snapshot", QOL.captureInventorySnapshot, "ExportSession", "Export Session", QOL.exportSessionSummary)
    QOL.makePanelLabel(history, "ActionLog", "", 180, 5)
    QOL.makePanelLabel(history, "LootHistory2", "", 170, 6)
    toggle(history, 7, "AutoExportSession", "Auto-export summary on script stop")

    local ui = makePage("UI")
    twoButtons(ui, 1, "ModeMinimal", "Minimal", function() QOL.applyUIMode("Minimal") refreshMorePopup() end, "ModeCompact", "Compact", function() QOL.applyUIMode("Compact") refreshMorePopup() end)
    QOL.makePanelButton(ui, "ModeDetailed", "Detailed", 2, function() QOL.applyUIMode("Detailed") refreshMorePopup() end)
    toggle(ui, 3, "HideBadges", "Hide all item badges")
    toggle(ui, 4, "HideStatusBadge", "Hide roll/status badges")
    toggle(ui, 5, "HideNewBadge", "Hide NEW badges")
    toggle(ui, 6, "HideUpgradeBadge", "Hide upgrade/potential badges")
    toggle(ui, 7, "HideProtectionBadge", "Hide protection badges")
    toggle(ui, 8, "CompactTooltip", "Compact tooltips")
    numeric(ui, 9, "TooltipSize", "Tooltip text size", "TooltipTextSize", 10, 22)
    numeric(ui, 10, "GridScale", "Card/grid scale %", "GridScale", 70, 140)
    numeric(ui, 11, "GridColumns", "Grid columns (0 = native)", "GridColumns", 0, 12)
    numeric(ui, 12, "GoldMilestone", "Gold milestone (0 = off)", "GoldMilestone", 0, 9e15)
    QOL.makePanelButton(ui, "ImportMode", "", 13, function() Persistent.Settings.ImportMode = Persistent.Settings.ImportMode == "Merge" and "Replace" or "Merge" saveDiskState() refreshMorePopup() end)
    twoButtons(ui, 14, "ExportButton", "Export Settings", exportSettings, "ImportButton", "Import Settings", requestImportSettings)

    local active = Persistent.Settings.QOLTab
    local valid = false
    for _, name in ipairs(tabNames) do if name == active then valid = true end end
    if not valid then active = "Overview" Persistent.Settings.QOLTab = active end
    for name, page in pairs(pages) do page.Visible = name == active end
    return popup
end

refreshMorePopup = function()
    local popup = Controller.CurrentMorePopup
    if not popup or not popup.Parent then return end
    rebuildMetrics()
    local pages = popup:FindFirstChild("Pages", true)
    if not pages then return end
    local active = tostring(Persistent.Settings.QOLTab or "Overview")
    for _, page in ipairs(pages:GetChildren()) do if page:IsA("ScrollingFrame") then page.Visible = page.Name == active end end
    local tabs = popup:FindFirstChild("Tabs", true)
    if tabs then
        for _, button in ipairs(tabs:GetChildren()) do
            if button:IsA("TextButton") then
                local name = button.Name:gsub("^Tab_", "")
                local face = button:FindFirstChild("DQInner")
                if face then setPlateColor(face, name == active and Color3.fromRGB(87, 112, 145) or Color3.fromRGB(68, 78, 92)) end
            end
        end
    end

    local function setLabel(name, value)
        local obj = popup:FindFirstChild(name, true)
        if obj and obj:IsA("TextLabel") then obj.Text = value end
    end
    setLabel("OverviewSummary", QOL.inventoryOverviewText())
    setLabel("LoadoutCompare", QOL.fullLoadoutComparisonText())
    setLabel("CleanupPreview", QOL.cleanupPreviewText())
    setLabel("QueueSummary", QOL.queueText())
    setLabel("CompareSummary", QOL.compareSelectionText())
    setLabel("LootSummary", sessionLootSummaryText())
    setLabel("LootHistory", QOL.lootHistoryText())
    setLabel("UpgradeAnalytics", QOL.topUpgradeTargetsText())
    setLabel("LoadoutSummary", QOL.fullLoadoutComparisonText())
    setLabel("ProtectionSummary", QOL.protectionSummaryText())
    local keepParts = {}
    for key, count in pairs(Persistent.KeepRules or {}) do keepParts[#keepParts + 1] = tostring(key) .. "=" .. tostring(count) end
    table.sort(keepParts)
    setLabel("KeepRuleList", "PER-ITEM KEEP RULES • " .. (#keepParts > 0 and table.concat(keepParts, ", ") or "none"))
    setLabel("SessionSummary", sessionLootSummaryText())
    local stats = Controller.SessionStats or {}
    setLabel("SessionStats", "SESSION ACTIONS • equipped " .. tostring(stats.Equipped or 0) .. " • upgrades " .. tostring(stats.Upgrades or 0) .. " • upgrade gold " .. formatCompact(stats.UpgradeGold or 0) .. " • sold " .. tostring(stats.Sold or 0) .. " • sell value " .. formatCompact(stats.SellGold or 0))
    setLabel("SnapshotDiff", QOL.snapshotDiffText())
    setLabel("ActionLog", actionLogText())
    setLabel("LootHistory2", QOL.lootHistoryText())

    local wishNames = {}
    for _, display in pairs(Persistent.Wishlist or {}) do wishNames[#wishNames + 1] = tostring(display) end
    table.sort(wishNames)
    setLabel("WishlistList", "WISHLIST • " .. (#wishNames > 0 and table.concat(wishNames, ", ") or "empty"))

    local saved = {}
    for name, query in pairs(Persistent.SavedSearches or {}) do saved[#saved + 1] = tostring(name) .. " = " .. tostring(query) end
    table.sort(saved)
    setLabel("SavedSearchList", "SAVED SEARCHES\n" .. (#saved > 0 and table.concat(saved, "\n") or "none"))

    local profiles = {}
    for name in pairs(Persistent.SettingsProfiles or {}) do profiles[#profiles + 1] = tostring(name) end
    table.sort(profiles)
    setLabel("ProfileList", "SETTINGS PROFILES • " .. (#profiles > 0 and table.concat(profiles, ", ") or "none"))

    local loadoutNames = sortedLoadoutNames()
    setLabel("LoadoutList", "SAVED LOADOUTS • " .. (#loadoutNames > 0 and table.concat(loadoutNames, ", ") or "none") .. "\nEnter a name below to apply/delete; use a new name to rename/duplicate.")

    local info = QOL.selectedMetaInfo()
    setLabel("PinnedMeta", info and ("PINNED / HOVERED • " .. tostring(info.Name) .. " • UID " .. tostring(info.UID) .. (info.CustomTag ~= "" and (" • tag " .. info.CustomTag) or "") .. (info.Note ~= "" and ("\nNote: " .. info.Note) or "")) or "PINNED / HOVERED • none")

    for _, obj in ipairs(popup:GetDescendants()) do
        if obj:IsA("TextButton") and obj.Name:match("^Toggle_") then
            local key = obj.Name:gsub("^Toggle_", "")
            local labels = {
                DropNotifications = "Drop notifications", WishlistNotifications = "Wishlist notifications", GodpotNotifications = "Godpot drop notifications", SRollNotifications = "S-roll notifications", LegendaryNotifications = "Legendary+ notifications",
                AdvancedSearch = "Advanced search syntax", RequireBetterNow = "Auto Equip must also be better now", UpgradeWeapon = "Upgrade weapon", UpgradeChest = "Upgrade chest", UpgradeHelmet = "Upgrade helmet",
                ProtectGodpot = "Auto-protect Godpots", ProtectSRolls = "Auto-protect S rolls", ProtectLegendary = "Auto-protect Legendary+", WishlistAutoLock = "Wishlist auto-lock", AutoCleanupPrompt = "Capacity cleanup prompt",
                AutoExportSession = "Auto-export summary on script stop", HideBadges = "Hide all item badges", HideStatusBadge = "Hide roll/status badges", HideNewBadge = "Hide NEW badges",
                HideUpgradeBadge = "Hide upgrade/potential badges", HideProtectionBadge = "Hide protection badges", CompactTooltip = "Compact tooltips",
            }
            obj.Text = tostring(labels[key] or key) .. ": " .. (Persistent.Settings[key] == true and "ON" or "OFF")
            local face = obj:FindFirstChild("DQInner")
            if face then setPlateColor(face, Persistent.Settings[key] == true and Color3.fromRGB(79, 118, 91) or Color3.fromRGB(72, 72, 72)) end
        elseif obj:IsA("TextBox") and obj.Parent and obj.Parent.Name:match("^SettingInput_") then
            local key = obj.Parent.Name:gsub("^SettingInput_", "")
            if not obj:IsFocused() and Persistent.Settings[key] ~= nil then obj.Text = tostring(Persistent.Settings[key]) end
        end
    end

    local junkModeBtn = popup:FindFirstChild("ToggleJunkMode", true)
    if junkModeBtn and junkModeBtn:IsA("TextButton") then
        local isNonBest = Persistent.Settings.JunkMode == "NonBest"
        junkModeBtn.Text = "Junk Mode: " .. (isNonBest and "NOT BEST (Sell Obsolete)" or "DUPLICATES ONLY")
        local face = junkModeBtn:FindFirstChild("DQInner")
        if face then
            setPlateColor(face, isNonBest and Color3.fromRGB(87, 112, 145) or Color3.fromRGB(72, 72, 72))
        end
    end
    local importMode = popup:FindFirstChild("ImportMode", true)
    if importMode and importMode:IsA("TextButton") then importMode.Text = "Import mode: " .. tostring(Persistent.Settings.ImportMode) end
    local review = popup:FindFirstChild("ToggleReview", true)
    if review and review:IsA("TextButton") then review.Text = "Review New Loot: " .. (Controller.ReviewLootOnly and "ON" or "OFF") end
end


toggleMorePopup = function()
    local popup = Controller.CurrentMorePopup
    if not popup then
        return
    end

    local opening = not popup.Visible
    closePopups()
    popup.Visible = opening

    if opening then
        rebuildMetrics()
        refreshMorePopup()
    end
end

showDuplicateComparison = function(sourceInfo)
    if not sourceInfo then
        return
    end

    rebuildMetrics()

    if Controller.CurrentDuplicatePopup and Controller.CurrentDuplicatePopup.Parent then
        Controller.CurrentDuplicatePopup:Destroy()
        Controller.CurrentDuplicatePopup = nil
    end

    local gui = Controller.CurrentGui
    local main = gui and gui:FindFirstChild("mainBackground")
    local innerBG = main and main:FindFirstChild("innerBackground")
    local rightSide = innerBG and innerBG:FindFirstChild("rightSideFrame")
    if not rightSide then
        return
    end

    local list = {}
    for _, info in ipairs(Controller.InventoryInfos or {}) do
        if info.ItemType == sourceInfo.ItemType and info.NameLower == sourceInfo.NameLower then
            list[#list + 1] = info
        end
    end

    if #list <= 1 then
        nativeAlert("This item does not currently have a duplicate group.")
        return
    end

    table.sort(list, function(a, b)
        if a.Potential ~= b.Potential then return a.Potential > b.Potential end
        if a.Current ~= b.Current then return a.Current > b.Current end
        return tostring(a.UID) < tostring(b.UID)
    end)

    closePopups()

    local popup, inner = makePopupPlate(
        rightSide,
        "DQDuplicatePopup",
        UDim2.new(0.05, 0, 0.25, 0),
        UDim2.new(0.90, 0, 0.56, 0)
    )
    popup.ZIndex = 110
    inner.ZIndex = 111
    popup.Visible = true
    Controller.CurrentDuplicatePopup = popup

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(0.86, 0, 0, 34)
    title.Position = UDim2.new(0.03, 0, 0.025, 0)
    title.BackgroundTransparency = 1
    title.Text = tostring(sourceInfo.Name) .. " • " .. tostring(#list) .. " copies"
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 16
    title.TextColor3 = Color3.fromRGB(255, 227, 130)
    title.TextStrokeColor3 = Color3.new(0, 0, 0)
    title.TextStrokeTransparency = 0
    title.ZIndex = 115
    title.Parent = inner

    local close = makeNativeButton(inner, {
        Name = "Close",
        Size = UDim2.new(0.09, 0, 0, 30),
        Text = "X",
        InnerColor = Color3.fromRGB(132, 65, 65),
        ZIndex = 116,
        MinTextSize = 10,
        MaxTextSize = 16,
    })
    close.AnchorPoint = Vector2.new(1, 0)
    close.Position = UDim2.new(0.98, 0, 0.025, 0)
    addConnection(Controller.AttachConnections, close.MouseButton1Click:Connect(function()
        popup.Visible = false
    end))

    local scroller = Instance.new("ScrollingFrame")
    scroller.Position = UDim2.new(0.03, 0, 0.16, 0)
    scroller.Size = UDim2.new(0.94, 0, 0.80, 0)
    scroller.BackgroundTransparency = 1
    scroller.BorderSizePixel = 0
    scroller.ClipsDescendants = true
    scroller.ScrollBarThickness = 5
    scroller.ScrollingDirection = Enum.ScrollingDirection.X
    scroller.AutomaticCanvasSize = Enum.AutomaticSize.X
    scroller.CanvasSize = UDim2.new()
    scroller.ZIndex = 112
    scroller.Parent = inner

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.Padding = UDim.new(0, 8)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = scroller

    local potentialCounts = {}
    local highest = list[1].Potential
    for _, info in ipairs(list) do
        potentialCounts[info.Potential] = (potentialCounts[info.Potential] or 0) + 1
    end

    for index, info in ipairs(list) do
        local plate = Instance.new("Frame")
        plate.LayoutOrder = index
        plate.Size = UDim2.new(0, 220, 0.96, 0)
        plate.BackgroundTransparency = 1
        plate.ZIndex = 113
        plate.Parent = scroller

        makeImagePlate(
            plate,
            "BG",
            UDim2.fromScale(1, 1),
            UDim2.fromScale(0, 0),
            Color3.fromRGB(62, 62, 62),
            114
        )

        local tie = (potentialCounts[info.Potential] or 0) > 1
        local rankText
        if tie and info.Potential == highest then
            rankText = "TIED BEST POTENTIAL"
        elseif tie then
            rankText = "EQUAL POTENTIAL"
        elseif info.Potential == highest then
            rankText = "BEST POTENTIAL"
        else
            rankText = "LOWER POTENTIAL"
        end

        local status = {}
        if info.IsEquipped then status[#status + 1] = "EQUIPPED" end
        if info.UID and Persistent.Favorites[info.UID] then status[#status + 1] = "FAVORITE" end
        if info.UID and Persistent.Locked[info.UID] then status[#status + 1] = "LOCKED" end
        if info.IsLoadoutProtected then status[#status + 1] = "LOADOUT" end

        local junkReason = info.IsJunk
            and "JUNK: lowest eligible potential/current copy"
            or (info.IsEquipped or info.IsLoadoutProtected
                or (info.UID and Persistent.Favorites[info.UID])
                or (info.UID and Persistent.Locked[info.UID]))
                and "PROTECTED: cannot be Smart Junk"
                or "KEEP: not the single worst copy"

        local label = Instance.new("TextLabel")
        label.Position = UDim2.fromScale(0.05, 0.04)
        label.Size = UDim2.fromScale(0.90, 0.92)
        label.BackgroundTransparency = 1
        label.TextWrapped = true
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.TextYAlignment = Enum.TextYAlignment.Top
        label.Font = Enum.Font.Highway
        label.TextSize = 13
        label.TextColor3 = Color3.fromRGB(245, 245, 245)
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.TextStrokeTransparency = 0
        label.ZIndex = 115
        label.Text =
            rankText
            .. "\n" .. tostring(info.Rarity):upper()
            .. "\nCurrent " .. formatCompact(info.Current)
            .. " • Max " .. formatCompact(info.Potential)
            .. "\nRemaining " .. formatInt(info.RemainingUpgrades)
            .. " • finish cost " .. formatInt(info.UpgradeCost)
            .. "\nUpgrade " .. formatUpgradeProgress(info.CurrentUpgrade, info.MaxUpgrades, 1)
            .. "\n" .. (#status > 0 and table.concat(status, " • ") or "UNPROTECTED")
            .. "\n" .. junkReason
            .. "\nUID " .. tostring(info.UID)
        label.Parent = plate
    end
end

function QOL.makeActionProgress(rightSide)
    local strip = Instance.new("Frame")
    strip.Name = "DQActionProgress"
    strip.AnchorPoint = Vector2.new(0.5, 0)
    strip.Position = UDim2.new(0.5, 0, 0.224, 0)
    strip.Size = UDim2.new(0.96, 0, 0.033, 0)
    strip.BackgroundTransparency = 1
    strip.ZIndex = 30
    strip.Parent = rightSide

    local status = Instance.new("TextLabel")
    status.Name = "Status"
    status.Size = UDim2.new(0.78, 0, 1, 0)
    status.BackgroundTransparency = 1
    status.Text = Controller.ActionProgressText or "Idle"
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.TextWrapped = false
    status.TextTruncate = Enum.TextTruncate.AtEnd
    status.Font = Enum.Font.Highway
    status.TextSize = 12
    status.TextColor3 = Color3.fromRGB(230, 230, 230)
    status.TextStrokeColor3 = Color3.new(0, 0, 0)
    status.TextStrokeTransparency = 0
    status.ZIndex = 32
    status.Parent = strip

    local stop = makeNativeButton(strip, {
        Name = "Stop",
        Size = UDim2.new(0.20, 0, 1, 0),
        Text = "STOP",
        InnerColor = Color3.fromRGB(145, 62, 62),
        ZIndex = 34,
        MinTextSize = 9,
        MaxTextSize = 14,
    })
    stop.AnchorPoint = Vector2.new(1, 0)
    stop.Position = UDim2.fromScale(1, 0)

    addConnection(Controller.AttachConnections, stop.MouseButton1Click:Connect(requestStopAction))
    return strip
end

updateActionVisuals = function()
    local bar = Controller.CurrentActionBar
    if not bar then
        return
    end

    local upgradeButton = bar:FindFirstChild("AutoUpgradeButton")
    if upgradeButton and upgradeButton:IsA("TextButton") then
        if Controller.PendingAutoUpgradeClass then
            upgradeButton.Text =
                "Queued: " .. Controller.PendingAutoUpgradeClass
        elseif getDQPlaceName() == "Level" then
            upgradeButton.Text = "Queue Upgrade"
        else
            upgradeButton.Text = "Auto Upgrade Best"
        end
    end

    local junkButton = bar:FindFirstChild("JunkOnlyButton")
    if junkButton and junkButton:IsA("TextButton") then
        local inner = junkButton:FindFirstChild("DQInner")
        junkButton.Text = Controller.JunkOnly and "Junk: ON" or "Junk"

        if inner then
            setPlateColor(
                inner,
                Controller.JunkOnly and Color3.fromRGB(166, 63, 63)
                    or Color3.fromRGB(82, 70, 70)
            )
        end
    end
end

function QOL.makeActionBar(rightSide)
    local old = rightSide:FindFirstChild("DQInventoryActions")
    if old then
        old:Destroy()
    end

    local bar = Instance.new("Frame")
    bar.Name = "DQInventoryActions"
    bar.AnchorPoint = Vector2.new(0.5, 0)
    bar.Position = UDim2.new(0.5, 0, 0.168, 0)
    bar.Size = UDim2.new(0.96, 0, 0.055, 0)
    bar.BackgroundTransparency = 1
    bar.BorderSizePixel = 0
    bar.ClipsDescendants = false
    bar.ZIndex = 30
    bar.Parent = rightSide

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0.012, 0)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = bar

    local equipButton = makeNativeButton(bar, {
        Name = "AutoEquipButton",
        LayoutOrder = 1,
        Size = UDim2.new(0.245, 0, 0.98, 0),
        Text = "Auto Equip Best",
        InnerColor = Color3.fromRGB(66, 117, 154),
        ZIndex = 35,
        MinTextSize = 9,
        MaxTextSize = 16,
    })

    local upgradeButton = makeNativeButton(bar, {
        Name = "AutoUpgradeButton",
        LayoutOrder = 2,
        Size = UDim2.new(0.275, 0, 0.98, 0),
        Text = "Auto Upgrade Best",
        InnerColor = Color3.fromRGB(151, 119, 50),
        ZIndex = 35,
        MinTextSize = 9,
        MaxTextSize = 16,
    })

    local sellJunkButton = makeNativeButton(bar, {
        Name = "AutoSellJunkButton",
        LayoutOrder = 3,
        Size = UDim2.new(0.255, 0, 0.98, 0),
        Text = "Auto Sell Junk",
        InnerColor = Color3.fromRGB(145, 79, 55),
        ZIndex = 35,
        MinTextSize = 8,
        MaxTextSize = 15,
    })

    local junkButton = makeNativeButton(bar, {
        Name = "JunkOnlyButton",
        LayoutOrder = 4,
        Size = UDim2.new(0.125, 0, 0.98, 0),
        Text = "Junk",
        InnerColor = Color3.fromRGB(82, 70, 70),
        ZIndex = 35,
        MinTextSize = 8,
        MaxTextSize = 15,
    })

    addConnection(Controller.AttachConnections, equipButton.MouseButton1Click:Connect(function()
        closePopups()
        autoEquipBest()
    end))

    addConnection(Controller.AttachConnections, upgradeButton.MouseButton1Click:Connect(function()
        closePopups()
        requestAutoUpgradeBest()
    end))

    addConnection(Controller.AttachConnections, sellJunkButton.MouseButton1Click:Connect(function()
        closePopups()
        requestAutoSellJunk()
    end))

    addConnection(Controller.AttachConnections, junkButton.MouseButton1Click:Connect(function()
        Controller.JunkOnly = not Controller.JunkOnly

        if Controller.JunkOnly then
            Persistent.Settings.HideJunk = false
        end

        saveDiskState()
        updateActionVisuals()
        applyAll()
    end))

    updateActionVisuals()

    return bar
end





reindexCards = function()
    local scroll = Controller.CurrentScroll

    if not scroll or not scroll.Parent then
        return
    end

    
    refreshInventoryData()

    local liveCards = {}

    for _, card in ipairs(scroll:GetChildren()) do
        if card:IsA("GuiObject") and card:FindFirstChild("itemType") then
            liveCards[card] = true

            local itemType, itemNumber = getCardIdentity(card)

            if itemType and itemNumber then
                local item = lookupItem(itemType, itemNumber)
                local existing = Controller.CardInfo[card]

                if existing then
                    
                    
                    
                    existing.ItemType = itemType
                    existing.ItemNumber = itemNumber

                    if item then
                        existing.Item = item
                    end
                elseif item then
                    
                    bindCard(card)
                end
            end
        end
    end

    
    for card in pairs(Controller.CardInfo) do
        if not liveCards[card] or not card.Parent then
            Controller.CardInfo[card] = nil
            Controller.TargetLayoutOrder[card] = nil
            Controller.OriginalCardOrder[card] = nil
        end
    end

    seedKnownIDs()
    applyAll()
    refreshSellShopLocks()
end




QOL.inventoryRefreshGeneration = 0
QOL.inventoryRefreshRunning = false
QOL.inventoryRefreshQueued = false

scheduleInventoryRefresh = function(delaySeconds)
    QOL.inventoryRefreshGeneration += 1
    local generation = QOL.inventoryRefreshGeneration

    task.delay(delaySeconds or 0.18, function()
        if not Controller.Alive or generation ~= QOL.inventoryRefreshGeneration then
            return
        end

        if QOL.inventoryRefreshRunning then
            QOL.inventoryRefreshQueued = true
            return
        end

        QOL.inventoryRefreshRunning = true

        local ok, err = pcall(reindexCards)

        QOL.inventoryRefreshRunning = false

        if not ok then
            warn("[DQ Inventory QOL v19.1] batched refresh error:", err)
        end

        if QOL.inventoryRefreshQueued and Controller.Alive then
            QOL.inventoryRefreshQueued = false
            scheduleInventoryRefresh(0.08)
        end
    end)
end

function QOL.cleanupAttachment()
    clearEquippedBindings()
    disconnectAll(Controller.AttachConnections)
    unbindCards(true)

    local scroll = Controller.CurrentScroll

    if scroll and scroll.Parent then
        pcall(function()
            if Controller.OriginalScrollPosition then
                scroll.Position = Controller.OriginalScrollPosition
            end
            if Controller.OriginalScrollSize then
                scroll.Size = Controller.OriginalScrollSize
            end
            if Controller.OriginalScrollZIndex ~= nil then
                scroll.ZIndex = Controller.OriginalScrollZIndex
            end

            local grid = scroll:FindFirstChildOfClass("UIGridLayout")
            if grid and Controller.OriginalGridSortOrder then
                grid.SortOrder = Controller.OriginalGridSortOrder
                if Controller.OriginalGridCellSize then grid.CellSize = Controller.OriginalGridCellSize end
            end

            for _, child in ipairs(scroll:GetChildren()) do
                if child:IsA("GuiObject") and child:FindFirstChild("itemType") then
                    child.Visible = true
                    local originalOrder = Controller.OriginalCardOrder[child]
                    if originalOrder ~= nil then
                        child.LayoutOrder = originalOrder
                    end
                end
            end
        end)
    end

    if Controller.CurrentClassBar and Controller.CurrentClassBar.Parent then
        pcall(function()
            Controller.CurrentClassBar:Destroy()
        end)
    end

    if Controller.CurrentToolbar and Controller.CurrentToolbar.Parent then
        pcall(function()
            Controller.CurrentToolbar:Destroy()
        end)
    end

    if Controller.CurrentActionBar and Controller.CurrentActionBar.Parent then
        pcall(function()
            Controller.CurrentActionBar:Destroy()
        end)
    end

    if Controller.CurrentActionProgress and Controller.CurrentActionProgress.Parent then
        pcall(function()
            Controller.CurrentActionProgress:Destroy()
        end)
    end

    if Controller.CurrentMorePopup and Controller.CurrentMorePopup.Parent then
        pcall(function()
            Controller.CurrentMorePopup:Destroy()
        end)
    end

    if Controller.CurrentDuplicatePopup and Controller.CurrentDuplicatePopup.Parent then
        pcall(function()
            Controller.CurrentDuplicatePopup:Destroy()
        end)
    end

    if Controller.CurrentSortPopup and Controller.CurrentSortPopup.Parent then
        pcall(function()
            Controller.CurrentSortPopup:Destroy()
        end)
    end

    if Controller.CurrentFilterPopup and Controller.CurrentFilterPopup.Parent then
        pcall(function()
            Controller.CurrentFilterPopup:Destroy()
        end)
    end

    if Controller.CurrentConfirmPopup and Controller.CurrentConfirmPopup.Parent then
        pcall(function()
            Controller.CurrentConfirmPopup:Destroy()
        end)
    end

    
    
    restoreNativeTooltipStack()

    if Controller.TooltipExtra and Controller.TooltipExtra.Parent then
        pcall(function()
            Controller.TooltipExtra:Destroy()
        end)
    end

    Controller.CurrentGui = nil
    Controller.CurrentScroll = nil
    Controller.CurrentClassBar = nil
    Controller.CurrentToolbar = nil
    Controller.CurrentActionBar = nil
    Controller.CurrentActionProgress = nil
    Controller.CurrentMorePopup = nil
    Controller.CurrentDuplicatePopup = nil
    Controller.CurrentSortPopup = nil
    Controller.CurrentFilterPopup = nil
    Controller.CurrentConfirmPopup = nil
    Controller.ConfirmAction = nil
    Controller.TooltipExtra = nil
    Controller.TooltipNativeState = {}
    Controller.OriginalScrollPosition = nil
    Controller.OriginalScrollSize = nil
    Controller.OriginalScrollZIndex = nil
    Controller.OriginalGridSortOrder = nil
    Controller.OriginalGridCellSize = nil
    Controller.HoveredCard = nil
    Controller.HoveredEquippedInfo = nil

    table.clear(Controller.TargetLayoutOrder)
end

function QOL.attachInventory(gui)
    if not Controller.Alive or not gui or not gui.Parent then
        return
    end

    if Controller.CurrentGui == gui
        and Controller.CurrentClassBar
        and Controller.CurrentClassBar.Parent
    then
        return
    end

    QOL.cleanupAttachment()

    local mainBackground = gui:FindFirstChild("mainBackground")
    local innerBackground = mainBackground
        and mainBackground:FindFirstChild("innerBackground")
    local rightSide = innerBackground
        and innerBackground:FindFirstChild("rightSideFrame")
    local scroll = rightSide
        and rightSide:FindFirstChild("ScrollingFrame")

    if not rightSide or not scroll or not scroll:IsA("ScrollingFrame") then
        return
    end

    refreshInventoryData()
    seedKnownIDs()

    Controller.CurrentGui = gui
    Controller.CurrentScroll = scroll
    Controller.OriginalScrollPosition = scroll.Position
    Controller.OriginalScrollSize = scroll.Size
    Controller.OriginalScrollZIndex = scroll.ZIndex
    scroll.ZIndex = 10

    local grid = scroll:FindFirstChildOfClass("UIGridLayout")
    if grid then
        Controller.OriginalGridSortOrder = grid.SortOrder
        Controller.OriginalGridCellSize = grid.CellSize
        grid.SortOrder = Enum.SortOrder.LayoutOrder
    end

    
    scroll.AnchorPoint = Vector2.new(0.5, 0.5)
    scroll.Position = UDim2.new(0.5, 0, 0.655, 0)
    scroll.Size = UDim2.new(0.97, 0, 0.63, 0)

    Controller.CurrentClassBar = makeClassBar(rightSide)
    Controller.CurrentToolbar = makeToolbar(rightSide)
    Controller.CurrentActionBar = QOL.makeActionBar(rightSide)
    Controller.CurrentActionProgress = QOL.makeActionProgress(rightSide)
    Controller.CurrentSortPopup = buildSortPopup(rightSide)
    Controller.CurrentFilterPopup = buildFilterPopup(rightSide)
    Controller.CurrentConfirmPopup = buildConfirmPopup(rightSide)
    Controller.CurrentMorePopup = QOL.buildMorePopup(rightSide)
    refreshMorePopup()

    
    
    
    promoteNativeTooltipStack(gui)

    bindAllCards(scroll)
    applyAll()

    addConnection(Controller.AttachConnections, scroll.ChildAdded:Connect(function(child)
        if not Controller.Alive or Controller.CurrentScroll ~= scroll then
            return
        end

        
        if child:IsA("GuiObject") then
            scheduleInventoryRefresh(0.18)
        end
    end))

    addConnection(Controller.AttachConnections, gui.AncestryChanged:Connect(function(_, parent)
        if not parent and Controller.CurrentGui == gui then
            QOL.cleanupAttachment()
        end
    end))

    local tooltipAccumulator = 0

    addConnection(Controller.AttachConnections, RunService.RenderStepped:Connect(function(dt)
        if not Controller.HoveredCard and not Controller.HoveredEquippedInfo then
            tooltipAccumulator = 0
            return
        end

        tooltipAccumulator += dt

        if tooltipAccumulator >= 0.08 then
            tooltipAccumulator = 0
            updateHoveredTooltip()
        end
    end))

    local counts = {
        Mage = 0,
        Warrior = 0,
        Tank = 0,
    }

    for _, info in ipairs(Controller.InventoryInfos or {}) do
        if counts[info.Class] ~= nil then
            counts[info.Class] += 1
        end
    end

    print(string.format(
        "[DQ Inventory QOL v19.1] attached | Mage %d | Warrior %d | Tank %d | Authoritative items %d | Native cards %d",
        counts.Mage,
        counts.Warrior,
        counts.Tank,
        #(Controller.InventoryInfos or {}),
        #scroll:GetChildren()
    ))
end





function Controller:Stop()
    if not self.Alive then
        return
    end

    self.Alive = false

    saveDiskState()
    QOL.cleanupAttachment()
    cleanupSellShop()
    disconnectAll(self.GlobalConnections)

    if ENV[CONTROLLER_KEY] == self then
        ENV[CONTROLLER_KEY] = nil
    end

    print("[DQ Inventory QOL v19.1] stopped")
end





function QOL.tryAttachInventory()
    local gui = playerGui:FindFirstChild("inventory")
    if gui and gui:IsA("ScreenGui") then
        task.defer(QOL.attachInventory, gui)
    end
end

function QOL.tryAttachSellShop()
    local gui = playerGui:FindFirstChild("sellShop")
    if gui and gui:IsA("ScreenGui") then
        task.defer(attachSellShop, gui)
    end
end

addConnection(Controller.GlobalConnections, playerGui.ChildAdded:Connect(function(child)
    if child.Name == "inventory" and child:IsA("ScreenGui") then
        task.defer(function()
            task.wait()
            QOL.attachInventory(child)
        end)
    elseif child.Name == "sellShop" and child:IsA("ScreenGui") then
        task.defer(function()
            task.wait()
            attachSellShop(child)
        end)
    end
end))

QOL.remotes = ReplicatedStorage:FindFirstChild("remotes")

function QOL.listenForInventoryRefresh(remoteName)
    local remote = QOL.remotes and QOL.remotes:FindFirstChild(remoteName)

    if remote and remote:IsA("RemoteEvent") then
        addConnection(Controller.GlobalConnections, remote.OnClientEvent:Connect(function()
            scheduleInventoryRefresh(0.18)
        end))
    end
end

QOL.listenForInventoryRefresh("updateLocalInventoryTable")
QOL.listenForInventoryRefresh("reloadInventory")

QOL.tryAttachInventory()
QOL.tryAttachSellShop()

function QOL.tryRunPendingAutoUpgrade()
    if not Controller.Alive
        or Controller.PendingAutoUpgradeRunning
        or not Controller.PendingAutoUpgradeClass
        or not isUpgradeCapablePlace()
    then
        return
    end

    Controller.PendingAutoUpgradeRunning = true

    task.spawn(function()
        
        
        task.wait(1.25)

        if not Controller.Alive
            or not Controller.PendingAutoUpgradeClass
            or not isUpgradeCapablePlace()
        then
            Controller.PendingAutoUpgradeRunning = false
            return
        end

        local queuedClass = Controller.PendingAutoUpgradeClass
        Controller.ClassFilter = queuedClass

        if reindexCards then
            pcall(reindexCards)
        end

        
        
        local confirmationCreated = requestAutoUpgradeBest()

        task.wait(0.10)

        local callback = confirmationCreated and Controller.ConfirmAction or nil
        if type(callback) == "function" then
            Controller.ConfirmAction = nil

            if Controller.CurrentConfirmPopup then
                Controller.CurrentConfirmPopup.Visible = false
            end

            nativeAlert(
                "Running queued "
                .. queuedClass
                .. " Auto Upgrade Best..."
            )

            callback()
        else
            
            
            Controller.PendingAutoUpgradeRunning = false
        end
    end)
end

task.delay(1.5, QOL.tryRunPendingAutoUpgrade)

print("[DQ Inventory QOL v19.2] loaded")
print("[DQ Inventory QOL v19.2] dungeon Auto Upgrade now queues for Lobby")
print("[DQ Inventory QOL v19.2] place = " .. getDQPlaceName())
print("[DQ Inventory QOL v19.2] sequential potential + truthful progress + counted upgrade plans")
print("[DQ Inventory QOL v19.2] Auto Sell Junk: Not Best (Sell Obsolete) & Duplicates modes enabled")
print("[DQ Inventory QOL v19.2] multi-class best protection (Mage, Warrior, Tank, Loadouts, Locks)")
print("[DQ Inventory QOL v19.2] Skills category + level sorting enabled")
print("[DQ Inventory QOL v19.2] authoritative potential + stale-card safety enabled")
print("[DQ Inventory QOL v19.2] verified sale removals + marginal-budget Auto Upgrade enabled")
print("[DQ Inventory QOL v19.2] batched reward refresh + O(1) efficiency math enabled")
print("[DQ Inventory QOL v19.2] persistent UI state enabled")
print("[DQ Inventory QOL v19.2] left-click favorite | right-click lock")
print("[DQ Inventory QOL v19.2] native tooltip ZIndex promotion enabled")
print("[DQ Inventory QOL v19.2] More-panel overflow guard + native-style controls enabled")
