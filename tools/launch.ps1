param([switch]$CheckOnly)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$runtimeRoot = Join-Path $projectRoot '.runtime'
$logsRoot = Join-Path $runtimeRoot 'logs'
$engineName = 'Godot_v4.7.2-stable_win64.exe'
$downloadUrl = 'https://github.com/godotengine/godot-builds/releases/download/4.7.2-stable/Godot_v4.7.2-stable_win64.exe.zip'
$expectedHash = '731980F9608D61333E5BAF54A2EF17210ACC7A538446C0CB9969F002ACA1E953'
try {
    New-Item -ItemType Directory -Force -Path $logsRoot | Out-Null
    $enginePath = Join-Path $runtimeRoot $engineName
    if (-not (Test-Path -LiteralPath $enginePath)) {
        if ($env:GODOT_BIN -and (Test-Path -LiteralPath $env:GODOT_BIN -PathType Leaf)) {
            $enginePath = $env:GODOT_BIN
        } else {
            $installedEngine = Get-Command godot -CommandType Application -ErrorAction SilentlyContinue
            if ($installedEngine) {
                $enginePath = $installedEngine.Source
            } else {
                Write-Host 'Preparando o jogo pela primeira vez. Baixando o Godot oficial...'
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
                $archivePath = Join-Path $runtimeRoot 'godot-download.zip'
                Invoke-WebRequest -UseBasicParsing -Uri $downloadUrl -OutFile $archivePath
                if ((Get-FileHash -LiteralPath $archivePath -Algorithm SHA256).Hash -ne $expectedHash) {
                    throw 'O download nao passou na verificacao de integridade. Tente novamente.'
                }
                Expand-Archive -LiteralPath $archivePath -DestinationPath $runtimeRoot -Force
                Remove-Item -LiteralPath $archivePath
                $enginePath = Join-Path $runtimeRoot $engineName
            }
        }
    }
    if (-not (Test-Path -LiteralPath $enginePath -PathType Leaf)) { throw 'O executavel do Godot nao foi encontrado.' }
    Write-Host 'Preparando imagens e arquivos do jogo...'
    $importLog = Join-Path $logsRoot 'import.log'
    $importErrors = Join-Path $logsRoot 'import-errors.log'
    $arguments = '--headless --editor --import --path "' + $projectRoot + '"'
    $importProcess = Start-Process -FilePath $enginePath -ArgumentList $arguments -WindowStyle Hidden -PassThru -Wait -RedirectStandardOutput $importLog -RedirectStandardError $importErrors
    $importOutput = (Get-Content -LiteralPath $importLog,$importErrors -Raw -ErrorAction SilentlyContinue) -join "`n"
    if ($importProcess.ExitCode -ne 0 -or $importOutput -match 'SCRIPT ERROR:|Parse Error:|Failed to load script') {
        throw 'Falha ao preparar o projeto. Consulte .runtime\logs\import-errors.log.'
    }
    $gameLog = Join-Path $logsRoot 'game.log'
    $arguments = '--path "' + $projectRoot + '" --log-file "' + $gameLog + '"'
    if ($CheckOnly) { $arguments += ' --headless --quit-after 10' }
    Write-Host 'Abrindo RutherFox...'
    $gameProcess = Start-Process -FilePath $enginePath -ArgumentList $arguments -PassThru -Wait
    $gameOutput = Get-Content -LiteralPath $gameLog -Raw -ErrorAction SilentlyContinue
    if ($gameProcess.ExitCode -ne 0 -or $gameOutput -match 'SCRIPT ERROR:|Parse Error:|Failed to load script') {
        throw 'O jogo encontrou um erro. Consulte .runtime\logs\game.log.'
    }
    exit 0
} catch {
    Write-Host ''
    Write-Host ('Erro: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'No pacote completo, extraia todo o ZIP antes de clicar em Jogar.cmd.'
    Write-Host 'No codigo-fonte do GitHub, a primeira abertura precisa de internet para baixar o Godot.'
    exit 1
}
