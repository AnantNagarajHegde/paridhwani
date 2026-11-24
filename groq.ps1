param(
    [string]$Model = '',
    [ValidateRange(1,65535)][int]$Port = 8767,
    [switch]$CheckConfiguration,
    [switch]$CheckProvider
)

& (Join-Path $PSScriptRoot 'game\Start-VillageConversation.ps1') -Provider groq @PSBoundParameters
exit $LASTEXITCODE
