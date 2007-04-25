From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 25 Apr 2007 20:03:16 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c lib/m ...
Message-ID: <20070425200316.5434.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-04-25 21:03:16

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c metadata.h 
	man            : pvck.8 
	tools          : commands.h pvck.c 

Log message:
	Update pvck to read labels on disk, with flexible --labelsector
	parameter.
	
	--

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.602&r2=1.603
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.105&r2=1.106
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.h.diff?cvsroot=lvm2&r1=1.154&r2=1.155
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/pvck.8.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/commands.h.diff?cvsroot=lvm2&r1=1.95&r2=1.96
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvck.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2007/04/25 18:24:19	1.602
+++ LVM2/WHATS_NEW	2007/04/25 20:03:15	1.603
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Update pvck to read labels on disk, with --labelsector parameter
   Add count_chars and count_chars_len functions
   Add /sys/block listings to lvm_dump.sh
   Make lvm_dump.sh list /dev recursively
--- LVM2/lib/metadata/metadata.c	2007/04/23 18:21:01	1.105
+++ LVM2/lib/metadata/metadata.c	2007/04/25 20:03:15	1.106
@@ -1555,3 +1555,35 @@
 
 	return 1;
 }
+/*
+ * Returns:
+ *  0 - fail
+ *  1 - success
+ */
+int pv_analyze(struct cmd_context *cmd, const char *pv_name,
+	       int64_t label_sector)
+{
+	struct label *label;
+	struct device *dev;
+
+	dev = dev_cache_get(pv_name, cmd->filter);
+	if (!dev) {
+		log_error("Device %s not found (or ignored by filtering).",
+			  pv_name);
+		return 0;
+	}
+
+	/*
+	 * First, scan for LVM labels.
+	 */
+	if (!label_read(dev, &label, label_sector)) {
+		log_error("Could not find LVM label on %s",
+			  pv_name);
+		return 0;
+	}
+
+	log_print("Found label on %s, sector %"PRIu64", type=%s",
+		  pv_name, label->sector, label->type);
+
+	return 1;
+}
--- LVM2/lib/metadata/metadata.h	2007/03/23 12:43:17	1.154
+++ LVM2/lib/metadata/metadata.h	2007/04/25 20:03:15	1.155
@@ -443,6 +443,8 @@
 				  uint64_t pvmetadatasize, struct list *mdas);
 int pv_resize(struct physical_volume *pv, struct volume_group *vg,
               uint32_t new_pe_count);
+int pv_analyze(struct cmd_context *cmd, const char *pv_name,
+	       int64_t label_sector);
 
 struct volume_group *vg_create(struct cmd_context *cmd, const char *name,
 			       uint32_t extent_size, uint32_t max_pv,
--- LVM2/man/pvck.8	2007/03/30 21:00:25	1.1
+++ LVM2/man/pvck.8	2007/04/25 20:03:15	1.2
@@ -3,11 +3,29 @@
 pvck \- check physical volume metadata
 .SH SYNOPSIS
 .B pvck
-[\-d/\-\-debug] [\-h/\-?/\-\-help] [\-v/\-\-verbose] [PhysicalVolume...]
+.RB [ \-d | \-\-debug ]
+.RB [ \-h | \-\-help ]
+.RB [ \-v | \-\-verbose ]
+.RB [ \-\-labelsector ]
+.IR PhysicalVolume " [" PhysicalVolume ...]
 .SH DESCRIPTION
 pvck checks physical volume LVM metadata for consistency.
 .SH OPTIONS
 See \fBlvm\fP for common options.
+.TP
+.BR \-\-labelsector " sector"
+By default, 4 sectors of \fBPhysicalVolume\fP are scanned for an LVM label,
+starting at sector 0.  This parameter allows you to specify a different
+starting sector for the scan and is useful for recovery situations.  For
+example, suppose the partition table is corrupted or lost on /dev/sda,
+but you suspect there was an LVM partition at approximately 100 MB.  This
+area of the disk may be scanned by using the \fB--labelsector\fP parameter
+with a value of 204800 (100 * 1024 * 1024 / 512 = 204800):
+.sp
+.BI "pvck --labelsector 204800 /dev/sda"
+.sp
+Note that a script can be used with \fB--labelsector\fP to automate the
+process of finding LVM labels.
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvcreate (8),
--- LVM2/tools/commands.h	2007/03/30 21:00:26	1.95
+++ LVM2/tools/commands.h	2007/04/25 20:03:16	1.96
@@ -412,9 +412,12 @@
    "pvck "
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
+   "\t[--labelsector sector] " "\n"
    "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
-   "\tPhysicalVolume [PhysicalVolume...]\n" )
+   "\tPhysicalVolume [PhysicalVolume...]\n",
+
+   labelsector_ARG)
 
 xx(pvcreate,
    "Initialize physical volume(s) for use by LVM",
--- LVM2/tools/pvck.c	2007/03/30 21:00:26	1.1
+++ LVM2/tools/pvck.c	2007/04/25 20:03:16	1.2
@@ -15,16 +15,26 @@
 
 #include "tools.h"
 
-static int _pvck_single(struct cmd_context * cmd,
-			struct volume_group * vg,
-			struct physical_volume * pv,
-			void *handle)
-{
-	return ECMD_PROCESSED;
-}
-
 int pvck(struct cmd_context *cmd, int argc, char **argv)
 {
-	/* FIXME: Correlate findings of each PV */
-	return process_each_pv(cmd, argc, argv, NULL, NULL, _pvck_single);
+	int i;
+
+	/* FIXME: validate cmdline options */
+	/* FIXME: what does the cmdline look like? */
+	/*
+	 * Use what's on the cmdline directly, and avoid calling into
+	 * some of the other infrastructure functions, so as to avoid
+	 * hitting some of the lvmcache behavior, scanning other devices,
+	 * etc.
+	 */
+	for (i = 0; i < argc; i++) {
+		/* FIXME: warning and/or check if in use? */
+		log_verbose("Scanning %s", argv[i]);
+
+		pv_analyze(cmd, argv[i],
+			   arg_int64_value(cmd, labelsector_ARG,
+					   UINT64_C(0)));
+	}
+
+	return ECMD_PROCESSED;
 }


