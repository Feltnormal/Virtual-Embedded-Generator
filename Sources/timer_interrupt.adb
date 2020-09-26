with Discovery_Board.LED_Interface;
with Discovery_Board; use Discovery_Board;
with STM32F4.Timers.Ops; use STM32F4.Timers.Ops;
with ANU_Base_Board;  use ANU_Base_Board;
with ANU_Base_Board.LED_Interface;
with ANU_Base_Board.Com_Interface; pragma Unreferenced (ANU_Base_Board.Com_Interface);

package body Timer_Interrupt is
   package DBL  renames Discovery_Board.LED_Interface;
   package ABBL renames ANU_Base_Board.LED_Interface;
   package Tmr renames STM32F4.Timers.Ops;
   package ABBC renames ANU_Base_Board.Com_Interface;

   protected body Tim2_Intr is

      function Get_TIM2_State return Boolean is (TIM2_State);

      procedure Set_DC (DC : Bits_32) is -- NOT USED
      begin
         TIM2_DC_HIGH := DC;
         TIM2_DC_LOW := Default_Rate - DC;
         Tmr.Generate (No => 2, This_Event => Update);
      end Set_DC;

      procedure TIM2_Interrupt_Handler is
      begin
         Clear_Flag (No => 2, This_Flag => Update);
         if TIM2_State then -- WHEN HIGH
            DBL.Off (Green);
            ABBL.Off ((1, R));
            ABBC.Reset (1);   -- Turn off COM Port 1
            TIM2_State := False;
            Tmr.Set_Auto_Reload_32 (No => 2, Auto_Reload => TIM2_DC_HIGH);
         else               -- WHEN LOW
            DBL.On (Green);
            ABBL.On ((1, R));
            ABBC.Set (1); -- Turn on COM Port 1
            TIM2_State := True;
            Tmr.Set_Auto_Reload_32 (No => 2, Auto_Reload => TIM2_DC_LOW);
         end if;
      end TIM2_Interrupt_Handler;
   end Tim2_Intr;

   protected body Tim5_Intr is

      function Get_TIM5_State return Boolean is (TIM5_State);

      procedure Set_DC (DC : Bits_32) is -- NOT USED
      begin
         TIM5_DC_HIGH := DC;
         TIM5_DC_LOW := Default_Rate - DC;
         Tmr.Generate (No => 5, This_Event => Update);
      end Set_DC;

      procedure TIM5_Interrupt_Handler is
      begin
         Clear_Flag (No => 5, This_Flag => Update);
         if TIM5_State then
            DBL.Off (Blue);
            ABBL.Off ((2, R));
            ABBC.Reset (2);   -- Turn off COM Port 2
            TIM5_State := False;
            Tmr.Set_Auto_Reload_32 (No => 5, Auto_Reload => TIM5_DC_HIGH);
         else
            DBL.On (Blue);
            ABBL.On ((2, R));
            ABBC.Set (2);   -- Turn on COM Port 2
            TIM5_State := True;
            Tmr.Set_Auto_Reload_32 (No => 5, Auto_Reload => TIM5_DC_LOW);
         end if;
      end TIM5_Interrupt_Handler;
   end Tim5_Intr;

end Timer_Interrupt;
