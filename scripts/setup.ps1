# ========================================
# Atlassian Enterprise User Manager
# PowerShell Setup Script for Windows
# ========================================

param(
    [switch]$SkipNodeJS,
    [switch]$SkipMongoDB,
    [switch]$SkipRedis,
    [switch]$SkipDocker,
    [switch]$QuietMode
)

# Enable strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Color functions for output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Write-Success {
    param([string]$Message)
    Write-ColorOutput "✅ $Message" "Green"
}

function Write-Warning {
    param([string]$Message)
    Write-ColorOutput "⚠️ $Message" "Yellow"
}

function Write-Error {
    param([string]$Message)
    Write-ColorOutput "❌ $Message" "Red"
}

function Write-Info {
    param([string]$Message)
    Write-ColorOutput "ℹ️ $Message" "Cyan"
}

function Write-Header {
    param([string]$Message)
    Write-ColorOutput "`n🏢 $Message" "Blue"
    Write-ColorOutput ("=" * 50) "Blue"
}

# Function to check if running as administrator
function Test-Administrator {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Function to check if command exists
function Test-CommandExists {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Function to install Chocolatey
function Install-Chocolatey {
    Write-ColorOutput "📦 Installing Chocolatey package manager..." "Yellow"
    
    if (Test-CommandExists "choco") {
        Write-Success "Chocolatey already installed"
        return
    }
    
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        Write-Success "Chocolatey installed successfully"
    }
    catch {
        Write-Error "Failed to install Chocolatey: $($_.Exception.Message)"
        throw
    }
}

# Function to install Node.js
function Install-NodeJS {
    if ($SkipNodeJS) {
        Write-Info "Skipping Node.js installation"
        return
    }
    
    Write-ColorOutput "📦 Installing Node.js..." "Yellow"
    
    if (Test-CommandExists "node") {
        $nodeVersion = node --version
        Write-Success "Node.js already installed: $nodeVersion"
        return
    }
    
    try {
        # Install Node.js using Chocolatey
        choco install nodejs -y --version=18.17.0
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        # Verify installation
        $nodeVersion = node --version
        Write-Success "Node.js installed successfully: $nodeVersion"
    }
    catch {
        Write-Error "Failed to install Node.js: $($_.Exception.Message)"
        
        Write-Info "Alternative installation methods:"
        Write-Info "1. Download from: https://nodejs.org/dist/v18.17.0/node-v18.17.0-x64.msi"
        Write-Info "2. Use winget: winget install OpenJS.NodeJS"
        throw
    }
}

# Function to install MongoDB
function Install-MongoDB {
    if ($SkipMongoDB) {
        Write-Info "Skipping MongoDB installation"
        return
    }
    
    Write-ColorOutput "🗄️ Installing MongoDB..." "Yellow"
    
    if (Test-CommandExists "mongod") {
        Write-Success "MongoDB already installed"
        return
    }
    
    try {
        # Install MongoDB using Chocolatey
        choco install mongodb -y
        
        # Create MongoDB data directory
        $mongoDataPath = "C:\data\db"
        if (-not (Test-Path $mongoDataPath)) {
            New-Item -ItemType Directory -Path $mongoDataPath -Force | Out-Null
            Write-Info "Created MongoDB data directory: $mongoDataPath"
        }
        
        # Create MongoDB log directory
        $mongoLogPath = "C:\data\log"
        if (-not (Test-Path $mongoLogPath)) {
            New-Item -ItemType Directory -Path $mongoLogPath -Force | Out-Null
            Write-Info "Created MongoDB log directory: $mongoLogPath"
        }
        
        # Start MongoDB service
        Start-Service MongoDB -ErrorAction SilentlyContinue
        
        Write-Success "MongoDB installed successfully"
        Write-Info "MongoDB service can be managed with: net start MongoDB / net stop MongoDB"
    }
    catch {
        Write-Error "Failed to install MongoDB: $($_.Exception.Message)"
        
        Write-Info "Alternative installation methods:"
        Write-Info "1. Download from: https://www.mongodb.com/try/download/community"
        Write-Info "2. Use winget: winget install MongoDB.Server"
        Write-Warning "You may need to install MongoDB manually"
    }
}

# Function to install Redis
function Install-Redis {
    if ($SkipRedis) {
        Write-Info "Skipping Redis installation"
        return
    }
    
    Write-ColorOutput "🔄 Installing Redis..." "Yellow"
    
    if (Test-CommandExists "redis-server") {
        Write-Success "Redis already installed"
        return
    }
    
    try {
        # Install Redis using Chocolatey
        choco install redis-64 -y
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        Write-Success "Redis installed successfully"
        Write-Info "Redis can be started with: redis-server"
    }
    catch {
        Write-Error "Failed to install Redis: $($_.Exception.Message)"
        
        Write-Info "Alternative installation methods:"
        Write-Info "1. Download from: https://github.com/microsoftarchive/redis/releases"
        Write-Info "2. Use Docker: docker run -d -p 6379:6379 redis:alpine"
        Write-Warning "You may need to install Redis manually"
    }
}

# Function to install Docker Desktop
function Install-Docker {
    if ($SkipDocker) {
        Write-Info "Skipping Docker installation"
        return
    }
    
    Write-ColorOutput "🐳 Installing Docker Desktop..." "Yellow"
    
    if (Test-CommandExists "docker") {
        Write-Success "Docker already installed"
        return
    }
    
    try {
        # Install Docker Desktop using Chocolatey
        choco install docker-desktop -y
        
        Write-Success "Docker Desktop installed successfully"
        Write-Warning "Please restart your computer and start Docker Desktop manually"
        Write-Info "Docker Desktop requires Windows 10/11 with WSL2 or Hyper-V enabled"
    }
    catch {
        Write-Error "Failed to install Docker Desktop: $($_.Exception.Message)"
        
        Write-Info "Manual installation required:"
        Write-Info "1. Download from: https://www.docker.com/products/docker-desktop/"
        Write-Info "2. Enable WSL2 feature: dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart"
        Write-Info "3. Enable Virtual Machine Platform: dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart"
        Write-Warning "You may need to install Docker Desktop manually"
    }
}

# Function to install Git
function Install-Git {
    Write-ColorOutput "📝 Installing Git..." "Yellow"
    
    if (Test-CommandExists "git") {
        $gitVersion = git --version
        Write-Success "Git already installed: $gitVersion"
        return
    }
    
    try {
        choco install git -y
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        Write-Success "Git installed successfully"
    }
    catch {
        Write-Error "Failed to install Git: $($_.Exception.Message)"
        Write-Info "Download from: https://git-scm.com/download/win"
        throw
    }
}

# Function to install Visual Studio Code
function Install-VSCode {
    Write-ColorOutput "💻 Installing Visual Studio Code..." "Yellow"
    
    if (Test-Path "${env:ProgramFiles}\Microsoft VS Code\Code.exe") {
        Write-Success "Visual Studio Code already installed"
        return
    }
    
    try {
        choco install vscode -y
        Write-Success "Visual Studio Code installed successfully"
    }
    catch {
        Write-Warning "Failed to install VS Code via Chocolatey"
        Write-Info "Download from: https://code.visualstudio.com/download"
    }
}

# Function to generate secure keys
function New-SecurityKeys {
    Write-ColorOutput "🔐 Generating security keys..." "Yellow"
    
    try {
        # Generate random keys using .NET crypto
        $encryptionKey = [System.Web.Security.Membership]::GeneratePassword(64, 0)
        $sessionSecret = [System.Web.Security.Membership]::GeneratePassword(128, 0)
        $jwtSecret = [System.Web.Security.Membership]::GeneratePassword(64, 0)
        $backupKey = [System.Web.Security.Membership]::GeneratePassword(64, 0)
        
        # Create temporary file with generated keys
        $keysContent = @"
# Generated security keys - DO NOT COMMIT TO VERSION CONTROL
DATABASE_ENCRYPTION_KEY=$encryptionKey
SESSION_SECRET=$sessionSecret
JWT_SECRET=$jwtSecret
BACKUP_ENCRYPTION_KEY=$backupKey
"@
        
        $keysContent | Out-File -FilePath ".env.generated" -Encoding UTF8
        
        Write-Success "Security keys generated successfully"
    }
    catch {
        Write-Error "Failed to generate security keys: $($_.Exception.Message)"
        throw
    }
}

# Function to setup environment file
function Initialize-Environment {
    Write-ColorOutput "⚙️ Setting up environment configuration..." "Yellow"
    
    if (Test-Path ".env") {
        Write-Info "Environment file already exists"
        return
    }
    
    try {
        # Copy template
        if (Test-Path "config\env.example") {
            Copy-Item "config\env.example" ".env"
        } else {
            Write-Warning "config\env.example not found, creating basic .env"
            # Create basic .env file
            $basicEnv = @"
# Atlassian Enterprise User Manager Configuration
NODE_ENV=development
PORT=3000

# Atlassian API Configuration
ATLASSIAN_DIRECTORY_ID=your_directory_id_here
ATLASSIAN_DIRECTORY_TOKEN=your_directory_token_here
ATLASSIAN_ORG_ID=your_org_id_here
ATLASSIAN_ORG_TOKEN=your_org_token_here

# Database Configuration
DATABASE_URL=mongodb://localhost:27017/atlassian_user_manager
REDIS_URL=redis://localhost:6379

# Generated keys will be applied automatically
"@
            $basicEnv | Out-File -FilePath ".env" -Encoding UTF8
        }
        
        # Apply generated keys if they exist
        if (Test-Path ".env.generated") {
            $generatedKeys = Get-Content ".env.generated"
            foreach ($line in $generatedKeys) {
                if ($line -match "^([A-Z_]+)=(.+)$") {
                    $key = $matches[1]
                    $value = $matches[2]
                    
                    # Replace in .env file
                    $envContent = Get-Content ".env"
                    $envContent = $envContent -replace "^$key=.*", "$key=$value"
                    $envContent | Out-File -FilePath ".env" -Encoding UTF8
                }
            }
            
            Remove-Item ".env.generated" -Force
        }
        
        Write-Success "Environment file created: .env"
        Write-Warning "Please edit .env file with your Atlassian API credentials"
    }
    catch {
        Write-Error "Failed to setup environment: $($_.Exception.Message)"
        throw
    }
}

# Function to install npm dependencies
function Install-Dependencies {
    Write-ColorOutput "📦 Installing project dependencies..." "Yellow"
    
    if (-not (Test-Path "package.json")) {
        Write-Warning "package.json not found, creating basic package.json"
        
        $basicPackage = @{
            name = "atlassian-enterprise-user-manager"
            version = "1.0.0"
            description = "Atlassian Cloud Enterprise統合ユーザー管理システム"
            main = "server.js"
            scripts = @{
                start = "node server.js"
                dev = "nodemon server.js"
                test = "echo 'No tests specified'"
            }
            dependencies = @{
                express = "^4.18.2"
                dotenv = "^16.3.1"
                mongoose = "^7.5.0"
                redis = "^4.6.8"
            }
        } | ConvertTo-Json -Depth 10
        
        $basicPackage | Out-File -FilePath "package.json" -Encoding UTF8
    }
    
    try {
        npm install
        Write-Success "Dependencies installed successfully"
    }
    catch {
        Write-Error "Failed to install dependencies: $($_.Exception.Message)"
        Write-Info "Try running: npm install --legacy-peer-deps"
        throw
    }
}

# Function to setup database
function Initialize-Database {
    Write-ColorOutput "🗄️ Setting up database..." "Yellow"
    
    # Check if MongoDB is running
    try {
        $mongoProcess = Get-Process mongod -ErrorAction SilentlyContinue
        if (-not $mongoProcess) {
            Write-Info "Starting MongoDB..."
            Start-Process -FilePath "mongod" -ArgumentList "--dbpath C:\data\db" -WindowStyle Hidden
            Start-Sleep -Seconds 5
        }
        
        # Test MongoDB connection
        $testConnection = mongosh --eval "db.adminCommand('ismaster')" 2>$null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "MongoDB is running"
            
            # Create database and collections
            $initScript = @"
use atlassian_user_manager
db.createCollection('users')
db.createCollection('audit_logs')
db.createCollection('sessions')
db.createCollection('presets')
db.users.createIndex({ 'emails.value': 1 }, { unique: true })
db.audit_logs.createIndex({ 'timestamp': -1 })
db.sessions.createIndex({ 'expires': 1 }, { expireAfterSeconds: 0 })
print('Database setup completed')
"@
            
            $initScript | mongosh
            Write-Success "Database initialized successfully"
        }
    }
    catch {
        Write-Warning "Could not connect to MongoDB. Please ensure MongoDB is running."
        Write-Info "You can start MongoDB manually with: mongod --dbpath C:\data\db"
    }
}

