From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Oct 2010 01:10:31 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdevmapper.h libdm ...
Message-ID: <20101015011031.20036.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-10-15 01:10:29

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdevmapper.h libdm-common.c 
	libdm/ioctl    : libdm-iface.c libdm-targets.h 
	libdm/misc     : dm-ioctl.h 
	man            : dmsetup.8.in 
	tools          : dmsetup.c 

Log message:
	Add --setuuid to dmsetup rename.
	Add dm_task_set_newuuid to set uuid of mapped device post-creation. (pjones)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.416&r2=1.417
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.126&r2=1.127
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.100&r2=1.101
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.81&r2=1.82
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-targets.h.diff?cvsroot=lvm2&r1=1.26&r2=1.27
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dm-ioctl.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.35&r2=1.36
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.145&r2=1.146

--- LVM2/WHATS_NEW_DM	2010/09/27 19:09:34	1.416
+++ LVM2/WHATS_NEW_DM	2010/10/15 01:10:27	1.417
@@ -1,5 +1,7 @@
 Version 1.02.56 - 
 =====================================
+  Add --setuuid to dmsetup rename.
+  Add dm_task_set_newuuid to set uuid of mapped device post-creation.
 
 Version 1.02.55 - 24th September 2010
 =====================================
--- LVM2/libdm/libdevmapper.h	2010/09/30 21:06:52	1.126
+++ LVM2/libdm/libdevmapper.h	2010/10/15 01:10:28	1.127
@@ -167,6 +167,7 @@
 
 int dm_task_set_ro(struct dm_task *dmt);
 int dm_task_set_newname(struct dm_task *dmt, const char *newname);
+int dm_task_set_newuuid(struct dm_task *dmt, const char *newuuid);
 int dm_task_set_minor(struct dm_task *dmt, int minor);
 int dm_task_set_major(struct dm_task *dmt, int major);
 int dm_task_set_major_minor(struct dm_task *dmt, int major, int minor, int allow_default_major_fallback);
--- LVM2/libdm/libdm-common.c	2010/09/30 21:06:52	1.100
+++ LVM2/libdm/libdm-common.c	2010/10/15 01:10:28	1.101
@@ -192,6 +192,7 @@
 	dmt->event_nr = 0;
 	dmt->cookie_set = 0;
 	dmt->query_inactive_table = 0;
+	dmt->new_uuid = 0;
 
 	return dmt;
 }
--- LVM2/libdm/ioctl/libdm-iface.c	2010/08/18 13:11:57	1.81
+++ LVM2/libdm/ioctl/libdm-iface.c	2010/10/15 01:10:28	1.82
@@ -826,6 +826,11 @@
 	if (dmt->type == DM_DEVICE_TABLE)
 		dmi->flags |= DM_STATUS_TABLE_FLAG;
 
+	if (dmt->new_uuid) {
+		log_error("Changing UUID is not supported by kernel.");
+		goto bad;
+	}
+
 	log_debug("dm %s %s %s%s%s [%u]", _cmd_data_v1[dmt->type].name,
 		  dmi->name, dmi->uuid, dmt->newname ? " " : "",
 		  dmt->newname ? dmt->newname : "",
@@ -1185,6 +1190,22 @@
 	return 1;
 }
 
+int dm_task_set_newuuid(struct dm_task *dmt, const char *newuuid)
+{
+	if (strlen(newuuid) >= DM_UUID_LEN) {
+		log_error("Uuid \"%s\" too long", newuuid);
+		return 0;
+	}
+
+	if (!(dmt->newname = dm_strdup(newuuid))) {
+		log_error("dm_task_set_newuuid: strdup(%s) failed", newuuid);
+		return 0;
+	}
+	dmt->new_uuid = 1;
+
+	return 1;
+}
+
 int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 {
 	if (strchr(newname, '/')) {
@@ -1201,6 +1222,7 @@
 		log_error("dm_task_set_newname: strdup(%s) failed", newname);
 		return 0;
 	}
+	dmt->new_uuid = 0;
 
 	return 1;
 }
@@ -1399,7 +1421,7 @@
 	}
 
 	if (count && dmt->newname) {
-		log_error("targets and newname are incompatible");
+		log_error("targets and rename are incompatible");
 		return NULL;
 	}
 
@@ -1409,12 +1431,12 @@
 	}
 
 	if (dmt->newname && (dmt->sector || dmt->message)) {
-		log_error("message and newname are incompatible");
+		log_error("message and rename are incompatible");
 		return NULL;
 	}
 
 	if (dmt->newname && dmt->geometry) {
-		log_error("geometry and newname are incompatible");
+		log_error("geometry and rename are incompatible");
 		return NULL;
 	}
 
@@ -1514,6 +1536,14 @@
 				 "by kernel.  It will use live table.");
 		dmi->flags |= DM_QUERY_INACTIVE_TABLE_FLAG;
 	}
+	if (dmt->new_uuid) {
+		if (_dm_version_minor < 19) {
+			log_error("WARNING: Setting UUID unsupported by "
+				  "kernel.  Aborting operation.");
+			goto bad;
+		}
+		dmi->flags |= DM_NEW_UUID_FLAG;
+	}
 
 	dmi->target_count = count;
 	dmi->event_nr = dmt->event_nr;
@@ -1910,9 +1940,10 @@
 		}
 	}
 
