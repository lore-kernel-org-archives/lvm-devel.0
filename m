From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 5 Mar 2012 12:48:15 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-common.c libdm ...
Message-ID: <20120305124815.27974.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-05 12:48:13

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-common.c libdm-common.h 
	libdm/ioctl    : libdm-iface.c 
	tools          : dmsetup.c 

Log message:
	Check for multiple mangled names in auto mangling mode.
	
	Auto mode can't deal with multiple mangled names. We can do that while working
	in hex mode, but in auto mode, this would lead to device name ambiguity.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.588&r2=1.589
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.h.diff?cvsroot=lvm2&r1=1.14&r2=1.15
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.185&r2=1.186

--- LVM2/WHATS_NEW_DM	2012/03/05 12:45:43	1.588
+++ LVM2/WHATS_NEW_DM	2012/03/05 12:48:12	1.589
@@ -1,5 +1,6 @@
 Version 1.02.74 - 
 ================================
+  Check for multiple mangled names in auto mangling mode.
   Fix dm_task_get_name_unmangled to not unmangle already unmangled name.
   Check whether device names are properly mangled on ioctl return.
   Deactivation of failed thin check on thin pool returns success.
--- LVM2/libdm/libdm-common.c	2012/03/05 12:45:43	1.146
+++ LVM2/libdm/libdm-common.c	2012/03/05 12:48:12	1.147
@@ -326,6 +326,17 @@
         return 0;
 }
 
+int check_multiple_mangled_name_allowed(dm_string_mangling_t mode, const char *name)
+{
+	if (mode == DM_STRING_MANGLING_AUTO && strstr(name, "\\x5cx")) {
+		log_error("The name \"%s\" seems to be multiple mangled. "
+			  "This is not allowed in auto mode.", name);
+		return 0;
+	}
+
+	return 1;
+}
+
 /*
  * Mangle all characters in the input string which are not on a whitelist
  * with '\xNN' format where NN is the hex value of the character.
@@ -485,6 +496,9 @@
 		return 0;
 	}
 
+	if (!check_multiple_mangled_name_allowed(mangling_mode, name))
+		return_0;
+
 	if (mangling_mode != DM_STRING_MANGLING_NONE &&
 	    (r = mangle_name(name, strlen(name), mangled_name,
 			     sizeof(mangled_name), mangling_mode)) < 0) {
@@ -620,6 +634,9 @@
 		return 0;
 	}
 
+	if (!check_multiple_mangled_name_allowed(mangling_mode, newname))
+		return_0;
+
 	if (mangling_mode != DM_STRING_MANGLING_NONE &&
 	    (r = mangle_name(newname, strlen(newname), mangled_name,
 			     sizeof(mangled_name), mangling_mode)) < 0) {
--- LVM2/libdm/libdm-common.h	2012/02/15 12:23:16	1.14
+++ LVM2/libdm/libdm-common.h	2012/03/05 12:48:13	1.15
@@ -28,6 +28,8 @@
 int unmangle_name(const char *str, size_t len, char *buf,
 		  size_t buf_len, dm_string_mangling_t mode);
 
+int check_multiple_mangled_name_allowed(dm_string_mangling_t mode, const char *name);
+
 struct target *create_target(uint64_t start,
 			     uint64_t len,
 			     const char *type, const char *params);
--- LVM2/libdm/ioctl/libdm-iface.c	2012/03/05 12:43:03	1.142
+++ LVM2/libdm/ioctl/libdm-iface.c	2012/03/05 12:48:13	1.143
@@ -1559,6 +1559,9 @@
 	if (mode == DM_STRING_MANGLING_NONE)
 		return 1;
 
+	if (!check_multiple_mangled_name_allowed(mode, name))
+		return_0;
+
 	if ((r = unmangle_name(name, DM_NAME_LEN, buf, sizeof(buf),
 			       dm_get_name_mangling_mode())) < 0) {
 		log_debug("_do_dm_ioctl_unmangle_name: failed to "
--- LVM2/tools/dmsetup.c	2012/03/01 21:56:44	1.185
+++ LVM2/tools/dmsetup.c	2012/03/05 12:48:13	1.186
@@ -2944,6 +2944,12 @@
 	target_format = _switches[MANGLENAME_ARG] ? _int_args[MANGLENAME_ARG]
 						  : DEFAULT_DM_NAME_MANGLING;
 
+	if (target_format == DM_STRING_MANGLING_AUTO && strstr(name, "\\x5cx")) {
+		log_error("The name \"%s\" seems to be multiple mangled. "
+			  "Manual intervention required to rename the device.", name);
+		goto out;
+	}
+
 	if (target_format == DM_STRING_MANGLING_NONE) {
 		if (!(new_name = dm_task_get_name_unmangled(dmt)))
 			goto out;