# Function to create Windows services
function New-WindowsServices {
    Write-ColorOutput "🔧 Setting up Windows services..." "Yellow"
    
    try {
        # Create MongoDB service if not exists
        $mongoService = Get-Service -Name "MongoDB" -ErrorAction SilentlyContinue
        if (-not $mongoService) {
            Write-Info "Creating MongoDB Windows service..."
            
            $mongodPath = (Get-Command mongod -ErrorAction SilentlyContinue).Source
            if ($mongodPath) {
                $serviceArgs = @(
                    "--bind_ip", "127.0.0.1",
                    "--port", "27017",
                    "--dbpath", "C:\data\db",
                    "--logpath", "C:\data\log\mongod.log",
                    "--service"
                )
                
                New-Service -Name "MongoDB" -BinaryPathName "$mongodPath $($serviceArgs -join ' ')" -DisplayName "MongoDB Database Server" -StartupType Automatic
                Write-Success "MongoDB service created"
            }
        }
        
        # Create Redis service if not exists
        $redisService = Get-Service -Name "Redis" -ErrorAction SilentlyContinue
        if (-not $redisService) {
            Write-Info "Redis service not found. Redis can be started manually with: redis-server"
        }
    }
    catch {
        Write-Warning "Could not create Windows services: $($_.Exception.Message)"
        Write-Info "Services can be created manually or run applications directly"
    }
}

