--
-- Uwe R. Zimmer, Australia 2015
--

with STM32F4; use STM32F4;

package ANU_Base_Board.Com_Interface is

   pragma Elaborate_Body;

   procedure Set    (Port : Com_Ports);
   procedure Reset  (Port : Com_Ports);
   procedure Toggle (Port : Com_Ports);

   function Read (Port : Com_Ports) return Bit;

end ANU_Base_Board.Com_Interface;
