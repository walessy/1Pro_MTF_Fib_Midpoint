//+------------------------------------------------------------------+
//|                      FibDayStrategy.mqh                           |
//|                                                                   |
//|  Main indicator class that brings everything together             |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property version   "1.00"

// Include all necessary files
#include "PlatformAbstraction.mqh"
#include "FibonacciModel.mqh"
#include "StrategyModel.mqh"
#include "DrawingService.mqh"

// Main indicator class
class FibDayStrategy {
private:
   // Core components
   PlatformBridge *m_platform;
   FibonacciModel *m_fibModel;
   StrategyModel *m_strategyModel;
   DrawingService *m_drawingService;
   
   // Tracking variables
   datetime m_prevDayTime;
   string m_currentSymbol;
   ENUM_TIMEFRAMES m_currentTimeframe;
   int m_lookbackCandles;
   bool m_restrictToCurrentDay;
   
   // Internal flags
   bool m_ownsPlatform;
   bool m_ownsFibModel;
   bool m_ownsStrategyModel;
   bool m_ownsDrawingService;
   
public:
   // Constructor
   FibDayStrategy(PlatformBridge *platform = NULL, 
                 FibonacciModel *fibModel = NULL,
                 StrategyModel *strategyModel = NULL,
                 DrawingService *drawingService = NULL) {
      // Create or use provided components
      if(platform == NULL) {
         m_platform = new PlatformBridge();
         m_ownsPlatform = true;
      } else {
         m_platform = platform;
         m_ownsPlatform = false;
      }
      
      if(fibModel == NULL) {
         m_fibModel = new FibonacciModel();
         m_ownsFibModel = true;
      } else {
         m_fibModel = fibModel;
         m_ownsFibModel = false;
      }
      
      if(strategyModel == NULL) {
         m_strategyModel = new StrategyModel(m_fibModel);
         m_ownsStrategyModel = true;
      } else {
         m_strategyModel = strategyModel;
         m_ownsStrategyModel = false;
      }
      
      if(drawingService == NULL) {
         m_drawingService = new DrawingService(m_platform, m_fibModel, m_strategyModel);
         m_ownsDrawingService = true;
      } else {
         m_drawingService = drawingService;
         m_ownsDrawingService = false;
      }
      
      // Initialize tracking variables
      m_prevDayTime = 0;
      m_currentSymbol = "";
      m_currentTimeframe = PERIOD_CURRENT;
      m_lookbackCandles = 100;
      m_restrictToCurrentDay = true;
   }
   
   // Destructor - clean up owned components
   ~FibDayStrategy() {
      if(m_ownsPlatform && m_platform != NULL) {
         delete m_platform;
      }
      
      if(m_ownsFibModel && m_fibModel != NULL) {
         delete m_fibModel;
      }
      
      if(m_ownsStrategyModel && m_strategyModel != NULL) {
         delete m_strategyModel;
      }
      
      if(m_ownsDrawingService && m_drawingService != NULL) {
         delete m_drawingService;
      }
   }
   
   // Set lookback period for strategy detection
   void SetLookbackCandles(int candles) {
      m_lookbackCandles = MathMax(10, candles); // Minimum of 10 candles
   }
   
   // Set whether to restrict visualizations to current day
   void SetRestrictToCurrentDay(bool restrict) {
      m_restrictToCurrentDay = restrict;
   }
   
   // Get access to internal components for configuration
   FibonacciModel* GetFibonacciModel() { return m_fibModel; }
   StrategyModel* GetStrategyModel() { return m_strategyModel; }
   DrawingService* GetDrawingService() { return m_drawingService; }
   PlatformBridge* GetPlatformBridge() { return m_platform; }
   
   // Check if any strategy conditions are met
   bool IsCondition1Met() { 
      return m_strategyModel.IsCondition1Met(); 
   }
   
   bool IsCondition2Met() { 
      return m_strategyModel.IsCondition2Met(); 
   }
   
   bool IsCondition3Met() { 
      return m_strategyModel.IsCondition3Met(); 
   }
   
   bool IsCondition4Met() { 
      return m_strategyModel.IsCondition4Met(); 
   }
   
   bool IsEntrySignal() { 
      return m_strategyModel.IsEntrySignal(); 
   }
   
   // Main update method - called on each new tick/bar
   void OnCalculate(const int rates_total,
                   const int prev_calculated,
                   const datetime &time[],
                   const double &open[],
                   const double &high[],
                   const double &low[],
                   const double &close[]) {
      // Check if timeframe has changed - force redraw if needed
      if(m_currentTimeframe != m_platform.GetTimeframe()) {
         m_currentTimeframe = m_platform.GetTimeframe();
         m_prevDayTime = 0; // Force redraw
         m_strategyModel.ResetState();
         Print("Timeframe changed - resetting indicator");
      }
      
      // Check if we need to update previous day's data
      datetime currentDay = m_platform.GetBarTime(0);
      string symbol = m_platform.GetSymbol();
      
      // Force redraw if symbol has changed or day has changed
      if(m_prevDayTime != currentDay || m_currentSymbol != symbol) {
         // Reset strategy state
         m_strategyModel.ResetState();
         
         // Update current symbol
         m_currentSymbol = symbol;
         
         // Get yesterday's OHLC data
         double yesterdayOpen = m_platform.GetOpen(1);
         double yesterdayHigh = m_platform.GetHigh(1);
         double yesterdayLow = m_platform.GetLow(1);
         double yesterdayClose = m_platform.GetClose(1);
         
         // Update Fibonacci model with yesterday's data
         m_fibModel.SetPrevDayData(yesterdayHigh, yesterdayLow, yesterdayOpen, yesterdayClose);
         
         // Update timestamp
         m_prevDayTime = currentDay;
         
         // Clear all drawings before redrawing
         m_drawingService.ClearAll();
      }
      
      // Apply strategy detection logic if enabled and we have enough data
      if(rates_total > m_lookbackCandles) {
         // Check for strategy conditions
         m_strategyModel.CheckStrategyCriteria(time, open, high, low, close, rates_total, false);
         
         // Draw everything
         m_drawingService.DrawAll(time, open, high, low, close, rates_total, m_lookbackCandles);
      }
   }
   
   // Handle chart events
   void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam) {
      // Store the current symbol
      static string lastSymbol = m_platform.GetSymbol();
      
      // For any chart event, check if the symbol has changed
      string currentSymbolName = m_platform.GetSymbol();
      if(currentSymbolName != lastSymbol) {
         Print("Symbol changed from ", lastSymbol, " to ", currentSymbolName, " - forcing redraw");
         lastSymbol = currentSymbolName;
         
         // Reset to force redraw
         m_prevDayTime = 0;
         m_strategyModel.ResetState();
         m_currentSymbol = currentSymbolName;
      }
   }
};