From: David Teigland <teigland@sourceware.org>
Date: Mon, 7 Aug 2017 11:53:13 -0400
Subject: master - lvmlockd: fix lm running check during adoption
Message-ID: <201708071553.v77FrDsd023063@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=568c7ed6f1a1df23b9843a54b0bc53816ac5f621
Commit:        568c7ed6f1a1df23b9843a54b0bc53816ac5f621
Parent:        fe423ef583a48ca0f780156ec5f1fe33716318ad
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Aug 7 10:37:22 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 7 10:45:59 2017 -0500

lvmlockd: fix lm running check during adoption

When trying to adopt locks in startup, we want to ignore
a lock manager that isn't running, not fail.
---
 WHATS_NEW                        |    1 +
 daemons/lvmlockd/lvmlockd-core.c |   11 ++++-------
 2 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ebbc7d1..c484529 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.174 - 
 =================================
+  Fix lvmlockd check for running lock managers during lock adoption.
   Add --withgeneralpreamble and --withlocalpreamble to lvmconfig.
   Improve makefiles' linking.
   Fix some paths in generated makefiles to respected configured settings.
diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 867e3ca..5f08bbf 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -5176,20 +5176,17 @@ static void adopt_locks(void)
 	 * Get list of lockspaces from lock managers.
 	 * Get list of VGs from lvmetad with a lockd type.
 	 * Get list of active lockd type LVs from /dev.
-	 *
-	 * ECONNREFUSED means the lock manager is not running.
-	 * This is expected for at least one of them.
 	 */
 
-	if (lm_support_dlm()) {
+	if (lm_support_dlm() && lm_is_running_dlm()) {
 		rv = lm_get_lockspaces_dlm(&ls_found);
-		if ((rv < 0) && (rv != -ECONNREFUSED))
+		if (rv < 0)
 			goto fail;
 	}
 
-	if (lm_support_sanlock()) {
+	if (lm_support_sanlock() && lm_is_running_sanlock()) {
 		rv = lm_get_lockspaces_sanlock(&ls_found);
-		if ((rv < 0) && (rv != -ECONNREFUSED))
+		if (rv < 0)
 			goto fail;
 	}
 


