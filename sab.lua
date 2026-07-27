
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- ============================================================
-- ANTI-DUPLICATO: rimuove GUI precedente se esiste
-- ============================================================
if CoreGui:FindFirstChild("TradeSpoofV47") then
    CoreGui:FindFirstChild("TradeSpoofV47"):Destroy()
end

-- ============================================================
-- VARIABILI DI STATO
-- ============================================================
local isSpoofing = false
local currentSpoofTarget = "N/A"
local signMessage = "Sign"
local openKey = Enum.KeyCode.T    -- Apri/chiudi GUI
local spoofKey = Enum.KeyCode.V   -- Attiva/disattiva spoof

-- ============================================================
-- LISTA USERNAME PREDEFINITI (vittime / account salvati)
-- ============================================================
local savedUsernames = {
    "SpyderSammy",
    "SpyderSammy",       -- duplicato nell'originale
    "How_Nasty",
    "iiiiiiiiiiiiiohh34",
    "Luxyurixx",
    "Gioisgoodatfortnit2",
    "Scarlettroson",
    "Skypurpppppp",
    "diexask",
    "chipotlepapii",
    "seuvair",
    "yourlilprincessa",
    "Mcdonaldsforlife120",
    "THEMONKEYRATBOII",
    "Makayla_otheracc4",
    "TheTerminator11100",
    "THESLEEPYFISHY",
    "GodRaider32",
    "Daboiz20259",
    "Chunks2514",
}

-- ============================================================
-- LISTA MESSAGGI CHAT PREIMPOSTATI (per ingannare le vittime)
-- ============================================================
local chatMessages = {
    -- Messaggi "legit" in italiano (per sembrare affidabile)
    "GRAZIE LEGIT",
    "Oddio sei legit graziee",
    "O MIO DIO GRAZIE MILLEEEE",
    "graziee!!",
    "raga fidatevi",
    "grazie per index",
    "grazie per non avermi scammato",
    "legit grazie",
    "grazie per il regalo tieni e l'index!!",
    "ODDIO TI AMO",
    "RAGA GLIELO RIDO SI O NO?",
    -- Domande per attirare vittime
    "Posso index?",
    "Posso spinnare questo?",
    "Cosa vinco?",
    -- Messaggi di scam diretti (rivelatori)
    "AHAHAHAH TI HO SCAMMATO",
    "BITCHASS NIGGA I SCAMMED YOU",
    -- Messaggi "legit" in inglese
    "legittttt",
    "vouch",
    "thx",
    "meowl",
    "skibidi",
    "immigrato",
    -- Insulti e spam
    "negraccio di merda adda",
    "FIGLIO DI PUTTANA ADDA O MUORI",
    "ESPLODI BOMBOLONE DEL CAZZO",
    "esci di casa fottutissima bomba ucraina sembri un palloncino da quanto cazzo sei obeso",
    -- Altro
    "Vuoi venire nel letto con me stanotte??\xF0\x9F\xA5\xB5\xF0\x9F\xA5\xB5",
}

