# Integrated Resort Database — Demo Script (20–25 min)

A guided walkthrough of the repository, with the spotlight on the **SQL Database Project** (`.sqlproj`). The infrastructure and pipelines are covered briefly; the last segment is a **live Azure DevOps demo** where we add a new schema object and watch it deploy.

---

## Audience & goal

- **Audience:** developers, DBAs, and platform engineers evaluating "database as code" on Azure SQL.
- **Goal:** show how a schema lives in source control as an SDK-style SQL project, how it builds into a DACPAC, and how a commit to `main` flows through CI/CD into a live Azure SQL database.

## Timing at a glance

| # | Segment | Time |
| --- | --- | --- |
| 1 | Repository tour (light: infra + pipelines) | 3 min |
| 2 | The SQL project: structure & object definitions | 7 min |
| 3 | Build configuration & the DACPAC | 4 min |
| 4 | Deployment configuration (SqlCmd vars, pre/post-deploy, publish options) | 4 min |
| 5 | **Live demo:** add a schema object → commit → push → track ADO deployment | 6 min |
| — | Q&A / closing | 1 min |

## Before you present (setup checklist)

- Open the workspace `sqlproject2` in VS Code with the **SQL Database Projects** extension installed.
- Terminal authenticated: `az login` (subscription `ME-MngEnvMCAP012327-leozelentsov-3`).
- Azure DevOps project open in a browser tab: <https://dev.azure.com/leozelentsov/sql-project-demo>.
- A clean `git status` on `main`.
- Optional: have a prior successful pipeline run open to show green history.

---

## Segment 1 — Repository tour (3 min)

Open the tree and narrate the top level. The repo is one database plus everything needed to ship it.

```
sqlproject2/
├─ azuredbsqlproj/        ← the SQL project (our focus)
├─ infra/                 ← Bicep: the Azure SQL server + database + monitoring
├─ scripts/               ← Deploy-Database.ps1 (local one-command deploy)
├─ tests/                 ← SmokeTest.sql (post-deploy verification)
├─ azure-pipelines.yml    ← Azure DevOps CI/CD
├─ .github/workflows/     ← GitHub Actions CI/CD
└─ README.md
```

**Light touch — infra:** [infra/main.bicep](../infra/main.bicep) provisions an **Entra-only** Azure SQL server, the database, and Log Analytics. Environment differences live in parameter files — [development.bicepparam](../infra/environments/development.bicepparam) uses a serverless General Purpose database with auto-pause; [production.bicepparam](../infra/environments/production.bicepparam) disables public network access.

**Light touch — pipelines:** two equivalent CI/CD definitions exist so the same project ships through either platform — [azure-pipelines.yml](../azure-pipelines.yml) (Azure DevOps) and [.github/workflows/database.yml](../.github/workflows/database.yml) (GitHub Actions). Both authenticate with **workload identity federation (OIDC)** — no stored secret or SQL password.

> Key message: the database schema, the infrastructure, the tests, and the delivery pipeline are all versioned together in one repo.

---

## Segment 2 — The SQL project: structure & object definitions (7 min)

Open [azuredbsqlproj/azuredbsqlproj.sqlproj](../azuredbsqlproj/azuredbsqlproj.sqlproj).

### 2a. An SDK-style SQL project

```xml
<Project DefaultTargets="Build">
  <Sdk Name="Microsoft.Build.Sql" Version="2.2.0" />
  <PropertyGroup>
    <Name>azuredbsqlproj</Name>
    <DSP>Microsoft.Data.Tools.Schema.Sql.SqlAzureV12DatabaseSchemaProvider</DSP>
    <ModelCollation>1033, CI</ModelCollation>
    <DefaultCollation>SQL_Latin1_General_CP1_CI_AS</DefaultCollation>
  </PropertyGroup>
```

Talking points:

