From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 22 Jan 2010 09:15:31 -0500
Subject: [PATCH 2/3] Check LV's status before sleeping in _wait_for_single_lv.
In-Reply-To: <1264169732-8692-1-git-send-email-snitzer@redhat.com>
References: <1264169732-8692-1-git-send-email-snitzer@redhat.com>
Message-ID: <1264169732-8692-3-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Sleeping before checking status can lead to extraneous polldaemons being
left running.  These polldaemons would have otherwise exited had they
checked before sleeping.  This is by no means reliable (as it is still
racey with background polling) but it does help the polldaemons to
exit more reliably in strange corner case scenarios.

Checking before sleeping is used in _poll_for_all_vgs and I can't see
any reason why we'd benefit from not doing it in _wait_for_single_lv.
---
 tools/polldaemon.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 7fdc502..595d888 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -165,14 +165,6 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
 
 	/* Poll for completion */
 	while (!finished) {
-		/* FIXME Also needed in vg/lvchange -ay? */
-		/* FIXME Use alarm for regular intervals instead */
-		if (parms->interval && !parms->aborting) {
-			sleep(parms->interval);
-			/* Devices might have changed while we slept */
-			init_full_scan_done(0);
-		}
-
 		/* Locks the (possibly renamed) VG again */
 		vg = parms->poll_fns->get_copy_vg(cmd, name, uuid);
 		if (vg_read_error(vg)) {
@@ -196,6 +188,14 @@ static int _wait_for_single_lv(struct cmd_context *cmd, const char *name, const
 		}
 
 		unlock_and_release_vg(cmd, vg, vg->name);
+
+		/* FIXME Also needed in vg/lvchange -ay? */
+		/* FIXME Use alarm for regular intervals instead */
+		if (parms->interval && !parms->aborting) {
+			sleep(parms->interval);
+			/* Devices might have changed while we slept */
+			init_full_scan_done(0);
+		}
 	}
 
 	return 1;
-- 
1.6.6


