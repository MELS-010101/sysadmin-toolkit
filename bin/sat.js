#!/usr/bin/env node
const { spawn } = require('child_process');
const path = require('path');
const os = require('os');
const fs = require('fs');

const isWin = os.platform() === 'win32';

const SCRIPT_DIR = __dirname;
const ROOT_DIR = path.dirname(SCRIPT_DIR);
const LINUX_DIR = path.join(ROOT_DIR, 'src', 'linux');
const WIN_DIR = path.join(ROOT_DIR, 'src', 'windows');

const args = process.argv.slice(2);
const cmd = args[0];

// Маппинг команд на имена файлов (если они отличаются)
const cmdMap = {
    'procs': 'process_manager',
    'find': 'file_finder'
};
const baseName = cmdMap[cmd] || cmd;

if (!cmd || cmd === '--help') {
    console.log(`SysAdmin-Toolkit
Usage: sat <command>
Commands: health, procs, find, ssl, docker, backup, update, ...`);
    process.exit(0);
}

let commandToRun;
let scriptArgs = args.slice(1);
let scriptFile;

if (isWin) {
    // WINDOWS: Ищем .ps1 файл
    scriptFile = path.join(WIN_DIR, baseName + '.ps1');
    if (fs.existsSync(scriptFile)) {
        commandToRun = 'powershell.exe';
        scriptArgs = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', scriptFile, ...scriptArgs];
    } else {
        // Если нет .ps1, пробуем bash (Git Bash)
        scriptFile = path.join(LINUX_DIR, baseName + '.sh');
        if (fs.existsSync(scriptFile)) {
             const bashPaths = ['C:\\Program Files\\Git\\bin\\bash.exe', 'C:\\Program Files (x86)\\Git\\bin\\bash.exe'];
             let foundBash = bashPaths.find(p => fs.existsSync(p));
             if (foundBash) {
                 commandToRun = foundBash;
                 scriptArgs = [scriptFile, ...scriptArgs];
             } else {
                 console.error(`Error: Windows script '${baseName}.ps1' not found, and Git Bash is not installed.`);
                 process.exit(1);
             }
        } else {
            console.error(`Error: Command '${cmd}' script not found.`);
            process.exit(1);
        }
    }
} else {
    // LINUX/MAC: Ищем .sh файл
    scriptFile = path.join(LINUX_DIR, baseName + '.sh');
    if (fs.existsSync(scriptFile)) {
        commandToRun = 'bash';
        scriptArgs = [scriptFile, ...scriptArgs];
    } else {
        console.error(`Error: Command '${cmd}' script not found.`);
        process.exit(1);
    }
}

// Запуск процесса
const proc = spawn(commandToRun, scriptArgs, { stdio: 'inherit' });

proc.on('close', (code) => {
    process.exit(code);
});