-- ============================================================
-- COSTRUZIONE DELLA GUI
-- ============================================================
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "TradeSpoofV47"
ScreenGui.Parent = CoreGui   -- Nascosta nel CoreGui (non visibile all'utente)

-- Frame principale
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 280, 0, 320)
MainFrame.Position = UDim2.new(0.5, -140, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.Parent = MainFrame

local MainStroke = Instance.new("UIStroke")
MainStroke.Color = Color3.fromRGB(80, 80, 90)
MainStroke.Thickness = 1.5
MainStroke.Parent = MainFrame

-- Bottone toggle (invisibile, usato per aprire/chiudere con click)
local ToggleButton = Instance.new("TextButton")
ToggleButton.Size = UDim2.new(0, 20, 0, 20)
ToggleButton.Position = UDim2.new(0, 5, 0, 5)
ToggleButton.BackgroundTransparency = 1
ToggleButton.Text = ""
ToggleButton.ZIndex = 999
ToggleButton.Parent = ScreenGui

-- ============================================================
-- SEZIONE 1: STATUS E SPOOF INFO
-- ============================================================

-- Label "CURRENTLY SPOOFING"
local SpoofLabel = Instance.new("TextLabel")
SpoofLabel.Size = UDim2.new(1, -10, 0, 40)
SpoofLabel.Position = UDim2.new(0, 5, 0, 10)
SpoofLabel.BackgroundTransparency = 1
SpoofLabel.Text = "CURRENTLY SPOOFING:\nN/A"
SpoofLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SpoofLabel.Font = Enum.Font.GothamBold
SpoofLabel.TextSize = 10
SpoofLabel.TextXAlignment = Enum.TextXAlignment.Left
SpoofLabel.Parent = MainFrame

-- Immagine item spoofato (placeholder)
local ItemImage = Instance.new("ImageLabel")
ItemImage.Size = UDim2.new(0, 50, 0, 50)
ItemImage.Position = UDim2.new(0, 5, 0, 55)
ItemImage.BackgroundColor3 = Color3.fromRGB(50, 50, 55)
ItemImage.Image = "rbxassetid://0"  -- placeholder, viene sostituito runtime
ItemImage.Parent = MainFrame
local ItemImageCorner = Instance.new("UICorner")
ItemImageCorner.CornerRadius = UDim.new(0, 6)
ItemImageCorner.Parent = ItemImage

-- Bottone "COPY CURRENT INFO"
local CopyButton = Instance.new("TextButton")
CopyButton.Size = UDim2.new(0, 120, 0, 20)
CopyButton.Position = UDim2.new(0, 5, 0, 110)
CopyButton.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
CopyButton.Text = "COPY CURRENT INFO"
CopyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CopyButton.Font = Enum.Font.GothamBold
CopyButton.TextSize = 10
CopyButton.Parent = MainFrame
Instance.new("UICorner").Parent = CopyButton

CopyButton.MouseButton1Click:Connect(function()
    -- Copia le info dello spoof corrente negli appunti
    setclipboard(currentSpoofTarget)
end)

-- Label STATUS
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(0, 80, 0, 20)
StatusLabel.Position = UDim2.new(1, -85, 0, 110)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "STATUS: OFF"
StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
StatusLabel.Font = Enum.Font.GothamBold
StatusLabel.TextSize = 10
StatusLabel.Parent = MainFrame

-- Label tasto V
local VLabel = Instance.new("TextLabel")
VLabel.Size = UDim2.new(0, 20, 0, 20)
VLabel.Position = UDim2.new(0, 5, 0, 135)
VLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
VLabel.Text = "V"
VLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
VLabel.Font = Enum.Font.GothamBold
VLabel.TextSize = 10
VLabel.Parent = MainFrame

-- Label tasto T
local TLabel = Instance.new("TextLabel")
TLabel.Size = UDim2.new(0, 20, 0, 20)
TLabel.Position = UDim2.new(0, 30, 0, 135)
TLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
TLabel.Text = "T"
TLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TLabel.Font = Enum.Font.GothamBold
TLabel.TextSize = 10
TLabel.Parent = MainFrame

-- Label sign name
local SignLabel = Instance.new("TextLabel")
SignLabel.Size = UDim2.new(1, -10, 0, 20)
SignLabel.Position = UDim2.new(0, 5, 0, 160)
SignLabel.BackgroundTransparency = 1
SignLabel.Text = "Sign"
SignLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SignLabel.Font = Enum.Font.GothamBold
SignLabel.TextSize = 10
SignLabel.Parent = MainFrame

-- TextBox input per amount 1 (default 15)
local AmountBox1 = Instance.new("TextBox")
AmountBox1.Size = UDim2.new(0, 60, 0, 20)
AmountBox1.Position = UDim2.new(0, 5, 0, 185)
AmountBox1.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
AmountBox1.Text = "15"
AmountBox1.TextColor3 = Color3.fromRGB(255, 255, 255)
AmountBox1.Parent = MainFrame
Instance.new("UICorner").Parent = AmountBox1

-- TextBox input per amount 2 (default 20)
local AmountBox2 = Instance.new("TextBox")
AmountBox2.Size = UDim2.new(0, 60, 0, 20)
AmountBox2.Position = UDim2.new(0, 75, 0, 185)
AmountBox2.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
AmountBox2.Text = "20"
AmountBox2.TextColor3 = Color3.fromRGB(255, 255, 255)
AmountBox2.Parent = MainFrame
Instance.new("UICorner").Parent = AmountBox2

-- Bottone UPDATE SIGN MESSAGE
local UpdateSignButton = Instance.new("TextButton")
UpdateSignButton.Size = UDim2.new(0, 140, 0, 20)
UpdateSignButton.Position = UDim2.new(0, 5, 0, 210)
UpdateSignButton.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
UpdateSignButton.Text = "UPDATE SIGN MESSAGE"
UpdateSignButton.TextColor3 = Color3.fromRGB(255, 255, 255)
UpdateSignButton.Font = Enum.Font.GothamBold
UpdateSignButton.TextSize = 10
UpdateSignButton.Parent = MainFrame
Instance.new("UICorner").Parent = UpdateSignButton

UpdateSignButton.MouseButton1Click:Connect(function()
    signMessage = SignLabel.Text
end)

-- ============================================================
-- SEZIONE 2: LISTA USERNAME (ScrollingFrame)
-- ============================================================
local UsernameScroll = Instance.new("ScrollingFrame")
UsernameScroll.Size = UDim2.new(0, 130, 0, 200)
UsernameScroll.Position = UDim2.new(1, -135, 0, 5)
UsernameScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
UsernameScroll.ScrollBarThickness = 4
UsernameScroll.Parent = MainFrame

local UsernameLayout = Instance.new("UIListLayout")
UsernameLayout.SortOrder = Enum.SortOrder.LayoutOrder
UsernameLayout.Padding = UDim.new(0, 2)
UsernameLayout.Parent = UsernameScroll

for i, username in ipairs(savedUsernames) do
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -4, 0, 20)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Btn.Text = username
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Btn.LayoutOrder = i
    Btn.Parent = UsernameScroll
    Instance.new("UICorner").Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        -- Seleziona l'utente da spoofare
        currentSpoofTarget = username
        SpoofLabel.Text = "CURRENTLY SPOOFING:\n" .. username
    end)
