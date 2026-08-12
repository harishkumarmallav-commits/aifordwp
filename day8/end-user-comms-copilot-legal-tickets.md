# End-User Communications – Copilot Legal Team Tickets

**Date:** 2026-08-12  
**Purpose:** Plain-English user-facing responses for each ticket, with the next step clearly stated.

---

## Ticket CL-001
**User:** Paralegal  
**User issue:** Asked Copilot to summarise a client NDA in SharePoint and received "I don't have access to that content." She heard about the file in a meeting but has never opened or navigated to the folder herself.

**End-user communication:**

Hi, thanks for reporting this. The message you received usually means Copilot cannot reach that file, and the most likely reason is that you do not yet have direct permissions to the folder it is stored in. Knowing about a file from a meeting is not the same as having been granted access to it — SharePoint permissions need to be set up separately.

Before we do anything else, could you try navigating to the folder in SharePoint and opening the NDA directly? If you see an access error there too, that confirms it is a permissions issue rather than a Copilot problem. If you can open it fine, please let us know and we will investigate further from there.

**Next step:**  
Ask the user to confirm whether she can open the file manually in SharePoint. If not, raise a permissions request with the site or folder owner. If she can open it, the service desk will investigate the document's sensitivity settings and Copilot access path.

---

## Ticket CL-002
**User:** New associate (started this week)  
**User issue:** Copilot in Outlook cannot find or provide context on case emails they need.

**End-user communication:**

Hi, welcome to the team and thanks for flagging this. Because you only started this week, the most likely explanation is that your mailbox content has not yet been fully indexed by the background systems that Copilot relies on to find emails. This is normal for new accounts and usually resolves on its own within 24 to 72 hours.

To help us narrow it down — can you check whether the standard Outlook search bar finds those same emails? If normal search works but Copilot cannot see them, it is almost certainly just the indexing catching up. If standard search is also not finding the emails, there may be a separate question about which mailbox or folder they are in that we should check together.

**Next step:**  
Confirm whether standard Outlook search finds the emails. If yes, advise the user to allow up to 72 hours for Copilot indexing to complete and to re-test. If no, investigate whether the case emails are in a shared mailbox or location the user has not yet been added to.

---

## Ticket CL-003
**User:** Partner  
**User issue:** Copilot surfaced and summarised a draft settlement document from a matter the partner is not assigned to. The partner was not aware they could see that folder.

**End-user communication:**

Hi, thank you for reporting this — it is exactly the kind of thing we need to know about and you were right to flag it.

What happened is that Copilot found a document you already had permission to access, even though that was not intentional. Copilot only ever surfaces content you are permitted to see, so this tells us that your account has access to that matter folder when it should not. This is a permissions configuration issue, not a fault with Copilot itself.

We are treating this as a data governance matter and will be reviewing the permissions on that folder urgently. In the meantime, please avoid accessing or sharing the document or its contents. We will update you once we have reviewed the scope and taken corrective action.

**Next step:**  
Escalate to the information security or DLP team as a compliance finding. Review and remediate the permissions on the matter folder. Determine the full scope — whether other unassigned users have the same access — before closing the finding. Update the partner once remediation is confirmed.

---

## Ticket CL-004
**User:** Legal ops manager  
**User issue:** All 40 members of the Legal team lost Copilot access simultaneously this morning. It was working last week.

**End-user communication:**

Hi, thank you for raising this. Because the whole Legal team has been affected at the same time, we are treating this as a high-priority issue.

A simultaneous failure like this is almost always caused by a change at the service level — such as a licence update, a policy change, or a configuration change — rather than anything individual users have done. This means the fix, once identified, should restore access for everyone at once.

We are investigating now and will update you as soon as we have identified the cause. There is no action needed from your team at this stage.

**Next step:**  
Check licence assignment status for affected accounts in the Microsoft 365 admin centre. Review the audit log for changes made overnight or this morning. Check Microsoft 365 service health for Copilot. Contact the change management team if no admin-centre explanation is found. Provide an update to the legal ops manager once root cause is identified.

---

## Ticket CL-005
**User:** Contract specialist  
**User issue:** Copilot gives vague, generic answers when asked about clauses in the contract templates library and does not appear to be reading the actual documents.

**End-user communication:**

Hi, thanks for raising this. When Copilot gives general answers rather than drawing on specific documents, it usually means it is not connecting to the files you have in mind — rather than reading your contract templates, it is falling back on general knowledge.

A couple of things can cause this. The first is how the question is phrased: Copilot works best when you reference a specific file or document directly in your prompt, rather than asking generically about a topic. The second is that some document libraries have protection settings that prevent Copilot from reading their content, even when you can open the files yourself.

Could you send us an example of a prompt you used and the response you got? That will help us understand whether this is a prompting approach we can adjust, or a settings issue we need to investigate on the library.

**Next step:**  
Ask the user to share an example prompt and Copilot response. Check whether the contract templates library is indexed in Microsoft 365 Search. Review whether documents carry sensitivity labels that block Copilot grounding. If prompting approach is the issue, provide guidance on referencing specific files in Copilot queries.
