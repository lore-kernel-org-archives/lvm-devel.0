From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 30 Nov 2018 19:08:06 -0500
Subject: master - gcc: avoid shadowing activate_lv
Message-ID: <201812010008.wB1086oP031224@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0d61a171520beeff0bf592458359d04257e2c780
Commit:        0d61a171520beeff0bf592458359d04257e2c780
Parent:        1aac59f82ac021afe8a0a7aa6059e068637db9ba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 30 21:50:41 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Dec 1 01:06:57 2018 +0100

gcc: avoid shadowing activate_lv

Function activate_lv() is already declared, avoid its shadowing.
activate.h:133: warning: shadowed declaration is here
---
 lib/activate/activate.c |    8 ++++----
 lib/activate/activate.h |    4 ++--
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index b1f7391..ce9d67c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2476,19 +2476,19 @@ out:
 
 /* Test if LV passes filter */
 int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
-			 int *activate_lv, const struct logical_volume *lv)
+			 int *activate, const struct logical_volume *lv)
 {
 	if (!activation()) {
-		*activate_lv = 1;
+		*activate = 1;
 		return 1;
 	}
 
 	if (!_passes_activation_filter(cmd, lv)) {
 		log_verbose("Not activating %s since it does not pass "
 			    "activation filter.", display_lvname(lv));
-		*activate_lv = 0;
+		*activate = 0;
 	} else
-		*activate_lv = 1;
+		*activate = 1;
 
 	return 1;
 }
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index 8f9c918..aa5410c 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -162,10 +162,10 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 int lv_check_not_in_use(const struct logical_volume *lv, int error_if_used);
 
 /*
- * Returns 1 if activate_lv has been set: 1 = activate; 0 = don't.
+ * Returns 1 if activate has been set: 1 = activate; 0 = don't.
  */
 int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
-			 int *activate_lv, const struct logical_volume *lv);
+			 int *activate, const struct logical_volume *lv);
 /*
  * Checks against the auto_activation_volume_list and
  * returns 1 if the LV should be activated, 0 otherwise.


