with Ada.Text_IO, Ada.Integer_Text_IO, GNAT.Semaphores;
use Ada.Text_IO, Ada.Integer_Text_IO, GNAT.Semaphores;

with Ada.Containers.Indefinite_Doubly_Linked_Lists;
use Ada.Containers;

with Ada.Unchecked_Deallocation;

procedure Main is

   package String_Lists is new Indefinite_Doubly_Linked_Lists (String);
   use String_Lists;

   procedure Starter
     (Count_Of_Producer : in Integer;
      Count_Of_Consumer : in Integer;
      Storage_Size      : in Integer;
      Item_Max          : in Integer)
   is
      Storage : List;

      Access_Storage : Counting_Semaphore (1, Default_Ceiling);
      Full_Storage   : Counting_Semaphore (Storage_Size, Default_Ceiling);
      Empty_Storage  : Counting_Semaphore (0, Default_Ceiling);

      Count_Of_Produced_Items : Integer := 0;
      Count_Of_Consumed_Items : Integer := 0;

      task type Producer (Count_Of_Produced_Items_For_Thread : Integer);
      task type Consumer (Count_Of_Consumed_Items_For_Thread : Integer);

      type Producer_Task_Access is access Producer;
      type Consumer_Task_Access is access Consumer;

      procedure Free_Producer is new
        Ada.Unchecked_Deallocation (Producer, Producer_Task_Access);

      procedure Free_Consumer is new
        Ada.Unchecked_Deallocation (Consumer, Consumer_Task_Access);

      task body Producer is
      begin
         for I in 1 .. Count_Of_Produced_Items_For_Thread loop
            Full_Storage.Seize;
            Access_Storage.Seize;

            Storage.Append ("item " & Integer'Image (I));
            Count_Of_Produced_Items := Count_Of_Produced_Items + 1;

            Put_Line
              ("Added item " & Integer'Image (Integer (Storage.Length)));

            Access_Storage.Release;
            Empty_Storage.Release;
         end loop;

         Put_Line
           ("Кількість вироблених товарів: "
            & Integer'Image (Count_Of_Produced_Items));
      end Producer;

      task body Consumer is
      begin
         for I in 1 .. Count_Of_Consumed_Items_For_Thread loop
            Empty_Storage.Seize;
            Access_Storage.Seize;

            declare
               Item : String := First_Element (Storage);
            begin
               Put_Line ("Took " & Item);
            end;

            Storage.Delete_First;
            Count_Of_Consumed_Items := Count_Of_Consumed_Items + 1;

            Access_Storage.Release;
            Full_Storage.Release;
         end loop;

         Put_Line
           ("Кількість спожитих товарів: "
            & Integer'Image (Count_Of_Consumed_Items));
      end Consumer;

      Producers : array (1 .. Count_Of_Producer) of Producer_Task_Access;
      Consumers : array (1 .. Count_Of_Consumer) of Consumer_Task_Access;

   begin
      for I in 1 .. Count_Of_Producer loop
         declare
            Count_Of_Produced_Items_For_Thread : Integer;
         begin
            if I = Count_Of_Producer then
               Count_Of_Produced_Items_For_Thread :=
                 Item_Max / Count_Of_Producer + Item_Max mod Count_Of_Producer;
            else
               Count_Of_Produced_Items_For_Thread :=
                 Item_Max / Count_Of_Producer;
            end if;

            Producers (I) := new Producer (Count_Of_Produced_Items_For_Thread);
         end;
      end loop;

      for I in 1 .. Count_Of_Consumer loop
         declare
            Count_Of_Consumed_Items_For_Thread : Integer;
         begin
            if I = Count_Of_Consumer then
               Count_Of_Consumed_Items_For_Thread :=
                 Item_Max / Count_Of_Consumer + Item_Max mod Count_Of_Consumer;
            else
               Count_Of_Consumed_Items_For_Thread :=
                 Item_Max / Count_Of_Consumer;
            end if;

            Consumers (I) := new Consumer (Count_Of_Consumed_Items_For_Thread);
         end;
      end loop;

      for I in Producers'Range loop
         Free_Producer (Producers (I));
      end loop;

      for I in Consumers'Range loop
         Free_Consumer (Consumers (I));
      end loop;

   end Starter;

   Count_Of_Producer : Integer;
   Count_Of_Consumer : Integer;
   Storage_Size      : Integer;
   Item_Max          : Integer;

begin
   Put ("Введіть кількість виробників: ");
   Get (Count_Of_Producer);

   Put ("Введіть кількість споживачів: ");
   Get (Count_Of_Consumer);

   Put ("Введіть кількість товарів, що може містити склад: ");
   Get (Storage_Size);

   Put ("Введіть загальну кількість товарів: ");
   Get (Item_Max);

   Starter (Count_Of_Producer, Count_Of_Consumer, Storage_Size, Item_Max);

end Main;
