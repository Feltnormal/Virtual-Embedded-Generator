--
-- Uwe R. Zimmer, Australia 2015
--

with ANU_Base_Board.Config;               use ANU_Base_Board.Config;
with STM32F4.General_purpose_IOs;         use STM32F4.General_purpose_IOs;
with STM32F4.General_purpose_IOs.Ops;     use STM32F4.General_purpose_IOs.Ops;
with STM32F4.Reset_and_clock_control.Ops; use STM32F4.Reset_and_clock_control.Ops;

package body ANU_Base_Board.Com_Interface is

   procedure Set (Port : Com_Ports) is

   begin
      Set (Com_Wires (Port, Tx, Data));
   end Set;

   procedure Reset (Port : Com_Ports) is

   begin
      Reset (Com_Wires (Port, Tx, Data));
   end Reset;

   procedure Toggle (Port : Com_Ports) is

   begin
      Atomic_Switch.Toggle (Com_Wires (Port, Tx, Data));
   end Toggle;

   function Read (Port : Com_Ports) return Bit is

     (Input_Read (Com_Wires (Port, Rx, Data)));

begin
   for Port in Com_Ports loop
      for Dir in Com_Directions loop
         for Feature in Com_Features loop
            Enable (Com_Wires (Port, Dir, Feature).Port);
         end loop;
         Initialize_Output_Pin (Com_Wires (Port, Dir, Enable));

      end loop;
      Initialize_Output_Pin (Com_Wires (Port, Tx, Data));
      Initialize_Input_Pin  (Com_Wires (Port, Rx, Data), Pull_Down);
      Reset                 (Com_Wires (Port, Rx, Enable)); -- Active low!
      Set                   (Com_Wires (Port, Tx, Enable));
      Set                   (Com_Wires (Port, Tx, Data));
   end loop;
end ANU_Base_Board.Com_Interface;
