with Ada.Text_IO, Ada.Integer_Text_IO, GNAT.Semaphores;
use Ada.Text_IO, Ada.Integer_Text_IO, GNAT.Semaphores;

procedure Main is

   N : constant Integer := 5;

   Forks : array (0 .. N - 1) of Counting_Semaphore (1, Default_Ceiling);

   Limit : Counting_Semaphore (4, Default_Ceiling);

   Mode : Boolean;

   task type Philosopher (Id : Integer);

   task body Philosopher is
      Left_Fork  : Integer;
      Right_Fork : Integer;
   begin

      if Mode and Id = N - 1 then
         Left_Fork := (Id + 1) mod N;
         Right_Fork := Id;
      else
         Left_Fork := Id;
         Right_Fork := (Id + 1) mod N;
      end if;

      for I in 1 .. 10 loop

         Put_Line
           ("Philosopher "
            & Integer'Image (Id)
            & " is thinking "
            & Integer'Image (I));

         if not Mode then
            Limit.Seize;
         end if;

         Forks (Right_Fork).Seize;
         Forks (Left_Fork).Seize;

         Put_Line
           ("Philosopher "
            & Integer'Image (Id)
            & " is eating "
            & Integer'Image (I));

         Forks (Left_Fork).Release;
         Forks (Right_Fork).Release;

         if not Mode then
            Limit.Release;
         end if;

      end loop;

   end Philosopher;

   P0 : Philosopher (0);
   P1 : Philosopher (1);
   P2 : Philosopher (2);
   P3 : Philosopher (3);
   P4 : Philosopher (4);

begin
   begin
      Mode := True;
   end;

end Main;
