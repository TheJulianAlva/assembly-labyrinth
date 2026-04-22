@echo off
docker run --rm -it -v "C:\Users\julia\OneDrive\Documentos\assembly-labyrinth:/code" -w /code codeneomatrix/nasm sh -c "make run"
