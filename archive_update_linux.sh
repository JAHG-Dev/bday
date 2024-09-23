#!/bin/bash

# Fecha de nacimiento
birthdate="2000-10-04"
birthYear=$(date -d "$birthdate" +%Y)
birthMonth=$(date -d "$birthdate" +%m)
birthDay=$(date -d "$birthdate" +%d)
current_date=$(date '+%Y-%m-%d')

# Función para calcular diferencia de años, meses y días
calculate_version() {
    birthdate="$1"
    commit_date="$2"

    # Convertir las fechas a segundos
    diff_in_seconds=$(($(date -d "$commit_date" +%s) - $(date -d "$birthdate" +%s)))

    # Calcular años, meses y días
    years=$(($diff_in_seconds / 31557600))
    remaining_seconds=$(($diff_in_seconds % 31557600))
    months=$(($remaining_seconds / 2629800))
    days=$(($remaining_seconds % 2629800 / 86400))

    # Corregir para que el día de cumpleaños sea vX.0.0 y la fecha de nacimiento sea v0.0.0
    if [[ "$months" -eq 0 && "$days" -eq 0 ]]; then
        echo "v$years.0.0"
    elif [[ "$years" -eq 0 && "$months" -eq 0 && "$days" -eq 0 ]]; then
        echo "v0.0.0"
    else
        echo "v$years.$months.$days"
    fi
}

# Función para obtener la estación del año con emojis
get_season() {
    month=$(date -d "$1" +%m)
    day=$(date -d "$1" +%d)

    # Corregir el error de interpretación de meses como octales
    month=$(echo "$month" | sed 's/^0*//')
    day=$(echo "$day" | sed 's/^0*//')

    if [[ ( $month -eq 12 && $day -ge 21 ) || ( $month -lt 3 || ( $month -eq 3 && $day -lt 21 )) ]]; then
        echo "Winter ❄️"
    elif [[ ( $month -eq 3 && $day -ge 21 ) || ( $month -lt 6 || ( $month -eq 6 && $day -lt 21 )) ]]; then
        echo "Spring 🌸"
    elif [[ ( $month -eq 6 && $day -ge 21 ) || ( $month -lt 9 || ( $month -eq 9 && $day -lt 21 )) ]]; then
        echo "Summer ☀️"
    else
        echo "Autumn 🍁"
    fi
}

# Iterar desde la fecha de nacimiento hasta la fecha actual
d="$birthdate"
while [ "$d" != "$current_date" ]; do
    version=$(calculate_version "$birthdate" "$d")

    # Calcular tiempos transcurridos
    diff_in_seconds=$(($(date -d "$d" +%s) - $(date -d "$birthdate" +%s)))
    minutes=$(($diff_in_seconds / 60))
    hours=$(($diff_in_seconds / 3600))
    days=$(($diff_in_seconds / 86400))

    # Obtener estación del año
    season=$(get_season "$d")

    # Actualizar README.md con la versión y la información adicional
    echo "# Version: $version" > README.md
    echo "Time since birth: $days days, $hours hours, $minutes minutes, $diff_in_seconds seconds" >> README.md
    echo "Season: $season" >> README.md

    # Verificar si es cumpleaños (ahora usando correctamente el número de años cumplidos)
    if [[ "$(date -d "$d" '+%m-%d')" == "$birthMonth-$birthDay" ]]; then
        # Incrementar correctamente el año en cada cumpleaños calculando la diferencia con el año de nacimiento
        years=$(($(date -d "$d" +%Y) - $birthYear))

        echo -e "# Happy birthday! 🎂" >> README.md
        commit_message="Happy birthday! 🎂 Update version to v$years.0.0"
    else
        commit_message="Update version to $version"
    fi

    # Configurar la fecha del commit al día correspondiente
    GIT_COMMITTER_DATE="$d 04:45:00" git commit --date="$d 04:45:00" -am "$commit_message"

    # Incrementar al siguiente día
    d=$(date -d "$d +1 day" +"%Y-%m-%d")
done

# Hacer push de todos los commits
git push origin main
