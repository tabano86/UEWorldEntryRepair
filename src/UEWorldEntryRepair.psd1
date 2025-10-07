@{
    RootModule        = 'UEWorldEntryRepair.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'a7be3f2d-0d5e-4b8a-9d1b-4b0bde6a4e31'
    Author            = 'UEWorldEntryRepair'
    CompanyName       = 'UEWorldEntryRepair'
    Copyright         = '(c) UEWorldEntryRepair'
    PowerShellVersion = '5.1'
    FunctionsToExport = @('Repair-UEWorldEntry','Get-UEGames')
    AliasesToExport   = @()
    CmdletsToExport   = @()
    PrivateData       = @{
        PSData = @{ Tags = @('Unreal','Crash','Gaming','DLSS','FrameGen','WorldEntry') }
    }
}
