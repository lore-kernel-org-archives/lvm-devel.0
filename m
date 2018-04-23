From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:52:36 -0400
Subject: master - label_scan: fix independent metadata areas
Message-ID: <201804231352.w3NDqaWY000875@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d9ef9eb330bdc66dd6d9b45713d5c0b25d645ac0
Commit:        d9ef9eb330bdc66dd6d9b45713d5c0b25d645ac0
Parent:        748f29b42a61e05fb696a86e04b4b589d70d6d79
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Oct 25 13:39:46 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:21:41 2018 -0500

label_scan: fix independent metadata areas

This fixes the use of lvmcache_label_rescan_vg() in the previous
commit for the special case of independent metadata areas.

label scan is about discovering VG name to device associations
using information from disks, but devices in VGs with
independent metadata areas have no information on disk, so
the label scan does nothing for these VGs/devices.
With independent metadata areas, only the VG metadata found
in files is used.  This metadata is found and read in
vg_read in the processing phase.

lvmcache_label_rescan_vg() drops lvmcache info for the VG devices
before repeating the label scan on them.  In the case of
independent metadata areas, there is no metadata on devices, so the
label scan of the devices will find nothing, so will not recreate
the necessary vginfo/info data in lvmcache for the VG.  Fix this
by setting a flag in the lvmcache vginfo struct indicating that
the VG uses independent metadata areas, and label rescanning should
be skipped.

In the case of independent metadata areas, it is the metadata
processing in the vg_read phase that sets up the lvmcache
vginfo/info information, and label scan has no role.
---
 lib/format_text/format-text.c |   24 +++++++++++++++++++++++-
 1 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 6c13346..8c12c82 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1141,6 +1141,9 @@ static int _scan_file(const struct format_type *fmt, const char *vgname)
 
 	dir_list = &((struct mda_lists *) fmt->private)->dirs;
 
+	if (!dm_list_empty(dir_list))
+		log_debug_metadata("Scanning independent files for %s", vgname ? vgname : "VGs");
+
 	dm_list_iterate_items(dl, dir_list) {
 		if (!(d = opendir(dl->dir))) {
 			log_sys_error("opendir", dl->dir);
@@ -1173,10 +1176,14 @@ static int _scan_file(const struct format_type *fmt, const char *vgname)
 					stack;
 					break;
 				}
+
+				log_debug_metadata("Scanning independent file %s for VG %s", path, scanned_vgname);
+
 				if ((vg = _vg_read_file_name(fid, scanned_vgname,
 							     path))) {
 					/* FIXME Store creation host in vg */
 					lvmcache_update_vg(vg, 0);
+					lvmcache_set_independent_location(vg->name);
 					release_vg(vg);
 				}
 			}
@@ -1302,6 +1309,8 @@ int read_metadata_location_summary(const struct format_type *fmt,
 	return 1;
 }
 
+/* used for independent_metadata_areas */
+
 static int _scan_raw(const struct format_type *fmt, const char *vgname __attribute__((unused)))
 {
 	struct raw_list *rl;
@@ -1313,11 +1322,16 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 
 	raw_list = &((struct mda_lists *) fmt->private)->raws;
 
+	if (!dm_list_empty(raw_list))
+		log_debug_metadata("Scanning independent raw locations for %s", vgname ? vgname : "VGs");
+
 	fid.fmt = fmt;
 	dm_list_init(&fid.metadata_areas_in_use);
 	dm_list_init(&fid.metadata_areas_ignored);
 
 	dm_list_iterate_items(rl, raw_list) {
+		log_debug_metadata("Scanning independent dev %s", dev_name(rl->dev_area.dev));
+
 		/* FIXME We're reading mdah twice here... */
 		if (!dev_open_readonly(rl->dev_area.dev)) {
 			stack;
@@ -1331,8 +1345,10 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 
 		if (read_metadata_location_summary(fmt, mdah, 0, &rl->dev_area, &vgsummary, NULL)) {
 			vg = _vg_read_raw_area(&fid, vgsummary.vgname, &rl->dev_area, NULL, NULL, 0, 0, 0);
-			if (vg)
+			if (vg) {
 				lvmcache_update_vg(vg, 0);
+				lvmcache_set_independent_location(vg->name);
+			}
 		}
 	close_dev:
 		if (!dev_close(rl->dev_area.dev))
@@ -1342,6 +1358,8 @@ static int _scan_raw(const struct format_type *fmt, const char *vgname __attribu
 	return 1;
 }
 
+/* used for independent_metadata_areas */
+
 static int _text_scan(const struct format_type *fmt, const char *vgname)
 {
 	return (_scan_file(fmt, vgname) & _scan_raw(fmt, vgname));
@@ -1796,6 +1814,8 @@ static struct metadata_area_ops _metadata_text_raw_ops = {
 	.mda_import_text = _mda_import_text_raw
 };
 
+/* used only for sending info to lvmetad */
+
 static int _mda_export_text_raw(struct metadata_area *mda,
 				struct dm_config_tree *cft,
 				struct dm_config_node *parent)
@@ -1820,6 +1840,8 @@ static int _mda_export_text_raw(struct metadata_area *mda,
 				 NULL) ? 1 : 0;
 }
 
+/* used only for receiving info from lvmetad */
+
 static int _mda_import_text_raw(struct lvmcache_info *info, const struct dm_config_node *cn)
 {
 	struct device *device;


