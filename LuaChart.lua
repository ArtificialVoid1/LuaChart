local ChartParser = {}
---------------------------- Enum --------------------------------------------

ChartParser.SyncTrackEventType = {
    TimeSignature = 'TimeSignature',
    BPM = 'BPM',
    Anchor = 'Anchor',
}
ChartParser.GlobalEventType = {
    Section = 'Section',
    Other = 'Other',
}
ChartParser.DifficultyType = {
    Easy = 'Easy',
    Medium = 'Medium',
    Hard = 'Hard',
    Expert = 'Expert',
}
ChartParser.InstrumentType = {
    Guitar = 'Single',
    CoOp_Guitar = 'DoubleGuitar',
    Bass = 'DoubleBass',
    Rhythm = 'DoubleRhythm',
    Keyboard = 'Keyboard',
    Drums = 'Drums'
}
ChartParser.GHLInstrumentType = {
    Guitar = 'GHLGuitar',
    Bass = 'GHLBass',
    Rhythm = 'GHLRhythm',
    Guitar_CoOp = 'GHLCoop',
}
ChartParser.LocalEventType = {
    StarPowerPhrase = 'starpowerphrase',
    Other = 'Other',
}

---------------------------- Classes --------------------------------------------
LocalEvent = {}
LocalEvent.__index = LocalEvent

function LocalEvent:__tostring()
    local main = '\n '.. tostring(self.TickTime) .. ' = '
    if self.EventType == ChartParser.LocalEventType.StarPowerPhrase then
        return main .. 'S ' .. '2 ' .. tostring(self.TickLength)
    elseif self.EventType == ChartParser.LocalEventType.Other then
        return main .. 'E ' .. tostring(self.Name)
    end
end

function LocalEvent:new(TickTime, EventType, MetaData)
    if EventType == ChartParser.LocalEventType.StarPowerPhrase then
        local obj = {
            Type = "LocalEvent",
            TickTime = TickTime or 0,
            EventType = EventType,
            TickLength = MetaData or 0,
            DrumActivationPhrase = false,
        }
        setmetatable(obj, self)
        return obj
    elseif EventType == ChartParser.LocalEventType.Other then
        local obj = {
            Type = "LocalEvent",
            TickTime = TickTime or 0,
            EventType = EventType,
            Name = MetaData or "",
        }
        setmetatable(obj, self)
        return obj
    else
        error("Invalid LocalEventType")
    end
end
ChartParser.LocalEvent = LocalEvent
--------------------------------------------------------------------------
Note = {}
Note.__index = Note

function Note:__tostring()
    local txt = ''
    if self.Instrument.IsDrums == true then
        local lane = 0
        for i=1, #self.Lanes do
            if self.Lanes[i] == 1 then
                lane = i - 1
                break
            end
        end

        if lane >= 0 and lane <= 5 then
            txt = '\n '.. tostring(self.TickTime) .. ' = N ' .. tostring(lane) .. ' ' .. tostring(self.TickLength)
        elseif lane == 6 then
            txt = '\n '.. tostring(self.TickTime) .. ' = N 32 ' .. tostring(self.TickLength)
        end

        if self.Modifiers[1] == 1 and lane ~= 0 then
            AccentNum = lane + 33
            txt = txt .. '\n '.. tostring(self.TickTime) .. ' = N ' .. AccentNum .. ' 0'
        end
        if self.Modifiers[2] == 1 and lane ~= 0 then
            GhostNum = lane + 39
            txt = txt .. '\n '.. tostring(self.TickTime) .. ' = N ' .. GhostNum .. ' 0'
        end
        if self.Modifiers[3] == 1 and lane ~= 0 then
            CymbalNum = lane + 64
            txt = txt .. '\n '.. tostring(self.TickTime) .. ' = N ' .. CymbalNum .. ' 0'
        end
        return txt
    else
        for i=1, #self.Lanes do
            if self.Lanes[i] == 1 then
                txt = txt .. '\n '.. tostring(self.TickTime) .. ' = N ' .. tostring(i - 1) .. ' ' .. tostring(self.TickLength)
            end
        end
        if self.Modifiers[2] == 1 then
            txt = txt .. '\n '.. tostring(self.TickTime) .. ' = N 6 0'
        elseif self.Modifiers[1] == 1 then
            txt = txt .. '\n '.. tostring(self.TickTime) .. ' = N 5 0'
        end
        return txt
    end
