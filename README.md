# Project: Proactive M365 License & Cost Optimizer

**Author:** Seth Yang
**Contact:** sethyang7531@gmail.com
**LinkedIn:** https://www.linkedin.com/in/seth-yang-a1b8941b8/

---

### **The Business Case: Finding Hidden Costs**

In any growing company, one of the biggest hidden costs in IT is software licensing. An employee might change roles, go on leave, or leave the company, but their expensive Microsoft 365 license (like an E5, Visio, or Power BI Pro) often remains assigned and unused, quietly accumulating costs month after month.

As an IT professional, I see my role as more than just fixing problems—it's about proactively finding opportunities to make the business more efficient. Manually auditing hundreds or thousands of user accounts is incredibly time-consuming. I knew there had to be a smarter, data-driven way to handle this.

### My Approach: Turning Data into Actionable Insights

I built this tool to solve that exact problem. It's a simple yet powerful PowerShell script that connects to the company's Microsoft 365 tenant and acts as an intelligent auditor.

It doesn't just list users and licenses. It uses a **heuristic approach**, applying a simple rule: "If a user is assigned a high-cost license but hasn't logged in for more than 90 days, they are a prime candidate for a license review."

The script automatically scans all users, cross-references their assigned licenses with their last login activity, and generates a clean, simple CSV report of potential cost-saving opportunities. It turns raw data into a clear, actionable list that can be used to make smarter financial decisions.

### Key Features

*   ✅ **Direct Cost Savings:** Immediately identifies specific, unused licenses that can be unassigned and reallocated, leading to tangible budget savings.
*   📊 **Data-Driven Decisions:** Replaces guesswork with a clear report based on actual user activity data from Azure Active Directory.
*   🔒 **Enhanced Security Posture:** By flagging inactive accounts that hold powerful licenses, it also helps reduce the company's attack surface.
*   ⏱️ **Fast and Efficient:** What would take hours of manual work in the M365 Admin Center can now be done in minutes by running a single script.

This project demonstrates my ability to look beyond the immediate ticket and think strategically about how technology can serve the business's financial goals.

---

### **Getting Started**

1.  **Prerequisites:** You must have the `Microsoft.Graph` PowerShell module. The script will automatically check if it's installed and will guide you if it's missing.

2.  **Permissions:** To run this script, you must sign in with a Microsoft 365 account that has at least **"Global Reader"** permissions. This is a read-only role that allows the script to see user and sign-in data without being able to change anything.

3.  **Execution:**
    *   Open a PowerShell 7 terminal and navigate to the script's folder.
    *   Run the command: `.\Run-LicenseOptimizer.ps1`
    *   A Microsoft login window will pop up. Sign in with your authorized account. You will be asked to consent to the read-only permissions the first time you run it.

4.  **The Report:** The script will display its findings directly in the console and, most importantly, will generate a `License_Optimization_Report_YYYY-MM-DD.csv` file in the same directory for easy sharing and analysis.````

---

### **Part 2: The Final, Professional Code**

This script is clean, well-commented, and robust. An interviewer will see that you write code with clarity and best practices in mind.

#### **`Run-LicenseOptimizer.ps1`**

