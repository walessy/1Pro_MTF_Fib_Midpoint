//+------------------------------------------------------------------+
//|                        FibDay5Min_OOP.mq4                        |
//|                                                                   |
//|  Object-oriented implementation of the Fibonacci Day Strategy     |
//|  for MT4 platform                                                |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property version   "1.30"
#property indicator_chart_window
#property strict

// Include all necessary files in correct order
#include <1Pro_MTF_Fib_Midpoint//PlatformAbstraction.mqh>
#include <1Pro_MTF_Fib_Midpoint//FibonacciModel.mqh>
#include <1Pro_MTF_Fib_Midpoint//StrategyModel.mqh>
#include <1Pro_MTF_Fib_Midpoint//DrawingService.mqh>
#include <1Pro_MTF_Fib_Midpoint//FibDayStrategy.mqh>

// Main strategy instance
FibDayStrategy *g_strategy = NULL;

// Input parameters for original functionality
extern bool  UseDirectionalColors = true;   // Use direction-based colors (Bull/Bear)
extern color BullishColor = SkyBlue;        // Color for Bullish Days
extern color BearishColor = Maroon;         // Color for Bearish Days
extern color LineColor = DodgerBlue;        // Default Line Color (if not using directional)
extern bool  ShowFibLevels = true;          // Show Fibonacci Levels
extern bool  Show0Level = true;             // Show 0% Level
extern bool  Show23_6Level = true;          // Show 23.6% Level
extern bool  Show38_2Level = true;          // Show 38.2% Level
extern bool  Show50Level = true;            // Show 50% Level
extern bool  Show61_8Level = true;          // Show 61.8% Level
extern bool  Show76_4Level = true;          // Show 76.4% Level
extern bool  Show100Level = true;           // Show 100% Level
extern bool  Show161_8Level = false;        // Show 161.8% Level
extern bool  Show261_8Level = false;        // Show 261.8% Level
extern bool  ShowLabels = true;             // Show Price Labels on Lines
extern color LabelColor = Brown;            // Label Text Color
extern int   LabelFontSize = 8;             // Label Font Size

// Input parameters for sub-Fibonacci trend lines
extern string SubFibSection = "--- Sub-Fibonacci Settings ---"; // Sub-Fibonacci Settings
extern bool   ShowSubFib = true;            // Show Sub-Fibonacci Trend Lines
extern bool   AlwaysShowSubFib = false;     // Always show Sub-Fibonacci levels (ignore strategy conditions)
extern double StartPoint = 0.5;             // Starting Point for Sub-Fibonacci (0-1)
extern double EndPoint = 0.618;             // Ending Point for Sub-Fibonacci (0-1)
extern bool   UseCustomSubFibColor = false; // Use custom Sub-Fibonacci color (or inherit from main)
extern color  SubFibColor = Magenta;        // Custom Sub-Fibonacci Lines Color (if enabled)
extern double SubFibLineLength = 0.5;       // Length of Sub-Fib lines (0-1 ratio of day)
extern double SubFibStartOffset = 0.25;     // Start offset for Sub-Fib lines (0-1 ratio of day)
extern bool   ShowSubFib0Level = true;      // Show Sub-Fib 0% Level
extern bool   ShowSubFib23_6Level = true;   // Show Sub-Fib 23.6% Level
extern bool   ShowSubFib38_2Level = true;   // Show Sub-Fib 38.2% Level
extern bool   ShowSubFib50Level = true;     // Show Sub-Fib 50% Level
extern bool   ShowSubFib61_8Level = true;   // Show Sub-Fib 61.8% Level
extern bool   ShowSubFib76_4Level = true;   // Show Sub-Fib 76.4% Level
extern bool   ShowSubFib100Level = true;    // Show Sub-Fib 100% Level
extern bool   ShowSubFibLabels = true;      // Show Sub-Fib Labels

// Input parameters for strategy detection
extern string StrategySection = "--- Strategy Detection Settings ---"; // Strategy Detection Settings
extern bool   EnableStrategyDetection = true;  // Enable strategy condition detection
extern bool   DrawCandleMidpoints = true;      // Draw midpoints for candle bodies
extern color  MidpointColor = Purple;          // Color for candle midpoint lines
extern int    LookbackCandles = 100;           // Number of candles to look back for conditions
extern bool   HighlightEntryZone = true;       // Highlight the entry zone when detected
extern color  EntryZoneColor = Lime;           // Color for the entry zone highlight
extern double InputUpperZoneLimit = 0.6;       // Upper limit for zone (default 60%)
extern double InputLowerZoneLimit = 0.5;       // Lower limit for zone (default 50%)
extern bool   ShowEntryArrow = true;           // Show arrow at entry point
extern color  EntryArrowColor = Red;           // Color for entry arrow

