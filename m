From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 5 Mar 2012 12:40:35 -0000
Subject: LVM2/libdm libdm-common.c ioctl/libdm-iface.c
Message-ID: <20120305124035.25157.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-05 12:40:35

Modified files:
	libdm          : libdm-common.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Clean up internal mangling interface.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.143&r2=1.144
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.140&r2=1.141

--- LVM2/libdm/libdm-common.c	2012/02/28 14:24:57	1.143
+++ LVM2/libdm/libdm-common.c	2012/03/05 12:40:34	1.144
@@ -340,7 +340,7 @@
 		return -1;
 
 	/* Is there anything to do at all? */
-	if (!*str || !len || mode == DM_STRING_MANGLING_NONE)
+	if (!*str || !len)
 		return 0;
 
 	if (buf_len < DM_NAME_LEN) {
@@ -348,6 +348,9 @@
 		return -1;
 	}
 
+	if (mode == DM_STRING_MANGLING_NONE)
+		mode = DM_STRING_MANGLING_AUTO;
+
 	for (i = 0, j = 0; str[i]; i++) {
 		if (mode == DM_STRING_MANGLING_AUTO) {
 			/*
@@ -427,7 +430,7 @@
 		return -1;
 
 	/* Is there anything to do@all? */
-	if (!*str || !len || mode == DM_STRING_MANGLING_NONE)
+	if (!*str || !len)
 		return 0;
 
 	if (buf_len < DM_NAME_LEN) {
@@ -462,7 +465,7 @@
 			     dm_string_mangling_t mangling_mode)
 {
 	char mangled_name[DM_NAME_LEN];
-	int r;
+	int r = 0;
 
 	dm_free(dmt->dev_name);
 	dmt->dev_name = NULL;
@@ -474,7 +477,8 @@
 		return 0;
 	}
 
-	if ((r = mangle_name(name, strlen(name), mangled_name,
+	if (mangling_mode != DM_STRING_MANGLING_NONE &&
+	    (r = mangle_name(name, strlen(name), mangled_name,
 			     sizeof(mangled_name), mangling_mode)) < 0) {
 		log_error("Failed to mangle device name \"%s\".", name);
 		return 0;
@@ -562,13 +566,8 @@
 	char *rs = NULL;
 	int r;
 
-	/*
-	 * We're using 'auto mangling' here. If the name is already mangled,
-	 * this is detected and we keep it as it is. If the name is not mangled,
-	 * we do mangle it. This way we always get a mangled form of the name.
-	 */
 	if ((r = mangle_name(s, strlen(s), buf, sizeof(buf),
-			     DM_STRING_MANGLING_AUTO)) < 0)
+			     dm_get_name_mangling_mode())) < 0)
 		log_error("Failed to mangle device name \"%s\".", s);
 	else if (!(rs = r ? dm_strdup(buf) : dm_strdup(s)))
 		log_error("dm_task_get_name_mangled: dm_strdup failed");
@@ -583,12 +582,8 @@
 	char *rs = NULL;
 	int r;
 
-	/*
-	 * We just want to unmangle the string.
-	 * Both auto and hex mode will do it.
-	 */
 	if ((r = unmangle_name(s, strlen(s), buf, sizeof(buf),
-			       DM_STRING_MANGLING_AUTO)) < 0)
+			       dm_get_name_mangling_mode())) < 0)
 		log_error("Failed to unmangle device name \"%s\".", s);
 	else if (!(rs = r ? dm_strdup(buf) : dm_strdup(s)))
 		log_error("dm_task_get_name_unmangled: dm_strdup failed");
@@ -600,7 +595,7 @@
 {
 	dm_string_mangling_t mangling_mode = dm_get_name_mangling_mode();
 	char mangled_name[DM_NAME_LEN];
-	int r;
+	int r = 0;
 
 	if (strchr(newname, '/')) {
 		log_error("Name \"%s\" invalid. It contains \"/\".", newname);
@@ -612,7 +607,8 @@
 		return 0;
 	}
 
-	if ((r = mangle_name(newname, strlen(newname), mangled_name,
+	if (mangling_mode != DM_STRING_MANGLING_NONE &&
+	    (r = mangle_name(newname, strlen(newname), mangled_name,
 			     sizeof(mangled_name), mangling_mode)) < 0) {
 		log_error("Failed to mangle new device name \"%s\"", newname);
 		return 0;
--- LVM2/libdm/ioctl/libdm-iface.c	2012/03/01 10:46:39	1.140
+++ LVM2/libdm/ioctl/libdm-iface.c	2012/03/05 12:40:34	1.141
@@ -1552,9 +1552,13 @@
 
 static void _do_dm_ioctl_unmangle_name(char *name)
 {
+	dm_string_mangling_t mode = dm_get_name_mangling_mode();
 	char buf[DM_NAME_LEN];
 	int r;
 
+	if (mode == DM_STRING_MANGLING_NONE)
+		return;
+
 	if ((r = unmangle_name(name, DM_NAME_LEN, buf, sizeof(buf),
 			       dm_get_name_mangling_mode())) < 0)
 		log_debug("_do_dm_ioctl_unmangle_name: failed to "


