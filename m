From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 04 Feb 2013 16:29:23 -0600
Subject: [PATCH] Make "raid10" the default when creating a mirror+stripe LV
Message-ID: <1360016963.27137.2.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 brassow

RAID: Default to RAID10 when creating mirror+stripe LV

If '--mirrors/-m' and '--stripes/-i' are used together when creating
a logical volume, assume the user would like to use "raid10" rather
than a mirror stacked on striped sub-LVs.

This patch also makes this option configurable with 'raid10_segtype_default'
in the LVM configuration file.

Index: lvm2/tools/lvcreate.c
===================================================================
--- lvm2.orig/tools/lvcreate.c
+++ lvm2/tools/lvcreate.c
@@ -673,11 +673,12 @@ static int _lvcreate_params(struct lvcre
 
 	/* Set default segtype */
 	if (arg_count(cmd, mirrors_ARG))
-		/*
-		 * FIXME: Add default setting for when -i and -m arguments
-		 *        are both given.  We should default to "raid10".
-		 */
-		segtype_str = find_config_tree_str(cmd, "global/mirror_segtype_default", DEFAULT_MIRROR_SEGTYPE);
+		if (arg_uint_value(cmd, arg_count(cmd, stripes_long_ARG) ?
+				   stripes_long_ARG : stripes_ARG, 1) > 1) {
+			segtype_str = find_config_tree_str(cmd, "global/raid10_segtype_default", DEFAULT_RAID10_SEGTYPE);
+		} else {
+			segtype_str = find_config_tree_str(cmd, "global/mirror_segtype_default", DEFAULT_MIRROR_SEGTYPE);
+		}
 	else if (arg_count(cmd, thin_ARG) || arg_count(cmd, thinpool_ARG))
 		segtype_str = "thin";
 	else
Index: lvm2/doc/example.conf.in
===================================================================
--- lvm2.orig/doc/example.conf.in
+++ lvm2/doc/example.conf.in
@@ -498,6 +498,23 @@ global {
     # setting.
     mirror_segtype_default = "raid1"
 
+    # 'raid10_segtype_default' determines the segment types used by default
+    # when the '--stripes/-i' and '--mirrors/-m' arguments are both specified
+    # during the creation of a logical volume.
+    # Possible settings include:
+    #
+    # "raid10" - This implementation leverages MD's RAID10 personality through
+    #            device-mapper.
+    #
+    # "mirror" - LVM will layer the 'mirror' and 'stripe' segment types.  It
+    #            will do this by creating a mirror on top of striped sub-LVs;
+    #            effectively creating a RAID 0+1 array.  This is suboptimal
+    #            in terms of providing redunancy and performance.  Changing to
+    #            this setting is not advised.
+    # Specify the '--type <raid10|mirror>' option to override this default
+    # setting.
+    raid10_segtype_default "raid10"
+
     # The default format for displaying LV names in lvdisplay was changed 
     # in version 2.02.89 to show the LV name and path separately.
     # Previously this was always shown as /dev/vgname/lvname even when that
Index: lvm2/lib/config/defaults.h
===================================================================
--- lvm2.orig/lib/config/defaults.h
+++ lvm2/lib/config/defaults.h
@@ -56,6 +56,7 @@
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
+#define DEFAULT_RAID10_SEGTYPE "raid10"
 #define DEFAULT_RAID_FAULT_POLICY "warn"
 #define DEFAULT_DMEVENTD_RAID_LIB "libdevmapper-event-lvm2raid.so"
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"



