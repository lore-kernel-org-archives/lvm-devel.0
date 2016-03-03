From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  3 Mar 2016 13:20:29 +0000 (UTC)
Subject: master - conf: add metadata/lvs_history_timeout configuration setting
Message-ID: <20160303132029.4D0E860310@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff6e124a338d1dbdde3b6280784d599e504378ef
Commit:        ff6e124a338d1dbdde3b6280784d599e504378ef
Parent:        74272e163de8c62208d6de41d15631cf3ecf0b2c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 1 15:29:27 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 3 13:50:59 2016 +0100

conf: add metadata/lvs_history_timeout configuration setting

---
 lib/config/config_settings.h |    5 +++++
 lib/config/defaults.h        |    1 +
 lib/metadata/metadata.c      |    3 ++-
 3 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index b093351..1291109 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1367,6 +1367,11 @@ cfg(metadata_record_lvs_history_CFG, "record_lvs_history", metadata_CFG_SECTION,
 	"information kept in metadata for live LVs. Currently, this\n"
 	"feature is supported for thin and thin snapshot LVs only.\n")
 
+cfg(metadata_lvs_history_retention_time_CFG, "lvs_history_retention_time", metadata_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_LVS_HISTORY_RETENTION_TIME, vsn(2, 2, 145), NULL, 0, NULL,
+	"Retention time in seconds after which a record about individual\n"
+	"historical logical volume is automatically destroyed.\n"
+	"A value of 0 disables this feature.\n")
+
 cfg(metadata_pvmetadatacopies_CFG, "pvmetadatacopies", metadata_CFG_SECTION, CFG_ADVANCED | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_PVMETADATACOPIES, vsn(1, 0, 0), NULL, 0, NULL,
 	"Number of copies of metadata to store on each PV.\n"
 	"The --pvmetadatacopies option overrides this setting.\n"
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 6c7060a..fd7986c 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -129,6 +129,7 @@
 
 #define DEFAULT_STRIPESIZE 64	/* KB */
 #define DEFAULT_RECORD_LVS_HISTORY 0
+#define DEFAULT_LVS_HISTORY_RETENTION_TIME 0
 #define DEFAULT_PVMETADATAIGNORE 0
 #define DEFAULT_PVMETADATASIZE 255
 #define DEFAULT_PVMETADATACOPIES 1
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 417629b..a5cb15a 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4460,6 +4460,7 @@ struct volume_group *vg_read_internal(struct cmd_context *cmd, const char *vgnam
 			goto out;
 		}
 	}
+
 out:
 	if (!*consistent && (warn_flags & WARN_INCONSISTENT)) {
 		if (is_orphan_vg(vgname))
@@ -6013,7 +6014,7 @@ int is_lockd_type(const char *lock_type)
 int vg_strip_outdated_historical_lvs(struct volume_group *vg) {
 	struct glv_list *glvl, *tglvl;
 	time_t current_time = time(NULL);
-	uint64_t threshold = 0;
+	uint64_t threshold = find_config_tree_int(vg->cmd, metadata_lvs_history_retention_time_CFG, NULL);
 
 	if (!threshold)
 		return 1;


