From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 23 Aug 2016 13:58:07 +0000 (UTC)
Subject: master - libdm: add some comments about DM_UDEV_DISABLE_LIBRARY_FALLBACK flag
Message-ID: <20160823135807.9BC2960ECF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db0e34535c82cfb73af19a7673de82881ad2468c
Commit:        db0e34535c82cfb73af19a7673de82881ad2468c
Parent:        b975532433dcbcc01e3cc0ebe8c6165e2d6470f8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Aug 23 15:57:47 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Aug 23 15:58:03 2016 +0200

libdm: add some comments about DM_UDEV_DISABLE_LIBRARY_FALLBACK flag

---
 libdm/libdevmapper.h |   14 +++++++++++++-
 1 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 5246b15..5790486 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -216,6 +216,7 @@ int dm_task_set_major_minor(struct dm_task *dmt, int major, int minor, int allow
 int dm_task_set_uid(struct dm_task *dmt, uid_t uid);
 int dm_task_set_gid(struct dm_task *dmt, gid_t gid);
 int dm_task_set_mode(struct dm_task *dmt, mode_t mode);
+/* See also description for DM_UDEV_DISABLE_LIBRARY_FALLBACK flag! */
 int dm_task_set_cookie(struct dm_task *dmt, uint32_t *cookie, uint16_t flags);
 int dm_task_set_event_nr(struct dm_task *dmt, uint32_t event_nr);
 int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char *heads, const char *sectors, const char *start);
@@ -3496,7 +3497,18 @@ struct dm_pool *dm_config_memory(struct dm_config_tree *cft);
  * DM_UDEV_DISABLE_LIBRARY_FALLBACK is set in case we need to disable
  * libdevmapper's node management. We will rely on udev completely
  * and there will be no fallback action provided by libdevmapper if
- * udev does something improperly.
+ * udev does something improperly. Using the library fallback code has
+ * a consequence that you need to take into account: any device node
+ * or symlink created without udev is not recorded in udev database
+ * which other applications may read to get complete list of devices.
+ * For this reason, use of DM_UDEV_DISABLE_LIBRARY_FALLBACK is
+ * recommended on systems where udev is used. Keep library fallback
+ * enabled just for exceptional cases where you need to debug udev-related
+ * problems. If you hit such problems, please contact us through upstream
+ * LVM2 development mailing list (see also README file). This flag is
+ * currently not set by default in libdevmapper so you need to set it
+ * explicitly if you're sure that udev is behaving correctly on your
+ * setups.
  */
 #define DM_UDEV_DISABLE_LIBRARY_FALLBACK 0x0020
 /*


