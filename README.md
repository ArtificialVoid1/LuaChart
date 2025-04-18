# LuaChart
A Lua Module for reading .chart files generated by Moonscraper Chart Editor

# Introductoin
LuaChart is super easy to use! All it takes is one string of the entire text file

```lua
local LuaChart = require('LuaChart')

chartFile = io.open('chart.sng', 'r').read('*a')
ChartObject = LuaChart.ParseChart(chartFile)
```

The `ChartObject` Stores all of the data about the chart in classes. For example the main class `Chart` is as follows:

# Class Reference

## LuaChart.Chart
- `Type` : `Chart`
- `Name` : The name of the song
- `Artist` : The name of the artist
- `Charter` : The name of the charter
- `Album` : Album the song was in
- `Year` : The year the song released
- `Offset` : The amount of miliseconds to offset the song by at the start of the chart
- `Resolution` : How many ticks inside 1 quarter note (Default 192)
- `Player2` : ..
- `Difficulty` : The number difficulty used in guitar hero
- `PreviewStart` : The time when the preview of the song in the menu starts
- `PreviewEnd` : The time when the preview of the song in the menu ends
- `Genre` : Name of the genre of the song
- `MediaType` : Extra Metadata
- `MusicStream` : Extra Metadata
- `Instruments` : The list of `InstrumentTrack` objects
- `SyncTrack` : The list of `SyncTrackEvent` objects
- `Events` : The list of `GlobalEvent` objects

Methods:

`LuaChart.Chart:__tostring()` -> `string`

Looking at the synctrack, it stores all the data about bpm, time signatures, and bpm anchors

## LuaChart.SyncTrackEvent
This can have 3 possible structures based on the `SyncTrackEventType` as follows:

`LuaChart.SyncTrackEventType.TimeSignature`:
- `Type` : `SyncTrackEvent`
- `TickTime` : The time the event occurs (In ticks)
- `EventType` : `LuaChart.SyncTrackEventType.TimeSignature`
- `Value` : (Numerator, Denominator) A tuple containing the time signature
- `Exponent` : The power of 2 that the Denominator is

`LuaChart.SyncTrackEventType.BPM`:
- `Type` : `SyncTrackEvent`
- `TickTime` : The time the event occurs (In ticks)
- `EventType` : `LuaChart.SyncTrackEventType.BPM`
- `Tempo` : A number describing the change in tempo

`LuaChart.SyncTrackEventType.Anchor`:
- `Type` : `SyncTrackEvent`
- `TickTime` : The time the event occurs (In ticks)
- `EventType` : `LuaChart.SyncTrackEventType.Anchor`
- `AudioTime` : A number describing the time (In Seconds) that the event occurs

Methods:

`LuaChart.SyncTrackEvent:__tostring()` -> `string`

## LuaChart.GlobalEvent
The Global Events also have Type specific cases as shown

`LuaChart.GlobalEventType.Section`:
- `Type` : `GlobalEvent`
- `TickTime` : The time the event occurs (In ticks)
- `EventType` : `LuaChart.GlobalEventType.Section`
- `Name` : The name of the section (Used for practice mode)

`LuaChart.GlobalEventType.Other`:
- `Type` : `GlobalEvent`
- `TickTime` : The time the event occurs (In ticks)
- `EventType` : `LuaChart.GlobalEventType.Other`
- `Value` : The Value of the event such as "Lyric" or crowd events

Methods:

`LuaChart.GlobalEvent:__tostring()` -> `string`

## LuaChart.InstrumentTrack
- `Type` : `InstrumentTrack`
- `InstrumentType` : `InstrumentType` or `GHLInstrumentType`
- `DifficultyType` : `DifficultyType`
- `Data` : The notes and local events found in the chart
- `IsDrums` : A bool saying if its a drum track
- `IsGHL` : A bool saying if its a `GHLInstrumentType`

Methods:

`LuaChart.InstrumentTrack:__tostring()` -> `string`

## LuaChart.Note
- `Type` : `Note`
- `TickTime` : The time the note happens in ticks
- `Lanes` : `{1, 2, 3, 4, 5, 6, 7}`
- `Modifiers` : `{1, 2, 3}`
- `TickLength` : Length of the note in ticks
- `Instrument` : The parent `InstrumentTrack`

### 5 Fret
In this the Lanes represent the different colors

- 1 : Green fret
- 2 : Red fret
- 3 : Yellow fret
- 4 : Blue fret
- 5 : Orange fret
- 6 : unused
- 7 : Open fret

Modifiers tell you if the note is forced or tapped
- 1 : Forced
- 2 : Tap
- 3 : unused

5 fret related methods:

`LuaChart.Note:__tostring()` -> `string`

`LuaChart.Note:HasOpen()` -> `bool`

`LuaChart.Note:IsChord()` -> `bool`

`LuaChart.Note:IsTap()` -> `bool`

`LuaChart.Note:IsForced()` -> `bool`

### Drums

- 1 : Kick
- 2 : Red fret
- 3 : Yellow fret
- 4 : Blue fret
- 5 : Green fret / Blue fret (5 lane)
- 6 : Orange fret (5 lane)
- 7 : Kick x2

Modifiers tell you if the note is forced or tapped
- 1 : Accent
- 2 : Ghost
- 3 : Cymbal

Drum related methods:

`LuaChart.Note:__tostring()` -> `string`

`LuaChart.Note:HasKick()` -> `bool`

`LuaChart.Note:IsAccent()` -> `bool`

`LuaChart.Note:IsGhost()` -> `bool`

`LuaChart.Note:IsCymbal()` -> `bool`

## LuaChart.LocalEvent
Based on `LocalEventType`

`LuaChart.LocalEventType.StarPowerPhrase`
- `Type` : `LocalEvent`
- `TickTime` : Time the event occured in ticks
- `EventType` : `LuaChart.LocalEventType.StarPowerPhrase`
- `TickLength` : Length of the phrase in ticks
- `DrumsActivationPhrase` : a bool noting if the phrase is a drum activation phrase

`LuaChart.LocalEventType.Other`
- `Type` : `LocalEvent`
- `TickTime` : Time the event occured in ticks
- `EventType` : `LuaChart.LocalEventType.Other`
- `Name` : The value of the event such as "solo" or "soloend"

Methods:

`LuaChart.LocalEvent:__tostring()` -> `string`

# Enumerators

## LuaChart.LocalEventType
- `StarPowerPhrase`
- `Other`

## LuaChart.GHLInstrumentType
- `Guitar`
- `Bass`
- `Rhythm`
- `Guitar_CoOp`

## LuaChart.InstrumentType
- `Guitar`
- `CoOp_Guitar`
- `Bass`
- `Rhythm`
- `Keyboard`
- `Drums`

## LuaChart.DifficultyType
- `Easy`
- `Medium`
- `Hard`
- `Expert`

## LuaChart.GlobalEventType
- `Section`
- `Other`

## LuaChart.SyncTrackEventType
- `TimeSignature`
- `BPM`
- `Anchor`

