From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:40:03 -0000
Subject: LVM2 lib/metadata/metadata-exported.h lib/meta ...
Message-ID: <20100628204003.21009.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:40:01

Modified files:
	lib/metadata   : metadata-exported.h metadata.c 
	lib/report     : report.c 
	tools          : args.h lvmcmdline.c tools.h 

Log message:
	Allow 'all' and 'unmanaged' values for --vgmetadatacopies.
	
	Allowing an 'all' and 'unmanaged' value is more intuitive, and
	provides a simple way for users to get back to original LVM behavior
	of metadata written to all PVs in the volume group.
	
	If the user requests "--vgmetadatacopies unmanaged", this instructs
	LVM not to manage the ignore bits to achieve a specific number of
	metadata copies in the volume group.  The user is free to use
	"pvchange --metadataignore" to control the mdas on a per-PV basis.
	If the user requests "--vgmetadatacopies all", this instructs LVM
	to do 2 things: 1) clear all ignore bits, and 2) set the "unmanaged"
	policy going forward.
	
	Internally, we use the special MAX_UINT32 value to indicate 'all'.
	This 'just' works since it's the largest value possible for the
	field and so all 'ignore' bits on all mdas in the VG will get
	cleared inside _vg_metadata_balance().  However, after we've
	called the _vg_metadata_balance function, we check for the special
	'all' value, and if set, we write the "unmanaged" value into the
	metadata.  As such, the 'all' value is never written to disk.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata-exported.h.diff?cvsroot=lvm2&r1=1.157&r2=1.158
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.362&r2=1.363
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.121&r2=1.122
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/args.h.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.123&r2=1.124
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/tools.h.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/lib/metadata/metadata-exported.h	2010/06/28 20:36:56	1.157
+++ LVM2/lib/metadata/metadata-exported.h	2010/06/28 20:40:01	1.158
@@ -882,6 +882,8 @@
 uint64_t vg_max_lv(const struct volume_group *vg);
 uint32_t vg_mda_count(const struct volume_group *vg);
 uint32_t vg_mda_used_count(const struct volume_group *vg);
+#define VGMETADATACOPIES_ALL UINT32_MAX
+#define VGMETADATACOPIES_UNMANAGED 0
 uint32_t vg_mda_copies(const struct volume_group *vg);
 int vg_set_mda_copies(struct volume_group *vg, uint32_t value);
 int vg_check_write_mode(struct volume_group *vg);
--- LVM2/lib/metadata/metadata.c	2010/06/28 20:38:56	1.362
+++ LVM2/lib/metadata/metadata.c	2010/06/28 20:40:01	1.363
@@ -1063,7 +1063,7 @@
 	int ret = 1;
 
 	mda_copies = vg_mda_used_count(vg);
-	if (!vg->mda_copies)
+	if (vg->mda_copies == VGMETADATACOPIES_UNMANAGED)
 		goto skip_adjust;
 
 	if (mda_copies > vg->mda_copies) {
@@ -1076,6 +1076,15 @@
 			count = vg->mda_copies - mda_copies;
 		ret = _vg_unignore_mdas(vg, count);
 	}
+	/*
+	 * The VGMETADATACOPIES_ALL value will never be written disk.
+	 * It is a special cmdline value that means 2 things:
+	 * 1. clear all ignore bits in all mdas in this vg
+	 * 2. set the "unmanaged" policy going forward for metadata balancing
+	 */
+	if (vg->mda_copies == VGMETADATACOPIES_ALL)
+		vg->mda_copies = VGMETADATACOPIES_UNMANAGED;
+
 	if (!ret)
 		return ret;
 
--- LVM2/lib/report/report.c	2010/06/28 20:37:23	1.121
+++ LVM2/lib/report/report.c	2010/06/28 20:40:01	1.122
@@ -926,6 +926,11 @@
 
 	count = vg_mda_copies(vg);
 
+	if (count == VGMETADATACOPIES_UNMANAGED) {
+		dm_report_field_set_value(field, "unmanaged", &_minusone64);
+		return 1;
+	}
+
 	return _uint32_disp(rh, mem, field, &count, private);
 }
 
--- LVM2/tools/args.h	2010/06/28 20:37:37	1.76
+++ LVM2/tools/args.h	2010/06/28 20:40:01	1.77
@@ -23,7 +23,7 @@
 arg(ignorelockingfailure_ARG, '\0', "ignorelockingfailure", NULL, 0)
 arg(nolocking_ARG, '\0', "nolocking", NULL, 0)
 arg(pvmetadatacopies_ARG, '\0', "pvmetadatacopies", int_arg, 0)
-arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", int_arg, 0)
+arg(vgmetadatacopies_ARG, '\0', "vgmetadatacopies", vgmetadatacopies_arg, 0)
 arg(metadatacopies_ARG, '\0', "metadatacopies", int_arg, 0)
 arg(metadatasize_ARG, '\0', "metadatasize", size_mb_arg, 0)
 arg(metadataignore_ARG, '\0', "metadataignore", yes_no_arg, 0)
--- LVM2/tools/lvmcmdline.c	2010/06/28 20:39:39	1.123
+++ LVM2/tools/lvmcmdline.c	2010/06/28 20:40:01	1.124
@@ -473,6 +473,34 @@
 	return 1;
 }
 
+/*
+ * Non-zero, positive integer, "all", or "unmanaged"
+ */
+int vgmetadatacopies_arg(struct cmd_context *cmd __attribute((unused)),
+			 struct arg *a)
+{
+	if (!strcasecmp(a->value, "all")) {
+		a->ui_value = VGMETADATACOPIES_ALL;
+		return 1;
+	}
+
+	if (!strcasecmp(a->value, "unmanaged")) {
+		a->ui_value = VGMETADATACOPIES_UNMANAGED;
+		return 1;
+	}
+
+	if (!_size_arg(cmd, a, 1))
+		return 0;
+
+	if (a->sign == SIGN_MINUS)
+		return 0;
+
+	if (!a->ui_value)
+		return 0;
+
+	return 1;
+}
+
 static void __alloc(int size)
 {
 	if (!(_cmdline.commands = dm_realloc(_cmdline.commands, sizeof(*_cmdline.commands) * size))) {
--- LVM2/tools/tools.h	2010/06/15 11:00:46	1.68
+++ LVM2/tools/tools.h	2010/06/28 20:40:01	1.69
@@ -152,6 +152,8 @@
 int segtype_arg(struct cmd_context *cmd, struct arg *a);
 int alloc_arg(struct cmd_context *cmd, struct arg *a);
 int readahead_arg(struct cmd_context *cmd, struct arg *a);
+int vgmetadatacopies_arg(struct cmd_context *cmd __attribute((unused)),
+			 struct arg *a);
 
 /* we use the enums to access the switches */
 unsigned arg_count(const struct cmd_context *cmd, int a);


