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

if (!cmd || cmd === '--help') {
    console.log('SysAdmin-Toolkit v3.0.3');
    console.log('Usage: sat <command>');
    console.log('Commands: procs, find, health, ssl, docker, backup, update');
    process.exit(0);
}

const cmdMap = { 'procs': 'process_manager', 'find': 'file_finder' };
const baseName = cmdMap[cmd] || cmd;
let scriptFile, commandToRun, scriptArgs = args.slice(1);

if (isWin) {
    scriptFile = path.join(WIN_DIR, baseName + '.ps1');
    if (fs.existsSync(scriptFile)) {
        commandToRun = 'powershell.exe';
        scriptArgs = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', scriptFile, ...scriptArgs];
    } else {
        scriptFile = path.join(LINUX_DIR, baseName + '.sh');
        const bashPath = 'C:\\\\Program Files\\\\Git\\\\bin\\\\bash.exe';
        if (fs.existsSync(scriptFile) && fs.existsSync(bashPath)) {
            commandToRun = bashPath;
            scriptArgs = [scriptFile, ...scriptArgs];
        } else {
            console.error('Error: Script not found');
            process.exit(1);
        }
    }
} else {
    scriptFile = path.join(LINUX_DIR, baseName + '.sh');
    commandToRun = 'bash';
    scriptArgs = [scriptFile, ...scriptArgs];
}

const proc = spawn(commandToRun, scriptArgs, { stdio: 'inherit' });
proc.on('close', (code) => process.exit(code));