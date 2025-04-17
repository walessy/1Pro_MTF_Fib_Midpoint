//+------------------------------------------------------------------+
//|                        FibDay5Min_OOP.mq5                        |
//|                                                                   |
//|  Object-oriented implementation of the Fibonacci Day Strategy     |
//|  for MT5 platform                                                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property version   "1.30"
#property indicator_chart_window
#property indicator_plots   0

// Include OOP structure
#include "..//include//FibDayStrategy.mqh"

// Main strategy instance
FibDayStrategy *g_strategy = NULL;

// Input parameters for original functionality
input bool  UseDirectionalColors = true;   // Use direction-based colors (Bull/Bear)
input color BullishColor = clrSkyBlue;     // Color for Bullish Days
input color BearishColor = clrMaroon;      // Color for Bearish Days
input color LineColor = clrDodgerBlue;     // Default Line Color (if not using directional)
input bool  ShowFibLevels = true;          // Show Fibonacci Levels
input bool  Show0Level = true;             // Show 0% Level
input bool  Show23_6Level = true;          // Show 23.6% Level
input bool  Show38_2Level = true;          // Show 38.2% Level
input bool  Show50Level = true;            // Show 50% Level
input bool  Show61_8Level = true;          // Show 61.8% Level
input bool  Show76_4Level = true;          // Show 76.4% Level
input bool  Show100Level = true;           // Show 100% Level
input bool  Show161_8Level = false;        // Show 161.8% Level
input bool  Show261_8Level = false;        // Show 261.8% Level
input bool  ShowLabels = true;             // Show Price Labels on Lines
input color LabelColor = clrBrown;         // Label Text Color
input int   LabelFontSize = 8;             // Label Font Size

// Input parameters for sub-Fibonacci trend lines
input string SubFibSection = "--- Sub-Fibonacci Settings ---"; // Sub-Fibonacci Settings
input bool   ShowSubFib = true;            // Show Sub-Fibonacci Trend Lines
input bool   AlwaysShowSubFib = false;     // Always show Sub-Fibonacci levels (ignore strategy conditions)
input double StartPoint = 0.5;             // Starting Point for Sub-Fibonacci (0-1)
input double EndPoint = 0.618;             // Ending Point for Sub-Fibonacci (0-1)
input bool   UseCustomSubFibColor = false; // Use custom Sub-Fibonacci color (or inherit from main)
input color  SubFibColor = clrMagenta;     // Custom Sub-Fibonacci Lines Color (if enabled)
input double SubFibLineLength = 0.5;       // Length of Sub-Fib lines (0-1 ratio of day)
input double SubFibStartOffset = 0.25;     // Start offset for Sub-Fib lines (0-1 ratio of day)
input bool   ShowSubFib0Level = true;      // Show Sub-Fib 0% Level
input bool   ShowSubFib23_6Level = true;   // Show Sub-Fib 23.6% Level
input bool   ShowSubFib38_2Level = true;   // Show Sub-Fib 38.2% Level
input bool   ShowSubFib50Level = true;     // Show Sub-Fib 50% Level
input bool   ShowSubFib61_8Level = true;   // Show Sub-Fib 61.8% Level
input bool   ShowSubFib76_4Level = true;   // Show Sub-Fib 76.4% Level
input bool   ShowSubFib100Level = true;    // Show Sub-Fib 100% Level
input bool   ShowSubFibLabels = true;      // Show Sub-Fib Labels

// Input parameters for strategy detection
input string StrategySection = "--- Strategy Detection Settings ---"; // Strategy Detection Settings
input bool   EnableStrategyDetection = true;  // Enable strategy condition detection
input bool   DrawCandleMidpoints = true;      // Draw midpoints for candle bodies
input color  MidpointColor = clrPurple;       // Color for candle midpoint lines
input int    LookbackCandles = 100;           // Number of candles to look back for conditions
input bool   HighlightEntryZone = true;       // Highlight the entry zone when detected
input color  EntryZoneColor = clrLime;        // Color for the entry zone highlight
input double InputUpperZoneLimit = 0.6;       // Upper limit for zone (default 60%)
input double InputLowerZoneLimit = 0.5;       // Lower limit for zone (default 50%)
input bool   ShowEntryArrow = true;           // Show arrow at entry point
input color  EntryArrowColor = clrRed;        // Color for entry arrow

// Input parameters for condition highlighting
input string HighlightSection = "--- Condition Highlighting Settings ---"; // Condition Highlighting
input bool   ShowConditionPanel = true;       // Show condition status panel
input bool   MarkConditionCandles = true;     // Mark candles where conditions were met
input bool   RestrictToCurrentDay = true;     // Only show conditions from current day
input color  Condition1Color = clrGreen;      // Color for Condition 1 markers
input color  Condition2Color = clrBlue;       // Color for Condition 2 markers
input color  Condition3Color = clrOrange;     // Color for Condition 3 markers
input color  Condition4Color = clrRed;        // Color for Condition 4 markers

