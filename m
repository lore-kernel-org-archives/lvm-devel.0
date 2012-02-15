From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 11:39:39 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20120215113939.4808.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 11:39:38

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-common.c libdm-common.h 

Log message:
	Add dm_task_get_name_mangled/unmangled to libdevmapper.
	
	dm_task_get_name_mangled will always return mangled form of the name while
	the dm_task_get_name_unmangled will always return unmangled form of the name
	irrespective of the global setting (dm_set/get_name_mangling_mode).
	
	This is handy in situations where we need to detect whether the name is already
	mangled or not. Also display functions make use of it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.559&r2=1.560
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.180&r2=1.181
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.h.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/WHATS_NEW_DM	2012/02/15 11:27:01	1.559
+++ LVM2/WHATS_NEW_DM	2012/02/15 11:39:38	1.560
@@ -1,5 +1,6 @@
 Version 1.02.71 - 
 ====================================
+  Add dm_task_get_name_mangled/unmangled to libdevmapper.
   Mangle device name on dm_task_set_name/newname call if necessary.
   Add dm_set/get_name_mangling_mode to set/get name mangling in libdevmapper.
   Add configure --with-default-name-mangling.
--- LVM2/libdm/libdevmapper.h	2012/02/15 11:27:01	1.180
+++ LVM2/libdm/libdevmapper.h	2012/02/15 11:39:38	1.181
@@ -171,6 +171,7 @@
 struct dm_names *dm_task_get_names(struct dm_task *dmt);
 struct dm_versions *dm_task_get_versions(struct dm_task *dmt);
 
+
 int dm_task_set_ro(struct dm_task *dmt);
 int dm_task_set_newname(struct dm_task *dmt, const char *newname);
 int dm_task_set_newuuid(struct dm_task *dmt, const char *newuuid);
@@ -293,6 +294,14 @@
 dm_string_mangling_t dm_get_name_mangling_mode(void);
 
 /*
+ * Get mangled/unmangled form of the device-mapper name
+ * irrespective of the global setting (set by dm_set_name_mangling_mode).
+ * The name returned needs to be freed after use by calling dm_free!
+ */
+char *dm_task_get_name_mangled(const struct dm_task *dmt);
+char *dm_task_get_name_unmangled(const struct dm_task *dmt);
+
+/*
  * Configure the device-mapper directory
  */
 int dm_set_dev_dir(const char *dir);
--- LVM2/libdm/libdm-common.c	2012/02/15 11:27:02	1.139
+++ LVM2/libdm/libdm-common.c	2012/02/15 11:39:38	1.140
@@ -393,6 +393,53 @@
 	return -1;
 }
 
+/*
+ * Try to unmangle supplied string.
+ * Return value: -1 on error, 0 when no unmangling needed, 1 when unmangling applied
+ */
+int unmangle_name(const char *str, size_t len, char *buf,
+		  size_t buf_len, dm_string_mangling_t mode)
+{
+	char str_rest[DM_NAME_LEN];
+	size_t i, j;
+	int code;
+	int r = 0;
+
+	if (!str || !buf)
+		return -1;
+
+	/* Is there anything to do at all? */
+	if (!*str || !len || mode == DM_STRING_MANGLING_NONE)
+		return 0;
+
+	if (buf_len < DM_NAME_LEN) {
+		log_error(INTERNAL_ERROR "unmangle_name: supplied buffer too small");
+		return -1;
+	}
+
+	for (i = 0, j = 0; str[i]; i++, j++) {
+		if (str[i] == '\\' && str[i+1] == 'x') {
+			if (!sscanf(&str[i+2], "%2x%s", &code, str_rest)) {
+				log_debug("Hex encoding mismatch detected in \"%s\" "
+					  "while trying to unmangle it.", str);
+				goto out;
+			}
+			buf[j] = (unsigned char) code;
+
+			/* skip the encoded part we've just decoded! */
+			i+= 3;
+
+			/* unmangling applied */
+			r = 1;
+		} else
+			buf[j] = str[i];
+	}
+
+out:
+	buf[j] = '\0';
+	return r;
+}
+
 static int _dm_task_set_name(struct dm_task *dmt, const char *name,
 			     dm_string_mangling_t mangling_mode)
 {
@@ -490,6 +537,47 @@
 	return (dmt->dmi.v4->name);
 }
 
+char *dm_task_get_name_mangled(const struct dm_task *dmt)
+{
+	const char *s = dm_task_get_name(dmt);
+	char buf[DM_NAME_LEN];
+	char *rs = NULL;
+	int r;
+
+	/*
+	 * We're using 'auto mangling' here. If the name is already mangled,
+	 * this is detected and we keep it as it is. If the name is not mangled,
+	 * we do mangle it. This way we always get a mangled form of the name.
+	 */
+	if ((r = mangle_name(s, strlen(s), buf, sizeof(buf),
+			     DM_STRING_MANGLING_AUTO)) < 0)
+		log_error("Failed to mangle device name \"%s\".", s);
+	else if (!(rs = r ? dm_strdup(buf) : dm_strdup(s)))
+		log_error("dm_task_get_name_mangled: dm_strdup failed");
+
+	return rs;
+}
+
+char *dm_task_get_name_unmangled(const struct dm_task *dmt)
+{
+	const char *s = dm_task_get_name(dmt);
+	char buf[DM_NAME_LEN];
+	char *rs = NULL;
+	int r;
+
+	/*
+	 * We just want to unmangle the string.
+	 * Both auto and hex mode will do it.
+	 */
+	if ((r = unmangle_name(s, strlen(s), buf, sizeof(buf),
+			       DM_STRING_MANGLING_AUTO)) < 0)
+		log_error("Failed to unmangle device name \"%s\".", s);
+	else if (!(rs = r ? dm_strdup(buf) : dm_strdup(s)))
+		log_error("dm_task_get_name_unmangled: dm_strdup failed");
+
+	return rs;
+}
+
 int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 {
 	dm_string_mangling_t mangling_mode = dm_get_name_mangling_mode();
--- LVM2/libdm/libdm-common.h	2012/02/15 11:33:53	1.12
+++ LVM2/libdm/libdm-common.h	2012/02/15 11:39:38	1.13
@@ -23,6 +23,9 @@
 int mangle_name(const char *str, size_t len, char *buf,
 		size_t buf_len, dm_string_mangling_t mode);
 
+int unmangle_name(const char *str, size_t len, char *buf,
+		  size_t buf_len, dm_string_mangling_t mode);
+
 struct target *create_target(uint64_t start,
 			     uint64_t len,
 			     const char *type, const char *params);


