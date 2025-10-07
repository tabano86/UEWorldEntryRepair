function Get-SystemSnapshot {
    param()
    $gpu = Get-CimInstance Win32_VideoController -ErrorAction SilentlyContinue | Select-Object -First 1 Name,DriverVersion
    $cpu = Get-CimInstance Win32_Processor -ErrorAction SilentlyContinue | Select-Object -First 1 Name
    [pscustomobject]@{
        GPU        = $gpu.Name
        GPUDriver  = $gpu.DriverVersion
        CPU        = $cpu.Name
        OS         = [System.Environment]::OSVersion.VersionString
    }
}
