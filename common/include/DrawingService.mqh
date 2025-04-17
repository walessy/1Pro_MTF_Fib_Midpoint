//+------------------------------------------------------------------+
//|                      DrawingService.mqh                          |
//|                                                                   |
//|  Service class for handling chart drawing operations              |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property version   "1.00"

#include "PlatformAbstraction.mqh"
#include "FibonacciModel.mqh"
#include "StrategyModel.mqh"

// Class for handling all drawing operations
class DrawingService {
private:
   PlatformBridge *m_platform;
   FibonacciModel *m_fibModel;
   StrategyModel *m_strategyModel;
   
   // Drawing settings
   bool m_useDirectionalColors;
   color m_bullishColor;
   color m_bearishColor;
   color m_defaultLineColor;
   bool m_showLabels;
   color m_labelColor;
   int m_labelFontSize;
   
   // Sub-Fibonacci settings
   bool m_showSubFib;
   bool m_alwaysShowSubFib;
   bool m_useCustomSubFibColor;
   color m_subFibColor;
   double m_subFibLineLength;
   double m_subFibStartOffset;
   bool m_showSubFibLabels;
   
   // Strategy detection visualization
   bool m_enableStrategyDetection;
   bool m_drawCandleMidpoints;
   color m_midpointColor;
   bool m_highlightEntryZone;
   color m_entryZoneColor;
   bool m_showEntryArrow;
   color m_entryArrowColor;
   
   // Condition panel settings
   bool m_showConditionPanel;
   ENUM_BASE_CORNER m_panelCorner;
   int m_panelXDistance;
   int m_panelYDistance;
   int m_panelWidth;
   int m_panelHeight;
   color m_panelBackgroundColor;
   color m_panelBorderColor;
   color m_panelTitleColor;
   int m_panelTitleFontSize;
   
   // Day time boundaries
   datetime m_todayStartTime;
   datetime m_nextDayStartTime;
   
   // Boolean arrays for level display
   bool m_showLevels[9];
   bool m_showSubFibLevels[7];
   
   // Condition colors
   color m_conditionColors[4];
   
   // Helper method to determine the current line color
   color GetCurrentLineColor(bool isCustomColor = false, color customColor = CLR_NONE) {
      if(isCustomColor && customColor != CLR_NONE) {
         return customColor;
      } else if(m_useDirectionalColors) {
         return m_fibModel.IsPrevDayBullish() ? m_bullishColor : m_bearishColor;
      } else {
         return m_defaultLineColor;
      }
   }
   
   // Helper method to check if a datetime is today
   bool IsToday(datetime time) {
      return (time >= m_todayStartTime && time < m_nextDayStartTime);
   }
   
   // Helper method to convert color to ARGB with alpha
   uint ConvertColorToARGB(color clr, uchar alpha = 255) {
      // Extract RGB components
      uchar r = (uchar)clr;
      uchar g = (uchar)(clr >> 8);
      uchar b = (uchar)(clr >> 16);
      
      // Combine with alpha
      return ((uint)alpha << 24) + ((uint)b << 16) + ((uint)g << 8) + r;
   }
   
public:
   // Constructor
   DrawingService(PlatformBridge *platform, FibonacciModel *fibModel, StrategyModel *strategyModel) {
      m_platform = platform;
      m_fibModel = fibModel;
      m_strategyModel = strategyModel;
      
      // Default settings
      m_useDirectionalColors = true;
      m_bullishColor = clrSkyBlue;
      m_bearishColor = clrMaroon;
      m_defaultLineColor = clrDodgerBlue;
      m_showLabels = true;
      m_labelColor = clrBrown;
      m_labelFontSize = 8;
      
      // Sub-Fibonacci defaults
      m_showSubFib = true;
      m_alwaysShowSubFib = false;
      m_useCustomSubFibColor = false;
      m_subFibColor = clrMagenta;
      m_subFibLineLength = 0.5;
      m_subFibStartOffset = 0.25;
      m_showSubFibLabels = true;
      
      // Strategy detection defaults
      m_enableStrategyDetection = true;
      m_drawCandleMidpoints = true;
      m_midpointColor = clrPurple;
      m_highlightEntryZone = true;
      m_entryZoneColor = clrLime;
      m_showEntryArrow = true;
      m_entryArrowColor = clrRed;
      
      // Panel defaults
      m_showConditionPanel = true;
      m_panelCorner = CORNER_RIGHT_UPPER;
      m_panelXDistance = 200;
      m_panelYDistance = 20;
      m_panelWidth = 180;
      m_panelHeight = 120;
      m_panelBackgroundColor = clrWhite;
      m_panelBorderColor = clrBlack;
      m_panelTitleColor = clrBlack;
      m_panelTitleFontSize = 10;
      
      // Initialize arrays
      for(int i = 0; i < 9; i++) m_showLevels[i] = true;
      for(int j = 0; j < 7; j++) m_showSubFibLevels[j] = true;
      
      // Condition colors
      m_conditionColors[0] = clrGreen;  // Condition 1
      m_conditionColors[1] = clrBlue;   // Condition 2
      m_conditionColors[2] = clrOrange; // Condition 3
      m_conditionColors[3] = clrRed;    // Condition 4
      
      // Set day boundaries
      UpdateDayBoundaries();
   }
   
