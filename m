From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 05 Jul 2011 15:46:39 -0500
Subject: [PATCH 4 of 5] LVM2 add switch for mirror segtype selection
Message-ID: <1309898799.19763.16.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch is to be folded into 'lvm-add-raid-support.patch'.  It is only
separated here to allow those who have already reviewed that patch to see
what I've changed (in this case, a switch to allow the user to choose the
default mirroring segment type).

Index: LVM2/lib/config/defaults.h
===================================================================
--- LVM2.orig/lib/config/defaults.h
+++ LVM2/lib/config/defaults.h
@@ -49,6 +49,7 @@
 #define DEFAULT_USE_MLOCKALL 0
 #define DEFAULT_METADATA_READ_ONLY 0
 
+#define DEFAULT_MIRROR_SEGTYPE "mirror"
 #define DEFAULT_MIRRORLOG "disk"
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
Index: LVM2/tools/lvcreate.c
===================================================================
--- LVM2.orig/tools/lvcreate.c
+++ LVM2/tools/lvcreate.c
@@ -382,10 +382,10 @@ static int _lvcreate_params(struct lvcre
 	/*
 	 * Check selected options are compatible and determine segtype
 	 */
+	segtype_str = "striped";
 	if (arg_count(cmd, mirrors_ARG))
-		segtype_str = "mirror";
-	else
-		segtype_str = "striped";
+		segtype_str = find_config_tree_str(cmd, "activation/mirror_segtype_default", DEFAULT_MIRROR_SEGTYPE);
+
 	lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, segtype_str));
 
 	if (arg_count(cmd, snapshot_ARG) || seg_is_snapshot(lp) ||
Index: LVM2/doc/example.conf.in
===================================================================
--- LVM2.orig/doc/example.conf.in
+++ LVM2/doc/example.conf.in
@@ -474,6 +474,27 @@ activation {
     # "auto" - Use default value chosen by kernel.
     readahead = "auto"
 
+    # 'mirror_segtype_default' defines which segtype will be used when the
+    # shorthand '-m' option is used for mirroring.  The possible options are:
+    #
+    # "mirror" - The original RAID1 implementation provided by LVM2/DM.  It is
+    # 	         characterized by a flexible log solution (core, disk, mirrored)
+    #		 and by the necessity to block I/O while reconfiguring in the
+    #		 event of a failure.  Snapshots of this type of RAID1 can be
+    #		 problematic.
+    #
+    # "raid1"  - This implementation leverages MD's RAID1 personality through
+    # 	       	 device-mapper.  It is characterized by a lack of log options.
+    #		 (A log is always allocated for every device and they are placed
+    #		 on the same device as the image - no separate devices are
+    #		 required.)  This mirror implementation does not require I/O
+    #		 to be blocked in the kernel in the event of a failure.
+    #
+    # If a user wishes to override this default setting, the '--type' option
+    # is available.  Simply specify '--type <mirror|raid1>' along with the
+    # '-m' option when creating the mirror.
+    mirror_segtype_default = "mirror"
+
     # 'mirror_image_fault_policy' and 'mirror_log_fault_policy' define
     # how a device failure affecting a mirror is handled.
     # A mirror is composed of mirror images (copies) and a log.



