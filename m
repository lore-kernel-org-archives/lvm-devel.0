From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 Oct 2015 21:33:37 +0000 (UTC)
Subject: master - dmeventd: snapshot plugin device removal
Message-ID: <20151022213337.37E20610C3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b0bc5b2d9cc2f160b14d34e764bff99cd3c595f
Commit:        6b0bc5b2d9cc2f160b14d34e764bff99cd3c595f
Parent:        7ff5b03e5e82b31ed332ee95631cede836224621
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 22 15:38:24 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 22 22:29:53 2015 +0200

dmeventd: snapshot plugin device removal

Add #ifdef-ed code to have ability to even remove unusable device.
For now purely experimental.
---
 .../dmeventd/plugins/snapshot/dmeventd_snapshot.c  |   39 ++++++++++++++++++++
 1 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
index f864bb4..d9bef5c 100644
--- a/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
+++ b/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c
@@ -84,6 +84,41 @@ static int _extend(const char *cmd)
 	return dmeventd_lvm2_run_with_lock(cmd);
 }
 
+#ifdef SNAPSHOT_REMOVE
+/* Remove invalid snapshot from dm-table */
+/* Experimental for now and not used by default */
+static int _remove(const char *uuid)
+{
+	int r = 1;
+	uint32_t cookie = 0;
+	struct dm_task *dmt;
+
+	if (!(dmt = dm_task_create(DM_DEVICE_REMOVE)))
+		return 0;
+
+	if (!dm_task_set_uuid(dmt, uuid)) {
+		r = 0;
+		goto_out;
+	}
+
+	dm_task_retry_remove(dmt);
+
+	if (!dm_task_set_cookie(dmt, &cookie, 0)) {
+		r = 0;
+		goto_out;
+	}
+
+	if (!dm_task_run(dmt)) {
+		r = 0;
+		goto_out;
+	}
+out:
+	dm_task_destroy(dmt);
+
+	return r;
+}
+#endif /* SNAPSHOT_REMOVE */
+
 static void _umount(const char *device, int major, int minor)
 {
 	FILE *mounts;
@@ -164,6 +199,10 @@ void process_event(struct dm_task *dmt,
 		state->percent_check = 0;
 		if (dm_task_get_info(dmt, &info))
 			_umount(device, info.major, info.minor);
+#ifdef SNAPSHOT_REMOVE
+		/* Maybe configurable ? */
+		_remove(dm_task_get_uuid(dmt));
+#endif
 		goto out;
 	}
 


