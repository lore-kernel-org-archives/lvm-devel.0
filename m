From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Aug 2011 02:16:46 -0000
Subject: LVM2 daemons/clvmd/clvmd.c doc/example.conf.in ...
Message-ID: <20110812021646.23566.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-12 02:16:46

Modified files:
	daemons/clvmd  : clvmd.c 
	doc            : example.conf.in 
	tools          : lvcreate.c 

Log message:
	more pre-release fixes

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.233&r2=1.234

--- LVM2/daemons/clvmd/clvmd.c	2011/08/11 12:57:11	1.107
+++ LVM2/daemons/clvmd/clvmd.c	2011/08/12 02:16:46	1.108
@@ -468,7 +468,7 @@
 
 	/* Set up signal handlers, USR1 is for cluster change notifications (in cman)
 	   USR2 causes child threads to exit.
-	   HUP causes to re-read nodes list from CCS.
+	   (HUP used to cause gulm to re-read the nodes list from CCS.)
 	   PIPE should be ignored */
 	signal(SIGUSR2, sigusr2_handler);
 	signal(SIGHUP,  sighup_handler);
--- LVM2/doc/example.conf.in	2011/08/11 17:46:13	1.30
+++ LVM2/doc/example.conf.in	2011/08/12 02:16:46	1.31
@@ -413,6 +413,26 @@
     # performed (except for the unchanged vg_seqno).
     # Inappropriate use could mess up your system, so seek advice first!
     metadata_read_only = 0
+
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
+    # Specify the '--type <mirror|raid1>' option to override this default
+    # setting.
+    mirror_segtype_default = "mirror"
 }
 
 activation {
@@ -479,26 +499,6 @@
     # "auto" - Use default value chosen by kernel.
     readahead = "auto"
 
-    # 'mirror_segtype_default' defines which segtype will be used when the
-    # shorthand '-m' option is used for mirroring.  The possible options are:
-    #
-    # "mirror" - The original RAID1 implementation provided by LVM2/DM.  It is
-    # 	         characterized by a flexible log solution (core, disk, mirrored)
-    #		 and by the necessity to block I/O while reconfiguring in the
-    #		 event of a failure.  Snapshots of this type of RAID1 can be
-    #		 problematic.
-    #
-    # "raid1"  - This implementation leverages MD's RAID1 personality through
-    # 	       	 device-mapper.  It is characterized by a lack of log options.
-    #		 (A log is always allocated for every device and they are placed
-    #		 on the same device as the image - no separate devices are
-    #		 required.)  This mirror implementation does not require I/O
-    #		 to be blocked in the kernel in the event of a failure.
-    #
-    # Specify the '--type <mirror|raid1>' option to override this default
-    # setting.
-    mirror_segtype_default = "mirror"
-
     # 'mirror_image_fault_policy' and 'mirror_log_fault_policy' define
     # how a device failure affecting a mirror is handled.
     # A mirror is composed of mirror images (copies) and a log.
--- LVM2/tools/lvcreate.c	2011/08/10 20:25:31	1.233
+++ LVM2/tools/lvcreate.c	2011/08/12 02:16:46	1.234
@@ -384,7 +384,7 @@
 	 */
 	segtype_str = "striped";
 	if (arg_count(cmd, mirrors_ARG))
-		segtype_str = find_config_tree_str(cmd, "activation/mirror_segtype_default", DEFAULT_MIRROR_SEGTYPE);
+		segtype_str = find_config_tree_str(cmd, "global/mirror_segtype_default", DEFAULT_MIRROR_SEGTYPE);
 
 	lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, segtype_str));
 


