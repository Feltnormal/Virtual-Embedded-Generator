with STM32F4; use STM32F4;
with System; use System;
package Task_Init is

   protected type Initializer with Priority => Priority'Last is
      procedure Generate_Id;
      procedure Generate_Source;
      procedure Setup_Timers (Task_Id : Integer; Duty_Cycle_CNT : Bits_32);
      procedure Init_RNG;
      function Get_Duty_Cycle_CNT return Bits_32;
      function Get_Source return Integer;
      function Get_Id return Integer;
   private
      Default_CNT : Bits_32 := 420_000; -- For a half period
      Source : Integer := 0;
      Id : Integer := 0;
      RNG_Initialised, TIM2_Initialised, TIM5_Initialised : Boolean := False;
   end Initializer;

   Init : Initializer;

end Task_Init;
