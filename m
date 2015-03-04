From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  4 Mar 2015 09:48:36 +0000 (UTC)
Subject: master - vgremove: select: direct selection to be done per-VG, not per-LV
Message-ID: <20150304094836.AEDF860D70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e73dad787439c1376dfa00fef6d1ee0f18f42c9b
Commit:        e73dad787439c1376dfa00fef6d1ee0f18f42c9b
Parent:        bfbb5d269aa1ed56d9308117b57d4d2da49d53f6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Mar 4 10:44:31 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Mar 4 10:44:31 2015 +0100

vgremove: select: direct selection to be done per-VG, not per-LV

Though vgremove operates per VG by definition, internally, it
actually means iterating over each LV it contains to do the
remove.

So we need to direct selection a bit in this case so that the
selection is done per-VG, not per-LV.

That means, use processing handle with void_handle.internal_report_for_select=0
for the process_each_lv_in_vg that is called later in vgremove_single fn.
We need to disable internal selection for process_each_lv_in_vg
here as selection is already done by process_each_vg which calls
vgremove_single. Otherwise selection would be done per-LV and not
per-VG as we intend!

An intra-release fix for commit 00744b053f395be79ab1cb80fdf7342548aa79e2.
---
 test/shell/select-tools.sh |   10 ++++++++++
 tools/vgremove.c           |   16 +++++++++++++++-
 2 files changed, 25 insertions(+), 1 deletions(-)

diff --git a/test/shell/select-tools.sh b/test/shell/select-tools.sh
index c418716..1738a45 100644
--- a/test/shell/select-tools.sh
+++ b/test/shell/select-tools.sh
@@ -263,3 +263,13 @@ not check pv_field $dev2 pv_tags "309,tag"
 not check pv_field $dev3 pv_tags "309,tag"
 not check pv_field $dev4 pv_tags "309,tag"
 pvchange -a --deltag 309 --deltag tag
+
+#########################
+# special cases to test #
+#########################
+
+# if calling vgremove, make sure we're doing selection per-VG, not per-LV
+# (vgremove calls process_each_vg with vgremove_single which itself
+# iterates over LVs with process_each_lv_in_vg - so internally it actually
+# operates per-LV, but we still need the selection to be done per-VG)
+vgremove --yes -S 'lv_name=lv2' # should remove whole vg1, not just the lv2
diff --git a/tools/vgremove.c b/tools/vgremove.c
index 3ce0763..d33ab1b 100644
--- a/tools/vgremove.c
+++ b/tools/vgremove.c
@@ -20,6 +20,19 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 			   struct processing_handle *handle __attribute__((unused)))
 {
 	/*
+	 * Though vgremove operates per VG by definition, internally, it
+	 * actually means iterating over each LV it contains to do the remove.
+	 *
+	 * Use processing handle with void_handle.internal_report_for_select=0
+	 * for the process_each_lv_in_vg that is called later in this fn.
+	 * We need to disable internal selection for process_each_lv_in_vg
+	 * here as selection is already done by process_each_vg which calls
+	 * vgremove_single. Otherwise selection would be done per-LV and
+	 * not per-VG as we intend!
+	 */
+	struct processing_handle void_handle = {0};
+
+	/*
 	 * Single force is equivalent to sinle --yes
 	 * Even multiple --yes are equivalent to single --force
 	 * When we require -ff it cannot be replaces with -f -y
@@ -47,7 +60,8 @@ static int vgremove_single(struct cmd_context *cmd, const char *vg_name,
 				return ECMD_FAILED;
 			}
 		}
-		if ((ret = process_each_lv_in_vg(cmd, vg, NULL, NULL, 1, NULL,
+
+		if ((ret = process_each_lv_in_vg(cmd, vg, NULL, NULL, 1, &void_handle,
 						 (process_single_lv_fn_t)lvremove_single)) != ECMD_PROCESSED) {
 			stack;
 			return ret;


