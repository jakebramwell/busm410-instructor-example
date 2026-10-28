# Repository Review and Proposed Changes

October 27, 2026. Review branch: `review/project-audit`, based on local `main` at `f9fcfd9`. No push is authorized. This is instructor review material, not another required student document.

## Recommendation

Keep the current root-level documents and the `sql/`, `model/`, `visuals/`, and `Other/` folders. The project needs clearer responsibilities for each file and a stronger evidence trail. A larger folder structure would add little at this scale.

## Answers to your questions

| Question | Recommendation |
|---|---|
| README, charter, and findings overlap | README is the front door and reproduction guide. Charter states the initial question, decision maker, scope, and success criteria. Findings owns the results and recommendation. Keep the charter to about half a page. If the course does not assess planning separately, it can be a README section instead. |
| Recreate the full metadata? | No. Link the authoritative metadata. Keep a short project-specific field/definition table in `sql/README.md`, including derived fields and assumptions. The CMS manual does not document every later OMOP conversion choice. |
| Example model card | Added `model/model_card.md` using this project. The model is proposed, with no invented metrics. It covers the decision, target, available inputs, baseline, testing, and limits. |
| What is a baseline? | The simplest credible approach the model must improve upon. Here, predict the training-set readmission rate for everyone, and compare prioritization with a simple verified prior-use rule at equal capacity. The state benchmark answers a different question. |
| Protocol = student's process with an agent? | Yes. Include how the student directs work, checks consequential outputs, and records uncertainty. Keep it short and tailored to actual practice. |
| Log = evidence of that process? | Yes. Record the specific claim, actual check, actor, evidence, and resulting decision. Human review and agent self-checking must be distinguishable. |
| Skill to maintain both naturally? | Yes. Added a portable project-audit skill, referenced from AGENTS.md, plus a CLAUDE.md pointer. It records meaningful checks during normal work and proposes protocol changes when justified. It cannot independently certify a student's understanding or observe checks outside the session. |
| Everything should reproduce within the free tier | Agreed. No mandatory results-export folder. Document run order, workbook calculations, destination changes, and the actual full-run resource use. Feasibility on a fresh student account is still untested; model training must be checked separately from ordinary querying. |
| Instructor example has only Jake + Claude | Keep that arrangement explicit. Add a short student-team instruction to the README: name each human's contribution and one substantive review each performed. Do not invent teammate evidence in the example. |

## Changes prepared on this branch

- Keep all existing folders and executable SQL. No new model or data checks have been run.
- Separate the README, charter, and findings responsibilities. Correct unsupported language about causation, avoidability, and real-world conclusions.
- Link the supplied workbook and document inspected formulas in `sql/README.md`.
- Add a project-specific model card and audit skill. Broaden the protocol to include the student's full working process.
- Preserve all 15 historical audit entries verbatim. Add context about unresolved evidence and use richer attribution for future entries.
- Correct claim-date labels and remove the superseded inpatient-cost relationship from the diagram source. The old PDF remains marked as outdated.
- Add common local credential/cache exclusions to `.gitignore`.

## What the repository review found

### 1. Claims exceed the evidence

The original charter calls the estimated difference "avoidable" and the findings say the model will determine whether to target high-risk patients or fix care processes. The analysis cannot establish preventability, causal care quality, or intervention savings. This is especially consequential for synthetic data. The proposed wording describes a teaching example and a next validation step.

The CMS manual explicitly limits inference about actual Medicare beneficiaries and providers. Its printed pp. 1–2 and 16 support that boundary. [CMS manual](https://www.cms.gov/Research-Statistics-Data-and-Systems/Downloadable-Public-Use-Files/SynPUFs/Downloads/SynPUF_DUG.pdf)

### 2. The connected Sheet resolves part of the calculation trail

The reviewed `Pivot Table 1` contains the state-level counts and formulas. Summing its selected group independently gives 19,412 / 225,105 = 8.623531%. The Texas calculation gives about 891.44 events and $11.856 million at the existing cost assumption. Rounded 891 and $11.9 million are supported by those aggregates.

The selected group contains the lowest-rate whole states until the eligible-stay threshold first crosses 10%. Fourteen states cover 9.32%; California brings coverage to 17.13%. Share of readmissions happens to select the same group here but is a different rule. Document eligible stays as the proposed rule, consistent with the existing write-up.

The project uses raw state rates. Label this ABC-inspired rather than the full ABC implementation: the published method also adjusts small-sample rankings. Correct the citation's first author to Weissman. [Original paper](https://pubmed.ncbi.nlm.nih.gov/10461579/)

### 3. The reported populations and workbook views need clear labels

The saved table is reported as 1,322,931 stays. The pivot, excluding `54`, has 1,313,758 stays and 120,503 readmissions, giving 9.17%, rather than the earlier reported 9.16%. The difference is 9,173 stays; a source query is still needed to reconcile the excluded records and confirm the category mapping.

The separate `Sheet1` table has stale values: NM's excess count at `G9` is a hardcoded 4.03473459939018 displayed as dollars, while the current pivot calculates zero for NM. Designate the pivot as current and label the other table as an earlier snapshot unless it serves a documented purpose. The live workbook was being edited during review; no Sheet changes were made by this review.

### 4. The readmission definition needs validation before ML

Step 2 uses only the immediately next stay. An adjacent overlapping or 0–1-day claim can prevent a later 2–30-day stay from being counted for the earlier index stay. Check how often this occurs and decide whether to merge episodes or search for the next qualifying event. The 2-day rule alone does not prove that split claims and transfers are resolved.

Also check missing dates/keys, uniqueness of person/location join keys, dates around death, and follow-up availability. These are proposed checks, not confirmed dataset defects. Leave the SQL unchanged until query drafts are approved and their results can be checked.

### 5. Uncertainty and chart reproduction remain incomplete

The interval 0.77–1.21 percentage points appears in the original story and chart, but its formula was not located in the inspected workbook ranges or repository. Save the calculation and assumptions, considering repeat stays and selection of the reference group. Synthetic-data bias is not resolved by a narrow confidence interval.

The image lacks a saved creation method. Record the workbook/chart range or chart-building file. Update the chart's ABC label and cost wording when regenerating it; its original pixels remain unchanged on this branch.

### 6. Audit evidence is promising and needs precise attribution

Keep the examples catching the missing visit table, invalid inpatient-cost assumption, and stay-versus-patient wording. They show consequential judgment. Entry 6 is still pending. Entry 8 establishes only what was visible in a preview. Entries 10 and 13 need exact conversion-code links. Preserve the record and add later resolutions; do not retrofit evidence that is unavailable.

## What remains to do

1. Confirm the cohort and outcome definitions using approved check queries. No BigQuery access or executed results were available for this review.
2. Save the interval and chart steps, and reconcile the excluded state category.
3. Agree on the model scope, split, and prioritization capacity, then train and compare with the baseline within the student account's limits.
4. Use the audit skill during real student work and refine it from observed behavior. It has been structurally validated and reviewed against representative evidence cases; it has not yet been evaluated in a live student session.

The review preserves the existing unstaged deletion of `visuals/notes.md`; it is not part of the proposal commit.