// Input parameters for condition panel customization
input string PanelSection = "--- Condition Panel Settings ---"; // Condition Panel Settings
input ENUM_BASE_CORNER PanelCorner = CORNER_RIGHT_UPPER;    // Panel Position Corner
input int PanelXDistance = 200;                             // Panel X Distance
input int PanelYDistance = 20;                              // Panel Y Distance
input int PanelWidth = 180;                                 // Panel Width
input int PanelHeight = 120;                                // Panel Height
input color PanelBackgroundColor = clrWhite;                // Panel Background Color
input color PanelBorderColor = clrBlack;                    // Panel Border Color
input color PanelTitleColor = clrBlack;                     // Panel Title Color
input int PanelTitleFontSize = 10;                          // Panel Title Font Size
input bool PanelShowBulletPoints = true;                    // Show Bullet Points
input int PanelConditionFontSize = 8;                       // Condition Text Font Size
input int PanelSignalFontSize = 9;                          // Signal Text Font Size
input bool EnablePanelTransparency = false;                 // Enable Panel Transparency
input int PanelTransparencyLevel = 80;                      // Panel Transparency Level (0-100)
input bool EnableAutoPosition = false;                      // Auto-position Panel

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int OnInit()
{
   // Create a new strategy instance
   if(g_strategy != NULL) {
      delete g_strategy;
      g_strategy = NULL;
   }
   
   g_strategy = new FibDayStrategy();
   
   // Configure Fibonacci model
   FibonacciModel* fibModel = g_strategy.GetFibonacciModel();
   fibModel.SetCustomPoints(StartPoint, EndPoint);
   
   // Configure strategy model
   StrategyModel* strategyModel = g_strategy.GetStrategyModel();
   strategyModel.SetZoneLimits(InputLowerZoneLimit, InputUpperZoneLimit);
   
   // Configure drawing service
   DrawingService* drawingService = g_strategy.GetDrawingService();
   
   // Configure color settings
   drawingService.SetColorSettings(UseDirectionalColors, BullishColor, BearishColor, LineColor);
   
   // Configure which main Fibonacci levels to show
   drawingService.ConfigureMainLevels(Show0Level, Show23_6Level, Show38_2Level, Show50Level,
                                    Show61_8Level, Show76_4Level, Show100Level,
                                    Show161_8Level, Show261_8Level);
   
   // Configure which sub-Fibonacci levels to show
   drawingService.ConfigureSubLevels(ShowSubFib0Level, ShowSubFib23_6Level, ShowSubFib38_2Level,
                                   ShowSubFib50Level, ShowSubFib61_8Level, ShowSubFib76_4Level,
                                   ShowSubFib100Level);
   
   // Configure sub-Fibonacci settings
   drawingService.SetSubFibSettings(ShowSubFib, AlwaysShowSubFib, SubFibLineLength, SubFibStartOffset,
                                  UseCustomSubFibColor, SubFibColor, ShowSubFibLabels);
   
   // Configure strategy detection settings
   drawingService.SetStrategySettings(EnableStrategyDetection, DrawCandleMidpoints, MidpointColor,
                                    HighlightEntryZone, EntryZoneColor, ShowEntryArrow, EntryArrowColor);
   
   // Configure panel settings
   drawingService.SetPanelSettings(PanelCorner, PanelXDistance, PanelYDistance, PanelWidth, PanelHeight,
                                 PanelBackgroundColor, PanelBorderColor, PanelTitleColor, PanelTitleFontSize);
   
   // Configure condition colors
   drawingService.SetConditionColors(Condition1Color, Condition2Color, Condition3Color, Condition4Color);
   
   // Configure general settings
   g_strategy.SetLookbackCandles(LookbackCandles);
   g_strategy.SetRestrictToCurrentDay(RestrictToCurrentDay);
   
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   // Make sure the strategy instance exists
   if(g_strategy == NULL) return(rates_total);
   
   // Update the strategy
   g_strategy.OnCalculate(rates_total, prev_calculated, time, open, high, low, close);
   
   return(rates_total);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                               |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                 const long &lparam,
                 const double &dparam,
                 const string &sparam)
{
   // Make sure the strategy instance exists
   if(g_strategy == NULL) return;
   
   // Forward the event to the strategy
   g_strategy.OnChartEvent(id, lparam, dparam, sparam);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   // Clean up the strategy instance
   if(g_strategy != NULL) {
      delete g_strategy;
      g_strategy = NULL;
   }
}