-	log_debug("dm %s %s %s%s%s %s%.0d%s%.0d%s"
+	log_debug("dm %s %s%s %s%s%s %s%.0d%s%.0d%s"
 		  "%s%c%c%s%s %.0" PRIu64 " %s [%u]",
 		  _cmd_data_v4[dmt->type].name,
+		  dmt->new_uuid ? "UUID " : "",
 		  dmi->name, dmi->uuid, dmt->newname ? " " : "",
 		  dmt->newname ? dmt->newname : "",
 		  dmt->major > 0 ? "(" : "",
@@ -2044,7 +2075,7 @@
 
 	case DM_DEVICE_RENAME:
 		/* FIXME Kernel needs to fill in dmi->name */
-		if (dmt->dev_name && !udev_only)
+		if (!dmt->new_uuid && dmt->dev_name && !udev_only)
 			rename_dev_node(dmt->dev_name, dmt->newname,
 					check_udev);
 		break;
--- LVM2/libdm/ioctl/libdm-targets.h	2009/11/06 00:43:09	1.26
+++ LVM2/libdm/ioctl/libdm-targets.h	2010/10/15 01:10:28	1.27
@@ -62,6 +62,7 @@
 	int suppress_identical_reload;
 	uint64_t existing_table_size;
 	int cookie_set;
+	int new_uuid;
 
 	char *uuid;
 };
--- LVM2/libdm/misc/dm-ioctl.h	2010/06/01 16:08:14	1.5
+++ LVM2/libdm/misc/dm-ioctl.h	2010/10/15 01:10:28	1.6
@@ -46,7 +46,7 @@
  * Remove a device, destroy any tables.
  *
  * DM_DEV_RENAME:
- * Rename a device.
+ * Rename a device or set its uuid if none was previously supplied.
  *
  * DM_SUSPEND:
  * This performs both suspend and resume, depending which flag is
@@ -269,9 +269,9 @@
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
-#define DM_VERSION_MINOR	17
+#define DM_VERSION_MINOR	19
 #define DM_VERSION_PATCHLEVEL	0
-#define DM_VERSION_EXTRA	"-ioctl (2010-03-05)"
+#define DM_VERSION_EXTRA	"-ioctl (2010-10-14)"
 
 /* Status bits */
 #define DM_READONLY_FLAG	(1 << 0) /* In/Out */
@@ -324,4 +324,10 @@
  */
 #define DM_UEVENT_GENERATED_FLAG	(1 << 13) /* Out */
 
+/*
+ * If set, rename changes the uuid not the name.  Only permitted
+ * if no uuid was previously supplied: an existing uuid cannot be changed.
+ */
+#define DM_NEW_UUID_FLAG        (1 << 14) /* In */
+
 #endif				/* _LINUX_DM_IOCTL_H */
--- LVM2/man/dmsetup.8.in	2010/05/27 19:00:20	1.35
+++ LVM2/man/dmsetup.8.in	2010/10/15 01:10:28	1.36
@@ -33,6 +33,9 @@
 .B dmsetup rename
 .I device_name new_name
 .br
+.B dmsetup rename
+.I device_name --setuuid uuid
+.br
 .B dmsetup message
 .I device_name sector message
 .br
@@ -285,6 +288,11 @@
 .I device_name new_name
 .br
 Renames a device.
+.IP \fBrename
+.I device_name --setuuid uuid
+.br
+Sets the uuid of a device that was created without a uuid.
+After a uuid has been set it cannot be changed.
 .IP \fBresume
 .I device_name
 .br
--- LVM2/tools/dmsetup.c	2010/09/30 21:06:53	1.145
+++ LVM2/tools/dmsetup.c	2010/10/15 01:10:29	1.146
@@ -140,6 +140,7 @@
 	READAHEAD_ARG,
 	ROWS_ARG,
 	SEPARATOR_ARG,
+	SETUUID_ARG,
 	SHOWKEYS_ARG,
 	SORT_ARG,
 	TABLE_ARG,
@@ -665,7 +666,10 @@
 	if (!_set_task_device(dmt, (argc == 3) ? argv[1] : NULL, 0))
 		goto out;
 
-	if (!dm_task_set_newname(dmt, argv[argc - 1]))
+	if (_switches[SETUUID_ARG]) {
+		if  (!dm_task_set_newuuid(dmt, argv[argc - 1]))
+			goto out;
+	} else if (!dm_task_set_newname(dmt, argv[argc - 1]))
 		goto out;
 
 	if (_switches[NOOPENCOUNT_ARG] && !dm_task_no_open_count(dmt))
@@ -2699,7 +2703,7 @@
 	{"load", "<device> [<table_file>]", 0, 2, _load},
 	{"clear", "<device>", 0, 1, _clear},
 	{"reload", "<device> [<table_file>]", 0, 2, _load},
-	{"rename", "<device> <new_name>", 1, 2, _rename},
+	{"rename", "<device> [--setuuid] <new_name_or_uuid>", 1, 2, _rename},
 	{"message", "<device> <sector> <message>", 2, -1, _message},
 	{"ls", "[--target <target_type>] [--exec <command>] [--tree [-o options]]", 0, 0, _ls},
 	{"info", "[<device>]", 0, 1, _info},
@@ -3106,6 +3110,7 @@
 		{"readahead", 1, &ind, READAHEAD_ARG},
 		{"rows", 0, &ind, ROWS_ARG},
 		{"separator", 1, &ind, SEPARATOR_ARG},
+		{"setuuid", 0, &ind, SETUUID_ARG},
 		{"showkeys", 0, &ind, SHOWKEYS_ARG},
 		{"sort", 1, &ind, SORT_ARG},
 		{"table", 1, &ind, TABLE_ARG},
@@ -3278,6 +3283,8 @@
 		}
 		if ((ind == ROWS_ARG))
 			_switches[ROWS_ARG]++;
+		if ((ind == SETUUID_ARG))
+			_switches[SETUUID_ARG]++;
 		if ((ind == SHOWKEYS_ARG))
 			_switches[SHOWKEYS_ARG]++;
 		if ((ind == TABLE_ARG)) {


