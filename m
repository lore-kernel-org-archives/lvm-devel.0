From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 14 Nov 2012 20:59:25 +0000 (UTC)
Subject: master - mirror: Mirrored log should be fixed before mirror when double fault occurs
Message-ID: <20121114205925.D2DA7A0C24@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=54c73b7723713f43413584d59ca0bdd42c1d8241
Commit:        54c73b7723713f43413584d59ca0bdd42c1d8241
Parent:        7a34db0cfdeab53e56182c7499214016a93706b2
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Nov 14 14:58:47 2012 -0600
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Nov 14 14:58:47 2012 -0600

mirror:  Mirrored log should be fixed before mirror when double fault occurs

This patch is intended to fix bug 825323 - FS turns read-only during a double
fault of a mirror leg and mirrored log's leg at the same time.  It only
affects a 2-way mirror with a mirrored log.  3+-way mirrors and mirrors
without a mirrored log are not affected.

The problem resulted from the fact that the top level mirror was not
using 'noflush' when suspending before its "down-convert".  When a
mirror image fails, the bios are queue until a suspend is recieved.  If
it is a 'noflush' suspend, the bios can be safely requeued in the DM
core.  If 'noflush' is not used, the bios must be pushed through the
target and if a device is failed for a mirror, that means issuing an
error.  When an error is received by a file system, it results in it
turning read-only (depending on the FS).

Part of the problem was is due to the nature of the stacking involved in
using a mirror as a mirror's log.  When an image in each fail, the top
level mirror stalls because it is waiting for a log flush.  The other
stalls waiting for corrective action.  When the repair command is issued,
the entire stacked arrangement is collapsed to a linear LV.  The log
flush then fails (somewhat uncleanly) and the top-level mirror is suspended
without 'noflush' because it is a linear device.

This patch allows the log to be repaired first, which in turn allows the
top-level mirror's log flush to complete cleanly.  The top-level mirror
is then secondarily reduced to a linear device - at which time this mirror
is suspended properly with 'noflush'.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    8 ++------
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 972d87b..8117165 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Mirrored log is now fixed before its mirror when double-fault occurs.
   Add python-lvm unit test case
   Exit pvscan --cache immediately if cluster locking used or lvmetad not used.
   Don't use lvmetad in lvm2-monitor.service ExecStop to avoid a systemd issue.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index f23fc4b..27d8181 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1341,10 +1341,6 @@ int mirror_remove_missing(struct cmd_context *cmd,
 	if (!(failed_pvs = _failed_pv_list(lv->vg)))
 		return_0;
 
-	/* No point in keeping a log if the result is not a mirror */
-	if (_failed_mirrors_count(lv) + 1 >= lv_mirror_count(lv))
-		log_count = 0;
-
         if (force && _failed_mirrors_count(lv) == lv_mirror_count(lv)) {
 		log_error("No usable images left in %s.", lv->name);
 		return lv_remove_with_dependencies(cmd, lv, DONT_PROMPT, 0);
@@ -1363,8 +1359,8 @@ int mirror_remove_missing(struct cmd_context *cmd,
 			       _is_partial_lv, NULL, 0))
 		return 0;
 
-	if (!_lv_update_log_type(cmd, NULL, lv, failed_pvs,
-				 log_count))
+	if (lv_is_mirrored(lv) &&
+	    !_lv_update_log_type(cmd, NULL, lv, failed_pvs, log_count))
 		return 0;
 
 	if (!_reload_lv(cmd, lv->vg, lv))


