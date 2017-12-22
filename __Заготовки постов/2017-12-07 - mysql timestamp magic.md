Karel Wintersky, [07.12.17 13:30]
Зато узнал немного хитрой и неочевидной магии :)

Karel Wintersky, [07.12.17 13:32]
Следи за руками:
Мы объявляем столбец time типа TIMESTAMP (просто timestamp и больше ничего)
потом мы накладываем на него индекс: INDEX(`time) USING BTREE`
потом мы создаем автоматически таблицу... 

... и поле time автоматически приобретает вот какое определение:
time TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,

Thomas Moroh, [07.12.17 13:33]
т.е. идея в том, что в поле записывается время апдейта записи?

Karel Wintersky, [07.12.17 13:34]
[In reply to Thomas Moroh]
тип индекса, насколько я понимаю :) Двоичное дерево, очевидно из названия.

Karel Wintersky, [07.12.17 13:36]
[In reply to Thomas Moroh]
идея в том, что поле, определенное просто как TIMESTAMP благодаря применению к нему индекса типа "двоичное дерево" (ну это логично, там числа хранятся, а не строки, к строкам применяют индекс типа HASH) приобретает значение по умолчанию CURRENT_TIMESTAMP.
И не просто CURRENT_TIMESTAMP, а CURRENT_TIMESTAMP при добавлении значения (DEFAULT CURRENT_TIMESTAMP) и обновлении значения (ON UPDATE CURRENT_TIMESTAMP)