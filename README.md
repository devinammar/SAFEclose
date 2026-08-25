# Safeclose

Safeclose is a lightweight Windows utility that keeps your laptop running even when the lid or screen is closed. It monitors active AI agent processes in the background and disables lid-close sleep behavior when one is detected, then restores it back to normal once the agent stops. Designed for users who run AI agents like Claude Desktop, Cursor, Ollama, and more, Safeclose ensures your tasks keep running without interruption, no manual configuration needed

![License](https://img.shields.io/github/license/devinammar/safeclose?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Windows-blue?style=flat-square)
![PowerShell](https://img.shields.io/badge/made%20with-PowerShell-5391FE?style=flat-square)
![Last Commit](https://img.shields.io/github/last-commit/devinammar/safeclose?style=flat-square)
![Stars](https://img.shields.io/github/stars/devinammar/safeclose?style=flat-square)
![Issues](https://img.shields.io/github/issues/devinammar/safeclose?style=flat-square)

## 🎯 Problems
<p align="center">
  <img src="https://github.com/devinammar/Safeclose/blob/0a286c10e06eac3c42db1d17c9f1040297f625e2/Safeclose.jpg?raw=true" alt="Problems" width="600">
</p>

As AI agents become a common part of everyday workflows, many people now carry their laptops everywhere to cafes, airports, and public spaces while keeping them open just to keep their AI agents running. Closing the lid or screen risks interrupting an active task, so users are left with no choice but to leave their screens exposed. Safeclose solves this by automatically detecting when an AI agent is running and preventing the laptop from sleeping when the lid is closed, so users can safely shut their lid without stopping their work

## 🤖 Supported AI Agents

- Claude Desktop
- Cursor
- n8n
- Ollama
- Windsurf
- Gemini CLI
- And many more

## 📖 How to use

1. Download or clone this repository
2. Make sure all files (activate.bat, deactivate.bat & monitor.ps1) are in the same folder
3. Right-click on activate.bat → Run as administrator
4. That's it. Safeclose runs automatically in the background on every startup

### To stop Safeclose:
Right-click deactivate.bat → Run as administrator

## 🏗️ File Structure
```
Safeclose
│
├── activate.bat
├── deactivate.bat
├── monitor.ps1
├── Safeclose.jpg
├── LISENCE
└── README.md
```

| File | Description |
| --- | --- |
| `activate.bat` | Activates Safeclose and sets it to run on startup |
| `deactivate.bat` | Deactivates Safeclose and restores default settings |
| `monitor.ps1` | Core logic, for monitors processes and controls lid behavior |

## 📝 Notes

<i>MIT License

Copyright (c) 2026 devinammar

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.</i>
