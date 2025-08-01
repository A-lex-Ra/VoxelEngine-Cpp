# Библиотека *inventory*

Библиотека функций для работы с инвентарем.

```lua
-- Возвращает id предмета и его количество. id = 0 (core:empty) обозначает, что слот пуст.
inventory.get(
    -- id инвентаря
    invid: int,
    -- индекс слота
    slot: int
) -> int, int

-- Устанавливает содержимое слота, удаляя содержащиеся данные.
inventory.set(
    -- id инвентаря
    invid: int,
    -- индекс слота
    slot: int,
    -- id предмета
    itemid: int,
    -- количество предмета
    count: int
)

-- Устанавливает количество предмета в слоте не затрагивая данные при ненулевом значении аргумента.
inventory.set_count(
    -- id инвентаря
    invid: int,
    -- индекс слота
    slot: int,
    -- количество предмета
    count: int
)

-- Возвращает размер инвентаря (число слотов).
-- Если указанного инвентаря не существует, бросает исключение.
inventory.size(invid: int) -> int

-- Добавляет предмет в инвентарь. 
-- Если не удалось вместить все количество, возвращает остаток.
inventory.add(
    -- id инвентаря
    invid: int, 
    -- id предмета
    itemid: int, 
    -- количество предмета
    count: int
) -> int

-- Возвращает индекс первого подходящего под критерии слота в заданном диапазоне.
-- Если подходящий слот не был найден, возвращает nil
inventory.find_by_item(
    -- id инвентаря
    invid: int,
    -- id предмета
    itemid: int,
    -- [опционально] индекс начала диапазона слотов (c 0)
    range_begin: int,
    -- [опционально] индекс конца диапазона слотов (c 0)
    range_end: int,
    -- [опционально] минимальное количество предмета в слоте
    min_count: int = 1
) -> int

-- Функция возвращает id инвентаря блока.
-- Если блок не может иметь инвентарь - возвращает 0.
inventory.get_block(x: int, y: int, z: int) -> int

-- Привязывает указанный инвентарь к блоку.
inventory.bind_block(invid: int, x: int, y: int, z: int)

-- Отвязывает инвентарь от блока.
inventory.unbind_block(x: int, y: int, z: int)

-- Удаляет инвентарь.
inventory.remove(invid: int)
```

> [!WARNING]
> Инвентари, не привязанные ни к одному из блоков, удаляются при выходе из мира.


Локальные свойства предмета - данные прикреплённые к последнему предмету в стеке.
При разделении стека (ПКМ) данные не копируются а перемемещаются в новый стек.
Свойства могут иметь любой сериализуемый тип, включая таблицы. 
В отличие от полей блоков имена свойств не требуется регистрировать в определении предмета.

Сочетание
```lua
inventory.get(...)
inventory.get_all_data(...)
inventory.set(...)
inventory.set_all_data(...)
```
для перемещения вляется неэффективным, используйте inventory.move или inventory.move_range.

```lua
-- Проверяет наличие локального свойства по имени без копирования его значения.
-- Предпочтительно для таблиц, но не примитивных типов.
inventory.has_data(
    -- id инвентаря
    invid: int,
    -- индекс слота
    slot: int,
    -- имя свойства
    name: str
) -> bool

-- Возвращает копию значения локального свойства предмета по имени или nil.
inventory.get_data(
    -- id инвентаря
    invid: int,
    -- индекс слота
    slot: int,
    -- имя свойства
    name: str
) -> any

-- Устанавливает значение локального свойства предмета по имени.
-- Значение nil удаляет свойство.
inventory.set_data(
    -- id инвентаря
    invid: int,
    -- индекс слота
    slot: int,
    -- имя свойства
    name: str
    -- значение
    value: any
)

-- Возвращает копию таблицы всех локальных свойств предмета.
inventory.get_all_data(
    -- id инвентаря
    invid: int,
    -- индекс слота
    slot: int,
) -> table
```

```lua
-- Создаёт инвентарь и возвращает id.
inventory.create(size: int) -> int

-- Создает копию инвентаря и возвращает id копии.
-- Если копируемого инвентаря не существует, возвращает 0.
inventory.clone(invid: int) -> int

-- Перемещает предмет из slotA инвентаря invA в slotB инвентаря invB.
-- invA и invB могут указывать на один инвентарь.
-- slotB будет выбран автоматически, если не указывать явно.
-- Перемещение может быть неполным, если стек слота заполнится.
inventory.move(invA: int, slotA: int, invB: int, slotB: int)

-- Перемещает предмет из slotA инвентаря invA в подходящий слот, находящийся в
-- указанном отрезке инвентаря invB.
-- invA и invB могут указывать на один инвентарь.
-- rangeBegin - начало отрезка.
-- rangeEnd - конец отрезка.
-- Перемещение может быть неполным, если доступные слоты будут заполнены.
inventory.move_range(
    invA: int, 
    slotA: int, 
    invB: int, 
    rangeBegin: int, 
    [опционально] rangeEnd: int
)

-- Уменьшает количество предмета в слоте на указанное число.
inventory.decrement(
    -- id инвентаря
    invid: int,
    -- индекс слота
    slot: int,
    -- вычитаемое количество
    [опционально] count: int = 1
)

-- Уменьшает счётчик оставшихся использований / прочность предмета, 
-- создавая локальное свойство `uses` при отсутствии.
-- Удаляет один предмет из слота при достижении нулевого значения счётчика.
-- При отсутствии в JSON предмета свойства `uses` ничего не делает.
-- См. свойство предметов `uses`
inventory.use(
    -- id инвентаря
    invid: int,
    -- индекс слота
    slot: int
)
```
