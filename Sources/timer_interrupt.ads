with Ada.Interrupts.Names;                        use Ada.Interrupts.Names;
with System;                                      use System;
with STM32F4; use STM32F4;
package Timer_Interrupt is

   protected Tim2_Intr with Interrupt_Priority => Interrupt_Priority'Last is
      function Get_TIM2_State return Boolean;
      procedure Set_DC (DC : Bits_32);
   private
      procedure TIM2_Interrupt_Handler with Attach_Handler => TIM2_Interrupt;
      pragma Unreferenced (TIM2_Interrupt_Handler);
      TIM2_State : Boolean := False;
      Default_Rate : Bits_32 := 420_000; -- 50hz Signal at clock of 42mHz at 50% DC
      TIM2_DC_HIGH, TIM2_DC_LOW : Bits_32 := 420_000;
   end Tim2_Intr;

   protected Tim5_Intr with Interrupt_Priority => Interrupt_Priority'Last is
      function Get_TIM5_State return Boolean;
      procedure Set_DC (DC : Bits_32);
   private
      procedure TIM5_Interrupt_Handler with Attach_Handler => TIM5_Interrupt;
      pragma Unreferenced (TIM5_Interrupt_Handler);
      TIM5_State : Boolean := False;
      Default_Rate : Bits_32 := 420_000;
      TIM5_DC_HIGH, TIM5_DC_LOW : Bits_32 := 420_000;
   end Tim5_Intr;

end Timer_Interrupt;
