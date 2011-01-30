From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Sun, 30 Jan 2011 13:57:29 +0100
Subject: [PATCH 06/24] lv_info handle udev_sync
In-Reply-To: <cover.1296391340.git.zkabelac@redhat.com>
References: <cover.1296391340.git.zkabelac@redhat.com>
Message-ID: <9a4defa6949857ab698f1d25e5779d422c5cdcc6.1296391340.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

In case open_count is requested via lv_info - check if there
are any udev operations in-progress - and wait for them
before checking for lv_info

Remove fs_unlock after _lv_resume -  as it's now handled via
lv_info query.

Note: some those lv_info() which do not need open_count,
needs to pass 0 for 'with_open_count' parameter.

NoteII: locking_is_clustered() is needed to detect in which context
lv_info() is called as we cannot use sync_local_dev_names() when
locking is not defined.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/activate/activate.c |   13 ++++++++++++-
 lib/activate/fs.c       |    5 +++++
 lib/activate/fs.h       |    1 +
 3 files changed, 18 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 3670ea4..ff84f4f 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -460,6 +460,18 @@ int lv_info(struct cmd_context *cmd, const struct logical_volume *lv, unsigned o
 
 	if (!activation())
 		return 0;
+	/*
+	 * If open_count info is requested and we have to be sure our own udev
+	 * transactions are finished
+	 * For non-clustered locking type we are only interested for non-delete operation
+	 * in progress - as only those could lead to opened files
+	 */
+	if (with_open_count) {
+		if (locking_is_clustered())
+			sync_local_dev_names(cmd); /* Wait to have udev in sync */
+		else if (fs_has_non_delete_ops())
+			fs_unlock(); /* For non clustered - wait if there are non-delete ops */
+	}
 
 	if (!dev_manager_info(lv->vg->cmd->mem, lv, origin_only ? "real" : NULL, with_open_count,
 			      with_read_ahead, &dminfo, &info->read_ahead))
@@ -1112,7 +1124,6 @@ static int _lv_resume(struct cmd_context *cmd, const char *lvid_s,
 		goto_out;
 
 	memlock_dec(cmd);
-	fs_unlock();
 
 	if (!monitor_dev_for_events(cmd, lv, origin_only, 1))
 		stack;
diff --git a/lib/activate/fs.c b/lib/activate/fs.c
index a3db5a7..31a71b1 100644
--- a/lib/activate/fs.c
+++ b/lib/activate/fs.c
@@ -477,3 +477,8 @@ void fs_set_cookie(uint32_t cookie)
 {
 	_fs_cookie = cookie;
 }
+
+int fs_has_non_delete_ops(void)
+{
+	return _other_fs_ops(FS_DEL);
+}
diff --git a/lib/activate/fs.h b/lib/activate/fs.h
index 17ecedf..43e2846 100644
--- a/lib/activate/fs.h
+++ b/lib/activate/fs.h
@@ -32,5 +32,6 @@ int fs_rename_lv(struct logical_volume *lv, const char *dev,
 /* void fs_unlock(void);  moved to activate.h */
 uint32_t fs_get_cookie(void);
 void fs_set_cookie(uint32_t cookie);
+int fs_has_non_delete_ops(void);
 
 #endif
-- 
1.7.3.5


