From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 11:27:03 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20120215112703.11213.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 11:27:02

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-common.c libdm-common.h 
	libdm/ioctl    : libdm-iface.c libdm-targets.h 

Log message:
	Mangle device name on dm_task_set_name/newname call if necessary.
	
	If dm_task_set_name/newname is called, the name provided will be
	automatically translated to correct encoded form with the hex enconding
	so any character not on udev whitelist will be mangled with \xNN
	format where NN is hex value of the character used.
	
	By default, the name mangling mode used is the one set during
	configure with the '--with-default-name-mangling' option.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.558&r2=1.559
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.179&r2=1.180
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.h.diff?cvsroot=lvm2&r1=1.10&r2=1.11
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-targets.h.diff?cvsroot=lvm2&r1=1.33&r2=1.34

--- LVM2/WHATS_NEW_DM	2012/02/15 11:17:57	1.558
+++ LVM2/WHATS_NEW_DM	2012/02/15 11:27:01	1.559
@@ -1,5 +1,7 @@
 Version 1.02.71 - 
 ====================================
+  Mangle device name on dm_task_set_name/newname call if necessary.
+  Add dm_set/get_name_mangling_mode to set/get name mangling in libdevmapper.
   Add configure --with-default-name-mangling.
   Test for parsed words in _umount() dmeventd snapshot plugin.
   Fix memory leak in fail path of parse_loop_device_name() in dmsetup.
--- LVM2/libdm/libdevmapper.h	2012/02/15 11:17:58	1.179
+++ LVM2/libdm/libdevmapper.h	2012/02/15 11:27:01	1.180
@@ -287,6 +287,12 @@
 } dm_string_mangling_t;
 
 /*
+ * Set/get mangling mode used for device-mapper names.
+ */
+int dm_set_name_mangling_mode(dm_string_mangling_t name_mangling);
+dm_string_mangling_t dm_get_name_mangling_mode(void);
+
+/*
  * Configure the device-mapper directory
  */
 int dm_set_dev_dir(const char *dir);
--- LVM2/libdm/libdm-common.c	2012/02/13 14:39:24	1.138
+++ LVM2/libdm/libdm-common.c	2012/02/15 11:27:02	1.139
@@ -66,6 +66,7 @@
 
 static int _verbose = 0;
 static int _suspended_dev_counter = 0;
+static int _name_mangling_mode = DEFAULT_DM_NAME_MANGLING;
 
 #ifdef HAVE_SELINUX_LABEL_H
 static struct selabel_handle *_selabel_handle = NULL;
@@ -201,6 +202,18 @@
 	return _suspended_dev_counter;
 }
 
