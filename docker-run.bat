@echo off
docker run --rm -it -v "C:\Users\Rogelio\OneDrive\Documentos\GitHub\assembly-labyrinth:/code" -w /code codeneomatrix/nasm sh -c "make run"