end

function Note:IsChord()
    local e = 0
    for _, lane in ipairs(self.Lanes) do
        if lane == 1 then
            e = e + 1
        end
    end
    return e > 1
end

function Note:HasOpen()
    return self.Lanes[7] == 1
end

function Note:HasKick()
    return self.Lanes[1] == 1 or self.Lanes[7] == 1
end

function Note:IsTap()
    return self.Modifiers[2] == 1 and self.Instrument.IsDrums == false
end
function Note:IsForced()
    return self.Modifiers[1] == 1 and self.Instrument.IsDrums == false
end

function Note:IsGhost()
    return self.Modifiers[2] == 1 and self.Instrument.IsDrums == true
end
function Note:IsAccent()
    return self.Modifiers[1] == 1 and self.Instrument.IsDrums == true
end
function Note:IsCymbal()
    return self.Modifiers[3] == 1 and self.Instrument.IsDrums == true
end

function Note:new(TickTime, Lanes, Modifiers, TickLength, parent)
    local obj = {
        Type = "Note",
        TickTime = TickTime or 0,
        Lanes = Lanes or {},
        Modifiers = Modifiers or {},
        TickLength = TickLength or 0,
        Instrument = parent or nil,
    }
    setmetatable(obj, self)
    return obj
end
ChartParser.Note = Note
------------------------------------------------------------------------
InstrumentTrack = {}
InstrumentTrack.__index = InstrumentTrack

function InstrumentTrack:__tostring()
    local sng = '[' .. self.DifficultyType .. self.InstrumentType .. ']\n{'
    for _, event in ipairs(self.Data) do
        sng = sng .. tostring(event)
    end
    sng = sng .. '\n}'
    return sng
end

function InstrumentTrack:new(InstrumentType, DifficultyType, DrumTrack, IsGHL)
    local obj = {
        Type = "InstrumentTrack",
        InstrumentType = InstrumentType or "",
        DifficultyType = DifficultyType or "",
        Data = {},
        IsDrums = DrumTrack or false,
        IsGHL = IsGHL or false,
    }
    setmetatable(obj, self)
    return obj
end
ChartParser.InstrumentTrack = InstrumentTrack

------------------------------------------------------------------------
GlobalEvent = {}
GlobalEvent.__index = GlobalEvent

function GlobalEvent:__tostring()
    local main = ' '.. tostring(self.TickTime) .. ' = E '
    if self.EventType == ChartParser.GlobalEventType.Section then
        return main .. '"section ' .. tostring(self.Name) .. '"'
    elseif self.EventType == ChartParser.GlobalEventType.END then
        return main .. "end"
    else
        return main .. '"' .. tostring(self.Value) .. '"'
    end
end

function GlobalEvent:new(TickTime, EventType, MetaData)
    if EventType == ChartParser.GlobalEventType.Section then
        local obj = {
            Type = "GlobalEvent",
            TickTime = TickTime or 0,
            EventType = EventType,
            Name = MetaData or "",
        }
        setmetatable(obj, self)
        return obj
    else
        local obj = {
            Type = "GlobalEvent",
            TickTime = TickTime or 0,
            EventType = ChartParser.GlobalEventType.Other,
            Value = MetaData or "",
        }
        setmetatable(obj, self)
        return obj
    end
end
ChartParser.GlobalEvent = GlobalEvent

------------------------------------------------------------------------
SyncTrackEvent = {}
SyncTrackEvent.__index = SyncTrackEvent