- **`Microsoft.Build.Sql` SDK** — cross-platform, `dotnet build`-driven. No Visual Studio required; builds on Windows, macOS, Linux, and any CI runner with the .NET SDK.
- **`DSP` = SqlAzureV12** — the build validates every object against the **Azure SQL** surface area. If someone writes T-SQL that Azure SQL doesn't support, the build fails — not production.
- **Globbing** — the SDK automatically includes every `**/*.sql` file. Adding a new object is just adding a file; there's no per-file entry to maintain (contrast with legacy `.sqlproj` files that listed each `.sql`).

### 2b. Organized by schema, not by object type

Scroll to the `<Folder>` list and map it to the tree. Each database schema is a folder, and object types are subfolders:

```
azuredbsqlproj/
├─ Events/         Tables, Views, StoredProcedures, Functions, Triggers, Types, Sequences, Indexes
├─ Finance/        Tables, Views, StoredProcedures
├─ Loyalty/        Tables
├─ Reference/      Tables            ← lookup / reference data
├─ Resort/         Tables, Indexes
├─ Audit/          Tables
├─ Sustainability/ Tables, Views, StoredProcedures, Indexes
├─ Security/       Functions, SecurityPolicies, Roles
└─ Scripts/        Pre-Deployment.sql, Post-Deployment.sql
```

A schema is declared in one line, e.g. [Events/Events.sql](../azuredbsqlproj/Events/Events.sql):

```sql
CREATE SCHEMA [Events]
```

> Convention: **one object per file**, filename = object name. Reviews become readable diffs; the folder path tells you the schema and object kind at a glance.

### 2c. Declarative object definitions (the core idea)

Open [Events/Tables/EventBooking.sql](../azuredbsqlproj/Events/Tables/EventBooking.sql). This is the heart of the model — highlight how much intent is captured **declaratively**:

- **Keys & constraints:** `PRIMARY KEY`, `UNIQUE`, multiple `FOREIGN KEY`s, and `CHECK` constraints (enum-like `EventType`, date ordering, positive attendees).
- **Persisted computed columns:** `EventNumber AS ('EVT-' + …) PERSISTED` and `DurationDays AS DATEDIFF(…) PERSISTED`.
- **Defaults with expressions:** `DEFAULT (NEXT VALUE FOR [Events].[EventNumberSequence])`, `ORIGINAL_LOGIN()`, `SYSUTCDATETIME()`.
- **JSON validation:** `CHECK (… ISJSON([EventConfiguration]) = 1)`.

The key point: **you describe the desired end state**, and the tool computes the migration. There is no hand-written `ALTER TABLE`.

Quickly show the range of object types the project supports (open 2–3):

| Object type | Example file |
| --- | --- |
| Table | [Events/Tables/EventBooking.sql](../azuredbsqlproj/Events/Tables/EventBooking.sql) |
| Scalar function | [Events/Functions/ufn_EventBookingTotal.sql](../azuredbsqlproj/Events/Functions/ufn_EventBookingTotal.sql) |
| View | [Events/Views/EventOperationsSummary.sql](../azuredbsqlproj/Events/Views/EventOperationsSummary.sql) |
| Stored procedure | [Events/StoredProcedures/usp_CreateEventBooking.sql](../azuredbsqlproj/Events/StoredProcedures/usp_CreateEventBooking.sql) |
| Trigger | [Events/Triggers/trg_EventBooking_AuditStatus.sql](../azuredbsqlproj/Events/Triggers/trg_EventBooking_AuditStatus.sql) |
| Table type (TVP) | [Events/Types/BookingServiceLineType.sql](../azuredbsqlproj/Events/Types/BookingServiceLineType.sql) |
| Sequence | [Events/Sequences/EventNumberSequence.sql](../azuredbsqlproj/Events/Sequences/EventNumberSequence.sql) |
| Filtered index | [Resort/Indexes/IX_Venue_ActiveProperty.sql](../azuredbsqlproj/Resort/Indexes/IX_Venue_ActiveProperty.sql) |
| Row-level security policy | [Security/SecurityPolicies/PropertyAccessPolicy.sql](../azuredbsqlproj/Security/SecurityPolicies/PropertyAccessPolicy.sql) |

