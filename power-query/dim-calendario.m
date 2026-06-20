let
    StartDate = #date(2025, 1, 1),
    EndDate = #date(2026, 12, 31),
    DayCount = Duration.Days(EndDate - StartDate) + 1,
    DateList = List.Dates(StartDate, DayCount, #duration(1, 0, 0, 0)),
    ToTable = Table.FromList(DateList, Splitter.SplitByNothing(), {"Date"}, null, ExtraValues.Error),
    ChangedType = Table.TransformColumnTypes(ToTable, {{"Date", type date}}),

    AddYear = Table.AddColumn(ChangedType, "Year", each Date.Year([Date]), Int64.Type),
    AddMonth = Table.AddColumn(AddYear, "MonthNum", each Date.Month([Date]), Int64.Type),
    AddMonthName = Table.AddColumn(AddMonth, "MonthName", each Date.ToText([Date], "MMM yyyy"), type text),
    AddQuarter = Table.AddColumn(AddMonthName, "Quarter", each "Q" & Text.From(Date.QuarterOfYear([Date])), type text),
    AddWeekNum = Table.AddColumn(AddQuarter, "WeekNum", each Date.WeekOfYear([Date], Day.Monday), Int64.Type),
    AddWeekLabel = Table.AddColumn(AddWeekNum, "WeekLabel", each "CW" & Text.PadStart(Text.From([WeekNum]), 2, "0"), type text),
    AddYearWeek = Table.AddColumn(AddWeekLabel, "YearWeek", each Text.From([Year]) & "-" & Text.PadStart(Text.From([WeekNum]), 2, "0"), type text),

    Today = DateTime.Date(DateTime.LocalNow()),
    AddIsCurrentWeek = Table.AddColumn(AddYearWeek, "IsCurrentWeek",
        each Date.WeekOfYear([Date], Day.Monday) = Date.WeekOfYear(Today, Day.Monday)
            and Date.Year([Date]) = Date.Year(Today), type logical),
    AddIsCurrentMonth = Table.AddColumn(AddIsCurrentWeek, "IsCurrentMonth",
        each Date.Month([Date]) = Date.Month(Today)
            and Date.Year([Date]) = Date.Year(Today), type logical),

    AddDateKey = Table.AddColumn(AddIsCurrentMonth, "DateKey",
        each Date.Year([Date]) * 10000 + Date.Month([Date]) * 100 + Date.Day([Date]), Int64.Type),

    Reorder = Table.ReorderColumns(AddDateKey, {
        "DateKey", "Date", "Year", "MonthNum", "MonthName", "Quarter",
        "WeekNum", "WeekLabel", "YearWeek", "IsCurrentWeek", "IsCurrentMonth"
    })
in
    Reorder
