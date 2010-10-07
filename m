From: Peter Jones <pjones@redhat.com>
Date: Thu,  7 Oct 2010 15:34:29 -0400
Subject: [PATCH] Add dm_task_set_newuuid().
Message-ID: <1286480069-18605-1-git-send-email-pjones@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This adds dm_task_set_newuuid(), which allows callers to assign a uuid
to an existing map if a uuid has not been set before.  This goes with
the patch sent to dm-devel earlier today to implement the kernel side.
---
 libdm/ioctl/libdm-iface.c   |   24 ++++++++++++++++++++++++
 libdm/ioctl/libdm-targets.h |    1 +
 libdm/libdevmapper.h        |    1 +
 3 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 5ba6634..0c82759 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1185,6 +1185,22 @@ int dm_task_suppress_identical_reload(struct dm_task *dmt)
 	return 1;
 }
 
+int dm_task_set_newuuid(struct dm_task *dmt, const char *newuuid)
+{
+	if (strlen(newuuid) >= DM_UUID_LEN) {
+		log_error("Uuid \"%s\" too long", newuuid);
+		return 0;
+	}
+
+	if (!(dmt->newname = dm_strdup(newuuid))) {
+		log_error("dm_task_set_newuuid: strdup(%s) failed", newuuid);
+		return 0;
+	}
+	dmt->new_uuid = 1;
+
+	return 1;
+}
+
 int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 {
 	if (strchr(newname, '/')) {
@@ -1514,6 +1530,14 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 				 "by kernel.  It will use live table.");
 		dmi->flags |= DM_QUERY_INACTIVE_TABLE_FLAG;
 	}
+	if (dmt->new_uuid) {
+		if (_dm_version_minor < 19) {
+			log_error("WARNING: Updating UUID unsupported by "
+				  "kernel.");
+			goto bad;
+		}
+		dmi->flags |= DM_NEW_UUID_FLAG;
+	}
 
 	dmi->target_count = count;
 	dmi->event_nr = dmt->event_nr;
diff --git a/libdm/ioctl/libdm-targets.h b/libdm/ioctl/libdm-targets.h
index ea3d14f..d8cee45 100644
--- a/libdm/ioctl/libdm-targets.h
+++ b/libdm/ioctl/libdm-targets.h
@@ -62,6 +62,7 @@ struct dm_task {
 	int suppress_identical_reload;
 	uint64_t existing_table_size;
 	int cookie_set;
+	int new_uuid;
 
 	char *uuid;
 };
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 34bcf40..7ed60be 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -167,6 +167,7 @@ struct dm_versions *dm_task_get_versions(struct dm_task *dmt);
 
 int dm_task_set_ro(struct dm_task *dmt);
 int dm_task_set_newname(struct dm_task *dmt, const char *newname);
+int dm_task_set_newuuid(struct dm_task *dmt, const char *newuuid);
 int dm_task_set_minor(struct dm_task *dmt, int minor);
 int dm_task_set_major(struct dm_task *dmt, int major);
 int dm_task_set_major_minor(struct dm_task *dmt, int major, int minor, int allow_default_major_fallback);
-- 
1.7.2.2