### 2d. Cross-object references are validated at build

Point out inside `EventBooking.sql` the foreign keys to `[Resort].[Property]`, `[Events].[Organizer]`, and `[Reference].[BookingStatus]`. Because the whole schema is one **model**, the build fails if a referenced table, column, or type doesn't exist — catching broken dependencies before deployment. Show [Security/SecurityPolicies/PropertyAccessPolicy.sql](../azuredbsqlproj/Security/SecurityPolicies/PropertyAccessPolicy.sql), which references a function *and* two tables across schemas — all resolved at build time.

---

## Segment 3 — Build configuration & the DACPAC (4 min)

### 3a. Configuration-driven quality gates

Back in the `.sqlproj`, show the Release-only property group:

```xml
<PropertyGroup Condition="'$(Configuration)' == 'Release'">
  <TreatTSqlWarningsAsErrors>True</TreatTSqlWarningsAsErrors>
  <RunSqlCodeAnalysis>True</RunSqlCodeAnalysis>
</PropertyGroup>
```

Talking points:

- **Debug** builds are lenient for fast local iteration.
- **Release** builds (what CI uses) turn **T-SQL warnings into errors** and run **static code analysis** (SR-series rules) — the pipeline refuses to produce a DACPAC from sloppy schema.
- The `BeforeBuild` target deletes a stale `project.assets.json` to keep restores deterministic.

### 3b. Build it live

```powershell
dotnet build .\azuredbsqlproj\azuredbsqlproj.sqlproj --configuration Release
```

Then show the output artifact:

```powershell
Get-Item .\azuredbsqlproj\bin\Release\azuredbsqlproj.dacpac
```

**What is a DACPAC?** A single, portable file containing the **compiled model** of the entire database — every table, index, procedure, and their relationships. It is the deployable unit: environment-independent, diffable, and the exact same artifact flows to every environment. (You can double-click a demo of "one artifact, many environments" here.)

> This is the same build the pipeline runs — the `Validate` stage does exactly `dotnet build … --configuration Release` and publishes the DACPAC as an artifact.

---

## Segment 4 — Deployment configuration (4 min)

Deployment turns the DACPAC into changes on a target database. Three things make it repeatable and safe.

### 4a. SqlCmd variables — parameterize per environment

In the `.sqlproj`:

```xml
<SqlCmdVariable Include="EnvironmentName">
  <DefaultValue>Development</DefaultValue>
</SqlCmdVariable>
<SqlCmdVariable Include="SeedDemoData">
  <DefaultValue>True</DefaultValue>
</SqlCmdVariable>
```

These become `$(EnvironmentName)` / `$(SeedDemoData)` tokens usable in scripts, and are overridden at publish time (`/v:SeedDemoData=True`). Same DACPAC, different behavior per environment.

### 4b. Pre- and post-deployment scripts

