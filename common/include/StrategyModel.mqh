//+------------------------------------------------------------------+
//|                      StrategyModel.mqh                           |
//|                                                                   |
//|  Core class for Fibonacci strategy detection                      |
//+------------------------------------------------------------------+
#property copyright "Copyright 2025"
#property version   "1.00"

#include "FibonacciModel.mqh"

// Class for handling strategy detection logic
class StrategyModel {
private:
   FibonacciModel *m_fibModel;  // Fibonacci model for calculations
   
   // Strategy state variables
   bool m_condition1Met;
   bool m_condition2Met;
   bool m_condition3Met;
   bool m_condition4Met;
   bool m_entrySignal;
   
   // Strategy parameters
   double m_lowerZoneLimit;     // Lower zone boundary (default 50%)
   double m_upperZoneLimit;     // Upper zone boundary (default 61.8%)
   
   // Data for strategy detection
   double m_highPoint;          // High point for secondary Fibonacci
   double m_lowPoint;           // Low point for secondary Fibonacci
   datetime m_highPointTime;    // Time of high point
   datetime m_lowPointTime;     // Time of low point
   
   // Ownership flag for internal Fibonacci model
   bool m_ownsFibModel;
   
public:
   // Constructor
   StrategyModel(FibonacciModel *fibModel = NULL, 
                double lowerZoneLimit = 0.5, 
                double upperZoneLimit = 0.618) {
      // Create or use provided Fibonacci model
      if(fibModel == NULL) {
         m_fibModel = new FibonacciModel();
         m_ownsFibModel = true;
      } else {
         m_fibModel = fibModel;
         m_ownsFibModel = false;
      }
      
      // Set zone limits
      m_lowerZoneLimit = MathMax(0, MathMin(1, lowerZoneLimit));
      m_upperZoneLimit = MathMax(0, MathMin(1, upperZoneLimit));
      
      // Initialize state
      ResetState();
   }
   
   // Destructor
   ~StrategyModel() {
      if(m_ownsFibModel && m_fibModel != NULL) {
         delete m_fibModel;
      }
   }
   
   // Reset the strategy state
   void ResetState() {
      m_condition1Met = false;
      m_condition2Met = false;
      m_condition3Met = false;
      m_condition4Met = false;
      m_entrySignal = false;
      m_highPoint = 0.0;
      m_lowPoint = 0.0;
      m_highPointTime = 0;
      m_lowPointTime = 0;
   }
   
   // Set zone limits
   void SetZoneLimits(double lowerLimit, double upperLimit) {
      m_lowerZoneLimit = MathMax(0, MathMin(1, lowerLimit));
      m_upperZoneLimit = MathMax(0, MathMin(1, upperLimit));
   }
   
   // Get current state
   bool IsCondition1Met() const { return m_condition1Met; }
   bool IsCondition2Met() const { return m_condition2Met; }
   bool IsCondition3Met() const { return m_condition3Met; }
   bool IsCondition4Met() const { return m_condition4Met; }
   bool IsEntrySignal() const { return m_entrySignal; }
   
   // Get strategy points
   double GetHighPoint() const { return m_highPoint; }
   double GetLowPoint() const { return m_lowPoint; }
   datetime GetHighPointTime() const { return m_highPointTime; }
   datetime GetLowPointTime() const { return m_lowPointTime; }
   
   // Get Fibonacci model
   FibonacciModel *GetFibonacciModel() const { return m_fibModel; }
   
