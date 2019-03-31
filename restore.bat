@echo OFF
::if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
title Firebird Restore Database
setlocal EnableDelayedExpansion

echo ====== Restauracao de base de dados Firebird 2.5 ======

::Importante: verifique se o caminho abaixo corresponde a instalacao do Firebird local
set gbak_src=C:\Program Files (x86)\Firebird\Firebird_2_5\bin
set list=
set /a count_fbk=0

:label_search_fbks
for /f %%G IN ('dir /b') DO (
    if /I "%%~xG"==".FBK" (
        set /a count_fbk=count_fbk+1
        set list[!count_fbk!]=%%~nG
    )
)

if %count_fbk% == 0 goto :label_no_fbk_found

if %count_fbk% EQU 1 (
    echo.
    echo Restaurar base %list[1]%?
    pause
    set db_name=%list[1]%
    goto :label_restoring_database
)

:label_select_fbk
echo.
echo Arquivos FBK encontrados:
set /a i=1
for /F "tokens=2 delims==" %%s in ('set list[') do (
    echo [!i!] - %%~ns
    set /a i=i+1
)
echo.
set /p fbk_index="Selecione um arquivo: "
if %fbk_index% GTR %count_fbk% (
    goto :label_index_not_found
 ) else (
    set db_name=!list[%fbk_index%]!
 )

:label_restoring_database
echo.
echo Restaurando base: !list[%fbk_index%]!
@echo Inicio em: %date% %time%
"%gbak_src%\gbak" -r -v -p 16384 -use_ "%db_name%".FBK "%db_name%".FDB -user SYSDBA -pas masterkey
@echo Finalizado em: %date% %time%

:label_search_scripts
set scripts=
set script_name=
set /a count_scripts=0
for /f %%G IN ('dir /b') DO (
    if /I "%%~xG"==".sql" (
        set /a count_scripts=count_scripts+1
        set scripts[!count_scripts!]=%%~nG
    )
)
if %count_scripts% GTR 0 (
    set script_name=%scripts[1]%
    goto :label_running_dev_scripts
)

:label_running_dev_scripts
echo.
echo Rodar scripts %script_name%.SQL?
pause
echo Rodando scripts de desenvolvimento...
"%gbak_src%\isql" -i  %script_name%.sql %db_name%.FDB -user SYSDBA -pass masterkey
goto :end

:label_no_fbk_found
echo Nenhum backup FBK encontrado
goto :end

:label_index_not_found
echo Index invalido. Selecione um index entre 1 e %count_fbk%
goto :label_select_fbk

:end
echo.
echo Fim
pause
