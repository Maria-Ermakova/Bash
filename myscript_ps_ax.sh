#!/bin/bash

# Простейшая реализация ps ax - Читаем данные напрямую из /proc

# Печатаем заголовок
printf "%-8s %-8s %-5s %-8s %s\n" "PID" "TTY" "STAT" "TIME" "COMMAND"

for pid in /proc/[0-9]*/; do
    pid=${pid%/}
    pid=${pid##*/}
    
    [[ ! -d "/proc/$pid" ]] && continue
    
    awk_output=$(awk '
    {
        pid=$1
        tty=$7
        state=$3
        #суммарное время CPU, затраченнное на процесс, и преобразование из тиков в секунды
        time=($14+$15+$16+$17)/100   
        minutes=int(time/60)
        #деление на 60 и возвращение преобразованного в целое остатка
        seconds=int(time%60)       
        time_fmt = sprintf("%02d:%02d", minutes, seconds)
        
        # Для TTY (не получается пока...)
#        if (tty == 0)
#            tty_disp="?"
#        else {
#            major = (tty >> 8) & 0xFF
#            minor = tty & 0xFF
#            if (major == 4)
#                tty_disp = "tty" minor
#            else if (major >= 136 && major <= 252)
#                tty_disp = "pts/" minor
#            else
#                tty_disp = "?"
#        }

        printf("%-8s %-8s %-5s %-8s ", pid, tty, state, time_fmt)
    }' "/proc/$pid/stat" 2>/dev/null)

    [[ -z "$awk_output" ]] && continue

    # Добавляем cmdline (COMMAND)
    if [[ -r "/proc/$pid/cmdline" ]]; then
        #tr '\0' ' ' — утилита tr заменяет все нулевые байты (\0) на пробелы
        cmd=$(tr '\0' ' ' < "/proc/$pid/cmdline" 2>/dev/null)
        if [[ -z "$cmd" ]]; then
            # Поток ядра. tr -d '()' — удаляет скобки, оставляя только имя
            comm=$(awk '{print $2}' "/proc/$pid/stat" 2>/dev/null | tr -d '()')
            echo "$awk_output [$comm]"
        else
            echo "$awk_output $cmd"
        fi
    else
        echo "$awk_output ?"
    fi
done  