   // Update today's start and end times
   void UpdateDayBoundaries() {
      m_todayStartTime = m_platform.GetBarTime(0); // Start of current day
      
      // Calculate next day (platform independent)
      MqlDateTime today_struct;
      TimeToStruct(m_todayStartTime, today_struct);
      today_struct.day += 1;  // Add one day
      m_nextDayStartTime = StructToTime(today_struct);
   }
   
   // Configure which main Fibonacci levels to show
   void ConfigureMainLevels(bool show0, bool show23_6, bool show38_2, bool show50, 
                           bool show61_8, bool show76_4, bool show100, 
                           bool show161_8, bool show261_8) {
      m_showLevels[0] = show0;
      m_showLevels[1] = show23_6;
      m_showLevels[2] = show38_2;
      m_showLevels[3] = show50;
      m_showLevels[4] = show61_8;
      m_showLevels[5] = show76_4;
      m_showLevels[6] = show100;
      m_showLevels[7] = show161_8;
      m_showLevels[8] = show261_8;
   }
   
   // Configure which sub-Fibonacci levels to show
   void ConfigureSubLevels(bool show0, bool show23_6, bool show38_2, bool show50, 
                          bool show61_8, bool show76_4, bool show100) {
      m_showSubFibLevels[0] = show0;
      m_showSubFibLevels[1] = show23_6;
      m_showSubFibLevels[2] = show38_2;
      m_showSubFibLevels[3] = show50;
      m_showSubFibLevels[4] = show61_8;
      m_showSubFibLevels[5] = show76_4;
      m_showSubFibLevels[6] = show100;
   }
   
   // Set condition colors
   void SetConditionColors(color cond1, color cond2, color cond3, color cond4) {
      m_conditionColors[0] = cond1;
      m_conditionColors[1] = cond2;
      m_conditionColors[2] = cond3;
      m_conditionColors[3] = cond4;
   }
   
   // Set color settings
   void SetColorSettings(bool useDirectional, color bullish, color bearish, color defaultColor) {
      m_useDirectionalColors = useDirectional;
      m_bullishColor = bullish;
      m_bearishColor = bearish;
      m_defaultLineColor = defaultColor;
   }
   
   // Set panel settings
   void SetPanelSettings(ENUM_BASE_CORNER corner, int x, int y, int width, int height, 
                        color bgColor, color borderColor, color titleColor, int titleSize) {
      m_panelCorner = corner;
      m_panelXDistance = x;
      m_panelYDistance = y;
      m_panelWidth = width;
      m_panelHeight = height;
      m_panelBackgroundColor = bgColor;
      m_panelBorderColor = borderColor;
      m_panelTitleColor = titleColor;
      m_panelTitleFontSize = titleSize;
   }
   
   // Set sub-Fibonacci settings
   void SetSubFibSettings(bool show, bool always, double length, double offset, 
                         bool useCustomColor, color customColor, bool showLabels) {
      m_showSubFib = show;
      m_alwaysShowSubFib = always;
      m_subFibLineLength = length;
      m_subFibStartOffset = offset;
      m_useCustomSubFibColor = useCustomColor;
      m_subFibColor = customColor;
      m_showSubFibLabels = showLabels;
   }
   
   // Set strategy detection settings
   void SetStrategySettings(bool enable, bool drawMidpoints, color midpointColor,
                          bool highlightZone, color zoneColor, bool showArrow, color arrowColor) {
      m_enableStrategyDetection = enable;
      m_drawCandleMidpoints = drawMidpoints;
      m_midpointColor = midpointColor;
      m_highlightEntryZone = highlightZone;
      m_entryZoneColor = zoneColor;
      m_showEntryArrow = showArrow;
      m_entryArrowColor = arrowColor;
   }
   
