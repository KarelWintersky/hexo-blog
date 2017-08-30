title: Раскраска CLI-вывода в PHP-скриптах
author: Karel Wintersky
tags:
  - tools
categories:
  - нашкодили
date: 2016-08-13 17:33:15
---
Захотелось мне тут раскрасить вывод консольных скриптов. Поиск показал, что все придумано до нас, работало еще в DOS'е и называется "Escape-последовательности". 

Для подобной раскраски есть интересная библиотечка [kevinlebrun/colors.php](https://github.com/kevinlebrun/colors.php), но мне она не подошла. Хотя бы потому, что ставится через композер со всеми вытекающими. Для большого проекта это удобно, а для CLI-скриптов - перебор.

И я решил написать сам. 

Началось все с функции вывода статуса. Вызывалась она в скриптах, выводящих отчет в браузер и выглядела так:

```
echo_status_cli("In my basket I have <font color='red'>five tomatoes</font>.
Also I have <font color='yellow'>10 apples</font> 
and <font color='green'>another green apple</font>");
```

Для вывода в консоль к этой строчке применялся ```strip_tags()``` - теги в итоге пропадали, но в куче одноцветного текста . 

И тут я решил вывод раскрасить. Как? 

Очевидно, нужно выделить из строки соответствующие теги, взять у них атрибут *color*, взять содержимое тега и содержимое раскрасить Escape-последовательностями.

С помощью [https://regex101.com/](https://regex101.com/ "Online regexp tester'а") составил нужную регулярку: 

```
#\<font[\s]+color=[\\\'\"]([\D]+)[\\\'\"]\>(.*)\<\/font\>#U
```

Намучавшись с функцией preg_replace() решил клеить строчку сам. 
```PHP
function echo_status_cli($message = "", $breakline = TRUE)
{
    static $fgcolors = array(...);
    $pattern = '#\<font[\s]+color=[\\\'\"]([\D]+)[\\\'\"]\>(.*)\<\/font\>#U';
    preg_match_all($pattern, $message, $matches);

    $colors = $matches[1];
    $messages = $matches[0];

    $msgs = array_map( function($i) use ($fgcolors, $colors, $messages) {
        $c_index = isset( $fgcolors[ $colors[$i] ]) ? $colors[$i] : 'white';
        $c = $fgcolors[ $c_index ];
        $msg = strip_tags( $messages[ $i ]);
        return "\033[{$c}m{$msg}\033[0m";
    }, array_keys($messages));

    $message = (count($msgs) > 1) ? implode(' ', $msgs) : $msgs[0];
    if ($breakline === TRUE) $message .= PHP_EOL;
    echo $message;
}
//(значение массива $fgcolors опущено для сокращения кода)//
```

Что мы тут делаем? 
**Во-первых** разбиваем полученную строку по регулярному выражению. В $colors и $messages попадает содержимое соответствующих карманов (в $colors - цвета, в $messages - вся строка с тегом).
**Во-вторых**, к набору строк $messages мы применяем array_map() с callback-функцией. 

Немного хитрой магии: 
```
... use ($fgcolors, $colors, $messages)
```

Это совершенно не описанная в документации (по крайней мере в документации к `array_map()` ) штуковина. Эта конструкция передает внутрь замыкания (анонимной функции) переменные, перечисленные в скобках. В данном случае - массив ESCAPE-значений цветов, значения цветов из карманов регулярки и массив строк.

Зачем же мы используем третьим параметром `array_map()` именно `array_keys($messages)`?

Если мы передадим анонимной функции просто массив $messages - она проитерирует **значение** каждого элемента массива, а получить доступ к ключам не получится. В интернете предлагают использовать `array_filter()` , но с PHP 5.4.? в замыкание нельзя передавать значение по ссылке (*Fatal error: Call-time pass-by-reference has been removed*). В общем, все плохо :( 

Если же мы передаем `array_keys($message)` - `array_map()` передает в анонимную функцию индекс (0...n) , по которому мы извлекаем как цвет, так и саму строчку. 

Казалось бы, задача решена? Нет. Мы прекрасно раскрашиваем строки, потом их склеиваем функцией `implode()`... и видим, что всё, что было **между** тегами 

```
</font>. Also I have <font 
``` 
рассосалось. 

Дальше я еще раз сломал моск на функции `preg_replace()` :-(

А потом я наткнулся на [Skillz: Регулярные выражения для чайников](http://www.skillz.ru/dev/php/article-Regulyarnye_vyrazheniya_dlya_chaynikov.html) с очень подробным рассказом о регулярках... и в **сааааааааааааааааааамом** конце коротенькое упоминание о ``` preg_replace_callback```

И я решил попробовать снова (заодно использовал именование карманов). Код оказался элегантным и простым:
```
    
    $pattern = '#(?<Full>\<font[\s]+color=[\\\'\"](?<Color>[\D]+)[\\\'\"]\>(?<Content>.*)\<\/font\>)#U';
    $message = preg_replace_callback($pattern, function($matches) use ($fgcolors){
        $color = $matches['Color'];
        $color = isset( $fgcolors[ $color ]) ? $fgcolors[ $color ] : $fgcolors[ 'white' ];
        $message = $matches['Content'];
        return "\033[{$color}m{$message}\033[0m";
    }, $message);
    $message = strip_tags( $message);
    ....
```

Мы анализируем строку **$messages** (3 аргумент) при помощи паттерна **$pattern** (1 аргумент). И **совпадения** передаем в callback-функцию, которая возвращает нам новое значение (которым `preg_replace_callback()` и заменяет найденное.
<hr>
Итак, результирующий код: [KarelWintersky/echo_status_cli.php](https://gist.github.com/KarelWintersky/796c8a213923dd947ff760764ee852a1)

```
function echo_status_cli($message = "", $breakline = TRUE)
{
    static $fgcolors = array(
        'black' => '0;30',
        'dark gray' => '1;30',
        'blue' => '0;34',
        'light blue' => '1;34',
        'green' => '0;32',
        'light green' => '1;32',
        'cyan' => '0;36',
        'light cyan' => '1;36',
        'red' => '0;31',
        'light red' => '1;31',
        'purple' => '0;35',
        'light purple' => '1;35',
        'brown' => '0;33',
        'yellow' => '1;33',
        'light gray' => '0;37',
        'white' => '1;37');

    $pattern = '#(?<Full>\<font[\s]+color=[\\\'\"](?<Color>[\D]+)[\\\'\"]\>(?<Content>.*)\<\/font\>)#U';
    $message = strip_tags(preg_replace_callback($pattern, function($matches) use ($fgcolors){
        $color = isset( $fgcolors[ $matches['Color'] ]) ? $fgcolors[ $matches['Color'] ] : $fgcolors[ 'white' ];
        return "\033[{$color}m{$matches['Content']}\033[0m";
    }, $message) );
    if ($breakline === TRUE) $message .= PHP_EOL;
    echo $message;
}
```
<hr>
**Опыт:** 
- Передача в замыкание нескольких значений извне для использования внутри
- preg_replace_callback()