# Function to start development services
function Start-DevelopmentServices {
    Write-ColorOutput "🚀 Starting development services..." "Yellow"
    
    try {
        # Check if Docker is available and running
        if (Test-CommandExists "docker") {
            $dockerStatus = docker version 2>$null
            if ($LASTEXITCODE -eq 0) {
                Write-Info "Starting services with Docker Compose..."
                
                if (Test-Path "docker-compose.dev.yml") {
                    docker-compose -f docker-compose.dev.yml up -d
                } elseif (Test-Path "docker-compose.yml") {
                    docker-compose up -d
                } else {
                    Write-Warning "Docker Compose file not found"
                }
                
                # Wait for services
                Start-Sleep -Seconds 10
                
                # Health check
                try {
                    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -TimeoutSec 5 -ErrorAction Stop
                    if ($response.StatusCode -eq 200) {
                        Write-Success "Application is running at http://localhost:3000"
                    }
                }
                catch {
                    Write-Warning "Application may still be starting up..."
                }
            } else {
                Write-Warning "Docker is not running. Please start Docker Desktop first."
                Start-ManualServices
            }
        } else {
            Start-ManualServices
        }
    }
    catch {
        Write-Warning "Failed to start services with Docker: $($_.Exception.Message)"
        Start-ManualServices
    }
}

