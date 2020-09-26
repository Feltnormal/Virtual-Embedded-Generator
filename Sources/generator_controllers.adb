--
-- Uwe R. Zimmer, Australia 2015
--

with Ada.Real_Time;                       use Ada.Real_Time;
with ANU_Base_Board;                      use ANU_Base_Board;
with ANU_Base_Board.Com_Interface;        use ANU_Base_Board.Com_Interface;
with ANU_Base_Board.LED_Interface;        use ANU_Base_Board.LED_Interface;
with Discovery_Board;                     use Discovery_Board;
with Discovery_Board.Button;              use Discovery_Board.Button;
with Discovery_Board.LED_Interface;       use Discovery_Board.LED_Interface;
with STM32F4;                             use type STM32F4.Bit, STM32F4.Bits_32;
with STM32F4.Random_number_generator.Ops; use STM32F4.Random_number_generator.Ops;
with STM32F4.Reset_and_clock_control.Ops; use STM32F4.Reset_and_clock_control.Ops;
with System;                              use System;

package body Generator_Controllers is

   System_Start : constant Time := Clock;

   type Cycle      is mod 4;
   type Meta_Cycle is mod 24;

   Pattern : constant array (Cycle) of Discovery_Board.LEDs  := (Orange, Red, Blue, Green);

   task Controller with
     Storage_Size => 4 * 1024,
     Priority     => Default_Priority;

   task body Controller is

      Period       : constant Time_Span  := Milliseconds (50);
      Release_Time :          Time       := System_Start;
      Current_LED  :          Cycle      := Cycle'First;
      Pulse        :          Meta_Cycle := Meta_Cycle'First;

   begin
      Enable (Random_number_generator);
      Random_Enable;

      loop
         Toggle (Pattern (Current_LED));

         for Port in Com_Ports'First .. Com_Ports'Last - 1 loop -- Com_Ports loop
            if Pulse mod Meta_Cycle (Port) = 0 then
               Toggle  (Port);
               Toggle ((Port, L));
            end if;
         end loop;

         if Random_Data mod 5 = 0 then
            Toggle  (4);
            Toggle ((4, L));
         end if;

         Release_Time := Release_Time + Period;
         delay until Release_Time;

         Toggle (Pattern (Current_LED));

         Current_LED := Cycle'Succ      (Current_LED);
         Pulse       := Meta_Cycle'Succ (Pulse);
      end loop;
   exception
         when others => On (Green);
   end Controller;

   task Follower with
     Storage_Size => 4 * 1024,
     Priority     => Default_Priority;

   task body Follower is

      Period       : constant Time_Span := Milliseconds (50) + Microseconds (10);
      Release_Time : Time  := System_Start;
      Current_LED  : Cycle := Cycle'First;

   begin
      loop
         declare
            Follower_Enabled : constant Boolean := Button.Current_Blue_Button_State = Off;
         begin
            if Follower_Enabled then
               Toggle (Pattern (Current_LED));
            end if;

            for Port in Com_Ports loop
               case Read (Port) = 0 is
                  when True  => On  ((Port, R));
                  when False => Off ((Port, R));
               end case;
            end loop;

            Release_Time := Release_Time + Period;
            delay until Release_Time;

            if Follower_Enabled then
               Toggle (Pattern (Current_LED));
            end if;

            Current_LED := Current_LED + 1;
         end;
      end loop;
   end Follower;

end Generator_Controllers;