function SyncTrackEvent:__tostring()
    local main = ' '.. tostring(self.TickTime) .. ' = '
    if self.EventType == ChartParser.SyncTrackEventType.TimeSignature then
        local E = self.Exponent
        if self.Exponent == 2 then
            E = ''
        end
        return main .. 'TS ' .. tostring(self.Value[1]) .. ' ' .. tostring(E)
    elseif self.EventType == ChartParser.SyncTrackEventType.BPM then
        return main .. 'B ' .. tostring(math.floor(self.Tempo * 1000))
    elseif self.EventType == ChartParser.SyncTrackEventType.Anchor then
        return main .. 'A ' .. tostring(math.floor(self.AudioTime * 1000))
    end
end
function SyncTrackEvent:new(TickTime, EventType, MetaData1, MetaData2)
    if EventType == ChartParser.SyncTrackEventType.TimeSignature then
        local obj = {
            Type = "SyncTrackEvent",
            TickTime = TickTime or 0,
            EventType = EventType,
            Value = {MetaData1, 2^MetaData2} or {4, 4},
            Exponent = MetaData2 or 2,
        }
        setmetatable(obj, self)
        return obj
    elseif EventType == ChartParser.SyncTrackEventType.BPM then
        local obj = {
            Type = "SyncTrackEvent",
            TickTime = TickTime or 0,
            EventType = EventType,
            Tempo = MetaData1 or 120.000,
        }
        setmetatable(obj, self)
        return obj
    elseif EventType == ChartParser.SyncTrackEventType.Anchor then
        local obj = {
            Type = "SyncTrackEvent",
            TickTime = TickTime or 0,
            EventType = EventType,
            AudioTime = MetaData1 or 0,
        }
        setmetatable(obj, self)
        return obj
    else
        error("Invalid SyncTrackEventType")
    end
end
ChartParser.SyncTrackEvent = SyncTrackEvent


------------------------------------------------------------------------
Chart = {}
Chart.__index = Chart

function Chart:__tostring()
    local songData = {
        '[Song]',
        '{',
        ' Name = "' .. self.Name .. '"',
        ' Artist = "' .. self.Artist .. '"',
        ' Charter = "' .. self.Charter .. '"',
        ' Album = "' .. self.Album .. '"',
        ' Year = "' .. self.Year .. '"',
        ' Offset = ' .. tostring(self.Offset),
        ' Resolution = ' .. tostring(self.Resolution),
        ' Player2 = "' .. self.Player2 .. '"',
        ' Difficulty = ' .. tostring(self.Difficulty),
        ' PreviewStart = ' .. tostring(self.PreviewStart),
        ' PreviewEnd = ' .. tostring(self.PreviewEnd),
        ' Genre = "' .. self.Genre .. '"',
        ' MediaType = "' .. self.MediaType .. '"',
        ' MusicStream = "' .. self.MusicStream .. '"',
        '}',
    }
    local songStr = table.concat(songData, '\n')

    songStr = songStr .. '\n[SyncTrack]\n{'
    for _, event in ipairs(self.SyncTrack) do
        songStr = songStr .. '\n' .. tostring(event)
    end
    songStr = songStr .. '\n}'


    songStr = songStr .. '\n[Events]\n{'
    for _, event in ipairs(self.Events) do
        songStr = songStr .. '\n' .. tostring(event)
    end
    songStr = songStr .. '\n}'


    for _, instrument in ipairs(self.Instruments) do
        songStr = songStr .. '\n' .. tostring(instrument)
    end
    return songStr
end

function Chart:new(Instruments, SyncTrack, Events, Name, Artist, Charter, Album, Year, Offset, Resolution, Player2, Difficulty, PreviewStart, PreviewEnd, Genre, MediaType, MusicStream)
    local obj = {
        Type = "Chart",
        Instruments = Instruments or {},
        SyncTrack = SyncTrack or {},
        Events = Events or {},
        Name = Name or "",
        Artist = Artist or "",
        Charter = Charter or "",
        Album = Album or "",
        Year = Year or "",
        Offset = Offset or 0,
        Resolution = Resolution or 192,
        Player2 = Player2 or "bass",
        Difficulty = Difficulty or 0,
        PreviewStart = PreviewStart or 0,
        PreviewEnd = PreviewEnd or 0,
        Genre = Genre or "",
        MediaType = MediaType or "cd",
        MusicStream = MusicStream or "song.ogg"
    }
    setmetatable(obj, self)
    return obj
