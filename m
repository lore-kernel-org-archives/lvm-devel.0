From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 12:06:17 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20120215120617.12989.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 12:06:17

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Add 'mangled_name' and 'unmangled_name' fields to dmsetup info -c -o.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.561&r2=1.562
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.177&r2=1.178

--- LVM2/WHATS_NEW_DM	2012/02/15 12:02:58	1.561
+++ LVM2/WHATS_NEW_DM	2012/02/15 12:06:17	1.562
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Add 'mangled_name' and 'unmangled_name' fields to dmsetup info -c -o.
   Add --manglename option to dmsetup to select the name mangling mode.
   Add dm_task_get_name_mangled/unmangled to libdevmapper.
   Mangle device name on dm_task_set_name/newname call if necessary.
--- LVM2/tools/dmsetup.c	2012/02/15 12:02:59	1.177
+++ LVM2/tools/dmsetup.c	2012/02/15 12:06:17	1.178
@@ -2262,6 +2262,38 @@
 	return dm_report_field_string(rh, field, &name);
 }
 
+static int _dm_mangled_name_disp(struct dm_report *rh,
+				 struct dm_pool *mem __attribute__((unused)),
+				 struct dm_report_field *field, const void *data,
+				 void *private __attribute__((unused)))
+{
+	char *name;
+	int r = 0;
+
+	if ((name = dm_task_get_name_mangled((const struct dm_task *) data))) {
+		r = dm_report_field_string(rh, field, (const char **) &name);
+		dm_free(name);
+	}
+
+	return r;
+}
+
+static int _dm_unmangled_name_disp(struct dm_report *rh,
+				   struct dm_pool *mem __attribute__((unused)),
+				   struct dm_report_field *field, const void *data,
+				   void *private __attribute__((unused)))
+{
+	char *name;
+	int r = 0;
+
+	if ((name = dm_task_get_name_unmangled((const struct dm_task *) data))) {
+		r = dm_report_field_string(rh, field, (const char **) &name);
+		dm_free(name);
+	}
+
+	return r;
+}
+
 static int _dm_uuid_disp(struct dm_report *rh,
 			 struct dm_pool *mem __attribute__((unused)),
 			 struct dm_report_field *field,
@@ -2693,6 +2725,8 @@
 static const struct dm_report_field_type _report_fields[] = {
 /* *INDENT-OFF* */
 FIELD_F(TASK, STR, "Name", 16, dm_name, "name", "Name of mapped device.")
+FIELD_F(TASK, STR, "MangledName", 16, dm_mangled_name, "mangled_name", "Mangled name of mapped device.")
+FIELD_F(TASK, STR, "UnmangledName", 16, dm_unmangled_name, "unmangled_name", "Unmangled name of mapped device.")
 FIELD_F(TASK, STR, "UUID", 32, dm_uuid, "uuid", "Unique (optional) identifier for mapped device.")
 
 /* FIXME Next one should be INFO */