   // Clear all drawing objects
   void ClearAll() {
      m_platform.DeleteAllObjects("PrevDay_");
      m_platform.DeleteAllObjects("SubFib_");
      m_platform.DeleteAllObjects("Label_");
      m_platform.DeleteAllObjects("MidPoint_");
      m_platform.DeleteAllObjects("Strategy_");
      m_platform.DeleteAllObjects("Entry_");
      m_platform.DeleteAllObjects("Condition_");
      m_platform.DeleteAllObjects("CondMarker_");
   }
   
   // Draw horizontal line
   void CreateHorizontalLine(string name, double price, ENUM_LINE_STYLE style, string tooltip, 
                           bool isCustomColor = false, color customColor = CLR_NONE, 
                           bool useCustomLabel = false) {
      // Get the appropriate color
      color currentLineColor = GetCurrentLineColor(isCustomColor, customColor);
      
      // Create the horizontal line
      m_platform.CreateLine(name, m_todayStartTime, price, m_nextDayStartTime, price, 
                          currentLineColor, style, 1);
      
      // Add price label on the line if enabled
      bool shouldShowLabel = (useCustomLabel && m_showSubFibLabels) || (!useCustomLabel && m_showLabels);
      
      if(shouldShowLabel) {
         // Extract label text from tooltip (before the colon)
         string labelText = tooltip;
         int colonPos = StringFind(tooltip, ":");
         if(colonPos > 0)
            labelText = StringSubstr(tooltip, 0, colonPos);
            
         // Add "Day" prefix to the label text for main fibs, "Sub" prefix for sub-fibs
         if(StringFind(labelText, "Previous Day") >= 0) {
            // Don't modify if it already has "Previous Day" in the text
         }
         else if(StringFind(labelText, "SubFib") >= 0) {
            // It's already a SubFib label, keep as is
         }
         else if(StringFind(labelText, "Fib") >= 0) {
            // For Fibonacci levels
            labelText = "Day " + labelText;
         }
         else {
            // For any other label type
            labelText = "Day " + labelText;
         }
            
         // Create a text label at the start of the line
         string labelName = "Label_" + name;
         
         // Create text object
         m_platform.CreateText(labelName, m_todayStartTime, price, labelText, currentLineColor, m_labelFontSize);
      }
   }
   
   // Draw shorter horizontal line (for sub-Fibonacci levels)
   void CreateShorterHorizontalLine(string name, double price, ENUM_LINE_STYLE style, string tooltip, 
                                 bool isCustomColor = false, color customColor = CLR_NONE, 
                                 bool useCustomLabel = false) {
      // Get the appropriate color
      color currentLineColor = GetCurrentLineColor(isCustomColor, customColor);
      
      // Validate length ratio and start offset
      double lengthRatio = MathMax(0.1, MathMin(1.0, m_subFibLineLength));
      double startOffsetRatio = MathMax(0.0, MathMin(0.9, m_subFibStartOffset));
      
      // Ensure that offset + length doesn't exceed the day
      if(startOffsetRatio + lengthRatio > 1.0)
         lengthRatio = 1.0 - startOffsetRatio;
      
      // Calculate the day's time range
      long timeRange = (long)(m_nextDayStartTime - m_todayStartTime);
      
      // Calculate start and end times for the shorter line with offset
      datetime lineStartTime = m_todayStartTime + (datetime)(timeRange * startOffsetRatio);
      datetime lineEndTime = lineStartTime + (datetime)(timeRange * lengthRatio);
      
      // Create the horizontal line with shorter length and offset start
      m_platform.CreateLine(name, lineStartTime, price, lineEndTime, price, 
                          currentLineColor, style, 1);
      
      // Add price label on the line if enabled
      if(useCustomLabel) {
         // Extract label text from tooltip (before the colon)
         string labelText = tooltip;
         int colonPos = StringFind(tooltip, ":");
         if(colonPos > 0)
            labelText = StringSubstr(tooltip, 0, colonPos);
            
         // Create a text label at the start of the shorter line
         string labelName = "Label_" + name;
         
         // Create text object
         m_platform.CreateText(labelName, lineStartTime, price, labelText, currentLineColor, m_labelFontSize);
      }
   }
   