end
ChartParser.Chart = Chart


------------------------------------------------------------------------

local function split(inputstr, sep)
    if sep == nil then
      sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
      table.insert(t, str)
    end
    return t
end

------------------------------------------------------------------------

function ChartParser.ParseChart(fileString)
    local lines = split(fileString, "\n")
    local currentSection = nil
    local chart = Chart:new()
    local currentInst = nil
    local lastNote = nil

    for _, line in pairs(lines) do
        if line:sub(1,1) == '[' and line:sub(-1,-1) == ']' then
            local sectionName = line:sub(2, -2)
            currentSection = sectionName

            for _, difficultyName in pairs(ChartParser.DifficultyType) do
                for _, instrumentName in pairs(ChartParser.InstrumentType) do
                    if line:sub(2, -2) == difficultyName .. instrumentName then
                        isD = false
                        if instrumentName == 'Drums' then
                            isD = true
                        end
                        local instrumentTrack = InstrumentTrack:new(instrumentName, difficultyName, isD, false)
                        table.insert(chart.Instruments, instrumentTrack)
                        currentInst = instrumentTrack
                        break
                    end
                end
            end
            for _, difficultyName in pairs(ChartParser.DifficultyType) do
                for _, instrumentName in pairs(ChartParser.GHLInstrumentType) do
                    if line:sub(2, -2) == difficultyName .. instrumentName then
                        local instrumentTrack = InstrumentTrack:new(instrumentName, difficultyName, false, true)
                        table.insert(chart.Instruments, instrumentTrack)
                        currentInst = instrumentTrack
                        break
                    end
                end
            end


        elseif line == '{' or line == '}' then
            -- Ignore these lines
        
        elseif currentSection == 'Song' then
            line = line:gsub('"', '') -- Remove quotes
            line = line:gsub("%s+", "") -- Remove extra spaces
            local key, value = line:match("([^=]+)=([^=]+)")
            if key == "Name" then
                chart.Name = value
            elseif key == "Artist" then
                chart.Artist = value
            elseif key == "Charter" then
                chart.Charter = value
            elseif key == "Album" then
                chart.Album = value
            elseif key == "Year" then
                chart.Year = value
            elseif key == "Offset" then
                chart.Offset = tonumber(value)
            elseif key == "Resolution" then
                chart.Resolution = tonumber(value)
            elseif key == "Player2" then
                chart.Player2 = value
            elseif key == "Difficulty" then
                chart.Difficulty = tonumber(value)
            elseif key == "PreviewStart" then
                chart.PreviewStart = tonumber(value)
            elseif key == "PreviewEnd" then
                chart.PreviewEnd = tonumber(value)
            elseif key == "Genre" then
                chart.Genre = value
            elseif key == "MediaType" then
                chart.MediaType = value
            elseif key == "MusicStream" then
                chart.MusicStream = value
            end


        elseif currentSection == 'SyncTrack' then
            local parts = split(line, " ")
            local TickTime = tonumber(parts[1])
            local EventType = parts[3]
            local MetaData1 = tonumber(parts[4])

            if EventType == 'B' then
                local Tempo = MetaData1 / 1000
                local event = SyncTrackEvent:new(TickTime, ChartParser.SyncTrackEventType.BPM, Tempo)
                table.insert(chart.SyncTrack, event)
            elseif EventType == 'A' then
                local AudioTime = MetaData1 / 1000
                local event = SyncTrackEvent:new(TickTime, ChartParser.SyncTrackEventType.Anchor, AudioTime)
                table.insert(chart.SyncTrack, event)
            elseif EventType == 'TS' then
                if #parts == 5 then
                    local MetaData2 = tonumber(parts[5])
                    local event = SyncTrackEvent:new(TickTime, ChartParser.SyncTrackEventType.TimeSignature, MetaData1, MetaData2)
                    table.insert(chart.SyncTrack, event)
                else
                    local event = SyncTrackEvent:new(TickTime, ChartParser.SyncTrackEventType.TimeSignature, MetaData1, 2)
                    table.insert(chart.SyncTrack, event)
                end
            end
    
        elseif currentSection == 'Events' then
            local parts = split(line, " ")
            local TickTime = tonumber(parts[1])
            local Data = parts[4]
            Data = split(line, '"')[2]
            
            if string.find(Data, 'section ') ~= nil then
                local sectionName = string.gsub(Data, 'section ', '')

                local event = GlobalEvent:new(TickTime, ChartParser.GlobalEventType.Section, sectionName)
                table.insert(chart.Events, event)
            else
                local event = GlobalEvent:new(TickTime, ChartParser.GlobalEventType.Other, Data)
                table.insert(chart.Events, event)
            end


        elseif currentInst ~= nil and currentInst.IsDrums == true and currentInst.IsGHL == false then

            -- Drum Parser
            
            local parts = split(line, " ")
            local TickTime = tonumber(parts[1])
            RData = split(line, '=')[2]
            EData = split(RData, ' ')
            
            if EData[1] == 'S' then
                local event = LocalEvent:new(TickTime, ChartParser.LocalEventType.StarPowerPhrase, tonumber(EData[3]))
                if DataE[2] == '64' then
                    DrumActivationPhrase = true
                end
                table.insert(currentInst.Data, event)
            elseif EData[1] == 'E' then
                local event = LocalEvent:new(TickTime, ChartParser.LocalEventType.Other, EData[2])
                table.insert(currentInst.Data, event)
            elseif lastNote ~= nil and tonumber(EData[2]) >= 34 and tonumber(EData[2]) <= 38 then
                lastNote.Modifiers[1] = 1 --Accent
            elseif lastNote ~= nil and tonumber(EData[2]) >= 40 and tonumber(EData[2]) <= 44 then
                lastNote.Modifiers[2] = 1 --Ghost
            elseif lastNote ~= nil and tonumber(EData[2]) >= 66 and tonumber(EData[2]) <= 68 then
                lastNote.Modifiers[3] = 1 --Cymbal
            elseif EData[2] == '0' or EData[2] == '1' or EData[2] == '2' or EData[2] == '3' or EData[2] == '4' or EData[2] == '5' or EData[2] == '32' then
                local lane = EData[2] + 1
                if EData[2] == '32' then
                    lane = 7
                end
                local note = Note:new(TickTime, {0,0,0,0,0,0,0}, {0,0,0}, tonumber(EData[3]), currentInst)
                note.Lanes[lane] = 1
                table.insert(currentInst.Data, note)
                lastNote = note
            end





        elseif currentInst ~= nil and currentInst.IsDrums == false and currentInst.IsGHL == false then

            -- 5 Lane Parser
            
            local parts = split(line, " ")
            local TickTime = tonumber(parts[1])
            RData = split(line, '=')[2]
            EData = split(RData, ' ')
            if lastNote ~= nil and (EData[2] == '5' or EData[2] == '6') then
                if EData[2] == '5' then
                    lastNote.Modifiers[1] = 1
                elseif EData[2] == '6' then
                    lastNote.Modifiers[1] = 0
                    lastNote.Modifiers[2] = 1
                end
            elseif EData[1] == 'S' then
                local event = LocalEvent:new(TickTime, ChartParser.LocalEventType.StarPowerPhrase, tonumber(EData[3]))
                table.insert(currentInst.Data, event)
            elseif EData[1] == 'E' then
                local event = LocalEvent:new(TickTime, ChartParser.LocalEventType.Other, EData[2])
                table.insert(currentInst.Data, event)
            elseif EData[2] == '0' or EData[2] == '1' or EData[2] == '2' or EData[2] == '3' or EData[2] == '4' or EData[2] == '7' then
                if lastNote ~= nil and lastNote.TickTime == TickTime then
                    lastNote.Lanes[EData[2] + 1] = 1
                else
                    local lane = EData[2] + 1
                    local note = Note:new(TickTime, {0,0,0,0,0,0,0}, {0,0}, tonumber(EData[3]), currentInst)
                    note.Lanes[lane] = 1
                    table.insert(currentInst.Data, note)
                    lastNote = note
                end
            end
        end
    end



    return chart

end

return ChartParser
