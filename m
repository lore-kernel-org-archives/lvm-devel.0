From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 20 Nov 2014 15:53:13 +0000 (UTC)
Subject: master - lvchange: Accept --cachepolicy.
Message-ID: <20141120155313.7B14760DBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c164f59631ca08f56c5f1e2e6cf677f3a85145fb
Commit:        c164f59631ca08f56c5f1e2e6cf677f3a85145fb
Parent:        f67e1fadb0fcdc5887663f9b0c9c46fc5835d418
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Nov 19 18:39:58 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 20 16:51:07 2014 +0100

lvchange: Accept --cachepolicy.

---
 tools/commands.h |    3 ++-
 tools/lvchange.c |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 34 insertions(+), 1 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index d4473a4..e3bac1f 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -106,6 +106,7 @@ xx(lvchange,
    "\t[--addtag Tag]\n"
    "\t[--alloc AllocationPolicy]\n"
    "\t[-C|--contiguous y|n]\n"
+   "\t[--cachepolicy policy=type] [--cachepolicy parameter=value]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[--deltag Tag]\n"
@@ -143,7 +144,7 @@ xx(lvchange,
 
    activationmode_ARG, addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG,
    available_ARG,
-   contiguous_ARG, deltag_ARG, discards_ARG, detachprofile_ARG, force_ARG,
+   cachepolicy_ARG, contiguous_ARG, deltag_ARG, discards_ARG, detachprofile_ARG, force_ARG,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, ignoreactivationskip_ARG,
    ignoreskippedcluster_ARG, major_ARG, metadataprofile_ARG, minor_ARG,
    monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG, noudevsync_ARG,
diff --git a/tools/lvchange.c b/tools/lvchange.c
index e0bb4b1..144295b 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -605,6 +605,30 @@ static int lvchange_persistent(struct cmd_context *cmd,
 	return 1;
 }
 
+static int lvchange_cachepolicy(struct cmd_context *cmd, struct logical_volume *lv)
+{
+	struct dm_config_tree *policy = NULL;
+	int r = 0;
+
+	if (!lv_is_cache(lv) && !lv_is_cache_pool(lv)) {
+		log_error("LV %s is not a cache LV.", lv->name);
+		log_error("Only cache or cache pool devices can have --cachepolicy set.");
+		goto_out;
+	}
+
+	if (!(policy = get_cachepolicy_params(cmd)))
+		goto_out;
+	if (!lv_cache_setpolicy(lv, policy))
+		goto_out;
+	if (!lv_update_and_reload(lv))
+		goto_out;
+	r = 1;
+out:
+	if (policy)
+		dm_config_destroy(policy);
+	return r;
+}
+
 static int lvchange_tag(struct cmd_context *cmd, struct logical_volume *lv, int arg)
 {
 	if (!change_tag(cmd, NULL, lv, NULL, arg))
@@ -990,6 +1014,13 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		docmds++;
 	}
 
+	if (arg_count(cmd, cachepolicy_ARG)) {
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
+		doit += lvchange_cachepolicy(cmd, lv);
+		docmds++;
+	}
+
 	if (doit)
 		log_print_unless_silent("Logical volume \"%s\" changed.", lv->name);
 
@@ -1049,6 +1080,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		arg_count(cmd, maxrecoveryrate_ARG) ||
 		arg_count(cmd, resync_ARG) ||
 		arg_count(cmd, syncaction_ARG) ||
+		arg_count(cmd, cachepolicy_ARG) ||
 		arg_count(cmd, writebehind_ARG) ||
 		arg_count(cmd, writemostly_ARG) ||
 		arg_count(cmd, zero_ARG);


