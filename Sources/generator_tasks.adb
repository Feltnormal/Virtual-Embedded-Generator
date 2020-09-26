with ANU_Base_Board.Com_Interface; pragma Unreferenced (ANU_Base_Board.Com_Interface);
with ANU_Base_Board; use ANU_Base_Board;
with ANU_Base_Board.LED_Interface;  pragma Unreferenced (ANU_Base_Board.LED_Interface);
with Task_Init; use Task_Init;
with Ada.Real_Time; use Ada.Real_Time;
with STM32F4; use STM32F4;
with Timer_Interrupt; pragma Unreferenced (Timer_Interrupt);
with STM32F4.Timers.Ops; use STM32F4.Timers.Ops;
package body Generator_Tasks is
   package ABBC renames ANU_Base_Board.Com_Interface;
   package ABBL renames ANU_Base_Board.LED_Interface;
   package Tmr renames STM32F4.Timers.Ops;

   task body G_task is
      Task_Id : Integer;
      Leader_Flag : Boolean := False;
      Specified_Source : Com_Ports; -- Specify which Com port to transmit signal
      Local_Duty_Cycle_CNT : Bits_32;
      System_Startup : constant Time := Clock;
      Curr_Time : Time := System_Startup;
      Offset  : constant Time_Span := Milliseconds (0);
      Previous_Read_Value_T2 : Bit := 0;
      Previous_Read_Value_T5 : Bit := 0;

      -- TIM2_Periodic Check Variables
      Period_Start_Flag_T2 : Boolean := False;
      Period_Half_Flag_T2 : Boolean := False; -- When falling edge of within one period of incoming signal is processed
      Period_End_Flag_T2 : Boolean := False; -- When one period of incoming signal is processed
      Period_Start_T2 : Time := Clock; -- Dynamically changed
      Period_Half_T2 : Time := Clock;
      Pd_T2 : Time_Span;

      -- TIM5_Periodic Check Variables
      Period_Start_Flag_T5 : Boolean := False;
      Period_Half_Flag_T5 : Boolean := False; -- When falling edge of within one period of incoming signal is processed
      Period_End_Flag_T5 : Boolean := False; -- When one period of incoming signal is processed
      Period_Start_T5 : Time := Clock; -- Dynamically changed
      Period_Half_T5 : Time := Clock;
      Pd_T5 : Time_Span;

   begin
      Init.Generate_Source;
      Init.Generate_Id;
      Specified_Source := Com_Ports (Init.Get_Source);
      Task_Id := Init.Get_Id;
      Init.Init_RNG;
      Local_Duty_Cycle_CNT := Init.Get_Duty_Cycle_CNT;
      Init.Setup_Timers (Task_Id => Task_Id, Duty_Cycle_CNT => Local_Duty_Cycle_CNT);
      ABBL.On ((Specified_Source, L));

      Curr_Time := Curr_Time + Offset;
      delay until Curr_Time; -- Allow other tasks to spawn

      loop
         -- Election Algorithm (all nodes will have to continuously check this in case leader changes)
         -- TIM2 => Port_1, TIM5 => Port_2
         -- Both Timers need to be examined in order for consensus
         if ABBC.Read (1) = 1 then -- Begin timing on a rising edge
            if not Period_End_Flag_T2 and then not Period_Start_Flag_T2 then
               Period_Start_T2 := Clock; -- Start timing start of a full period
               Period_Start_Flag_T2 := True;
            elsif not Leader_Flag and then Period_Half_Flag_T2 then -- Full period detected
               Period_End_Flag_T2 := True; -- Anticipate next rising edge
            end if;
            Previous_Read_Value_T2 := 1;
         else
            if not Period_Half_Flag_T2 then
               Period_Half_T2 := Clock;
               Pd_T2 := Period_Half_T2 - Period_Start_T2;
               Period_Half_Flag_T2 := True;
            end if;
            Previous_Read_Value_T2 := 0;
         end if;

         if ABBC.Read (2) = 1 then -- Begin timing on a rising edge
            if not Period_End_Flag_T5 and then not Period_Start_Flag_T5 then
               Period_Start_T5 := Clock; -- Start timing start of a full period
               Period_Start_Flag_T5 := True;
            elsif not Leader_Flag and then Period_Half_Flag_T5 then -- Full period detected
               Period_End_Flag_T5 := True; -- Anticipate next rising edge
            end if;
            Previous_Read_Value_T5 := 1;
         else
            if not Period_Half_Flag_T5 then
               Period_Half_T5 := Clock;
               Pd_T5 := Period_Half_T5 - Period_Start_T5;
               Period_Half_Flag_T5 := True;
            end if;
            Previous_Read_Value_T5 := 0;
         end if;

         if Period_End_Flag_T2 and then Period_End_Flag_T5 then -- Compare Duty Cycles
            if Pd_T2 > Pd_T5 then
               if Leader_Flag then -- demote leader flag if task_id = 2
                  Leader_Flag := False;
               end if;

               if Task_Id = 1 then -- Task 1 is the leader
                  Leader_Flag := True;
               end if;
            else
               if Leader_Flag then -- demote leader flag if task_id = 1
                  Leader_Flag := False;
               end if;

               if Task_Id = 2 then -- Task 2 is the leader
                  Leader_Flag := True;
               end if;
            end if;
            -- Reset flags
            Period_Start_Flag_T2 := False;
            Period_Half_Flag_T2 := False;
            Period_End_Flag_T2 := False;
            Period_Start_Flag_T5 := False;
            Period_Half_Flag_T5 := False;
            Period_End_Flag_T5 := False;
         end if;

         if not Leader_Flag then
            -- Start adjusting phase via interrupt (introduces initial instability until leader is elected)
            if Task_Id = 1 and then not (ABBC.Read (1) = Previous_Read_Value_T2) then
               Tmr.Generate (No => 2, This_Event => Update);
               Previous_Read_Value_T2 := Previous_Read_Value_T2 + 1;
            elsif Task_Id = 2 and then not (ABBC.Read (2) = Previous_Read_Value_T5) then
               Tmr.Generate (No => 5, This_Event => Update);
               Previous_Read_Value_T5 := Previous_Read_Value_T5 + 1;
            end if;
         end if;

         Curr_Time := Curr_Time + Milliseconds (1);
         delay until Curr_Time; -- If you're the leader then do nothing
      end loop;

   end G_task;

end Generator_Tasks;
