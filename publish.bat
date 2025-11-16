@echo off
REM ============================================================
REM  Garry's Mod Addon Publishing Script
REM  This script packs and updates a workshop addon using
REM  gmad.exe and gmpublish.exe. The addon folder is the same
REM  directory where this .bat file is located.
REM ============================================================

REM --- Path to Garry's Mod bin tools (adjust if needed) ---
set "basepath=D:\SteamLibrary\common\GarrysMod\bin"
set "gmad=%basepath%\gmad.exe"
set "gmpublish=%basepath%\gmpublish.exe"

REM --- Use the directory of this .bat file as the addon source ---
REM %~dp0 = drive + path of the script, always ends with a backslash
set "publish_path=%~dp0"

REM --- Output .gma name and workshop addon ID ---
set "publish_gma=workshop.gma"
set "publish_id=3001397905"

REM --- Create .gma file from the addon folder ---
call "%gmad%" create -folder "%publish_path%" -out "%publish_gma%"

REM --- Upload/update the addon on the Steam Workshop ---
call "%gmpublish%" update -addon "%publish_gma%" -id "%publish_id%"

REM --- Clean up temporary .gma file ---
del "%publish_gma%"

pause