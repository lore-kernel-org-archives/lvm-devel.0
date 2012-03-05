From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 5 Mar 2012 12:43:05 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-common.c libdm ...
Message-ID: <20120305124305.25720.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-05 12:43:03

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-common.c 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Check whether device names are properly mangled on ioctl return.
	
	Be more strict when unmangling names on ioctl return - require the name to be
	properly mangled in 'auto' and 'hex' mode. There really should not be any
	blacklisted character since the names should be renamed already (by means of
	renaming it directly or running 'dmsetup mangle' for automatic rename).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.586&r2=1.587
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.144&r2=1.145
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.141&r2=1.142

--- LVM2/WHATS_NEW_DM	2012/03/04 17:40:59	1.586
+++ LVM2/WHATS_NEW_DM	2012/03/05 12:43:03	1.587
@@ -1,5 +1,6 @@
 Version 1.02.74 - 
 ================================
+  Check whether device names are properly mangled on ioctl return.
   Deactivation of failed thin check on thin pool returns success.
 
 Version 1.02.73 - 3rd March 2012
--- LVM2/libdm/libdm-common.c	2012/03/05 12:40:34	1.144
+++ LVM2/libdm/libdm-common.c	2012/03/05 12:43:03	1.145
@@ -421,6 +421,7 @@
 int unmangle_name(const char *str, size_t len, char *buf,
 		  size_t buf_len, dm_string_mangling_t mode)
 {
+	int strict = mode != DM_STRING_MANGLING_NONE;
 	char str_rest[DM_NAME_LEN];
 	size_t i, j;
 	int code;
@@ -439,6 +440,13 @@
 	}
 
 	for (i = 0, j = 0; str[i]; i++, j++) {
+		if (strict && !(_is_whitelisted_char(str[i]) || str[i]=='\\')) {
+			log_error("The name \"%s\" should be mangled but "
+				  "it contains blacklisted characters.", str);
+			j=0; r=-1;
+			goto out;
+		}
+
 		if (str[i] == '\\' && str[i+1] == 'x') {
 			if (!sscanf(&str[i+2], "%2x%s", &code, str_rest)) {
 				log_debug("Hex encoding mismatch detected in \"%s\" "
--- LVM2/libdm/ioctl/libdm-iface.c	2012/03/05 12:40:34	1.141
+++ LVM2/libdm/ioctl/libdm-iface.c	2012/03/05 12:43:03	1.142
@@ -1550,41 +1550,47 @@
 	return sanitised_message;
 }
 
-static void _do_dm_ioctl_unmangle_name(char *name)
+static int _do_dm_ioctl_unmangle_name(char *name)
 {
 	dm_string_mangling_t mode = dm_get_name_mangling_mode();
 	char buf[DM_NAME_LEN];
 	int r;
 
 	if (mode == DM_STRING_MANGLING_NONE)
-		return;
+		return 1;
 
 	if ((r = unmangle_name(name, DM_NAME_LEN, buf, sizeof(buf),
-			       dm_get_name_mangling_mode())) < 0)
+			       dm_get_name_mangling_mode())) < 0) {
 		log_debug("_do_dm_ioctl_unmangle_name: failed to "
 			  "unmangle \"%s\"", name);
-	else if (r)
+		return 0;
+	} else if (r)
 		memcpy(name, buf, strlen(buf) + 1);
+
+	return 1;
 }
 
-static void _dm_ioctl_unmangle_names(int type, struct dm_ioctl *dmi)
+static int _dm_ioctl_unmangle_names(int type, struct dm_ioctl *dmi)
 {
 	struct dm_names *names;
 	unsigned next = 0;
 	char *name;
+	int r = 1;
 
 	if ((name = dmi->name))
-		_do_dm_ioctl_unmangle_name(name);
+		r = _do_dm_ioctl_unmangle_name(name);
 
 	if (type == DM_DEVICE_LIST &&
 	    ((names = ((struct dm_names *) ((char *)dmi + dmi->data_start)))) &&
 	    names->dev) {
 		do {
 			names = (struct dm_names *)((char *) names + next);
-			_do_dm_ioctl_unmangle_name(names->name);
+			r = _do_dm_ioctl_unmangle_name(names->name);
 			next = names->next;
 		} while (next);
 	}
+
+	return r;
 }
 
 static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
@@ -1703,8 +1709,7 @@
 			 */
 			*retryable = errno == EBUSY;
 
-			_dm_zfree_dmi(dmi);
-			return NULL;
+			goto error;
 		}
 	}
 
@@ -1715,11 +1720,16 @@
 		_udev_complete(dmt);
 	}
 
-	(void) _dm_ioctl_unmangle_names(dmt->type, dmi);
+	if (!_dm_ioctl_unmangle_names(dmt->type, dmi))
+		goto error;
 
 #else /* Userspace alternative for testing */
 #endif
 	return dmi;
+
+error:
+	_dm_zfree_dmi(dmi);
+	return NULL;
 }
 
 void dm_task_update_nodes(void)


