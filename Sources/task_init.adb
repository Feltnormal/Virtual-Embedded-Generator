with STM32F4.Reset_and_clock_control.Ops; pragma Unreferenced (STM32F4.Reset_and_clock_control.Ops);
with STM32F4.Random_number_generator.Ops; pragma Unreferenced (STM32F4.Random_number_generator.Ops);
with Discovery_Board.LED_Interface; pragma Unreferenced (Discovery_Board.LED_Interface);
with Discovery_Board; pragma Unreferenced (Discovery_Board);
with STM32F4.Timers.Ops; use STM32F4.Timers.Ops;

package body Task_Init is
   package RCC_Pkg renames STM32F4.Reset_and_clock_control.Ops;
   package RNG renames STM32F4.Random_number_generator.Ops;
   -- package DBL renames Discovery_Board.LED_Interface;
   package Tmr renames STM32F4.Timers.Ops;

   protected body Initializer is
      procedure Generate_Source is
      begin
         Source := Source + 1;
      end Generate_Source;

      procedure Generate_Id is
      begin
         Id := Id + 1;
      end Generate_Id;

      procedure Setup_Timers (Task_Id : Integer; Duty_Cycle_CNT : Bits_32) is
      begin
         if Task_Id = 1 and then not TIM2_Initialised then
            RCC_Pkg.Enable (No => 2); -- TIM2
            Tmr.Enable (No => 2);
            Tmr.Enable (No => 2, Int => Update);
            Tmr.Set_Prescaler (No => 2, Prescaler => 2); -- prescale clock to 42mHz
            Tmr.Set_Auto_Reload_32 (No => 2, Auto_Reload => Duty_Cycle_CNT); -- Sartup value which will need to osilliate in protected interrupt obj
            TIM2_Initialised := True;
         elsif Task_Id = 2 and then not TIM5_Initialised then
            RCC_Pkg.Enable (No => 5); -- TIM5
            Tmr.Enable (No => 5);
            Tmr.Enable (No => 5, Int => Update);
            Tmr.Set_Prescaler (No => 5, Prescaler => 2);
            Tmr.Set_Auto_Reload_32 (No => 5, Auto_Reload => Duty_Cycle_CNT);
            TIM5_Initialised := True;
         end if;
      end Setup_Timers;

      procedure Init_RNG is
      begin
         if not RNG_Initialised then
            RCC_Pkg.Enable (Device => RCC_Pkg.Random_number_generator);
            RNG.Random_Enable;
            RNG_Initialised := True;
         end if;
      end Init_RNG;

      function Get_Duty_Cycle_CNT return Bits_32 is (Default_CNT - (RNG.Random_Data mod Default_CNT)); -- NOT USED

      function Get_Source return Integer is (Source);
      function Get_Id return Integer is (Id);
   end Initializer;

end Task_Init;
