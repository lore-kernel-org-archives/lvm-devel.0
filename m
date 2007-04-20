From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 20 Apr 2007 13:45:30 -0400
Subject: [PATCH 1/2] Add pvck ability to scan for labels on any area of disk
Message-ID: <1177091131.11574.13.camel@linux-cxyg>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Update pvck to read labels on disk, with flexible --labelsector
parameter.

Index: LVM2/lib/metadata/metadata.c
===================================================================
--- LVM2.orig/lib/metadata/metadata.c	2007-04-20 13:39:28.000000000 -0400
+++ LVM2/lib/metadata/metadata.c	2007-04-20 13:43:03.000000000 -0400
@@ -1555,3 +1555,39 @@ int pv_write_orphan(struct cmd_context *
 
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
+	/*
+	 * Take the pv directly, and ignore any filters.  We do this
+	 * because we're often in recovery mode here, and side-effects
+	 * with things like filters would probably be unexpected.
+	 */
+	dev = dev_cache_get(pv_name, NULL);
+	if (!dev)
+		goto error;
+
+	/*
+	 * First, scan for LVM labels.
+	 */
+	if (label_read(dev, &label, label_sector)) {
+		log_print("Found label on %s, sector %"PRIu64", type=%s",
+			  pv_name, label->sector, label->type);
+	} else {
+		log_error("Could not find LVM label on %s - "
+			  "try --labelsector option?", pv_name);
+		goto error;
+	}
+
+	return 1;
+ error:
+	return 0;
+}
Index: LVM2/lib/metadata/metadata.h
===================================================================
--- LVM2.orig/lib/metadata/metadata.h	2007-04-20 13:39:28.000000000 -0400
+++ LVM2/lib/metadata/metadata.h	2007-04-20 13:43:03.000000000 -0400
@@ -443,6 +443,8 @@ struct physical_volume *pv_create(const 
 				  uint64_t pvmetadatasize, struct list *mdas);
 int pv_resize(struct physical_volume *pv, struct volume_group *vg,
               uint32_t new_pe_count);
+int pv_analyze(struct cmd_context *cmd, const char *pv_name,
+	       int64_t label_sector);
 
 struct volume_group *vg_create(struct cmd_context *cmd, const char *name,
 			       uint32_t extent_size, uint32_t max_pv,
Index: LVM2/man/pvck.8
===================================================================
--- LVM2.orig/man/pvck.8	2007-04-20 13:39:28.000000000 -0400
+++ LVM2/man/pvck.8	2007-04-20 13:43:03.000000000 -0400
@@ -3,11 +3,27 @@
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
+By default the PV(s) are scanned for an LVM identifier (label) in its second
+sector (sector 1).  This lets you scan a different sector for an LVM label,
+and is useful for recovery situations.  For example, suppose the partition
+table is corrupted or lost on /dev/sda, but you know there were LVM partitions
+on it.  You can guess at the location of the partition, and pass this sector
+offset to pvck /dev/sda as the \fB--labelsector\fP parameter.  (With a script, you
+can automate this process if you are unsure about the location.)  Note that
+pvck scans a few sectors starting at labelsector (see LABEL_SCAN_SECTORS in
+the source) so you don't need to specify the exact sector for the label.
+For LVM1, you should use \fB--labelsector\fP 0.
 .SH SEE ALSO
 .BR lvm (8),
 .BR pvcreate (8),
Index: LVM2/tools/commands.h
===================================================================
--- LVM2.orig/tools/commands.h	2007-04-20 13:39:28.000000000 -0400
+++ LVM2/tools/commands.h	2007-04-20 13:43:03.000000000 -0400
@@ -412,9 +412,11 @@ xx(pvck,
    "pvck "
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
-   "\t[-v|--verbose]\n"
+    "\t[--labelsector sector] " "\n"
+  "\t[-v|--verbose]\n"
    "\t[--version]" "\n"
-   "\tPhysicalVolume [PhysicalVolume...]\n" )
+   "\tPhysicalVolume [PhysicalVolume...]\n",
+   labelsector_ARG)
 
 xx(pvcreate,
    "Initialize physical volume(s) for use by LVM",
Index: LVM2/tools/pvck.c
===================================================================
--- LVM2.orig/tools/pvck.c	2007-04-20 13:39:28.000000000 -0400
+++ LVM2/tools/pvck.c	2007-04-20 13:43:03.000000000 -0400
@@ -15,16 +15,29 @@
 
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
+		if (!pv_analyze(cmd, argv[i],
+				arg_int64_value(cmd, labelsector_ARG,
+						DEFAULT_LABELSECTOR)))
+			goto error;
+	}
+
+	return ECMD_PROCESSED;
+ error:
+	return ECMD_FAILED;
 }
Index: LVM2/WHATS_NEW
===================================================================
--- LVM2.orig/WHATS_NEW	2007-04-20 13:39:28.000000000 -0400
+++ LVM2/WHATS_NEW	2007-04-20 13:43:03.000000000 -0400
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Add ability for pvck to detect LVM2 and LVM1 labels.
   Add start_sector param to label_read and _find_labeller.
   Add lib/config support functions.
   Add count_chars_null and count_chars_len.



