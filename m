From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  8 Jan 2014 02:18:16 +0000 (UTC)
Subject: master - pvscan: use format feature flags in lvmetad code
Message-ID: <20140108021816.113B960275@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a13815e68c3d85b140f8c6d4d91592ae2f8b992
Commit:        0a13815e68c3d85b140f8c6d4d91592ae2f8b992
Parent:        21c3b41ea893fe64e7ca5245411899ace4ae2a81
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 8 02:13:13 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 8 02:13:13 2014 +0000

pvscan: use format feature flags in lvmetad code

Introduce FMT_OBSOLETE to identify pool metadata and use it and FMT_MDAS
instead of hard-coded format names.
Explain device accesses on pvscan --cache man page.
---
 lib/cache/lvmetad.c              |   27 ++++++++++++++-------------
 lib/format_pool/format_pool.c    |    2 +-
 lib/metadata/metadata-exported.h |    1 +
 man/pvscan.8.in                  |    9 ++++++++-
 4 files changed, 24 insertions(+), 15 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 85bbf88..aec6a71 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -20,8 +20,6 @@
 #include "lvmcache.h"
 #include "lvmetad-client.h"
 #include "format-text.h" // TODO for disk_locn, used as a DA representation
-#include "format_pool.h" // for FMT_POOL_NAME
-#include "format1.h" // for FMT_LVM1_NAME
 #include "crc.h"
 
 static daemon_handle _lvmetad;
@@ -901,25 +899,28 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 	info = (struct lvmcache_info *) label->info;
 
 	baton.vg = NULL;
-	baton.fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info),
-							     &fic);
+	baton.fid = lvmcache_fmt(info)->ops->create_instance(lvmcache_fmt(info), &fic);
 
 	if (!baton.fid)
 		goto_bad;
 
-	lvmcache_foreach_mda(info, _lvmetad_pvscan_single, &baton);
-
-	if (lvmcache_fmt(info) == get_format_by_name(cmd, FMT_POOL_NAME)) {
-		log_error("WARNING: Ignoring old GFS pool metadata on device %s "
-			  "when using lvmetad", dev_name(dev));
+	if (baton.fid->fmt->features & FMT_OBSOLETE) {
+		log_error("WARNING: Ignoring obsolete format of metadata (%s) on device %s when using lvmetad",
+			  baton.fid->fmt->name, dev_name(dev));
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
 		return 0;
 	}
 
-	/* LVM1 VGs have no MDAs. */
-	if (!baton.vg && lvmcache_fmt(info) == get_format_by_name(cmd, FMT_LVM1_NAME))
-		baton.vg = ((struct metadata_area *) dm_list_first(&baton.fid->metadata_areas_in_use))->
-			ops->vg_read(baton.fid, lvmcache_vgname_from_info(info), NULL, 0);
+	lvmcache_foreach_mda(info, _lvmetad_pvscan_single, &baton);
+
+	/*
+	 * LVM1 VGs have no MDAs and lvmcache_foreach_mda isn't worth fixing
+	 * to use pseudo-mdas for PVs.
+	 * Note that the single_device parameter also gets ignored and this code
+	 * can scan further devices.
+	 */
+	if (!baton.vg && !(baton.fid->fmt->features & FMT_MDAS))
+		baton.vg = ((struct metadata_area *) dm_list_first(&baton.fid->metadata_areas_in_use))->ops->vg_read(baton.fid, lvmcache_vgname_from_info(info), NULL, 1);
 
 	if (!baton.vg)
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
diff --git a/lib/format_pool/format_pool.c b/lib/format_pool/format_pool.c
index 0f8f3a3..503005a 100644
--- a/lib/format_pool/format_pool.c
+++ b/lib/format_pool/format_pool.c
@@ -298,7 +298,7 @@ struct format_type *init_format(struct cmd_context *cmd)
 	fmt->name = FMT_POOL_NAME;
 	fmt->alias = NULL;
 	fmt->orphan_vg_name = FMT_POOL_ORPHAN_VG_NAME;
-	fmt->features = 0;
+	fmt->features = FMT_OBSOLETE;
 	fmt->private = NULL;
 
 	dm_list_init(&fmt->mda_ops);
diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 1cce72c..6a959d1 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -122,6 +122,7 @@
 #define FMT_RESTRICTED_READAHEAD 0x00000200U	/* Readahead restricted to 2-120? */
 #define FMT_BAS			0x000000400U	/* Supports bootloader areas? */
 #define FMT_CONFIG_PROFILE	0x000000800U	/* Supports configuration profiles? */
+#define FMT_OBSOLETE		0x000001000U	/* Obsolete format? */
 
 /* Mirror conversion type flags */
 #define MIRROR_BY_SEG		0x00000001U	/* segment-by-segment mirror */
diff --git a/man/pvscan.8.in b/man/pvscan.8.in
index 37ecaaf..61b15d0 100644
--- a/man/pvscan.8.in
+++ b/man/pvscan.8.in
@@ -57,13 +57,20 @@ supported for logical volumes that are part of partial or clustered volume group
 .BR \-b ", " \-\-background
 Run the command in the background.
 .TP
-.BR \-\-cache " [" \-\-major " " \fImajor " " \-\-minor " " \fIminor " | " \fIDevicePath " ]..."
+.BR \-\-cache " [" \-\-major " " \fImajor " " \-\-minor " " \fIminor " | " \fIDevicePath " | " \fImajor:minor " ]..."
 Scan one or more devices and instruct the lvmetad daemon to update its cached
 state accordingly.  Called internally by udev rules.
 All devices listed explicitly are processed \fBregardless\fP of any device
 filters set using \fBdevices/filter\fP configuration setting. To filter
 devices even in this case, the \fBdevices/global_filter\fP must be used.
+If lvmetad has not yet cached any metadata or the filters have recently been
+changed, then all devices may be scanned, effectively ignoring the rest of
+the command line.  Otherwise, if all the devices referenced on the command line
+contain metadata in the default lvm2 format, other devices are not accessed.
+If metadata written using the obsolete GFS pool format is encountered, this is
+ignored and so lvmetad should not be used.
 .SH SEE ALSO
 .BR lvm (8),
+.BR lvmetad (8),
 .BR pvcreate (8),
 .BR pvdisplay (8)


