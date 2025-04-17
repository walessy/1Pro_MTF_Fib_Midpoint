//+------------------------------------------------------------------+
//|                      FibonacciModel.mqh                          |
//|                                                                   |
//|  Core class for Fibonacci calculations and levels                 |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property version   "1.00"

// Class for handling Fibonacci calculations and levels
class FibonacciModel {
private:
   double m_prevDayHigh;        // Previous day's high
   double m_prevDayLow;         // Previous day's low
   bool m_prevDayBullish;       // Was previous day bullish?
   
   double m_primaryFibLevels[9]; // Main Fibonacci levels
   double m_subFibLevels[7];     // Sub-Fibonacci levels
   
   double m_startPoint;         // Custom start point (0-1)
   double m_endPoint;           // Custom end point (0-1)
   
   double m_secondaryFibLevels[7]; // Secondary Fibonacci levels
   
   // Initialize the standard Fibonacci arrays
   void InitializeFibLevels() {
      // Main Fibonacci levels
      m_primaryFibLevels[0] = 0.0;
      m_primaryFibLevels[1] = 0.236;
      m_primaryFibLevels[2] = 0.382;
      m_primaryFibLevels[3] = 0.5;
      m_primaryFibLevels[4] = 0.618;
      m_primaryFibLevels[5] = 0.764;
      m_primaryFibLevels[6] = 1.0;
      m_primaryFibLevels[7] = 1.618;
      m_primaryFibLevels[8] = 2.618;
      
      // Sub-Fibonacci levels
      m_subFibLevels[0] = 0.0;
      m_subFibLevels[1] = 0.236;
      m_subFibLevels[2] = 0.382;
      m_subFibLevels[3] = 0.5;
      m_subFibLevels[4] = 0.618;
      m_subFibLevels[5] = 0.764;
      m_subFibLevels[6] = 1.0;
   }
   
public:
   // Constructor
   FibonacciModel(double startPoint = 0.5, double endPoint = 0.618) {
      m_prevDayHigh = 0;
      m_prevDayLow = 0;
      m_prevDayBullish = false;
      
      m_startPoint = MathMax(0, MathMin(1, startPoint)); // Ensure between 0-1
      m_endPoint = MathMax(0, MathMin(1, endPoint));     // Ensure between 0-1
      
      InitializeFibLevels();
      
      ArrayInitialize(m_secondaryFibLevels, 0.0);
   }
   
   // Set previous day's data
   void SetPrevDayData(double high, double low, double open, double close) {
      m_prevDayHigh = high;
      m_prevDayLow = low;
      m_prevDayBullish = (close > open);
   }
   
   // Get previous day's data
   double GetPrevDayHigh() const { return m_prevDayHigh; }
   double GetPrevDayLow() const { return m_prevDayLow; }
   bool IsPrevDayBullish() const { return m_prevDayBullish; }
   
   // Set custom points for sub-Fibonacci
   void SetCustomPoints(double startPoint, double endPoint) {
      m_startPoint = MathMax(0, MathMin(1, startPoint));
      m_endPoint = MathMax(0, MathMin(1, endPoint));
   }
   
   // Calculate a specific Fibonacci level based on previous day data
   double CalculateFibLevel(double fibRatio) const {
      double startPoint, endPoint;
      
      if(m_prevDayBullish) {
         // In bullish days, 0% is at the low, 100% at the high
         startPoint = m_prevDayLow;   // 0% level
         endPoint = m_prevDayHigh;    // 100% level
      } else {
         // In bearish days, 0% is at the high, 100% at the low
         startPoint = m_prevDayHigh;  // 0% level
         endPoint = m_prevDayLow;     // 100% level
      }
      
      return startPoint + (endPoint - startPoint) * fibRatio;
   }
   
   // Get a primary Fibonacci level by index
   double GetPrimaryFibLevel(int index) const {
      if(index >= 0 && index < ArraySize(m_primaryFibLevels)) {
         return CalculateFibLevel(m_primaryFibLevels[index]);
      }
      return 0;
   }
   
   // Get a primary Fibonacci ratio by index
   double GetPrimaryFibRatio(int index) const {
      if(index >= 0 && index < ArraySize(m_primaryFibLevels)) {
         return m_primaryFibLevels[index];
      }
      return 0;
   }
   
   // Get a sub-Fibonacci level
   double GetSubFibLevel(int index) const {
      if(index < 0 || index >= ArraySize(m_subFibLevels)) return 0;
      
      // Calculate the sub-fib range
      double startLevelPrice = CalculateFibLevel(m_startPoint);
      double endLevelPrice = CalculateFibLevel(m_endPoint);
      
      // Apply the sub-fib ratio to this range
      return startLevelPrice + (endLevelPrice - startLevelPrice) * m_subFibLevels[index];
   }
   
   // Get a sub-Fibonacci ratio by index
   double GetSubFibRatio(int index) const {
      if(index >= 0 && index < ArraySize(m_subFibLevels)) {
         return m_subFibLevels[index];
      }
      return 0;
   }
   
   // Calculate secondary Fibonacci levels between two points
   void CalculateSecondaryFibLevels(double highPoint, double lowPoint) {
      // Determine the range direction based on previous day trend
      double secStartPoint, secEndPoint;
      
      if(m_prevDayBullish) {
         // In bullish trend, the secondary Fibonacci is from low to high
         secStartPoint = lowPoint;
         secEndPoint = highPoint;
      } else {
         // In bearish trend, the secondary Fibonacci is from high to low
         secStartPoint = highPoint;
         secEndPoint = lowPoint;
      }
      
      // Calculate all the level prices for the secondary Fibonacci
      for(int i = 0; i < ArraySize(m_subFibLevels); i++) {
         m_secondaryFibLevels[i] = secStartPoint + (secEndPoint - secStartPoint) * m_subFibLevels[i];
      }
   }
   
   // Get a secondary Fibonacci level
   double GetSecondaryFibLevel(int index) const {
      if(index >= 0 && index < ArraySize(m_secondaryFibLevels)) {
         return m_secondaryFibLevels[index];
      }
      return 0;
   }
   
   // Get array sizes for iterations
   int GetPrimaryFibCount() const { return ArraySize(m_primaryFibLevels); }
   int GetSubFibCount() const { return ArraySize(m_subFibLevels); }
   int GetSecondaryFibCount() const { return ArraySize(m_secondaryFibLevels); }
   
   // Helper methods to get zone boundaries
   double GetLowerZone(double lowerLimit) const {
      return CalculateFibLevel(lowerLimit);
   }
   
   double GetUpperZone(double upperLimit) const {
      return CalculateFibLevel(upperLimit);
   }
};