# Function to start services manually
function Start-ManualServices {
    Write-Info "Starting services manually..."
    
    # Start MongoDB
    try {
        Start-Service MongoDB -ErrorAction SilentlyContinue
        Write-Success "MongoDB service started"
    }
    catch {
        Write-Info "Starting MongoDB manually..."
        Start-Process -FilePath "mongod" -ArgumentList "--dbpath C:\data\db" -WindowStyle Hidden
    }
    
    # Start Redis
    try {
        Write-Info "Starting Redis..."
        Start-Process -FilePath "redis-server" -WindowStyle Hidden
    }
    catch {
        Write-Warning "Could not start Redis. Please start manually: redis-server"
    }
    
    # Start the application
    if (Test-Path "package.json") {
        Write-Info "Starting development server..."
        Start-Process -FilePath "npm" -ArgumentList "run dev" -NoNewWindow
        Write-Success "Development server started"
    }
}

# Function to create desktop shortcuts
function New-DesktopShortcuts {
    Write-ColorOutput "🔗 Creating desktop shortcuts..." "Yellow"
    
    try {
        $desktop = [System.Environment]::GetFolderPath("Desktop")
        $currentPath = Get-Location
        
        # Create application shortcut
        $WshShell = New-Object -comObject WScript.Shell
        $Shortcut = $WshShell.CreateShortcut("$desktop\Atlassian User Manager.lnk")
        $Shortcut.TargetPath = "http://localhost:3000"
        $Shortcut.Save()
        
        # Create project folder shortcut
        $ProjectShortcut = $WshShell.CreateShortcut("$desktop\Atlassian Manager Project.lnk")
        $ProjectShortcut.TargetPath = $currentPath.Path
        $ProjectShortcut.Save()
        
        Write-Success "Desktop shortcuts created"
    }
    catch {
        Write-Warning "Could not create desktop shortcuts: $($_.Exception.Message)"
    }
}

