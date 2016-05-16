From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 16 May 2016 19:42:48 +0000 (UTC)
Subject: master - pvremove: allow clearing a duplicate PV
Message-ID: <20160516194248.A91AB606EF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba9b7b69d9200d9d977089a0b813f508961fcbee
Commit:        ba9b7b69d9200d9d977089a0b813f508961fcbee
Parent:        e0c22df5c41a8658dab953a413a679ceb5acd663
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 12 16:19:57 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 16 14:40:43 2016 -0500

pvremove: allow clearing a duplicate PV

Add a special case to allow modifying a duplicate PV
to erase it with pvremove -ff.
---
 lib/cache/lvmcache.c |   13 +++++++++++++
 lib/cache/lvmcache.h |    2 ++
 tools/toollib.c      |   45 +++++++++++++++++++++++++++++++++++++++++++--
 3 files changed, 58 insertions(+), 2 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index fe2ad07..0934b20 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -459,6 +459,19 @@ int lvmcache_get_unused_duplicate_devs(struct cmd_context *cmd, struct dm_list *
 	return 1;
 }
 
+void lvmcache_remove_unchosen_duplicate(struct device *dev)
+{
+	struct device_list *devl;
+
+	dm_list_iterate_items(devl, &_unused_duplicate_devs) {
+		if (devl->dev == dev) {
+			dm_list_del(&devl->list);
+			return;
+		}
+	}
+}
+
+
 static void _vginfo_attach_info(struct lvmcache_vginfo *vginfo,
 				struct lvmcache_info *info)
 {
diff --git a/lib/cache/lvmcache.h b/lib/cache/lvmcache.h
index 45318b9..4fb74db 100644
--- a/lib/cache/lvmcache.h
+++ b/lib/cache/lvmcache.h
@@ -211,4 +211,6 @@ void lvmcache_lock_ordering(int enable);
 
 int lvmcache_dev_is_unchosen_duplicate(struct device *dev);
 
+void lvmcache_remove_unchosen_duplicate(struct device *dev);
+
 #endif
diff --git a/tools/toollib.c b/tools/toollib.c
index 429ab91..ab1361d 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4199,6 +4199,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 	struct physical_volume *pv;
 	struct volume_group *orphan_vg;
 	struct lvmcache_info *info;
+	struct dm_list remove_duplicates;
 	struct dm_list arg_sort;
 	struct pv_list *pvl;
 	struct pv_list *vgpvl;
@@ -4210,6 +4211,7 @@ int pvcreate_each_device(struct cmd_context *cmd,
 
 	set_pv_notify(cmd);
 
+	dm_list_init(&remove_duplicates);
 	dm_list_init(&arg_sort);
 
 	handle->custom_handle = pp;
@@ -4295,6 +4297,23 @@ int pvcreate_each_device(struct cmd_context *cmd,
 		goto_bad;
 
 	/*
+	 * Special case: pvremove -ff is allowed to clear a duplicate device in
+	 * the unchosen duplicates list.  PVs in the unchosen duplicates list
+	 * won't be found by normal process_each searches -- they are not in
+	 * lvmcache and can't be processed normally.  We save them here and
+	 * erase them below without going through the normal processing code.
+	 */
+	if (pp->is_remove && (pp->force == DONT_PROMPT_OVERRIDE) &&
+	   !dm_list_empty(&pp->arg_devices) && lvmcache_found_duplicate_pvs()) {
+		dm_list_iterate_items_safe(pd, pd2, &pp->arg_devices) {
+			if (lvmcache_dev_is_unchosen_duplicate(pd->dev)) {
+				log_debug("Found pvremove arg %s: device is a duplicate.", pd->name);
+				dm_list_move(&remove_duplicates, &pd->list);
+			}
+		}
+	}
+
+	/*
 	 * Check if all arg_devices were found by process_each_pv.
 	 */
 	dm_list_iterate_items(pd, &pp->arg_devices)
@@ -4313,9 +4332,9 @@ int pvcreate_each_device(struct cmd_context *cmd,
 		goto_bad;
 
 	/*
-	 * The command cannot continue if there are no devices to create.
+	 * The command cannot continue if there are no devices to process.
 	 */
-	if (dm_list_empty(&pp->arg_process)) {
+	if (dm_list_empty(&pp->arg_process) && dm_list_empty(&remove_duplicates)) {
 		log_debug("No devices to process.");
 		goto bad;
 	}
@@ -4606,6 +4625,28 @@ do_command:
 					pd->name);
 	}
 
+	/*
+	 * Special case: pvremove duplicate PVs (also see above).
+	 */
+	dm_list_iterate_items_safe(pd, pd2, &remove_duplicates) {
+		if (!label_remove(pd->dev)) {
+			log_error("Failed to wipe existing label(s) on %s.", pd->name);
+			dm_list_move(&pp->arg_fail, &pd->list);
+			continue;
+		}
+
+		if (!lvmetad_pv_gone_by_dev(pd->dev, NULL)) {
+			log_error("Failed to remove PV %s from lvmetad.", pd->name);
+			dm_list_move(&pp->arg_fail, &pd->list);
+			continue;
+		}
+
+		lvmcache_remove_unchosen_duplicate(pd->dev);
+
+		log_print_unless_silent("Labels on physical volume \"%s\" successfully wiped.",
+					pd->name);
+	}
+
 	dm_list_iterate_items(pd, &pp->arg_fail)
 		log_debug("%s: command failed for %s.",
 			  cmd->command->name, pd->name);