The SDK wires two special scripts (note they're excluded from the model build and re-added as pre/post steps):

```xml
<PreDeploy Include="Scripts\Pre-Deployment.sql" />
<PostDeploy Include="Scripts\Post-Deployment.sql" />
```

- [Scripts/Pre-Deployment.sql](../azuredbsqlproj/Scripts/Pre-Deployment.sql) — runs before the schema diff (announces the target).
- [Scripts/Post-Deployment.sql](../azuredbsqlproj/Scripts/Post-Deployment.sql) — **idempotent `MERGE` seed data**. Reference data (booking statuses) always loads; demo data loads only when `$(SeedDemoData) = 'True'`. Because it's `MERGE`, re-running is safe.

### 4c. Publish options control the diff

The Azure DevOps deploy stage separates **infrastructure** from **database** and uses the native `SqlAzureDacpacDeployment@1` task (no manual `sqlpackage` install — it ships on the Windows agent). The same publish options are passed as task arguments (in [azure-pipelines.yml](../azure-pipelines.yml)):

```
AdditionalArguments:
  /p:BlockOnPossibleDataLoss=true      ← refuse destructive changes
  /p:DropObjectsNotInSource=false      ← additive; don't drop out-of-band objects
  /v:EnvironmentName=Development
  /v:SeedDemoData=True
```

- **`BlockOnPossibleDataLoss=true`** — the publish aborts rather than silently dropping a column/table.
- **`DropObjectsNotInSource=false`** — a conservative, additive rollout.
- Auth is the **ARM service connection** (`AuthenticationType: servicePrincipal`) against the Entra-only server — no password; the task also opens/removes the agent firewall rule automatically (`IpDetectionMethod: AutoDetect`).
- A **`DeploymentAction: Script`** step runs *before* publish to print the exact T-SQL that will be applied — a preview/diff you can review live.

After publish, [tests/SmokeTest.sql](../tests/SmokeTest.sql) runs via the same task (`deployType: SqlTask`) to verify key objects exist and reference data is complete — a fast fail if a deployment landed wrong.

> Mention the local path too: [scripts/Deploy-Database.ps1](../scripts/Deploy-Database.ps1) does this whole loop (validate Bicep → build → temporary firewall rule → publish → smoke test → remove rule) from a workstation with one command.

---

## Segment 5 — Live demo: add a schema object → push → track ADO deployment (6 min)

**Story:** the business wants to categorize events. We'll add a new **`Reference.EventCategory`** lookup table, seed it, extend the smoke test, and push to `main`. The Azure DevOps pipeline builds the DACPAC and deploys the new table to Azure SQL.

### Step 1 — Create the new object file

Create `azuredbsqlproj/Reference/Tables/EventCategory.sql`:

```sql
CREATE TABLE [Reference].[EventCategory]
(
    [EventCategoryCode] VARCHAR(20) NOT NULL,
    [DisplayName]       NVARCHAR(60) NOT NULL,
    [SortOrder]         TINYINT NOT NULL,
    [IsActive]          BIT NOT NULL
        CONSTRAINT [DF_EventCategory_IsActive] DEFAULT (1),
    CONSTRAINT [PK_EventCategory] PRIMARY KEY CLUSTERED ([EventCategoryCode]),
    CONSTRAINT [UQ_EventCategory_SortOrder] UNIQUE ([SortOrder])
);
```

> Note there is **nothing to edit in the `.sqlproj`** — the SDK globs the new file automatically. That's the whole point of Segment 2a.

### Step 2 — Seed it (idempotent) in the post-deploy script

Append to [Scripts/Post-Deployment.sql](../azuredbsqlproj/Scripts/Post-Deployment.sql):

```sql
MERGE [Reference].[EventCategory] AS target
USING
(
    VALUES
        ('CONVENTION',    N'Convention',    1, 1),
        ('EXHIBITION',    N'Exhibition',    2, 1),
        ('MEETING',       N'Meeting',       3, 1),
        ('INCENTIVE',     N'Incentive',     4, 1),
        ('ENTERTAINMENT', N'Entertainment', 5, 1),
        ('SPORTING',      N'Sporting',      6, 1)
) AS source ([EventCategoryCode], [DisplayName], [SortOrder], [IsActive])
    ON target.[EventCategoryCode] = source.[EventCategoryCode]
WHEN MATCHED THEN
    UPDATE SET [DisplayName] = source.[DisplayName],
               [SortOrder]  = source.[SortOrder],
               [IsActive]   = source.[IsActive]
WHEN NOT MATCHED THEN
    INSERT ([EventCategoryCode], [DisplayName], [SortOrder], [IsActive])
    VALUES (source.[EventCategoryCode], source.[DisplayName], source.[SortOrder], source.[IsActive]);
```

### Step 3 — Extend the smoke test (proves the deploy)

Add to [tests/SmokeTest.sql](../tests/SmokeTest.sql), before the final `PRINT`:

```sql
IF OBJECT_ID(N'Reference.EventCategory', N'U') IS NULL
    THROW 51007, 'Smoke test failed: Reference.EventCategory is missing.', 1;

IF (SELECT COUNT(*) FROM [Reference].[EventCategory]) <> 6
    THROW 51008, 'Smoke test failed: event category reference data is incomplete.', 1;
```

### Step 4 — Build locally first (never push a red build)

```powershell
dotnet build .\azuredbsqlproj\azuredbsqlproj.sqlproj --configuration Release
```

Expect `Build succeeded`. This is the same Release build the pipeline gates on.

### Step 5 — Commit and push to `main`

```powershell
git add azuredbsqlproj/Reference/Tables/EventCategory.sql `
        azuredbsqlproj/Scripts/Post-Deployment.sql `
        tests/SmokeTest.sql
git commit -m "feat: add Reference.EventCategory lookup with seed and smoke test"
git push ado main
```

> `ado` is the Azure DevOps remote. The push to `main` triggers the pipeline defined in [azure-pipelines.yml](../azure-pipelines.yml).

### Step 6 — Track the deployment

Open <https://dev.azure.com/leozelentsov/sql-project-demo/_build> and walk the stages live:

1. **Validate** — `UseDotNet` → `dotnet build --configuration Release` (warnings-as-errors + code analysis) → compile Bicep → publish the DACPAC artifact.
2. **DeployDevelopment** (skipped for PRs, runs on `main`) — infrastructure and database are now **separate steps**:
   - **Deploy Azure infrastructure (Bicep)** — Azure CLI (OIDC) creates/updates the resource group and runs the Bicep deployment, publishing the server FQDN + database name as pipeline variables.
   - **Preview database changes (script)** — `SqlAzureDacpacDeployment@1` with `DeploymentAction: Script` generates the T-SQL migration, and the next step prints it: you can *see* the `CREATE TABLE [Reference].[EventCategory]` before it runs.
   - **Deploy DACPAC (publish)** — the same native task with `DeploymentAction: Publish` applies the new table; the post-deploy `MERGE` seeds the six categories. The task auto-manages the firewall (`IpDetectionMethod: AutoDetect`) and authenticates via the service connection.
   - **Run smoke test** — the same task with `deployType: SqlTask` runs [tests/SmokeTest.sql](../tests/SmokeTest.sql); the new `THROW 51007/51008` checks now assert the table and its data exist.
   - No tool-install steps — `sqlpackage` is already on the Windows agent.

**Success looks like:** both stages green, and the smoke-test step printing `IntegratedResort.Database smoke test passed.`

### Optional — verify in the database

```powershell
Invoke-Sqlcmd -ServerInstance <sqlServerFqdn> -Database IntegratedResort `
  -AccessToken (az account get-access-token --resource https://database.windows.net/ --query accessToken -o tsv) `
  -Query "SELECT * FROM Reference.EventCategory ORDER BY SortOrder;"
```

### Reset after the demo (optional)

```powershell
git revert HEAD --no-edit
git push ado main
```

Because publish uses `DropObjectsNotInSource=False`, reverting the source **won't** auto-drop the table — call that out as a real-world consideration (managed drops require an explicit setting/migration).

---

## Closing (1 min)

Recap the through-line:

1. **The schema is code** — declarative object files, organized by schema, globbed by the SDK.
2. **The build is a quality gate** — Azure SQL validation, warnings-as-errors, static analysis, producing one portable **DACPAC**.
3. **Deployment is repeatable and safe** — SqlCmd variables, idempotent seed scripts, and conservative publish options, verified by a smoke test.
4. **One commit ships it** — a push to `main` flows through Azure DevOps (or GitHub Actions) via OIDC to a live Azure SQL database.

**Q&A prompts:** drift detection, handling data-loss migrations, pull-request validation (PRs run `Validate` only), promoting to production with the private-endpoint parameters.
```