end

-- ============================================================
-- SEZIONE 3: MESSAGGI CHAT PREIMPOSTATI (ScrollingFrame)
-- ============================================================
local ChatScroll = Instance.new("ScrollingFrame")
ChatScroll.Size = UDim2.new(1, -10, 0, 80)
ChatScroll.Position = UDim2.new(0, 5, 0, 235)
ChatScroll.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
ChatScroll.ScrollBarThickness = 4
ChatScroll.Parent = MainFrame

local ChatLayout = Instance.new("UIListLayout")
ChatLayout.SortOrder = Enum.SortOrder.LayoutOrder
ChatLayout.Padding = UDim.new(0, 2)
ChatLayout.Parent = ChatScroll

for i, msg in ipairs(chatMessages) do
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -4, 0, 20)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Btn.Text = msg
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 10
    Btn.LayoutOrder = i
    Btn.Parent = ChatScroll
    Instance.new("UICorner").Parent = Btn

    Btn.MouseButton1Click:Connect(function()
        -- Invia il messaggio in chat
        local success, err = pcall(function()
            game:GetService("Players").LocalPlayer:Chat(msg)
        end)
    end)
end

-- ============================================================
-- SEZIONE 4: SPIN THE WHEEL (Ruota della Fortuna Falsa)
-- ============================================================
local WheelFrame = Instance.new("Frame")
WheelFrame.Name = "yoou"
WheelFrame.AnchorPoint = Vector2.new(0.5, 0.5)
WheelFrame.Size = UDim2.new(0, 350, 0, 200)
WheelFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
WheelFrame.BackgroundTransparency = 1
WheelFrame.Visible = false   -- nascosto di default
WheelFrame.Parent = ScreenGui

local UIAspect = Instance.new("UIAspectRatioConstraint")
UIAspect.AspectRatio = 1.75
UIAspect.Parent = WheelFrame

-- Sfondo ruota (bg esterno)
local BgOuter = Instance.new("Frame")
BgOuter.Name = "bg"
BgOuter.ZIndex = 0
BgOuter.BorderSizePixel = 0
BgOuter.AnchorPoint = Vector2.new(0.5, 0.5)
BgOuter.Size = UDim2.new(1, 0, 1, 0)
BgOuter.Position = UDim2.new(0.5, 0, 0.5, 0)
BgOuter.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
BgOuter.BackgroundTransparency = 0.33
BgOuter.Parent = WheelFrame

-- Sfondo ruota (bg interno con clip)
local BgInner = Instance.new("Frame")
BgInner.Name = "bg"
BgInner.ZIndex = 0
BgInner.BorderSizePixel = 0
BgInner.AnchorPoint = Vector2.new(0.5, 0.5)
BgInner.Size = UDim2.new(0.85, 0, 0.85, 0)
BgInner.Position = UDim2.new(0.5, 0, 0.5, 0)
BgInner.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
BgInner.BackgroundTransparency = 0.33
BgInner.ClipsDescendants = true
BgInner.Parent = WheelFrame