   // Draw main Fibonacci levels
   void DrawMainFibonacciLevels() {
      // Draw High/Low lines
      double prevDayHigh = m_fibModel.GetPrevDayHigh();
      double prevDayLow = m_fibModel.GetPrevDayLow();
      bool prevDayBullish = m_fibModel.IsPrevDayBullish();
      
      CreateHorizontalLine("PrevDay_High", prevDayHigh, prevDayBullish ? STYLE_SOLID : STYLE_DASH, 
                        "Previous Day High: " + DoubleToString(prevDayHigh, m_platform.GetDigits()));
      
      CreateHorizontalLine("PrevDay_Low", prevDayLow, prevDayBullish ? STYLE_DASH : STYLE_SOLID, 
                        "Previous Day Low: " + DoubleToString(prevDayLow, m_platform.GetDigits()));
      
      // Create Fibonacci levels if enabled
      for(int i = 0; i < m_fibModel.GetPrimaryFibCount(); i++) {
         // Skip if this level is not enabled
         if(!m_showLevels[i]) continue;
         
         // Calculate the price for this level
         double levelPrice = m_fibModel.GetPrimaryFibLevel(i);
         double ratio = m_fibModel.GetPrimaryFibRatio(i);
         
         // Create the horizontal line
         string levelName = "PrevDay_Fib_" + DoubleToString(ratio * 100, 1);

         // Use solid line style for all main Fibonacci levels
         ENUM_LINE_STYLE lineStyle = STYLE_SOLID;
             
         CreateHorizontalLine(levelName, levelPrice, lineStyle, 
                             "Fib " + DoubleToString(ratio * 100, 1) + "%: " + 
                             DoubleToString(levelPrice, m_platform.GetDigits()));
      }
   }
   
   // Draw sub-Fibonacci levels
   void DrawSubFibonacciLevels() {
      for(int i = 0; i < m_fibModel.GetSubFibCount(); i++) {
         // Skip if this level is not enabled
         if(!m_showSubFibLevels[i]) continue;
         
         // Get the price for this sub-fib level
         double subLevelPrice = m_fibModel.GetSubFibLevel(i);
         double ratio = m_fibModel.GetSubFibRatio(i);
         
         // Create the horizontal line for sub-fib
         string subLevelName = "SubFib_" + DoubleToString(ratio * 100, 1);
         ENUM_LINE_STYLE subLineStyle = STYLE_DOT;  // Use dotted style for sub-fibs
         
         // Create the line with the specified sub-fib color and shorter length
         CreateShorterHorizontalLine(subLevelName, subLevelPrice, subLineStyle, 
                                "SubFib " + DoubleToString(ratio * 100, 1) + "%: " + 
                                DoubleToString(subLevelPrice, m_platform.GetDigits()), 
                                m_useCustomSubFibColor, m_subFibColor, 
                                m_showSubFibLabels);
      }
   }
   
   // Draw candle midpoints using platform abstraction
   void DrawCandleMidpoints(const datetime &time[], const double &open[], const double &close[], int maxCandles) {
      if(!m_drawCandleMidpoints) return;
      
      // Delete previous midpoint lines
      m_platform.DeleteAllObjects("MidPoint_");
      
      for(int i = 0; i < maxCandles; i++) {
         // Only process visible candles from today
         if(time[i] < m_todayStartTime || time[i] >= m_nextDayStartTime) continue;
         
         // Calculate midpoint of the candle body
         double midpoint = (open[i] + close[i]) / 2.0;
         
         // Create a midpoint line
         string midpointName = "MidPoint_" + IntegerToString(i);
         
         // Calculate times for short line
         int periodSeconds = m_platform.TimeframeToSeconds(m_platform.GetTimeframe());
         
         // For 5-minute chart, a candle is 5 minutes wide
         // Make the line slightly narrower than the candle
         datetime lineStartTime = time[i] - periodSeconds / 3;
         datetime lineEndTime = time[i] + periodSeconds / 3;
         
         // Create tooltip text
         string tooltip = "Midpoint: " + DoubleToString(midpoint, m_platform.GetDigits());
         
         // Use the platform abstraction to create the fixed trend line
         m_platform.CreateFixedTrendLine(
            midpointName,
            lineStartTime, midpoint,
            lineEndTime, midpoint,
            m_midpointColor, STYLE_SOLID, 1,
            tooltip
         );
      }
   }
   
