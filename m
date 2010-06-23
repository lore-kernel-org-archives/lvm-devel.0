From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Jun 2010 12:32:12 -0000
Subject: LVM2 ./WHATS_NEW lib/report/columns.h lib/repo ...
Message-ID: <20100623123212.8755.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-06-23 12:32:08

Modified files:
	.              : WHATS_NEW 
	lib/report     : columns.h report.c 
	man            : lvs.8.in 

Log message:
	Add lv_path to reports to offer full /dev pathname.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1627&r2=1.1628
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/columns.h.diff?cvsroot=lvm2&r1=1.38&r2=1.39
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvs.8.in.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/WHATS_NEW	2010/06/23 10:21:00	1.1627
+++ LVM2/WHATS_NEW	2010/06/23 12:32:08	1.1628
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Add lv_path to reports to offer full /dev pathname.
   Fix typo in warning message about missing device with allocated data areas.
   Add device name and offset to output of error messages in raw_read_mda_header().
   Use flexible data[] in cmirrord request to prevent abort in runtime size checks.
@@ -14,7 +15,8 @@
   Add --force, --nofsck and --resizefs to lvresize/extend/reduce man pages.
   Fix lvm2cmd example in documentation.
   Allow use of lvm2app and lvm2cmd headers in C++ code.
-  Remove some unused #includes from clvmd files.
+  Remove unused #includes from clvmd files and introduce clvmd-common.h.
+  Move common inclusions to clvmd-common.h.
   Use #include "" for libdevmapper.h and configure.h throughout tree.
   Fix LVM_PATH expansion when exec_prefix=NONE (2.02.67).
   Fix segfault in clvmd -R if no response from daemon received.
--- LVM2/lib/report/columns.h	2010/02/14 03:21:38	1.38
+++ LVM2/lib/report/columns.h	2010/06/23 12:32:08	1.39
@@ -57,6 +57,7 @@
 /* *INDENT-OFF* */
 FIELD(LVS, lv, STR, "LV UUID", lvid.id[1], 38, uuid, "lv_uuid", "Unique identifier.")
 FIELD(LVS, lv, STR, "LV", lvid, 4, lvname, "lv_name", "Name.  LVs created for internal use are enclosed in brackets.")
+FIELD(LVS, lv, STR, "Path", lvid, 4, lvpath, "lv_path", "Full pathname for LV.")
 FIELD(LVS, lv, STR, "Attr", lvid, 4, lvstatus, "lv_attr", "Various attributes - see man page.")
 FIELD(LVS, lv, NUM, "Maj", major, 3, int32, "lv_major", "Persistent major number or -1 if not persistent.")
 FIELD(LVS, lv, NUM, "Min", minor, 3, int32, "lv_minor", "Persistent minor number or -1 if not persistent.")
--- LVM2/lib/report/report.c	2010/05/20 22:24:35	1.116
+++ LVM2/lib/report/report.c	2010/06/23 12:32:08	1.117
@@ -523,6 +523,30 @@
 	return 1;
 }
 
+static int _lvpath_disp(struct dm_report *rh, struct dm_pool *mem,
+			struct dm_report_field *field,
+			const void *data, void *private __attribute((unused)))
+{
+	const struct logical_volume *lv = (const struct logical_volume *) data;
+	char *repstr;
+	size_t len;
+
+	len = strlen(lv->vg->cmd->dev_dir) + strlen(lv->vg->name) + strlen(lv->name) + 2;
+	if (!(repstr = dm_pool_zalloc(mem, len))) {
+		log_error("dm_pool_alloc failed");
+		return 0;
+	}
+
+	if (dm_snprintf(repstr, len, "%s%s/%s", lv->vg->cmd->dev_dir, lv->vg->name, lv->name) < 0) {
+		log_error("lvpath snprintf failed");
+		return 0;
+	}
+
+	dm_report_field_set_value(field, repstr, NULL);
+
+	return 1;
+}
+
 static int _origin_disp(struct dm_report *rh, struct dm_pool *mem,
 			struct dm_report_field *field,
 			const void *data, void *private)
--- LVM2/man/lvs.8.in	2010/01/13 01:48:38	1.12
+++ LVM2/man/lvs.8.in	2010/06/23 12:32:08	1.13
@@ -55,7 +55,7 @@
 Use \fb-o help\fP to view the full list of columns available.
 .IP
 Column names include:
-lv_uuid, lv_name, lv_attr, lv_major, lv_minor, lv_read_ahead, lv_kernel_major,
+lv_uuid, lv_name, lv_path, lv_attr, lv_major, lv_minor, lv_read_ahead, lv_kernel_major,
 lv_kernel_minor, lv_kernel_read_ahead, lv_size, seg_count, origin, origin_size,
 snap_percent, copy_percent, move_pv, convert_lv, lv_tags, mirror_log, modules,
 segtype, stripes, stripesize, regionsize, chunksize, seg_start, seg_start_pe,