// Input parameters for condition highlighting
extern string HighlightSection = "--- Condition Highlighting Settings ---"; // Condition Highlighting
extern bool   ShowConditionPanel = true;       // Show condition status panel
extern bool   MarkConditionCandles = true;     // Mark candles where conditions were met
extern bool   RestrictToCurrentDay = true;     // Only show conditions from current day
extern color  Condition1Color = Green;         // Color for Condition 1 markers
extern color  Condition2Color = Blue;          // Color for Condition 2 markers
extern color  Condition3Color = Orange;        // Color for Condition 3 markers
extern color  Condition4Color = Red;           // Color for Condition 4 markers

// Input parameters for condition panel customization
extern string PanelSection = "--- Condition Panel Settings ---"; // Condition Panel Settings
extern int PanelCorner = 1;                                  // Panel Position Corner (1=upper right)
extern int PanelXDistance = 200;                             // Panel X Distance
extern int PanelYDistance = 20;                              // Panel Y Distance
extern int PanelWidth = 180;                                 // Panel Width
extern int PanelHeight = 120;                                // Panel Height
extern color PanelBackgroundColor = White;                   // Panel Background Color
extern color PanelBorderColor = Black;                       // Panel Border Color
extern color PanelTitleColor = Black;                        // Panel Title Color
extern int PanelTitleFontSize = 10;                          // Panel Title Font Size
extern bool PanelShowBulletPoints = true;                    // Show Bullet Points
extern int PanelConditionFontSize = 8;                       // Condition Text Font Size
extern int PanelSignalFontSize = 9;                          // Signal Text Font Size

// Convert MT4 corner value to ENUM_BASE_CORNER
ENUM_BASE_CORNER ConvertCorner(int cornerValue) {
   switch(cornerValue) {
      case 0: return CORNER_LEFT_UPPER;
      case 1: return CORNER_RIGHT_UPPER;
      case 2: return CORNER_LEFT_LOWER;
      case 3: return CORNER_RIGHT_LOWER;
      default: return CORNER_RIGHT_UPPER;
   }
}

//+------------------------------------------------------------------+
//| Custom indicator initialization function                          |
//+------------------------------------------------------------------+
int init()
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
   
   // Convert MT4 corner value to ENUM_BASE_CORNER for our abstraction
   ENUM_BASE_CORNER corner = ConvertCorner(PanelCorner);
   
   // Configure panel settings
   drawingService.SetPanelSettings(corner, PanelXDistance, PanelYDistance, PanelWidth, PanelHeight,
                                 PanelBackgroundColor, PanelBorderColor, PanelTitleColor, PanelTitleFontSize);
   
   // Configure condition colors
   drawingService.SetConditionColors(Condition1Color, Condition2Color, Condition3Color, Condition4Color);
   
   // Configure general settings
   g_strategy.SetLookbackCandles(LookbackCandles);
   g_strategy.SetRestrictToCurrentDay(RestrictToCurrentDay);
   
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function                               |
//+------------------------------------------------------------------+
int start()
{
   // Make sure the strategy instance exists
   if(g_strategy == NULL) return(0);
   
   // Get data arrays for OnCalculate
   int counted_bars = IndicatorCounted();
   int limit = Bars - counted_bars;
   if(limit > Bars) limit = Bars;
   
   // Create arrays for the strategy
   datetime time[];
   double open[];
   double high[];
   double low[];
   double close[];
   
   // Copy data to arrays
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   ArrayResize(time, limit);
   ArrayResize(open, limit);
   ArrayResize(high, limit);
   ArrayResize(low, limit);
   ArrayResize(close, limit);
   
   for(int i = 0; i < limit; i++) {
      time[i] = Time[i];
      open[i] = Open[i];
      high[i] = High[i];
      low[i] = Low[i];
      close[i] = Close[i];
   }
   
   // Update the strategy
   g_strategy.OnCalculate(limit, counted_bars, time, open, high, low, close);
   
   return(0);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                        |
//+------------------------------------------------------------------+
int deinit()
{
   // Make sure the strategy instance exists
   if(g_strategy != NULL) {
      // Use the platform bridge to clean up all objects
      PlatformBridge *platform = g_strategy.GetPlatformBridge();
      if(platform != NULL) {
         platform.CleanupAllObjects();
      }
      
      // Clean up the strategy instance
      delete g_strategy;
      g_strategy = NULL;
   } else {
      // If strategy doesn't exist, do a direct cleanup
      // Create a temporary platform bridge just for cleanup
      PlatformBridge cleanupBridge;
      cleanupBridge.CleanupAllObjects();
   }
   
   return(0);
}

//+------------------------------------------------------------------+
//| ChartEvent function for MT4                                       |
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