   // Check strategy criteria
   void CheckStrategyCriteria(const datetime &time[], 
                            const double &open[], 
                            const double &high[], 
                            const double &low[], 
                            const double &close[], 
                            const int rates_total,
                            bool verbose=false) {
      // Reset strategy state before checking conditions
      ResetState();
      
      // Calculate zone boundaries
      double lowerZone = m_fibModel.GetLowerZone(m_lowerZoneLimit);
      double upperZone = m_fibModel.GetUpperZone(m_upperZoneLimit);
      
      // Track the state for Condition 2
      bool belowLowerZone = false;
      bool aboveUpperZone = false;
      bool backBelowLowerZone = false;
      
      // Arrays to store price zone location
      bool inZone[50];       // Is price in the target zone?
      bool aboveZone[50];    // Is price above the zone?
      bool belowZone[50];    // Is price below the zone?
      
      // Ensure our arrays are large enough
      int maxBars = MathMin(50, rates_total);
      
      // Analyze recent candles
      for(int i = maxBars-1; i >= 0; i--) {
         // Calculate the midpoint of each candle body
         double midpoint = (open[i] + close[i]) / 2.0;
         
         // Check if midpoint is in the target zone (50-60%)
         inZone[i] = (midpoint >= lowerZone && midpoint <= upperZone);
         aboveZone[i] = (midpoint > upperZone);
         belowZone[i] = (midpoint < lowerZone);
         
         // Check Condition 1: Price returns to 50-60% zone
         if(inZone[i] && !m_condition1Met) {
            m_condition1Met = true;
            if(verbose) Print("Condition 1 Met: Price returned to ", DoubleToString(m_lowerZoneLimit*100,1), 
                     "-", DoubleToString(m_upperZoneLimit*100,1), "% zone at bar ", i);
         }
         
         // Track zone transitions for Condition 2
         if(belowZone[i] && !belowLowerZone && !backBelowLowerZone) {
            belowLowerZone = true;
            if(verbose) Print("First below zone detected at bar ", i);
         }
         else if(aboveZone[i] && belowLowerZone && !aboveUpperZone && !backBelowLowerZone) {
            aboveUpperZone = true;
            if(verbose) Print("Above upper zone detected at bar ", i);
            
            // Store the high point for Condition 3
            if(midpoint > m_highPoint || m_highPoint == 0) {
               m_highPoint = midpoint;
               m_highPointTime = time[i];
            }
         }
         else if(belowZone[i] && belowLowerZone && aboveUpperZone && !backBelowLowerZone) {
            backBelowLowerZone = true;
            if(verbose) Print("Second below zone detected at bar ", i);
            
            // Store the low point for Condition 3
            if(midpoint < m_lowPoint || m_lowPoint == 0) {
               m_lowPoint = midpoint;
               m_lowPointTime = time[i];
            }
         }
      }
      
      // Check if Condition 2 is met (all three transitions occurred)
      if(belowLowerZone && aboveUpperZone && backBelowLowerZone && !m_condition2Met) {
         m_condition2Met = true;
         if(verbose) Print("Condition 2 Met: Price made the required zone transitions");
         
         // Now Condition 3 can be met - we have high and low points
         if(m_highPoint > 0 && m_lowPoint > 0 && m_highPointTime > 0 && m_lowPointTime > 0) {
            m_condition3Met = true;
            if(verbose) Print("Condition 3 Met: Secondary Fibonacci points identified");
            
            // Calculate secondary Fibonacci levels for Condition 4
            m_fibModel.CalculateSecondaryFibLevels(m_highPoint, m_lowPoint);
         }
      }
      
      // Check Condition 4: Price returns to 50-60% of the second Fibonacci
      if(m_condition3Met && !m_condition4Met) {
         // Get 50% and 61.8% levels from secondary Fibonacci
         double secLowerZone = m_fibModel.GetSecondaryFibLevel(3); // 50%
         double secUpperZone = m_fibModel.GetSecondaryFibLevel(4); // 61.8%
         
         // Ensure we have the levels in the correct order
         if(secLowerZone > secUpperZone) {
            double temp = secLowerZone;
            secLowerZone = secUpperZone;
            secUpperZone = temp;
         }
         
         // Check if current candle's midpoint is in the secondary zone
         double currentMidpoint = (open[0] + close[0]) / 2.0;
         
         if(currentMidpoint >= secLowerZone && currentMidpoint <= secUpperZone) {
            m_condition4Met = true;
            m_entrySignal = true;
            if(verbose) Print("Condition 4 Met: Price returned to secondary 50-61.8% zone");
         }
      }
   }
};