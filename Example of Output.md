# Project: Proactive M365 License & Cost Optimizer

**Author:** Seth Yang
**Contact:** sethyang7531@gmail.com
**LinkedIn:** https://www.linkedin.com/in/seth-yang-a1b8941b8/

---

### **The Business Case: Finding Hidden Costs**

In any growing company, one of the biggest hidden costs in IT is software licensing. An employee might change roles or leave the company, but their expensive Microsoft 365 license (like an E5, Visio, or Power BI Pro) often remains assigned and unused, quietly accumulating costs month after month.

As an IT professional, I see my role as more than just fixing problems—it's about proactively finding opportunities to make the business more efficient. Manually auditing hundreds of user accounts is incredibly time-consuming. I knew there had to be a smarter, data-driven way to handle this.

### My Approach: Turning Data into Actionable Insights

I built this tool to solve that exact problem. It's a simple yet powerful PowerShell script that connects to the company's Microsoft 365 tenant and acts as an intelligent auditor.

It uses a **heuristic approach**, applying a simple rule: "If a user is assigned a high-cost license but hasn't logged in for more than 90 days, they are a prime candidate for a license review."

The script automatically scans all users, cross-references their assigned licenses with their last login activity, and generates a clean, simple report of potential cost-saving opportunities.

---

### **The End Result: A Clear & Actionable Report**

This is what the tool looks like in action. It provides immediate feedback in the console and creates a clean, shareable CSV file that management can use to make informed decisions.

#### **Console Output Example**

When you run the script, the output in your terminal will look like this, providing a real-time status and a quick summary of the findings.

```powershell
--> Connecting to Microsoft Graph...
--> Successfully connected. Starting license analysis...
--> This may take a few minutes for large organizations.

--> Analyzing 1527 user accounts...

--> ANALYSIS COMPLETE: Found 3 potential cost-saving opportunities.

DisplayName     UserPrincipalName             InactiveForDays HighCostLicense   LastSignIn
-----------     -----------------             --------------- ---------------   ----------
Alice Johnson   alice.j@yourcompany.com       124             ENTERPRISEPREMIUM 2024-06-21
Bob Williams    bob.w@yourcompany.com         95              VISIO_PRO_365     2024-07-19
Charles Brown   charles.b@yourcompany.com     N/A             POWER_BI_PRO      Never

--> A detailed report has been saved to:
C:\Projects\M365-License-Optimizer\License_Optimization_Report_2025-10-27.csv
```

#### **Generated CSV Report Example**

The generated `License_Optimization_Report_2025-10-27.csv` is the main artifact. It's a clean spreadsheet that can be shared with IT leadership or finance departments. It would look like this when opened in Excel:

| DisplayName | UserPrincipalName | InactiveForDays | HighCostLicense | LastSignIn |
| :--- | :--- | :--- | :--- | :--- |
| Alice Johnson | alice.j@yourcompany.com | 124 | ENTERPRISEPREMIUM | 2024-06-21 |
| Bob Williams | bob.w@yourcompany.com | 95 | VISIO_PRO_365 | 2024-07-19 |
| Charles Brown | charles.b@yourcompany.com | N/A | POWER_BI_PRO | Never |

---

### **Key Features**

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

4.  **The Report:** The script will display its findings in the console and save the `.csv` report in the same directory.
````
