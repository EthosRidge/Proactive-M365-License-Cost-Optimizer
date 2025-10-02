<#
.SYNOPSIS
    Scans a Microsoft 365 tenant to find cost-saving opportunities by identifying
    high-cost licenses assigned to inactive users.
.DESCRIPTION
    This script connects to Microsoft Graph to get user data. It checks users
    with specific, high-cost licenses against their last sign-in date. If a user
    has been inactive for more than a defined period (default 90 days), they are
    flagged in a final CSV report.
.AUTHOR
    Seth Yang
#>

# --- CONFIGURATION ---
# Add the 'SkuPartNumber' of any high-cost licenses you want to track.
# Common examples are included below.
$HighCostLicenseSKUs = @(
    "ENTERPRISEPREMIUM" # Microsoft 365 E5
    "VISIO_PRO_365"     # Visio Plan 2
    "POWER_BI_PRO"      # Power BI Pro
    "PROJECTPREMIUM"    # Project Plan 5
)

# Define what "inactive" means in days.
$InactiveThresholdDays = 90
# --- END CONFIGURATION ---


# --- INITIALIZATION & PREREQUISITES ---
Clear-Host

# A professional script should always check for its dependencies.
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "[PREREQUISITE] The Microsoft.Graph module is not installed." -ForegroundColor Yellow
    Write-Host "Please run the following command in an Administrator PowerShell window:" -ForegroundColor Yellow
    Write-Host "Install-Module Microsoft.Graph -Scope AllUsers" -ForegroundColor Cyan
    exit
}

# Define the permissions (scopes) needed for this script to function.
# This follows the principle of least privilege.
$requiredScopes = @("User.Read.All", "AuditLog.Read.All", "Directory.Read.All")

Write-Host "Connecting to Microsoft Graph..." -ForegroundColor Green
try {
    Connect-MgGraph -Scopes $requiredScopes
}
catch {
    Write-Host "Failed to connect to Microsoft Graph. Please check your connection and permissions." -ForegroundColor Red
    exit
}

Write-Host "Successfully connected. Starting license analysis..."
Write-Host "This may take a few minutes for large organizations."
Write-Host ""


# --- CORE LOGIC ---
$optimizationCandidates = @()

# Get all users and the specific properties we need. This is more efficient than pulling everything.
$users = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,SignInActivity"

Write-Host "Analyzing $($users.Count) user accounts..."

foreach ($user in $users) {
    # Check if the user has any of the high-cost licenses.
    $userLicenses = $user.AssignedLicenses.SkuPartNumber
    $matchedLicense = $userLicenses | Where-Object { $_ -in $HighCostLicenseSKUs }

    if ($matchedLicense) {
        # If they have a target license, check their last sign-in date.
        $lastSignIn = $user.SignInActivity.LastSignInDateTime
        
        if ($lastSignIn) {
            $daysSinceSignIn = (New-TimeSpan -Start $lastSignIn -End (Get-Date)).Days
            
            if ($daysSinceSignIn -gt $InactiveThresholdDays) {
                # This user is a candidate for license optimization.
                # We create a custom object to store the relevant data.
                $candidate = [PSCustomObject]@{
                    DisplayName         = $user.DisplayName
                    UserPrincipalName   = $user.UserPrincipalName
                    InactiveForDays     = $daysSinceSignIn
                    HighCostLicense     = $matchedLicense -join ", " # Join if they have multiple
                    LastSignIn          = $lastSignIn.ToString("yyyy-MM-dd")
                }
                $optimizationCandidates += $candidate
            }
        }
        else {
            # Handle the case where a user has never signed in.
            $candidate = [PSCustomObject]@{
                DisplayName         = $user.DisplayName
                UserPrincipalName   = $user.UserPrincipalName
                InactiveForDays     = "N/A (Never Signed In)"
                HighCostLicense     = $matchedLicense -join ", "
                LastSignIn          = "Never"
            }
            $optimizationCandidates += $candidate
        }
    }
}

# --- GENERATE REPORT ---
Write-Host ""
if ($optimizationCandidates.Count -eq 0) {
    Write-Host "ANALYSIS COMPLETE: No optimization candidates found. All licensed users are active." -ForegroundColor Green
}
else {
    $reportFileName = "License_Optimization_Report_$(Get-Date -format 'yyyy-MM-dd').csv"
    $reportPath = Join-Path $PSScriptRoot $reportFileName
    
    Write-Host "ANALYSIS COMPLETE: Found $($optimizationCandidates.Count) potential cost-saving opportunities." -ForegroundColor Yellow
    
    # Display the results in the console.
    $optimizationCandidates | Format-Table -AutoSize

    # Export the results to a CSV file for easy sharing.
    $optimizationCandidates | Export-Csv -Path $reportPath -NoTypeInformation

    Write-Host "A detailed report has been saved to:" -ForegroundColor Green
    Write-Host $reportPath -ForegroundColor Cyan
}

Disconnect-MgGraph