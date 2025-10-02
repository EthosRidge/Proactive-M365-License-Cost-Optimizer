# Project: Proactive M365 License & Cost Optimizer

**Author:** Seth Yang
**Contact:** sethyang7531@gmail.com
**LinkedIn:** [Your LinkedIn Profile URL Here]

---

### **The Business Case: Finding Hidden Costs**

In any growing company, one of the biggest hidden costs in IT is software licensing. An employee might change roles, go on leave, or leave the company, but their expensive Microsoft 365 license (like an E5, Visio, or Power BI Pro) often remains assigned and unused, quietly accumulating costs month after month.

As an IT professional, I see my role as more than just fixing problems—it's about proactively finding opportunities to make the business more efficient. Manually auditing hundreds or thousands of user accounts is incredibly time-consuming and prone to errors. I knew there had to be a smarter, data-driven way to handle this.

### My Approach: Turning Data into Actionable Insights

I built this tool to solve that exact problem. It's a simple yet powerful PowerShell script that connects to the company's Microsoft 365 tenant and acts as an intelligent auditor.

It doesn't just list users and licenses. It uses a **heuristic approach**, applying a simple rule: "If a user is assigned a high-cost license but hasn't logged in for more than 90 days, they are a prime candidate for a license review."

The script automatically scans all users, cross-references their assigned licenses with their last login activity, and generates a clean, simple report of potential cost-saving opportunities. It turns raw data into a clear, actionable list that can be used to make smarter financial decisions.

### Key Features

*   ✅ **Direct Cost Savings:** Immediately identifies specific, unused licenses that can be unassigned and reallocated, leading to tangible budget savings.
*   📊 **Data-Driven Decisions:** Replaces guesswork with a clear report based on actual user activity data from Azure Active Directory.
*   🔒 **Enhanced Security Posture:** By flagging inactive accounts that hold powerful licenses, it also serves as a security tool, helping to reduce the company's attack surface.
*   ⏱️ **Fast and Efficient:** What would take hours of manual work in the M365 Admin Center can now be done in minutes by running a single script.

This project demonstrates my ability to look beyond the immediate ticket and think strategically about how technology can serve the business's financial goals.

---

### **Getting Started**

1.  **Prerequisites:** You must have the `Microsoft.Graph` PowerShell module installed. If you don't, the script will detect it and guide you on how to install it.
2.  **Execution:** Run the `Run-LicenseOptimizer.ps1` script from a PowerShell 7 terminal.
3.  **Authentication:** The first time you run it, a Microsoft login window will pop up. You must sign in with an account that has at least "Global Reader" permissions to read the necessary directory and sign-in data. You'll need to consent to the requested permissions.
4.  **The Report:** The script will display its findings directly in the console and, most importantly, will generate a `License_Optimization_Report.csv` file in the same directory for easy sharing and analysis.