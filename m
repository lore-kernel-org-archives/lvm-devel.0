From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 15 Feb 2012 12:01:28 -0000
Subject: LVM2/libdm libdevmapper.h ioctl/libdm-iface.c
Message-ID: <20120215120128.11090.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-15 12:01:28

Modified files:
	libdm          : libdevmapper.h 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Unamngle dm device name list automatically on ioctl return.
	
	If dm_task_get_name or dm_task_get_names gets called, these will return
	unmangled form of the names so the name mangling stays totally transparent
	to any libdevmapper user (unless DM_STRING_MANGLING_NONE is used in which
	case the name is not touched and it is is returned as it is in kernel).
	
	For example:
	
	dmsetup create "a b" - will create a\x20b device in kernel and so udev will
	create /dev/mapper/a\x20b
	
	dm_task_get_name/names will still return "a b"
	
	In AUTO mode, the libdevmapper user can still query the device by using
	the mangled ("a\x20b") or unmangled form of the name when calling dm_task_set_name.
	If mangled name is provided, it's detected and the name is kept as it is.
	If unmangled name is provided, it will be mangled. IOW in AUTO mode it's
	totally transparent and it should not require any changes in the code
	using libdevmapper.
	
	However, any libdevmapper user must be aware of the fact that the mangled form
	of the name appears in /dev/mapper (udev just can't deal with those blacklisted
	characters).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.181&r2=1.182
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.136&r2=1.137

--- LVM2/libdm/libdevmapper.h	2012/02/15 11:39:38	1.181
+++ LVM2/libdm/libdevmapper.h	2012/02/15 12:01:28	1.182
@@ -164,13 +164,22 @@
 int dm_get_library_version(char *version, size_t size);
 int dm_task_get_driver_version(struct dm_task *dmt, char *version, size_t size);
 int dm_task_get_info(struct dm_task *dmt, struct dm_info *dmi);
-const char *dm_task_get_name(const struct dm_task *dmt);
 const char *dm_task_get_uuid(const struct dm_task *dmt);
 
 struct dm_deps *dm_task_get_deps(struct dm_task *dmt);
-struct dm_names *dm_task_get_names(struct dm_task *dmt);
 struct dm_versions *dm_task_get_versions(struct dm_task *dmt);
 
+/*
+ * These functions return device-mapper names based on the value
+ * of the mangling mode set during preceding dm_task_run call:
+ *   - unmangled name for DM_STRING_MANGLING_{AUTO, HEX},
+ *   - name without any changes for DM_STRING_MANGLING_NONE.
+ *
+ * To get mangled or unmangled form of the name directly, use
+ * dm_task_get_name_mangled or dm_task_get_name_unmangled function.
+ */
+const char *dm_task_get_name(const struct dm_task *dmt);
+struct dm_names *dm_task_get_names(struct dm_task *dmt);
 
 int dm_task_set_ro(struct dm_task *dmt);
 int dm_task_set_newname(struct dm_task *dmt, const char *newname);
--- LVM2/libdm/ioctl/libdm-iface.c	2012/02/15 11:33:53	1.136
+++ LVM2/libdm/ioctl/libdm-iface.c	2012/02/15 12:01:28	1.137
@@ -1523,6 +1523,39 @@
 	return sanitised_message;
 }
 
+static void _do_dm_ioctl_unmangle_name(char *name)
+{
+	char buf[DM_NAME_LEN];
+	int r;
+
+	if ((r = unmangle_name(name, DM_NAME_LEN, buf, sizeof(buf),
+			       dm_get_name_mangling_mode())) < 0)
+		log_debug("_do_dm_ioctl_unmangle_name: failed to "
+			  "unmangle \"%s\"", name);
+	else if (r)
+		memcpy(name, buf, strlen(buf) + 1);
+}
+
+static void _dm_ioctl_unmangle_names(int type, struct dm_ioctl *dmi)
+{
+	struct dm_names *names;
+	unsigned next = 0;
+	char *name;
+
+	if ((name = dmi->name))
+		_do_dm_ioctl_unmangle_name(name);
+
+	if (type == DM_DEVICE_LIST &&
+	    ((names = ((struct dm_names *) ((char *)dmi + dmi->data_start)))) &&
+	    names->dev) {
+		do {
+			names = (struct dm_names *)((char *) names + next);
+			_do_dm_ioctl_unmangle_name(names->name);
+			next = names->next;
+		} while (next);
+	}
+}
+
 static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 				     unsigned buffer_repeat_count,
 				     unsigned retry_repeat_count,
@@ -1651,6 +1684,8 @@
 		_udev_complete(dmt);
 	}
 
+	(void) _dm_ioctl_unmangle_names(dmt->type, dmi);
+
 #else /* Userspace alternative for testing */
 #endif
 	return dmi;