+int dm_set_name_mangling_mode(dm_string_mangling_t name_mangling_mode)
+{
+	_name_mangling_mode = name_mangling_mode;
+
+	return 1;
+}
+
+dm_string_mangling_t dm_get_name_mangling_mode(void)
+{
+	return _name_mangling_mode;
+}
+
 struct dm_task *dm_task_create(int type)
 {
 	struct dm_task *dmt = dm_zalloc(sizeof(*dmt));
@@ -238,18 +251,18 @@
 /*
  * Find the name associated with a given device number by scanning _dm_dir.
  */
-static char *_find_dm_name_of_device(dev_t st_rdev)
+static int _find_dm_name_of_device(dev_t st_rdev, char *buf, size_t buf_len)
 {
 	const char *name;
 	char path[PATH_MAX];
 	struct dirent *dirent;
 	DIR *d;
-	struct stat buf;
-	char *new_name = NULL;
+	struct stat st;
+	int r = 0;
 
 	if (!(d = opendir(_dm_dir))) {
 		log_sys_error("opendir", _dm_dir);
-		return NULL;
+		return 0;
 	}
 
 	while ((dirent = readdir(d))) {
@@ -264,13 +277,12 @@
 			continue;
 		}
 
-		if (stat(path, &buf))
+		if (stat(path, &st))
 			continue;
 
-		if (buf.st_rdev == st_rdev) {
-			if (!(new_name = dm_strdup(name)))
-				log_error("dm_task_set_name: strdup(%s) failed",
-					  name);
+		if (st.st_rdev == st_rdev) {
+			strncpy(buf, name, buf_len);
+			r = 1;
 			break;
 		}
 	}
@@ -278,72 +290,212 @@
 	if (closedir(d))
 		log_sys_error("closedir", _dm_dir);
 
-	return new_name;
+	return r;
 }
 
-int dm_task_set_name(struct dm_task *dmt, const char *name)
+static int _is_whitelisted_char(char c)
 {
-	char *pos;
-	char *new_name = NULL;
-	char path[PATH_MAX];
-	struct stat st1, st2;
-
-	dm_free(dmt->dev_name);
-	dmt->dev_name = NULL;
-
 	/*
-	 * Path supplied for existing device?
+	 * Actually, DM supports any character in a device name.
+	 * This whitelist is just for proper integration with udev.
 	 */
-	if ((pos = strrchr(name, '/'))) {
-		if (dmt->type == DM_DEVICE_CREATE) {
-			log_error("Name \"%s\" invalid. It contains \"/\".", name);
-			return 0;
-		}
+        if ((c >= '0' && c <= '9') ||
+            (c >= 'A' && c <= 'Z') ||
+            (c >= 'a' && c <= 'z') ||
+            strchr("#+-.:=@_", c) != NULL)
+                return 1;
 
-		if (stat(name, &st1)) {
-			log_error("Device %s not found", name);
-			return 0;
-		}
+        return 0;
+}
 
-		/*
-		 * If supplied path points to same device as last component
-		 * under /dev/mapper, use that name directly.  Otherwise call
-		 * _find_dm_name_of_device() to scan _dm_dir for a match.
-		 */
-		if (dm_snprintf(path, sizeof(path), "%s/%s", _dm_dir,
-				pos + 1) == -1) {
-			log_error("Couldn't create path for %s", pos + 1);
-			return 0;
+/*
+ * Mangle all characters in the input string which are not on a whitelist
+ * with '\xNN' format where NN is the hex value of the character.
+ */
+int mangle_name(const char *str, size_t len, char *buf,
+		size_t buf_len, dm_string_mangling_t mode)
+{
+	int need_mangling = -1; /* -1 don't know yet, 0 no, 1 yes */
+	size_t i, j;
+
+	if (!str || !buf)
+		return -1;
+
+	/* Is there anything to do@all? */
+	if (!*str || !len || mode == DM_STRING_MANGLING_NONE)
+		return 0;
+
+	if (buf_len < DM_NAME_LEN) {
+		log_error(INTERNAL_ERROR "mangle_name: supplied buffer too small");
+		return -1;
+	}
+
+	for (i = 0, j = 0; str[i]; i++) {
+		if (mode == DM_STRING_MANGLING_AUTO) {
+			/*
+			 * Detect already mangled part of the string and keep it.
+			 * Return error on mixture of mangled/not mangled!
+			 */
+			if (str[i] == '\\' && str[i+1] == 'x') {
+				if ((len - i < 4) || (need_mangling == 1))
+					goto bad1;
+				if (buf_len - j < 4)
+					goto bad2;
+
+				memcpy(&buf[j], &str[i], 4);
+				i+=3; j+=4;
+
+				need_mangling = 0;
+				continue;
+			}
 		}
 
-		if (!stat(path, &st2) && (st1.st_rdev == st2.st_rdev))
-			name = pos + 1;
-		else if ((new_name = _find_dm_name_of_device(st1.st_rdev)))
-			name = new_name;
-		else {
-			log_error("Device %s not found", name);
-			return 0;
+		if (_is_whitelisted_char(str[i])) {
+			/* whitelisted, keep it. */
+			if (buf_len - j < 1)
+				goto bad2;
+			buf[j] = str[i];
+			j++;
+		} else {
+			/*
+			 * Not on a whitelist, mangle it.
+			 * Return error on mixture of mangled/not mangled
+			 * unless a DM_STRING_MANGLING_HEX is used!.
+			 */
+			if ((mode != DM_STRING_MANGLING_HEX) && (need_mangling == 0))
+				goto bad1;
+			if (buf_len - j < 4)
+				goto bad2;
+
+			sprintf(&buf[j], "\\x%02x", (unsigned char) str[i]);
+			j+=4;
+
+			need_mangling = 1;
 		}
 	}
 
+	if (buf_len - j < 1)
+		goto bad2;
+	buf[j] = '\0';
+
+	/* All chars in the string whitelisted? */
+	if (need_mangling == -1)
+		need_mangling = 0;
+
+	return need_mangling;
+
+bad1:
+	log_error("The name \"%s\" contains mixed mangled and unmangled "
+		  "characters or it's already mangled improperly.", str);
+	return -1;
+bad2:
+	log_error("Mangled form of the name too long for \"%s\".", str);
+	return -1;
+}
+
+static int _dm_task_set_name(struct dm_task *dmt, const char *name,
+			     dm_string_mangling_t mangling_mode)
+{
+	char mangled_name[DM_NAME_LEN];
+	int r;
+
+	dm_free(dmt->dev_name);
+	dmt->dev_name = NULL;
+	dm_free(dmt->mangled_dev_name);
+	dmt->mangled_dev_name = NULL;
+
 	if (strlen(name) >= DM_NAME_LEN) {
-		log_error("Name \"%s\" too long", name);
-		dm_free(new_name);
+		log_error("Name \"%s\" too long.", name);
+		return 0;
+	}
+
+	if ((r = mangle_name(name, strlen(name), mangled_name,
+			     sizeof(mangled_name), mangling_mode)) < 0) {
+		log_error("Failed to mangle device name \"%s\".", name);
 		return 0;
 	}
 
-	if (new_name)
-		dmt->dev_name = new_name;
-	else if (!(dmt->dev_name = dm_strdup(name))) {
-		log_error("dm_task_set_name: strdup(%s) failed", name);
+	/* Store mangled_dev_name only if it differs from dev_name! */
+	if (r) {
+		log_debug("Device name mangled [%s]: %s --> %s",
+			  mangling_mode == DM_STRING_MANGLING_AUTO ? "auto" : "hex",
+			  name, mangled_name);
+		if (!(dmt->mangled_dev_name = dm_strdup(mangled_name))) {
+			log_error("_dm_task_set_name: dm_strdup(%s) failed", mangled_name);
+			return 0;
+		}
+	}
+
+	if (!(dmt->dev_name = dm_strdup(name))) {
+		log_error("_dm_task_set_name: strdup(%s) failed", name);
 		return 0;
 	}
 
 	return 1;
 }
 
+static int _dm_task_set_name_from_path(struct dm_task *dmt, const char *path,
+				       const char *name)
+{
+	char buf[PATH_MAX];
+	struct stat st1, st2;
+	const char *final_name;
+
+	if (dmt->type == DM_DEVICE_CREATE) {
+		log_error("Name \"%s\" invalid. It contains \"/\".", path);
+		return 0;
+	}
+
+	if (stat(path, &st1)) {
+		log_error("Device %s not found", path);
+		return 0;
+	}
+
+	/*
+	 * If supplied path points to same device as last component
+	 * under /dev/mapper, use that name directly.  Otherwise call
+	 * _find_dm_name_of_device() to scan _dm_dir for a match.
+	 */
+	if (dm_snprintf(buf, sizeof(buf), "%s/%s", _dm_dir, name) == -1) {
+		log_error("Couldn't create path for %s", name);
+		return 0;
+	}
+
+	if (!stat(path, &st2) && (st1.st_rdev == st2.st_rdev))
+		final_name = name;
+	else if (_find_dm_name_of_device(st1.st_rdev, buf, sizeof(buf)))
+		final_name = buf;
+	else {
+		log_error("Device %s not found", name);
+		return 0;
+	}
+
+	/* This is an already existing path - do not mangle! */
+	return _dm_task_set_name(dmt, final_name, DM_STRING_MANGLING_NONE);
+}
+
+int dm_task_set_name(struct dm_task *dmt, const char *name)
+{
+	char *pos;
+
+	/* Path supplied for existing device? */
+	if ((pos = strrchr(name, '/')))
+		return _dm_task_set_name_from_path(dmt, name, pos + 1);
+
+	return _dm_task_set_name(dmt, name, dm_get_name_mangling_mode());
+}
+
+const char *dm_task_get_name(const struct dm_task *dmt)
+{
+	return (dmt->dmi.v4->name);
+}
+
 int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 {
+	dm_string_mangling_t mangling_mode = dm_get_name_mangling_mode();
+	char mangled_name[DM_NAME_LEN];
+	int r;
+
 	if (strchr(newname, '/')) {
 		log_error("Name \"%s\" invalid. It contains \"/\".", newname);
 		return 0;
@@ -354,10 +506,24 @@
 		return 0;
 	}
 
+	if ((r = mangle_name(newname, strlen(newname), mangled_name,
+			     sizeof(mangled_name), mangling_mode)) < 0) {
+		log_error("Failed to mangle new device name \"%s\"", newname);
+		return 0;
+	}
+
+	if (r) {
+		log_debug("New device name mangled [%s]: %s --> %s",
+			  mangling_mode == DM_STRING_MANGLING_AUTO ? "auto" : "hex",
+			  newname, mangled_name);
+		newname = mangled_name;
+	}
+
 	if (!(dmt->newname = dm_strdup(newname))) {
 		log_error("dm_task_set_newname: strdup(%s) failed", newname);
 		return 0;
 	}
+
 	dmt->new_uuid = 0;
 
 	return 1;
--- LVM2/libdm/libdm-common.h	2012/01/09 12:26:15	1.10
+++ LVM2/libdm/libdm-common.h	2012/02/15 11:27:02	1.11
@@ -18,6 +18,9 @@
 
 #include "libdevmapper.h"
 
+int mangle_name(const char *str, size_t len, char *buf,
+		size_t buf_len, dm_string_mangling_t mode);
+
 struct target *create_target(uint64_t start,
 			     uint64_t len,
 			     const char *type, const char *params);
--- LVM2/libdm/ioctl/libdm-iface.c	2012/02/08 12:59:20	1.134
+++ LVM2/libdm/ioctl/libdm-iface.c	2012/02/15 11:27:02	1.135
@@ -450,6 +450,7 @@
 
 	_dm_zfree_dmi(dmt->dmi.v4);
 	dm_free(dmt->dev_name);
+	dm_free(dmt->mangled_dev_name);
 	dm_free(dmt->newname);
 	dm_free(dmt->message);
 	dm_free(dmt->geometry);
@@ -674,11 +675,6 @@
 				       MINOR(dmt->dmi.v4->dev), read_ahead);
 }
 
-const char *dm_task_get_name(const struct dm_task *dmt)
-{
-	return (dmt->dmi.v4->name);
-}
-
 const char *dm_task_get_uuid(const struct dm_task *dmt)
 {
 	return (dmt->dmi.v4->uuid);
--- LVM2/libdm/ioctl/libdm-targets.h	2011/10/19 16:36:02	1.33
+++ LVM2/libdm/ioctl/libdm-targets.h	2012/02/15 11:27:02	1.34
@@ -33,6 +33,7 @@
 struct dm_task {
 	int type;
 	char *dev_name;
+	char *mangled_dev_name;
 
 	struct target *head, *tail;
 