-- Header della ruota
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.BorderSizePixel = 0
Header.AnchorPoint = Vector2.new(0.5, 0)
Header.Size = UDim2.new(1, 0, 0, 30)
Header.Position = UDim2.new(0.5, 0, 0, 0)
Header.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
Header.Parent = WheelFrame

-- Pulsante chiudi ruota
local CloseButton = Instance.new("ImageButton")
CloseButton.Name = "Close"
CloseButton.BorderSizePixel = 0
CloseButton.ScaleType = Enum.ScaleType.Fit
CloseButton.BackgroundTransparency = 1
CloseButton.AnchorPoint = Vector2.new(1, 0.5)
CloseButton.Image = "rbxassetid://105016554772347"
CloseButton.HoverImage = "rbxassetid://137110183435251"
CloseButton.Size = UDim2.new(0, 20, 0, 20)
CloseButton.Position = UDim2.new(1, -5, 0.5, 0)
CloseButton.Parent = Header

CloseButton.MouseButton1Click:Connect(function()
    WheelFrame.Visible = false
end)

-- TextLabel titolo ruota (vuoto nell'originale)
local WheelTitleLabel = Instance.new("TextLabel")
WheelTitleLabel.TextWrapped = true
WheelTitleLabel.BorderSizePixel = 0
WheelTitleLabel.TextSize = 14
WheelTitleLabel.TextScaled = true
WheelTitleLabel.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
WheelTitleLabel.BackgroundTransparency = 1
WheelTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
WheelTitleLabel.Font = Enum.Font.GothamBold
WheelTitleLabel.Parent = CloseButton

-- Bottone SPIN THE WHEEL nel pannello principale
local SpinButton = Instance.new("TextButton")
SpinButton.Size = UDim2.new(0, 120, 0, 20)
SpinButton.Position = UDim2.new(0, 5, 1, -30)
SpinButton.BackgroundColor3 = Color3.fromRGB(50, 90, 150)
SpinButton.Text = "SPIN THE WHEEL"
SpinButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SpinButton.Font = Enum.Font.GothamBold
SpinButton.TextSize = 10
SpinButton.Parent = MainFrame
Instance.new("UICorner").Parent = SpinButton

SpinButton.MouseButton1Click:Connect(function()
    WheelFrame.Visible = not WheelFrame.Visible
end)

-- ============================================================
-- FIRMA AUTORE
-- ============================================================
local MadeByLabel = Instance.new("TextLabel")
MadeByLabel.Size = UDim2.new(1, -10, 0, 15)
MadeByLabel.Position = UDim2.new(0, 5, 1, -20)
MadeByLabel.BackgroundTransparency = 1
MadeByLabel.Text = "Made by Ken"
MadeByLabel.TextColor3 = Color3.fromRGB(100, 100, 120)
MadeByLabel.Font = Enum.Font.GothamBold
MadeByLabel.TextSize = 12
MadeByLabel.Parent = MainFrame

-- ============================================================
-- INPUT HANDLING
-- ============================================================
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end

    -- Tasto T: apri/chiudi GUI principale
    if input.KeyCode == Enum.KeyCode.T then
        MainFrame.Visible = not MainFrame.Visible
    end

    -- Tasto V: attiva/disattiva spoofing
    if input.KeyCode == Enum.KeyCode.V then
        isSpoofing = not isSpoofing
        if isSpoofing then
            StatusLabel.Text = "STATUS: ON"
            StatusLabel.TextColor3 = Color3.fromRGB(80, 255, 80)
        else
            StatusLabel.Text = "STATUS: OFF"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
        end
    end
end)

-- ============================================================
-- LOOP PRINCIPALE (RunService)
-- ============================================================
RunService.Heartbeat:Connect(function()
    -- Qui nel codice originale offuscato viene eseguita
    -- la logica di spoof degli item durante il trade
    -- Non ricostruibile completamente senza eseguire
    -- il bytecode su un executor Roblox reale
    if isSpoofing and currentSpoofTarget ~= "N/A" then
        -- logica di spoof (omessa - richiederebbe API Roblox reali)
    end
end)

-- ============================================================
-- Fine script deoffuscato - TradeSpoofV47
-- ============================================================
