From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 27 May 2014 12:46:14 +0000 (UTC)
Subject: master - udev: also print subsystem udev flags in debug message about udev flags + fix typo DM_SUBSSYTEM_UDEV_FLAG7 -> DM_SUBSYSTEM_UDEV_FLAG7
Message-ID: <20140527124614.3995960EE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1569e7a4985776783fa0175ddfa6dd333a68b981
Commit:        1569e7a4985776783fa0175ddfa6dd333a68b981
Parent:        b3539907f582a924df1c056829a231d1d39e4cec
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue May 27 14:44:11 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue May 27 14:44:11 2014 +0200

udev: also print subsystem udev flags in debug message about udev flags + fix typo DM_SUBSSYTEM_UDEV_FLAG7 -> DM_SUBSYSTEM_UDEV_FLAG7

---
 libdm/libdevmapper.h |    2 +-
 libdm/libdm-common.c |   11 ++++++++++-
 2 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 990692c..386ef07 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1877,7 +1877,7 @@ struct dm_pool *dm_config_memory(struct dm_config_tree *cft);
 #define DM_SUBSYSTEM_UDEV_FLAG4 0x1000
 #define DM_SUBSYSTEM_UDEV_FLAG5 0x2000
 #define DM_SUBSYSTEM_UDEV_FLAG6 0x4000
-#define DM_SUBSSYTEM_UDEV_FLAG7 0x8000
+#define DM_SUBSYSTEM_UDEV_FLAG7 0x8000
 
 int dm_cookie_supported(void);
 
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index bb793e3..ea5b97e 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -2426,7 +2426,8 @@ int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 	dmt->cookie_set = 1;
 
 	log_debug_activation("Udev cookie 0x%" PRIx32 " (semid %d) assigned to "
-			     "%s task(%d) with flags%s%s%s%s%s%s%s (0x%" PRIx16 ")", *cookie, semid, _task_type_disp(dmt->type), dmt->type, 
+			     "%s task(%d) with flags%s%s%s%s%s%s%s%s%s%s%s%s%s%s%s (0x%" PRIx16 ")",
+			     *cookie, semid, _task_type_disp(dmt->type), dmt->type,
 			     (flags & DM_UDEV_DISABLE_DM_RULES_FLAG) ? " DISABLE_DM_RULES" : "",
 			     (flags & DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG) ? " DISABLE_SUBSYSTEM_RULES" : "",
 			     (flags & DM_UDEV_DISABLE_DISK_RULES_FLAG) ? " DISABLE_DISK_RULES" : "",
@@ -2434,6 +2435,14 @@ int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags)
 			     (flags & DM_UDEV_LOW_PRIORITY_FLAG) ? " LOW_PRIORITY" : "",
 			     (flags & DM_UDEV_DISABLE_LIBRARY_FALLBACK) ? " DISABLE_LIBRARY_FALLBACK" : "",
 			     (flags & DM_UDEV_PRIMARY_SOURCE_FLAG) ? " PRIMARY_SOURCE" : "",
+			     (flags & DM_SUBSYSTEM_UDEV_FLAG0) ? " SUBSYSTEM_0" : " ",
+			     (flags & DM_SUBSYSTEM_UDEV_FLAG1) ? " SUBSYSTEM_1" : " ",
+			     (flags & DM_SUBSYSTEM_UDEV_FLAG2) ? " SUBSYSTEM_2" : " ",
+			     (flags & DM_SUBSYSTEM_UDEV_FLAG3) ? " SUBSYSTEM_3" : " ",
+			     (flags & DM_SUBSYSTEM_UDEV_FLAG4) ? " SUBSYSTEM_4" : " ",
+			     (flags & DM_SUBSYSTEM_UDEV_FLAG5) ? " SUBSYSTEM_5" : " ",
+			     (flags & DM_SUBSYSTEM_UDEV_FLAG6) ? " SUBSYSTEM_6" : " ",
+			     (flags & DM_SUBSYSTEM_UDEV_FLAG7) ? " SUBSYSTEM_7" : " ",
 			     flags);
 
 	return 1;