# Function to show final instructions
function Show-FinalInstructions {
    Write-Header "Setup Completed Successfully! 🎉"
    
    Write-ColorOutput "`n⚡ Quick Start:" "Yellow"
    Write-ColorOutput "1. Edit .env file with your Atlassian API credentials" "White"
    Write-ColorOutput "2. Visit http://localhost:3000 to access the application" "White"
    Write-ColorOutput "3. Read docs\api-integration.md for API setup instructions" "White"
    Write-ColorOutput "4. Check docs\security.md for security configuration" "White"
    
    Write-ColorOutput "`n📁 Important Files:" "Yellow"
    Write-ColorOutput "📄 .env - Environment configuration" "White"
    Write-ColorOutput "📚 docs\ - Documentation directory" "White"
    Write-ColorOutput "🔧 config\ - Configuration templates" "White"
    Write-ColorOutput "🐳 docker-compose.yml - Docker services" "White"
    
    Write-ColorOutput "`n🎯 Useful Commands:" "Yellow"
    Write-ColorOutput "npm run dev - Start development server" "White"
    Write-ColorOutput "npm test - Run tests" "White"
    Write-ColorOutput "npm run build - Build for production" "White"
    Write-ColorOutput "docker-compose up - Start with Docker" "White"
    
    Write-ColorOutput "`n🛠️ Windows Services:" "Yellow"
    Write-ColorOutput "net start MongoDB - Start MongoDB service" "White"
    Write-ColorOutput "redis-server - Start Redis manually" "White"
    Write-ColorOutput "Docker Desktop - Container management" "White"
    
    Write-ColorOutput "`n🌟 Next Steps:" "Yellow"
    Write-ColorOutput "1. Configure Atlassian API credentials in .env" "Cyan"
    Write-ColorOutput "2. Restart services: docker-compose restart" "Cyan"
    Write-ColorOutput "3. Open http://localhost:3000 in your browser" "Cyan"
    
    Write-ColorOutput "`nHappy coding! 🚀`n" "Green"
}

# Main execution function
function Start-Setup {
    try {
        Write-Header "Atlassian Enterprise User Manager Setup"
        Write-Info "Starting automated setup for Windows..."
        
        # Check administrator privileges
        if (-not (Test-Administrator)) {
            Write-Warning "Running without administrator privileges"
            Write-Info "Some installations may require administrator rights"
            
            if (-not $QuietMode) {
                $continue = Read-Host "Continue anyway? (y/N)"
                if ($continue -ne "y" -and $continue -ne "Y") {
                    Write-Info "Setup cancelled. Please run as administrator for best results."
                    exit 1
                }
            }
        } else {
            Write-Success "Running with administrator privileges"
        }
        
        # Install Chocolatey first
        Install-Chocolatey
        
        # Install Git
        Install-Git
        
        # Install Node.js
        Install-NodeJS
        
        # Install MongoDB
        Install-MongoDB
        
        # Install Redis
        Install-Redis
        
        # Install Docker Desktop
        Install-Docker
        
        # Install Visual Studio Code
        Install-VSCode
        
        # Generate security keys
        New-SecurityKeys
        
        # Setup environment
        Initialize-Environment
        
        # Install dependencies
        Install-Dependencies
        
        # Setup database
        Initialize-Database
        
        # Create Windows services
        New-WindowsServices
        
        # Create desktop shortcuts
        New-DesktopShortcuts
        
        # Start services
        if (-not $QuietMode) {
            $startServices = Read-Host "Start development services now? (Y/n)"
            if ($startServices -ne "n" -and $startServices -ne "N") {
                Start-DevelopmentServices
            }
        }
        
        # Show final instructions
        Show-FinalInstructions
        
    }
    catch {
        Write-Error "Setup failed: $($_.Exception.Message)"
        Write-Info "Please check the error above and try again"
        Write-Info "You can also run setup with specific skip parameters:"
        Write-Info "  .\setup.ps1 -SkipNodeJS -SkipMongoDB -SkipRedis -SkipDocker"
        exit 1
    }
}

# Script entry point
if ($MyInvocation.InvocationName -ne '.') {
    Start-Setup
}
