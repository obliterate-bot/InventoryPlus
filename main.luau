 























































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
            KeepCopies = 1,
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
Persistent.Settings.KeepCopies = math.clamp(nonNegativeInteger and nonNegativeInteger(Persistent.Settings.KeepCopies, 1) or math.floor(tonumber(Persistent.Settings.KeepCopies) or 1), 1, 20)
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
    Persistent.Settings.KeepCopies = math.clamp(math.floor(tonumber(Persistent.Settings.KeepCopies) or 1), 1, 20)
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
        info.RollGrade = nil
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
    if Persistent.Settings.ProtectSRolls and info.RollGrade == "S" then reasons[#reasons + 1] = "S Roll" end
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
        info.RollGrade = nil
        info.RollRank = nil
        info.RollRankCount = nil
        info.BestDuplicate = false
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
            if total <= 1 then
                info.RollPercentile = 100
            else
                info.RollPercentile = math.floor(((total - index) / (total - 1)) * 100 + 0.5)
            end
        end
    end

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

    for _, info in ipairs(allInfos) do
        info.ProtectionReasons = protectionReasons(info)
        info.IsProtected = #info.ProtectionReasons > 0
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

    for _, info in ipairs(allInfos) do
        local slot = slotForType(info.ItemType)
        if (slot == "weapon" or slot == "chest" or slot == "helmet")
            and info.IsEquipable
        then
            local key = tostring(info.Class) .. ":" .. slot
            for _, mode in ipairs({"Now", "Potential", "Budget"}) do
                local currentBest = bestByMode[mode][key]
                if betterForMode(info, currentBest, mode) then
                    bestByMode[mode][key] = info
                end
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
    if Controller.BestMode ~= "Off" then
        for _, info in pairs(bestByMode[Controller.BestMode] or {}) do
            info.IsBestLoadout = true
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
                if info.IsWishlist and Persistent.Settings.WishlistNotifications then
                    qolNotify("Wishlist Drop", tostring(info.Name) .. " • " .. tostring(info.RollGrade or info.Rarity or "drop"))
                elseif info.RollGrade == "S" and Persistent.Settings.SRollNotifications then
                    qolNotify("S-Roll Drop", tostring(info.Name))
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
        if info.IsJunk then
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
        elseif info.RollGrade then
            status.Text = info.RollGrade
            status.TextColor3 = Color3.fromRGB(255, 232, 85)
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
        details[#details + 1] =
            "Roll "
            .. info.RollGrade
            .. " ("
            .. tostring(info.RollRank or info.DuplicateIndex)
            .. "/"
            .. tostring(info.RollRankCount or info.DuplicateCount)
            .. ")"
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
        details[#details + 1] = "★ Favorite"
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
    hint.Text = "★ click = favorite   •   ★ right-click = lock"
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
    local body =
        "Sell duplicate junk until only the best eligible copies remain?\n"
        .. tostring(plan.Count)
        .. " item" .. (plan.Count == 1 and "" or "s")
        .. " are marked in the first pass; estimated value "
        .. formatInt(plan.TotalValue) .. ".\n"
        .. "Keep policy: top " .. tostring(math.max(1, nonNegativeInteger(Persistent.Settings.KeepCopies, 1))) .. " copies plus protected items.\n"
        .. "Equipped, favorites, locks, loadouts, wishlist, S-roll and Legendary+ protection rules are respected.\n"
        .. (highValueCount > 0 and ("WARNING: " .. tostring(highValueCount) .. " marked item(s) meet the high-value warning threshold.\n") or "")
        .. (maxValue > 0
            and ("Auto-sell value ceiling: " .. formatInt(maxValue) .. ". Items above it are skipped.\n")
            or "Auto-sell value ceiling: OFF.\n")
        .. "Stop prevents later passes; it cannot undo a sell request already sent."

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
    return "CLEANUP PREVIEW • " .. tostring(plan.Count or 0) .. " removable"
        .. " • est. " .. formatCompact(plan.TotalValue or 0) .. " gold"
        .. " • default keep " .. tostring(math.max(1, nonNegativeInteger(Persistent.Settings.KeepCopies, 1)))
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
    "KeepCopies", "ProtectSRolls", "ProtectLegendary", "WishlistAutoLock", "InventoryWarningPct", "MinImprovementPct",
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
    numeric(protect, 2, "KeepCopies", "Keep best copies per duplicate", "KeepCopies", 1, 20)
    toggle(protect, 3, "ProtectSRolls", "Auto-protect S rolls")
    toggle(protect, 4, "ProtectLegendary", "Auto-protect Legendary+")
    toggle(protect, 5, "WishlistAutoLock", "Wishlist auto-lock")
    numeric(protect, 6, "SellMax", "Auto-sell value ceiling (0 = off)", "AutoSellMaxValue", 0, 9e15)
    numeric(protect, 7, "HighValue", "High-value sell warning (0 = off)", "HighValueWarning", 0, 9e15)
    toggle(protect, 8, "AutoCleanupPrompt", "Capacity cleanup prompt")
    local keepRuleRow = row(protect, "KeepRuleRow", 9)
    local _, keepRuleName = makeNativeInput(keepRuleRow, {Name = "KeepRuleName", Size = UDim2.new(0.53, 0, 1, 0), Text = "", Placeholder = "Per-item keep rule name", ZIndex = 96})
    local _, keepRuleCount = makeNativeInput(keepRuleRow, {Name = "KeepRuleCount", Size = UDim2.new(0.18, 0, 1, 0), Text = "2", Placeholder = "2", ZIndex = 96, TextXAlignment = Enum.TextXAlignment.Center})
    keepRuleCount.Parent.Position = UDim2.fromScale(0.55, 0)
    local setKeepButton = makeNativeButton(keepRuleRow, {Name = "SetKeepRule", Size = UDim2.new(0.12, 0, 1, 0), Text = "Set", InnerColor = Color3.fromRGB(72, 118, 83), ZIndex = 96, MinTextSize = 8, MaxTextSize = 12})
    setKeepButton.Position = UDim2.fromScale(0.75, 0)
    local clearKeepButton = makeNativeButton(keepRuleRow, {Name = "ClearKeepRule", Size = UDim2.new(0.11, 0, 1, 0), Text = "Clear", InnerColor = Color3.fromRGB(130, 66, 66), ZIndex = 96, MinTextSize = 8, MaxTextSize = 12})
    clearKeepButton.AnchorPoint = Vector2.new(1, 0) clearKeepButton.Position = UDim2.fromScale(1, 0)
    addConnection(Controller.AttachConnections, setKeepButton.MouseButton1Click:Connect(function() local name = keepRuleName.Text local info = QOL.selectedMetaInfo() if name == "" and info then name = info.Name end QOL.setKeepRule(name, keepRuleCount.Text) refreshMorePopup() end))
    addConnection(Controller.AttachConnections, clearKeepButton.MouseButton1Click:Connect(function() local name = keepRuleName.Text local info = QOL.selectedMetaInfo() if name == "" and info then name = info.Name end QOL.clearKeepRule(name) refreshMorePopup() end))
    QOL.makePanelLabel(protect, "KeepRuleList", "", 60, 10)
    QOL.makePanelLabel(protect, "ProtectionHelp", "Smart Junk keeps the configured top copies, then also preserves every equipped, favorite, locked, loadout, wishlist, protected S-roll, and protected Legendary+ item. Protected extras can make a group retain more than the keep count.", 72, 11)

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
                DropNotifications = "Drop notifications", WishlistNotifications = "Wishlist notifications", SRollNotifications = "S-roll notifications", LegendaryNotifications = "Legendary+ notifications",
                AdvancedSearch = "Advanced search syntax", RequireBetterNow = "Auto Equip must also be better now", UpgradeWeapon = "Upgrade weapon", UpgradeChest = "Upgrade chest", UpgradeHelmet = "Upgrade helmet",
                ProtectSRolls = "Auto-protect S rolls", ProtectLegendary = "Auto-protect Legendary+", WishlistAutoLock = "Wishlist auto-lock", AutoCleanupPrompt = "Capacity cleanup prompt",
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

print("[DQ Inventory QOL v19.1] loaded")
print("[DQ Inventory QOL v19.1] dungeon Auto Upgrade now queues for Lobby")
print("[DQ Inventory QOL v19.1] place = " .. getDQPlaceName())
print("[DQ Inventory QOL v19.1] sequential potential + truthful progress + counted upgrade plans")
print("[DQ Inventory QOL v19.1] Auto Sell Junk now clears every duplicate layer")
print("[DQ Inventory QOL v19.1] Smart Junk now marks only one worst duplicate")
print("[DQ Inventory QOL v19.1] Skills category + level sorting enabled")
print("[DQ Inventory QOL v19.1] authoritative potential + stale-card safety enabled")
print("[DQ Inventory QOL v19.1] verified sale removals + marginal-budget Auto Upgrade enabled")
print("[DQ Inventory QOL v19.1] batched reward refresh + O(1) efficiency math enabled")
print("[DQ Inventory QOL v19.1] persistent UI state enabled")
print("[DQ Inventory QOL v19.1] ★ left-click favorite | ★ right-click lock")
print("[DQ Inventory QOL v19.1] native tooltip ZIndex promotion enabled")
print("[DQ Inventory QOL v19.1] More-panel overflow guard + native-style controls enabled")
