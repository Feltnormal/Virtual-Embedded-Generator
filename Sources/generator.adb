--
-- Uwe R. Zimmer, Australia 2015
--

-- with Generator_Controllers;         pragma Unreferenced (Generator_Controllers);
with Last_Chance_Handler;           pragma Unreferenced (Last_Chance_Handler);
with System; use System;
with Generator_Tasks; pragma Unreferenced (Generator_Tasks);

procedure Generator with Priority => Priority'First is

begin
   -- All tasks are running at this point.
   loop
      null; -- Main task (at lowest priority) needs to be prevented from exiting
   end loop;
end Generator;
