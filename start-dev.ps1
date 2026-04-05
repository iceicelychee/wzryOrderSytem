# 订单管理系统 - 本地开发环境启动脚本
# 使用方式: 右键 -> 使用 PowerShell 运行

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  订单管理系统 - 本地开发环境启动器" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# 检查必要的环境
Write-Host "[1/4] 检查环境..." -ForegroundColor Yellow

# 检查 Python
try {
    $pythonVersion = python --version
    Write-Host "  [OK] Python: $pythonVersion" -ForegroundColor Green
} catch {
    Write-Error "未检测到 Python，请先安装 Python 3.10+"
    exit 1
}

# 检查 Node.js
try {
    $nodeVersion = node --version
    Write-Host "  [OK] Node.js: $nodeVersion" -ForegroundColor Green
} catch {
    Write-Error "未检测到 Node.js，请先安装 Node.js 18+"
    exit 1
}

# 检查 MySQL
try {
    $mysqlVersion = mysql --version
    Write-Host "  [OK] MySQL: 已安装" -ForegroundColor Green
} catch {
    Write-Warning "未检测到 MySQL，请确保 MySQL 服务已安装并运行"
}

Write-Host ""
Write-Host "[2/4] 配置后端环境..." -ForegroundColor Yellow

# 进入后端目录
Set-Location -Path "$PSScriptRoot\backend"

# 创建虚拟环境（如果不存在）
if (-not (Test-Path "venv")) {
    Write-Host "  创建虚拟环境..." -ForegroundColor Gray
    python -m venv venv
}

# 激活虚拟环境
Write-Host "  激活虚拟环境..." -ForegroundColor Gray
& .\venv\Scripts\Activate.ps1

# 安装依赖
Write-Host "  安装 Python 依赖..." -ForegroundColor Gray
pip install -q -r requirements.txt

# 检查 .env 文件
if (-not (Test-Path ".env")) {
    Write-Host "  创建 .env 配置文件..." -ForegroundColor Gray
    Copy-Item ".env.example" ".env"
    Write-Host "  [!] 请编辑 backend\.env 文件配置数据库信息" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "[3/4] 配置前端环境..." -ForegroundColor Yellow

# 进入前端目录
Set-Location -Path "$PSScriptRoot\frontend"

# 检查 node_modules
if (-not (Test-Path "node_modules")) {
    Write-Host "  安装 Node 依赖..." -ForegroundColor Gray
    npm install
} else {
    Write-Host "  [OK] 依赖已安装" -ForegroundColor Green
}

Write-Host ""
Write-Host "[4/4] 启动服务..." -ForegroundColor Yellow

# 启动后端（在新窗口）
Write-Host "  启动后端服务..." -ForegroundColor Gray
$backendPath = "$PSScriptRoot\backend"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$backendPath'; .\venv\Scripts\Activate.ps1; python main.py" -WindowStyle Normal

# 等待后端启动
Start-Sleep -Seconds 3

# 启动前端（在新窗口）
Write-Host "  启动前端服务..." -ForegroundColor Gray
$frontendPath = "$PSScriptRoot\frontend"
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$frontendPath'; npm run dev" -WindowStyle Normal

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  服务启动完成！" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "  前端地址: http://localhost:5174" -ForegroundColor Cyan
Write-Host "  后端地址: http://localhost:8000" -ForegroundColor Cyan
Write-Host "  API文档:  http://localhost:8000/docs" -ForegroundColor Cyan
Write-Host ""
Write-Host "  默认账号: admin / admin123" -ForegroundColor Yellow
Write-Host ""
Write-Host "  按任意键关闭此窗口..." -ForegroundColor Gray

$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