   // Create secondary Fibonacci visualization
   void CreateSecondaryFibonacci() {
      // Don't create if high/low points are outside current day when restriction is enabled
      if(!IsToday(m_strategyModel.GetHighPointTime()) || !IsToday(m_strategyModel.GetLowPointTime())) {
         return;
      }
      
      // Clear any existing secondary Fibonacci objects
      m_platform.DeleteAllObjects("Strategy_");
      
      // Get high/low points from strategy model
      double highPoint = m_strategyModel.GetHighPoint();
      double lowPoint = m_strategyModel.GetLowPoint();
      datetime highPointTime = m_strategyModel.GetHighPointTime();
      datetime lowPointTime = m_strategyModel.GetLowPointTime();
      
      // Create a line connecting the high and low points - using fixed trend line to prevent rays
      string connectionName = "Strategy_Connection";
      m_platform.CreateFixedTrendLine(
         connectionName, 
         highPointTime, highPoint, 
         lowPointTime, lowPoint,
         m_entryZoneColor, STYLE_DASH, 1,
         "High-Low Connection: " + DoubleToString(highPoint, m_platform.GetDigits()) + 
         " to " + DoubleToString(lowPoint, m_platform.GetDigits())
      );
      
      // Create marks at the high and low points
      // Platform-specific code for circle drawing handled in CreateFixedTrendLine
      
      // Draw the secondary Fibonacci levels
      for(int i = 0; i < m_fibModel.GetSecondaryFibCount(); i++) {
         double secFibLevel = m_fibModel.GetSecondaryFibLevel(i);
         double ratio = m_fibModel.GetSubFibRatio(i);
         
         // Always show 0%, 50%, 61.8% and 100% for the strategy
         if(i != 0 && i != 3 && i != 4 && i != 6) continue;
         
         // Create the horizontal line for this level
         string levelName = "Strategy_Level_" + DoubleToString(ratio * 100, 1);
         
         // Special highlighting for the 50-60% zone
         bool isEntryZone = (i == 3 || i == 4); // 50% or 61.8%
         
         // Use different line style for the entry zone
         ENUM_LINE_STYLE lineStyle = isEntryZone ? STYLE_SOLID : STYLE_DOT;
         
         // Create the level line
         CreateShorterHorizontalLine(levelName, secFibLevel, lineStyle, 
                                "Strategy " + DoubleToString(ratio * 100, 1) + "%: " + 
                                DoubleToString(secFibLevel, m_platform.GetDigits()),
                                true, m_entryZoneColor, true);
      }
      
      // Create a rectangle for the entry zone if highlighting is enabled
      if(m_highlightEntryZone) {
         // Note: Platform-specific code for rectangle drawing might be needed here
         // This is highly platform dependent and would need to be handled in the platform bridge
      }
   }
   
   // Update condition panel (simplified for now)
   void UpdateConditionPanel() {
      // Simplified implementation - to be expanded in a real-world scenario
      if(!m_showConditionPanel) {
         m_platform.DeleteAllObjects("Condition_Panel");
         m_platform.DeleteAllObjects("Condition_Title");
         m_platform.DeleteAllObjects("Condition_Status_");
         m_platform.DeleteAllObjects("Entry_Signal_Status");
         return;
      }
      
      // Basic implementation - could be expanded with full panel rendering
      Print("Condition panel update would happen here");
   }
   
   // Mark condition points on chart (simplified for now)
   void MarkConditionPoints(const datetime &time[], const double &close[]) {
      // Simplified implementation - to be expanded in a real-world scenario
      Print("Condition markers would be drawn here");
   }
   
   // Main drawing function - draw everything
   void DrawAll(const datetime &time[], const double &open[], const double &high[], 
               const double &low[], const double &close[], const int rates_total,
               int lookbackCandles) {
      // Update day boundaries
      UpdateDayBoundaries();
      
      // Clear previous drawings
      ClearAll();
      
      // Draw main Fibonacci levels
      DrawMainFibonacciLevels();
      
      // Draw sub-Fibonacci levels if enabled
      if(m_showSubFib && m_alwaysShowSubFib) {
         DrawSubFibonacciLevels();
      }
      
      // Draw candle midpoints
      if(m_drawCandleMidpoints) {
         int maxLines = MathMin(lookbackCandles, rates_total-1);
         DrawCandleMidpoints(time, open, close, maxLines);
      }
      
      // Draw strategy visualizations if conditions are met
      if(m_enableStrategyDetection) {
         // Check if Condition 3 is met (secondary Fibonacci)
         if(m_strategyModel.IsCondition3Met()) {
            CreateSecondaryFibonacci();
         }
         
         // Update condition panel
         UpdateConditionPanel();
         
         // Mark condition points
         MarkConditionPoints(time, close);
      }
   }
};