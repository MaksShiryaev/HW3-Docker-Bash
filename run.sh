#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

DATA_DIR="./data"

case "$1" in
    build_generator)
        echo -e "${GREEN}Сборка образа генератора...${NC}"
        docker build -t data_generator ./generator
        ;;
    
    run_generator)
        mkdir -p "$DATA_DIR"
        echo -e "${GREEN}Запуск генератора...${NC}"
        docker run --rm -v "$(pwd)/$DATA_DIR:/data" data_generator
        echo -e "${GREEN}Файл создан: $DATA_DIR/data.csv${NC}"
        ;;
    
    create_local_data)
        mkdir -p ./local_data
        echo -e "${GREEN}Локальный запуск...${NC}"
        python3 generator/generate.py ./local_data
        echo -e "${GREEN}Файл создан: ./local_data/data.csv${NC}"
        ;;
    
    build_reporter)
        echo -e "${GREEN}Сборка образа аналитика...${NC}"
        docker build -t data_reporter ./reporter
        ;;
    
    run_reporter)
        if [ ! -f "$DATA_DIR/data.csv" ]; then
            echo -e "${YELLOW}Ошибка: сначала запусти ./run.sh run_generator${NC}"
            exit 1
        fi
        echo -e "${GREEN}Запуск аналитика...${NC}"
        docker run --rm -v "$(pwd)/$DATA_DIR:/data" data_reporter
        echo -e "${GREEN}Отчёт создан: $DATA_DIR/report.html${NC}"
        ;;
    
    structure)
        echo -e "${GREEN}Структура проекта:${NC}"
        find . -type f -not -path "./data/*" -not -path "./local_data/*" -not -path "./.git/*" -not -path "./node_modules/*" | sort
        ;;
    
    clear_data)
        if [ -d "$DATA_DIR" ]; then
            rm -f "$DATA_DIR"/*.csv "$DATA_DIR"/*.html
            echo -e "${GREEN}Папка $DATA_DIR очищена${NC}"
        fi
        ;;
    
    inside_generator)
        echo -e "${GREEN}Содержимое /data из контейнера генератора:${NC}"
        docker run --rm -v "$(pwd)/$DATA_DIR:/data" data_generator sh -c "ls -la /data"
        ;;
    
    inside_reporter)
        echo -e "${GREEN}Содержимое /data из контейнера аналитика:${NC}"
        docker run --rm -v "$(pwd)/$DATA_DIR:/data" data_reporter sh -c "ls -la /data"
        ;;
    
    report_server)
        if [ ! -f "$DATA_DIR/report.html" ]; then
            echo -e "${YELLOW}Ошибка: сначала запусти ./run.sh run_reporter${NC}"
            exit 1
        fi
        docker stop report_server 2>/dev/null
        docker run --rm -d -p 8080:80 -v "$(pwd)/$DATA_DIR:/usr/share/nginx/html:ro" --name report_server nginx:alpine
        echo -e "${GREEN}Веб-сервер на http://localhost:8080${NC}"
        echo -e "${YELLOW}Для Codespaces: открой вкладку Ports → 8080 → глобус${NC}"
        ;;
    
    help|--help|-h)
        echo "Команды:"
        echo "  build_generator, run_generator, create_local_data"
        echo "  build_reporter, run_reporter"
        echo "  structure, clear_data, inside_generator, inside_reporter, report_server"
        ;;
    
    *)
        echo "Неизвестная команда: $1"
        echo "Используй: ./run.sh help"
        exit 1
        ;;
esac
