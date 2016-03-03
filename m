From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:20 +0000 (UTC)
Subject: master - conf: add metadata/record_lvs_history configuration setting
Message-ID: <20160303132020.E1CE960308@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ccebf3100deec6196c1a66301a36cad6892ff0aa
Commit:        ccebf3100deec6196c1a66301a36cad6892ff0aa
Parent:        b1399090cd7db6d16e10ddf0a7b0ca72e254c63c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:25:49 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:49:15 2016 +0100

conf: add metadata/record_lvs_history configuration setting

The metadata/record_lvs_history is global switch which enables or
disables recording historical LVs in metadata.

If both metadata/record_lvs_history=1 lvm.conf option and
--nohistory command switch is used at the same time, the
--nohistory prevails.
---
 lib/config/config_settings.h |    7 +++++++
 lib/config/defaults.h        |    1 +
 tools/lvmcmdline.c           |    4 ++--
 3 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 95eb8ee..b093351 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1360,6 +1360,13 @@ cfg(metadata_check_pv_device_sizes_CFG, "check_pv_device_sizes", metadata_CFG_SE
 	"less than corresponding PV size. You should not disable this unless\n"
 	"you are absolutely sure about what you are doing!\n")
 
+cfg(metadata_record_lvs_history_CFG, "record_lvs_history", metadata_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, DEFAULT_RECORD_LVS_HISTORY, vsn(2, 2, 145), NULL, 0, NULL,
+	"When enabled, LVM keeps history records about removed LVs in\n"
+	"metadata. The information that is recorded in metadata for\n"
+	"historical LVs is reduced when compared to original\n"
+	"information kept in metadata for live LVs. Currently, this\n"
+	"feature is supported for thin and thin snapshot LVs only.\n")
+
 cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_PVMETADATACOPIES, vsn(1, 0, 0), NULL, 0, NULL,
 	"Number of copies of metadata to store on each PV.\n"
 	"The --pvmetadatacopies option overrides this setting.\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 648a168..6c7060a 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -128,6 +128,7 @@
 #define DEFAULT_FORMAT "lvm2"
 
 #define DEFAULT_STRIPESIZE 64	/* KB */
+#define DEFAULT_RECORD_LVS_HISTORY 0
 #define DEFAULT_PVMETADATAIGNORE 0
 #define DEFAULT_PVMETADATASIZE 255
 #define DEFAULT_PVMETADATACOPIES 1
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index ffe8447..72570f7 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1102,8 +1102,8 @@ static int _get_settings(struct cmd_context *cmd)
 	cmd->include_foreign_vgs = arg_is_set(cmd, foreign_ARG) ? 1 : 0;
 	cmd->include_shared_vgs = arg_is_set(cmd, shared_ARG) ? 1 : 0;
 	cmd->include_historical_lvs = arg_is_set(cmd, history_ARG) ? 1 : 0;
-	cmd->include_historical_lvs = arg_is_set(cmd, history_ARG) ? 1 : 0;
-	cmd->record_historical_lvs = arg_is_set(cmd, nohistory_ARG) ? 0 : 1;
+	cmd->record_historical_lvs = find_config_tree_bool(cmd, metadata_record_lvs_history_CFG, NULL) ?
+							  (arg_is_set(cmd, nohistory_ARG) ? 0 : 1) : 0;
 
 	/*
 	 * This is set to zero by process_each which wants to print errors


