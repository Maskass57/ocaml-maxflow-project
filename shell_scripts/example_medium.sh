#!/bin/sh

WAITING_TIME_PROGRESS=100;
WAITING_TIME_STAMP=0.0025;
WAITING_TIME_PRINT=0.5;

progress_bar() {
    local progress=$1
    local total=100
    local width=50 # Largeur de la barre
    local filled=$(($progress * $width / $total))
    local empty=$(($width - $filled))
    local bar=""

    for i in $(seq 1 $filled); do
        bar="${bar}#"
    done
    for i in $(seq 1 $empty); do
        bar="${bar} "
    done

    printf "\r[%-${width}s] %d%%" "$bar" "$progress"
}

graph_file=${1:-"sportvoeux6.txt"}

if [ ! -f "../graphs/$graph_file" ]; then
    echo "Error: File ../graphs/$graph_file does not exist."
    exit 1
fi

echo "✅\e[1;32m Starting medium project example, make sure you change the file used in makefile \e[0m✅\n";
sleep $WAITING_TIME_PRINT;
cd ..;
sleep $WAITING_TIME_PRINT;
echo "";
echo "🚿\e[1;32m Cleaning \e[0mi🚿\n";
sleep $WAITING_TIME_PRINT;
make clean;
for i in $(seq 0 $WAITING_TIME_PROGRESS); do
    progress_bar $i
    sleep $WAITING_TIME_STAMP;
done
echo "";
sleep $WAITING_TIME_PRINT;
echo "";
echo "🧱\e[1;32m Building \e[0m🧱\n";
sleep $WAITING_TIME_PRINT;
make build;
for i in $(seq 0 $WAITING_TIME_PROGRESS); do
    progress_bar $i
    sleep $WAITING_TIME_STAMP;
done
echo "";
sleep $WAITING_TIME_PRINT;
echo "";
echo "🤞\e[1;32m Executing, textual output sent in log.txt \e[0m🤞\n";
sleep $WAITING_TIME_PRINT;
base_name=$(basename "$graph_file" .txt)
make demo graph=../graphs/$graph_file > "$base_name.txt";
dot -Tsvg aps.dot > "$base_name.svg";
eog "$base_name.svg" &
for i in $(seq 0 $WAITING_TIME_PROGRESS); do
    progress_bar $i
    sleep $WAITING_TIME_STAMP;
done
echo "";
sleep $WAITING_TIME_PRINT;
echo "";
echo "😎\e[1;32m aps.svg file generated \e[0m😎\n";

