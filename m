From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 20 Jan 2015 14:02:55 +0000 (UTC)
Subject: master - thin: lvchange support for errorwhenfull
Message-ID: <20150120140255.99DBF60E94@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=64d8ed502d29a1f19416280bb0e3f346e7f2668c
Commit:        64d8ed502d29a1f19416280bb0e3f346e7f2668c
Parent:        07eb1c7dc897fe75e45f1284301f0673a90ad70a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 15 15:20:08 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 20 14:53:03 2015 +0100

thin: lvchange support for errorwhenfull

Support lvchange --errorwhenfull y|n for thin pools.
---
 WHATS_NEW        |    1 +
 tools/commands.h |    4 +++-
 tools/lvchange.c |   36 ++++++++++++++++++++++++++++++++++++
 3 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4261801..0c96d5b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Support lvchange --errorwhenfull for thin pools.
   Improve the processing and reporting of duplicate PVs.
   Report lv_health_status and health attribute also for thin pool.
   Add lv_error_when_full reporting field.
diff --git a/tools/commands.h b/tools/commands.h
index 6eb8cc5..7bfc800 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -111,6 +111,7 @@ xx(lvchange,
    "\t[-d|--debug]\n"
    "\t[--deltag Tag]\n"
    "\t[--detachprofile]\n"
+   "\t[--errorwhenfull {y|n}]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
    "\t[--discards {ignore|nopassdown|passdown}]\n"
@@ -144,7 +145,8 @@ xx(lvchange,
 
    activationmode_ARG, addtag_ARG, alloc_ARG, autobackup_ARG, activate_ARG,
    available_ARG,
-   cachepolicy_ARG, cachesettings_ARG, contiguous_ARG, deltag_ARG, discards_ARG, detachprofile_ARG, force_ARG,
+   cachepolicy_ARG, cachesettings_ARG, contiguous_ARG, deltag_ARG, discards_ARG,
+   detachprofile_ARG, errorwhenfull_ARG, force_ARG,
    ignorelockingfailure_ARG, ignoremonitoring_ARG, ignoreactivationskip_ARG,
    ignoreskippedcluster_ARG, major_ARG, metadataprofile_ARG, minor_ARG,
    monitor_ARG, minrecoveryrate_ARG, maxrecoveryrate_ARG, noudevsync_ARG,
diff --git a/tools/lvchange.c b/tools/lvchange.c
index d9003b4..8a175e0 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -487,6 +487,28 @@ static int lvchange_alloc(struct cmd_context *cmd, struct logical_volume *lv)
 	return 1;
 }
 
+static int lvchange_errorwhenfull(struct cmd_context *cmd,
+				  struct logical_volume *lv)
+{
+	unsigned ewf = arg_int_value(cmd, errorwhenfull_ARG, 0);
+
+	if (ewf == lv_is_error_when_full(lv)) {
+		log_error("Error when full is already %sset for %s.",
+			  (ewf) ? "" : "un", display_lvname(lv));
+		return 0;
+	}
+
+	if (ewf)
+		lv->status |= LV_ERROR_WHEN_FULL;
+	else
+		lv->status &= ~LV_ERROR_WHEN_FULL;
+
+	if (!lv_update_and_reload(lv))
+		return_0;
+
+	return 1;
+}
+
 static int lvchange_readahead(struct cmd_context *cmd,
 			      struct logical_volume *lv)
 {
@@ -910,6 +932,11 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		}
 	}
 
+	if (arg_is_set(cmd, errorwhenfull_ARG) && !lv_is_thin_pool(lv)) {
+		log_error("Option --errorwhenfull is only supported with thin pools.");
+		return ECMD_FAILED;
+	}
+
 	/*
 	 * FIXME: DEFAULT_BACKGROUND_POLLING should be "unspecified".
 	 * If --poll is explicitly provided use it; otherwise polling
@@ -939,6 +966,14 @@ static int _lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 		docmds++;
 	}
 
+	/* error when full change */
+	if (arg_count(cmd, errorwhenfull_ARG)) {
+		if (!archive(lv->vg))
+			return_ECMD_FAILED;
+		doit += lvchange_errorwhenfull(cmd, lv);
+		docmds++;
+	}
+
 	/* read ahead sector change */
 	if (arg_count(cmd, readahead_ARG)) {
 		if (!archive(lv->vg))
@@ -1076,6 +1111,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 	int update_partial_unsafe =
 		arg_count(cmd, alloc_ARG) ||
 		arg_count(cmd, discards_ARG) ||
+		arg_count(cmd, errorwhenfull_ARG) ||
 		arg_count(cmd, minrecoveryrate_ARG) ||
 		arg_count(cmd, maxrecoveryrate_ARG) ||
 		arg_count(cmd, resync_ARG) ||


