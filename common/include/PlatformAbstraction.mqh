//+------------------------------------------------------------------+
//|                      PlatformAbstraction.mqh                     |
//|                                                                   |
//|  Abstracts platform-specific functions between MT4 and MT5        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property version   "1.00"

// Determine platform
#ifdef __MQL5__
   #define IS_MT5 true
#else
   #define IS_MT5 false
#endif

// Class for handling platform-specific operations
class PlatformBridge {
private:
   bool m_isMT5;
   string m_symbol;
   ENUM_TIMEFRAMES m_timeframe;
   
public:
   // Constructor
   PlatformBridge(string symbol = NULL, ENUM_TIMEFRAMES timeframe = PERIOD_CURRENT) {
      m_isMT5 = IS_MT5;
      m_symbol = (symbol == NULL) ? Symbol() : symbol;
      m_timeframe = timeframe;
   }
   
   // Get platform type
   bool IsMT5() const {
      return m_isMT5;
   }
   
   // Get symbol
   string GetSymbol() const {
      return m_symbol;
   }
   
   // Get timeframe
   ENUM_TIMEFRAMES GetTimeframe() const {
      return m_timeframe;
   }
   
   // Set symbol and timeframe
   void SetSymbol(string symbol) {
      m_symbol = symbol;
   }
   
   void SetTimeframe(ENUM_TIMEFRAMES timeframe) {
      m_timeframe = timeframe;
   }
   
   // Time functions
   datetime GetBarTime(int shift) {
      #ifdef __MQL5__
         return iTime(m_symbol, m_timeframe, shift);
      #else
         return iTime(m_symbol, m_timeframe, shift);
      #endif
   }
   
   // Price data functions
   double GetOpen(int shift) {
      #ifdef __MQL5__
         return iOpen(m_symbol, m_timeframe, shift);
      #else
         return iOpen(m_symbol, m_timeframe, shift);
      #endif
   }
   
   double GetClose(int shift) {
      #ifdef __MQL5__
         return iClose(m_symbol, m_timeframe, shift);
      #else
         return iClose(m_symbol, m_timeframe, shift);
      #endif
   }
   
   double GetHigh(int shift) {
      #ifdef __MQL5__
         return iHigh(m_symbol, m_timeframe, shift);
      #else
         return iHigh(m_symbol, m_timeframe, shift);
      #endif
   }
   
   double GetLow(int shift) {
      #ifdef __MQL5__
         return iLow(m_symbol, m_timeframe, shift);
      #else
         return iLow(m_symbol, m_timeframe, shift);
      #endif
   }
   
   // Drawing functions that differ between platforms
   bool CreateLine(string name, datetime time1, double price1, datetime time2, double price2, 
                  color clr, ENUM_LINE_STYLE style, int width) {
      #ifdef __MQL5__
         return ObjectCreate(0, name, OBJ_TREND, 0, time1, price1, time2, price2) &&
                ObjectSetInteger(0, name, OBJPROP_COLOR, clr) &&
                ObjectSetInteger(0, name, OBJPROP_STYLE, style) &&
                ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
      #else
         return ObjectCreate(name, OBJ_TREND, 0, time1, price1, time2, price2) &&
                ObjectSet(name, OBJPROP_COLOR, clr) &&
                ObjectSet(name, OBJPROP_STYLE, style) &&
                ObjectSet(name, OBJPROP_WIDTH, width);
      #endif
   }
   
   // Create a fixed-length trend line (no rays)
   bool CreateFixedTrendLine(string name, datetime time1, double price1, 
                           datetime time2, double price2, color clr, 
                           ENUM_LINE_STYLE style, int width, string tooltipText = "") {
      bool result = false;
      
      #ifdef __MQL5__
         result = ObjectCreate(0, name, OBJ_TREND, 0, time1, price1, time2, price2);
         if(result) {
            ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
            ObjectSetInteger(0, name, OBJPROP_STYLE, style);
            ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
            // Critical settings to prevent rays
            ObjectSetInteger(0, name, OBJPROP_RAY_LEFT, false);
            ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, false);
            
            // Set tooltip if provided
            if(tooltipText != "") {
               ObjectSetString(0, name, OBJPROP_TOOLTIP, tooltipText);
            }
         }
      #else
         result = ObjectCreate(name, OBJ_TREND, 0, time1, price1, time2, price2);
         if(result) {
            ObjectSet(name, OBJPROP_COLOR, clr);
            ObjectSet(name, OBJPROP_STYLE, style);
            ObjectSet(name, OBJPROP_WIDTH, width);
            // Critical settings to prevent rays
            ObjectSet(name, OBJPROP_RAY_LEFT, false);
            ObjectSet(name, OBJPROP_RAY_RIGHT, false);
            
            // In MT4, use object description for tooltip
            if(tooltipText != "") {
               ObjectSetText(name, tooltipText, 8, "Arial", clr);
            }
         }
      #endif
      
