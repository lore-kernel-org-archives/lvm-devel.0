From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 29 Jun 2012 08:38:38 +0000 (UTC)
Subject: master - cleanup: static volume filter fn, lvm.conf comment
Message-ID: <20120629083838.BFB9E1707@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ec8f377748f4922d6a18ff0136e9a93f1d0b3f86
Commit:        ec8f377748f4922d6a18ff0136e9a93f1d0b3f86
Parent:        2cec4b4a7748cefe4e2b8adcd1c287af354e21fb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jun 29 10:28:53 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 29 10:28:53 2012 +0200

cleanup: static volume filter fn, lvm.conf comment

Change 'lv_passes_volumes_filter' fn back to static as it's not
actually needed in the other code (a remnant from devel version).
Fix lvm.conf comment referencing '--autoactivate' which was finally
decided to be '--activate ay'.
---
 doc/example.conf.in     |    6 +++---
 lib/activate/activate.c |   10 +++++-----
 lib/activate/activate.h |    3 ---
 3 files changed, 8 insertions(+), 11 deletions(-)

diff --git a/doc/example.conf.in b/doc/example.conf.in
index 4864b81..fbb9271 100644
--- a/doc/example.conf.in
+++ b/doc/example.conf.in
@@ -550,9 +550,9 @@ activation {
     #
     # volume_list = [ "vg1", "vg2/lvol1", "@tag1", "@*" ]
 
-    # If auto_activation_volume_list is defined, each LV that is to be activated
-    # is checked against the list while using the --autoactivate option, and if
-    # it matches, it is activated.
+    # If auto_activation_volume_list is defined, each LV that is to be
+    # activated is checked against the list while using the autoactivation
+    # option (--activate ay/-a ay), and if it matches, it is activated.
     #   "vgname" and "vgname/lvname" are matched exactly.
     #   "@tag" matches any tag set in the LV or VG.
     #   "@*" matches if any tag defined on the host is also set in the LV or VG
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 939de6c..3156f01 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -328,8 +328,8 @@ int activation(void)
 	return _activation;
 }
 
-int lv_passes_volumes_filter(struct cmd_context *cmd, struct logical_volume *lv,
-			     const struct dm_config_node *cn, const char *config_path)
+static int _lv_passes_volumes_filter(struct cmd_context *cmd, struct logical_volume *lv,
+				     const struct dm_config_node *cn, const char *config_path)
 {
 	const struct dm_config_value *cv;
 	const char *str;
@@ -427,7 +427,7 @@ static int _passes_activation_filter(struct cmd_context *cmd,
 		return 0;
 	}
 
-	return lv_passes_volumes_filter(cmd, lv, cn, "activation/volume_list");
+	return _lv_passes_volumes_filter(cmd, lv, cn, "activation/volume_list");
 }
 
 static int _passes_readonly_filter(struct cmd_context *cmd,
@@ -438,7 +438,7 @@ static int _passes_readonly_filter(struct cmd_context *cmd,
 	if (!(cn = find_config_tree_node(cmd, "activation/read_only_volume_list")))
 		return 0;
 
-	return lv_passes_volumes_filter(cmd, lv, cn, "activation/read_only_volume_list");
+	return _lv_passes_volumes_filter(cmd, lv, cn, "activation/read_only_volume_list");
 }
 
 
@@ -452,7 +452,7 @@ int lv_passes_auto_activation_filter(struct cmd_context *cmd, struct logical_vol
 		return 1;
 	}
 
-	return lv_passes_volumes_filter(cmd, lv, cn, "activation/auto_activation_volume_list");
+	return _lv_passes_volumes_filter(cmd, lv, cn, "activation/auto_activation_volume_list");
 }
 
 int library_version(char *version, size_t size)
diff --git a/lib/activate/activate.h b/lib/activate/activate.h
index f698fc9..f473a11 100644
--- a/lib/activate/activate.h
+++ b/lib/activate/activate.h
@@ -93,9 +93,6 @@ int lv_check_not_in_use(struct cmd_context *cmd, struct logical_volume *lv,
  */
 int lv_activation_filter(struct cmd_context *cmd, const char *lvid_s,
 			 int *activate_lv);
-int lv_passes_volumes_filter(struct cmd_context *cmd, struct logical_volume *lv,
-			     const struct dm_config_node *cn, const char *config_path);
-
 /*
  * Checks against the auto_activation_volume_list and
  * returns 1 if the LV should be activated, 0 otherwise.