```powershell
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
# Here, you can define the 'SkuPartNumber' of any high-cost licenses you want to track.
# I've included common examples.
$HighCostLicenseSKUs = @(
    "ENTERPRISEPREMIUM" # Microsoft 365 E5
    "VISIO_PRO_365"     # Visio Plan 2
    "POWER_BI_PRO"      # Power BI Pro
    "PROJECTPREMIUM"    # Project Plan 5
)

# You can easily change what "inactive" means by adjusting this number.
$InactiveThresholdDays = 90
# --- END CONFIGURATION ---


# --- INITIALIZATION & PREREQUISITES ---
Clear-Host

# A professional script should always check for its own dependencies.
if (-not (Get-Module -ListAvailable -Name Microsoft.Graph)) {
    Write-Host "[PREREQUISITE] The Microsoft.Graph module is not installed." -ForegroundColor Yellow
    Write-Host "Please run the following command in an Administrator PowerShell window:" -ForegroundColor Yellow
    Write-Host "Install-Module Microsoft.Graph -Scope AllUsers -Force" -ForegroundColor Cyan
    exit
}

# Define the permissions (scopes) our script needs. This follows the principle
# of least privilege, only asking for the read permissions we absolutely need.
$requiredScopes = @("User.Read.All", "AuditLog.Read.All", "Directory.Read.All")

Write-Host "--> Connecting to Microsoft Graph..." -ForegroundColor Green
try {
    # Using the modern MSAL authentication provided by the Graph SDK.
    Connect-MgGraph -Scopes $requiredScopes
}
catch {
    Write-Host "--> Failed to connect to Microsoft Graph. Please check your connection and permissions." -ForegroundColor Red
    exit
}

Write-Host "--> Successfully connected. Starting license analysis..."
Write-Host "--> This may take a few minutes for large organizations."
Write-Host ""


# --- CORE LOGIC ---
$optimizationCandidates = @()

# Fetch all users, but only the specific properties we need.
# This is far more efficient than pulling the entire user object.
try {
    $users = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AssignedLicenses,SignInActivity"
}
catch {
    Write-Host "--> ERROR: Failed to retrieve user data. Ensure your account has Global Reader permissions." -ForegroundColor Red
    exit
}


Write-Host "--> Analyzing $($users.Count) user accounts..."

foreach ($user in $users) {
    # Check if the user has any of the high-cost licenses we defined earlier.
    $userLicenses = $user.AssignedLicenses.SkuPartNumber
    $matchedLicense = $userLicenses | Where-Object { $_ -in $HighCostLicenseSKUs }

    if ($matchedLicense) {
        # If they have a target license, check their last sign-in activity.
        $lastSignIn = $user.SignInActivity.LastSignInDateTime
        
        if ($lastSignIn) {
            $daysSinceSignIn = (New-TimeSpan -Start $lastSignIn -End (Get-Date)).Days
            
            if ($daysSinceSignIn -gt $InactiveThresholdDays) {
                # This user is a candidate. We create a clean object to store the data.
                $candidate = [PSCustomObject]@{
                    DisplayName         = $user.DisplayName
                    UserPrincipalName   = $user.UserPrincipalName
                    InactiveForDays     = $daysSinceSignIn
                    HighCostLicense     = $matchedLicense -join ", " # Handles users with multiple matches
                    LastSignIn          = $lastSignIn.ToString("yyyy-MM-dd")
                }
                $optimizationCandidates += $candidate
            }
        }
        else {
            # This handles users who have a license but have never signed in.
            $candidate = [PSCustomObject]@{
                DisplayName         = $user.DisplayName
                UserPrincipalName   = $user.UserPrincipalName
                InactiveForDays     = "N/A"
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
    Write-Host "--> ANALYSIS COMPLETE: No optimization candidates found. All licensed users are active." -ForegroundColor Green
}
else {
    $reportFileName = "License_Optimization_Report_$(Get-Date -format 'yyyy-MM-dd').csv"
    $reportPath = Join-Path $PSScriptRoot $reportFileName
    
    Write-Host "--> ANALYSIS COMPLETE: Found $($optimizationCandidates.Count) potential cost-saving opportunities." -ForegroundColor Yellow
    
    # Display the results directly in the console for a quick overview.
    $optimizationCandidates | Format-Table -AutoSize

    # Export the results to a CSV file. This is the main, shareable artifact.
    $optimizationCandidates | Export-Csv -Path $reportPath -NoTypeInformation

    Write-Host ""
    Write-Host "--> A detailed report has been saved to:" -ForegroundColor Green
    Write-Host $reportPath -ForegroundColor Cyan
}

# Always a good practice to disconnect the session when done.
Disconnect-MgGraph
```