      return result;
   }
   
   bool CreateText(string name, datetime time, double price, string text, color clr, int fontSize) {
      #ifdef __MQL5__
         return ObjectCreate(0, name, OBJ_TEXT, 0, time, price) &&
                ObjectSetString(0, name, OBJPROP_TEXT, text) &&
                ObjectSetInteger(0, name, OBJPROP_COLOR, clr) &&
                ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
      #else
         return ObjectCreate(name, OBJ_TEXT, 0, time, price) &&
                ObjectSetText(name, text, fontSize, "Arial", clr);
      #endif
   }
   
   bool CreateRectangleLabel(string name, int corner, int x, int y, int width, int height, color bgColor, color borderColor) {
      #ifdef __MQL5__
         return ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0) &&
                ObjectSetInteger(0, name, OBJPROP_CORNER, corner) &&
                ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x) &&
                ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y) &&
                ObjectSetInteger(0, name, OBJPROP_XSIZE, width) &&
                ObjectSetInteger(0, name, OBJPROP_YSIZE, height) &&
                ObjectSetInteger(0, name, OBJPROP_BGCOLOR, bgColor) &&
                ObjectSetInteger(0, name, OBJPROP_COLOR, borderColor);
      #else
         // In MT4, we'll use OBJ_RECTANGLE as a fallback
         return ObjectCreate(name, OBJ_RECTANGLE, 0, 
                             Time[0], 0, 
                             Time[0] + width*Point, height*Point) &&
                ObjectSet(name, OBJPROP_COLOR, borderColor) &&
                ObjectSet(name, OBJPROP_BACK, true);
      #endif
   }
   
   bool DeleteObject(string name) {
      #ifdef __MQL5__
         return ObjectDelete(0, name);
      #else
         return ObjectDelete(name);
      #endif
   }
   
   //+------------------------------------------------------------------+
   //| Delete all objects with a specific prefix                         |
   //+------------------------------------------------------------------+
   void DeleteAllObjects(string prefix) {
      #ifdef __MQL5__
         // MT5 version can delete by prefix
         ObjectsDeleteAll(0, prefix);
      #else
         // MT4 version needs more thorough cleanup
         ObjectsDeleteAll(0, -1, -1, prefix);
         
         // Also try with specific object types
         ObjectsDeleteAll(0, OBJ_TREND, -1, prefix);
         ObjectsDeleteAll(0, OBJ_TEXT, -1, prefix);
         ObjectsDeleteAll(0, OBJ_LABEL, -1, prefix);
         ObjectsDeleteAll(0, OBJ_RECTANGLE, -1, prefix);
         ObjectsDeleteAll(0, OBJ_ARROW, -1, prefix);
         ObjectsDeleteAll(0, OBJ_VLINE, -1, prefix);
         ObjectsDeleteAll(0, OBJ_HLINE, -1, prefix);
      #endif
   }
   
   //+------------------------------------------------------------------+
   //| Clean up all indicator objects from chart                         |
   //+------------------------------------------------------------------+
   void CleanupAllObjects() {
      // List of all prefixes used by the indicator
      string prefixes[] = {
         "PrevDay_", "SubFib_", "Label_", "MidPoint_", 
         "Strategy_", "Entry_", "Condition_", "CondMarker_"
      };
      
      // Delete each prefix
      for(int i = 0; i < ArraySize(prefixes); i++) {
         DeleteAllObjects(prefixes[i]);
      }
      
      #ifdef __MQL5__
         // In MT5, a final cleanup with no prefix to catch any stragglers
         ObjectsDeleteAll(0, "", -1, -1);
      #else
         // In MT4, make absolutely sure everything is gone
         ObjectsDeleteAll();
      #endif
   }
   
   // Convert a timeframe to seconds (implementation differs between platforms)
   int TimeframeToSeconds(ENUM_TIMEFRAMES tf) {
      #ifdef __MQL5__
         return PeriodSeconds(tf);
      #else
         // Manual conversion for MT4
         switch(tf) {
            case PERIOD_M1: return 60;
            case PERIOD_M5: return 300;
            case PERIOD_M15: return 900;
            case PERIOD_M30: return 1800;
            case PERIOD_H1: return 3600;
            case PERIOD_H4: return 14400;
            case PERIOD_D1: return 86400;
            case PERIOD_W1: return 604800;
            case PERIOD_MN1: return 2592000;
            default: return 60;
         }
      #endif
   }
   
   // Get the number of digits for the current symbol
   int GetDigits() {
      #ifdef __MQL5__
         return (int)SymbolInfoInteger(m_symbol, SYMBOL_DIGITS);
      #else
         return Digits;
      #endif
   }
   
   // Find the bar index by time
   int GetBarShift(datetime time) {
      #ifdef __MQL5__
         return iBarShift(m_symbol, m_timeframe, time);
      #else
         return iBarShift(m_symbol, m_timeframe, time);
      #endif
   }
};