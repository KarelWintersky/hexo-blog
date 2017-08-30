title: VMDK files shrink
date: 2017-05-22 13:35:01
tags: [tools]
categories: [IT]
---
Встала задача уменьшить (на хост-машине) размер файла образа виртуальной машины. Я как-то привык использовать VirtualBox, но формат образов - VMDK. Штатная утилита vboxmanage с дисками VMDK не работает, в интернете рекомендуют плясать с бубном, сначала конвертируя диск в VDI, потом сжимать, потом конвертировать обратно. И при этом бороться с возникающими проблемами (смена GUID образа итд итп). 

Хочешь сделать что-то хорошо - сделай сам (с)

1. Ставим zerofree : `emerge -v zerofree`
2. Перезагружаемся в *recovery mode*
3. Cмотрим имена дисков: `df`
4. Монтируем: `mount -n -o remount,ro -t ext4 /dev/sda2 /` (*Note: раздел и его тип указаны для примера*)
5. Заполняем нулями: `zerofree /dev/sda2`
6. Останавливаем систему: `halt`

Теперь идем на сайт [VMWare Knowledge base](https://kb.vmware.com/selfservice/microsites/search.do?language=en_US&cmd=displayKC&externalId=1023856) и внимательно читаем статью. 

Скачиваем в разделе *Attachments* нужный нам файл (скажем, `1023856-vdiskmanager-windows-7.0.1.exe.zip`), распаковываем, переименовываем файлик в `vmware-vdiskmanager.exe`, но... запускать рано. Теперь мы этот файл **перемещаем** в папку с любым установленным продуктом VMWare (Workstation, vCenter Converter Standalone, Player).

И только после этого (из каталога продукта VMWare) запускаем сжатие образа:

```
vmware-vdiskmanager.exe -k V:\MyVM\MyVM.vmdk
```

Как сжать vmdk-файл под другими хост-системами - я не разбирался. Полагаю, аналогичным образом.
