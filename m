From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Fri, 10 Jul 2015 14:23:48 +0000 (UTC)
Subject: master - lvmpolld: Fix segfault on 32 bit architectures
Message-ID: <20150710142348.DF1F060F36@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=738ae4a77f3e28b408c2a401ebce6db6949395b0
Commit:        738ae4a77f3e28b408c2a401ebce6db6949395b0
Parent:        47ac6a1a2eedd191ac69dea45490f8104b596fc5
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Jul 10 11:50:06 2015 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Jul 10 16:16:57 2015 +0200

lvmpolld: Fix segfault on 32 bit architectures

Explicit conversions are needed to align writes and reads on the stack.
int64_t is popped from stack while int was pushed.
---
 WHATS_NEW                        |    1 +
 daemons/lvmpolld/lvmpolld-core.c |    2 +-
 lib/lvmpolld/lvmpolld-client.c   |    6 +++---
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index f3da3e0..4fd027c 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.126 -
 ================================
+  Fix lvmpolld segfaults on 32 bit architectures.
   Fix ignored --startstopservices option if running lvmconf with systemd.
 
 Version 2.02.125 - 7th July 2015
diff --git a/daemons/lvmpolld/lvmpolld-core.c b/daemons/lvmpolld/lvmpolld-core.c
index 9d46c7e..1da2da2 100644
--- a/daemons/lvmpolld/lvmpolld-core.c
+++ b/daemons/lvmpolld/lvmpolld-core.c
@@ -529,7 +529,7 @@ static response progress_info(client_handle h, struct lvmpolld_state *ls, reques
 		if (st.polling_finished)
 			r = daemon_reply_simple(LVMPD_RESP_FINISHED,
 						"reason = %s", st.cmd_state.signal ? LVMPD_REAS_SIGNAL : LVMPD_REAS_RETCODE,
-						LVMPD_PARM_VALUE " = %d", st.cmd_state.signal ?: st.cmd_state.retcode,
+						LVMPD_PARM_VALUE " = %d", (int64_t)(st.cmd_state.signal ?: st.cmd_state.retcode),
 						NULL);
 		else
 			r = daemon_reply_simple(LVMPD_RESP_IN_PROGRESS, NULL);
diff --git a/lib/lvmpolld/lvmpolld-client.c b/lib/lvmpolld/lvmpolld-client.c
index 8be2d7b..f7faa8b 100644
--- a/lib/lvmpolld/lvmpolld-client.c
+++ b/lib/lvmpolld/lvmpolld-client.c
@@ -147,7 +147,7 @@ static struct progress_info _request_progress_info(const char *uuid, unsigned ab
 	}
 
 	if (abort_polling &&
-	    !daemon_request_extend(req, LVMPD_PARM_ABORT " = %d", abort_polling, NULL)) {
+	    !daemon_request_extend(req, LVMPD_PARM_ABORT " = %d", (int64_t)abort_polling, NULL)) {
 		log_error("Failed to create " LVMPD_REQ_PROGRESS " request.");
 		goto out_req;
 	}
@@ -228,14 +228,14 @@ static int _process_poll_init(const struct cmd_context *cmd, const char *poll_ty
 	}
 
 	if (parms->aborting &&
-	    !(daemon_request_extend(req, LVMPD_PARM_ABORT " = %d", parms->aborting, NULL))) {
+	    !(daemon_request_extend(req, LVMPD_PARM_ABORT " = %d", (int64_t)(parms->aborting), NULL))) {
 		log_error("Failed to create %s request." , poll_type);
 		goto out_req;
 	}
 
 	if (cmd->handles_missing_pvs &&
 	    !(daemon_request_extend(req, LVMPD_PARM_HANDLE_MISSING_PVS " = %d",
-				    cmd->handles_missing_pvs, NULL))) {
+				    (int64_t)(cmd->handles_missing_pvs), NULL))) {
 		log_error("Failed to create %s request." , poll_type);
 		goto out_req;
 	}


