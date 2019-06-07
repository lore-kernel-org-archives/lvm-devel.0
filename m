From: David Teigland <teigland@sourceware.org>
Date: Fri, 7 Jun 2019 17:08:09 -0400
Subject: master - ability to keep track of outdated pvs in lvmcache
Message-ID: <201906072108.x57L89vs005244@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0b18c25d934564015402de33e15a267045ed1b8c
Commit:        0b18c25d934564015402de33e15a267045ed1b8c
Parent:        650524b9559bb56339b281af52db9f4df91038ae
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Feb 5 12:55:51 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Jun 7 15:54:04 2019 -0500

ability to keep track of outdated pvs in lvmcache

Outdated PVs hold metadata for VG from which they
have been removed.  Add the ability to keep track
of these in lvmcache.
This will be used for more advanced repair in a
subsequent commit.
---
 lib/cache/lvmcache.c |   80 ++++++++++++++++++++++++++++++++++++++++++++++++++
 lib/cache/lvmcache.h |   15 +++++++++
 2 files changed, 95 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index a36e145..a860660 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -48,6 +48,7 @@ struct lvmcache_info {
 struct lvmcache_vginfo {
 	struct dm_list list;	/* Join these vginfos together */
 	struct dm_list infos;	/* List head for lvmcache_infos */
+	struct dm_list outdated_infos; /* vg_read moves info from infos to outdated_infos */
 	const struct format_type *fmt;
 	char *vgname;		/* "" == orphan */
 	uint32_t status;
@@ -1389,6 +1390,7 @@ static int _lvmcache_update_vgname(struct lvmcache_info *info,
 			return 0;
 		}
 		dm_list_init(&vginfo->infos);
+		dm_list_init(&vginfo->outdated_infos);
 
 		/*
 		 * A different VG (different uuid) can exist with the same name.
@@ -2392,3 +2394,81 @@ struct metadata_area *lvmcache_get_mda(struct cmd_context *cmd,
 	return NULL;
 }
 
+void lvmcache_get_outdated_devs(struct cmd_context *cmd,
+				const char *vgname, const char *vgid,
+				struct dm_list *devs)
+{
+	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_info *info;
+	struct device_list *devl;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
+		log_error(INTERNAL_ERROR "lvmcache_get_outdated_devs no vginfo %s", vgname);
+		return;
+	}
+
+	dm_list_iterate_items(info, &vginfo->outdated_infos) {
+		if (!(devl = zalloc(sizeof(*devl))))
+			return;
+		devl->dev = info->dev;
+		dm_list_add(devs, &devl->list);
+	}
+}
+
+void lvmcache_del_outdated_devs(struct cmd_context *cmd,
+				const char *vgname, const char *vgid)
+{
+	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_info *info, *info2;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
+		log_error(INTERNAL_ERROR "lvmcache_get_outdated_devs no vginfo");
+		return;
+	}
+
+	dm_list_iterate_items_safe(info, info2, &vginfo->outdated_infos)
+		lvmcache_del(info);
+}
+
+void lvmcache_get_outdated_mdas(struct cmd_context *cmd,
+				const char *vgname, const char *vgid,
+				struct device *dev,
+				struct dm_list **mdas)
+{
+	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_info *info;
+
+	*mdas = NULL;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
+		log_error(INTERNAL_ERROR "lvmcache_get_outdated_mdas no vginfo");
+		return;
+	}
+
+	dm_list_iterate_items(info, &vginfo->outdated_infos) {
+		if (info->dev != dev)
+			continue;
+		*mdas = &info->mdas;
+		return;
+	}
+}
+
+bool lvmcache_is_outdated_dev(struct cmd_context *cmd,
+			     const char *vgname, const char *vgid,
+			     struct device *dev)
+{
+	struct lvmcache_vginfo *vginfo;
+	struct lvmcache_info *info;
+
+	if (!(vginfo = lvmcache_vginfo_from_vgname(vgname, vgid))) {
+		log_error(INTERNAL_ERROR "lvmcache_get_outdated_mdas no vginfo");
+		return false;
+	}
+
+	dm_list_iterate_items(info, &vginfo->outdated_infos) {
+		if (info->dev == dev)
+			return true;
+	}
+
+	return false;
+}
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index dd6730e..0f83c80 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -222,6 +222,21 @@ int dev_in_device_list(struct device *dev, struct dm_list *head);
 
 bool lvmcache_has_bad_metadata(struct device *dev);
 
+void lvmcache_get_outdated_devs(struct cmd_context *cmd,
+                                const char *vgname, const char *vgid,
+                                struct dm_list *devs);
+void lvmcache_get_outdated_mdas(struct cmd_context *cmd,
+                                const char *vgname, const char *vgid,
+                                struct device *dev,
+                                struct dm_list **mdas);
+
+bool lvmcache_is_outdated_dev(struct cmd_context *cmd,
+                              const char *vgname, const char *vgid,
+                              struct device *dev);
+
+void lvmcache_del_outdated_devs(struct cmd_context *cmd,
+                                const char *vgname, const char *vgid);
+
 void lvmcache_save_bad_mda(struct lvmcache_info *info, struct metadata_area *mda);
 
 void lvmcache_get_bad_mdas(struct cmd_context *cmd,


