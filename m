From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Feb 2011 19:33:55 -0000
Subject: LVM2 ./WHATS_NEW libdm/libdevmapper.h libdm/io ...
Message-ID: <20110204193355.28325.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-02-04 19:33:54

Modified files:
	.              : WHATS_NEW 
	libdm          : libdevmapper.h 
	libdm/ioctl    : libdm-iface.c libdm-targets.h 
	man            : dmsetup.8.in 
	tools          : dmsetup.c 

Log message:
	Add --addnodeonresume, --addnodeoncreate
	
	Add new function dm_task_set_add_node() to select between 2 types
	of node creation in device directory.
	
	DM_ADD_NODE_ON_RESUME is now default and ensures node is created on
	resume. Old original behavior is accessible with DM_ADD_NODE_ON_CREATE.
	In this case node would be created during dmsetup create --notable.
	
	For the user 2 new options for dmsetup create are added:
	[{--addnodeonresume | --addnodeoncreate }]
	
	Properly working node creation on resume is needed for proper operation
	stacking and ability to correctly check in which state the device should
	after whole udev transation.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1904&r2=1.1905
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdevmapper.h.diff?cvsroot=lvm2&r1=1.134&r2=1.135
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.90&r2=1.91
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-targets.h.diff?cvsroot=lvm2&r1=1.28&r2=1.29
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/dmsetup.8.in.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.151&r2=1.152

--- LVM2/WHATS_NEW	2011/02/04 19:18:16	1.1904
+++ LVM2/WHATS_NEW	2011/02/04 19:33:53	1.1905
@@ -1,5 +1,6 @@
 Version 2.02.83 - 
 ===================================
+  Add --addnodeonresume, --addnodeoncreate options for dmsetup create.
   Use cluster-wide message to request device name sync.
   Fix operation node stacking for consecutive dm ops.
   Increase hash table size to 1024 lv names and 64 pv uuids.
--- LVM2/libdm/libdevmapper.h	2011/02/04 16:08:11	1.134
+++ LVM2/libdm/libdevmapper.h	2011/02/04 19:33:53	1.135
@@ -185,6 +185,11 @@
 int dm_task_query_inactive_table(struct dm_task *dmt);
 int dm_task_suppress_identical_reload(struct dm_task *dmt);
 int dm_task_secure_data(struct dm_task *dmt);
+typedef enum {
+	DM_ADD_NODE_ON_RESUME, /* add /dev/mapper node with dmsetup resume */
+	DM_ADD_NODE_ON_CREATE  /* add /dev/mapper node with dmsetup create */
+} dm_add_node_t;
+int dm_task_set_add_node(struct dm_task *dmt, dm_add_node_t add_node);
 
 /*
  * Control read_ahead.
--- LVM2/libdm/ioctl/libdm-iface.c	2011/02/04 16:08:12	1.90
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/02/04 19:33:53	1.91
@@ -1181,6 +1181,19 @@
 	return 1;
 }
 
+int dm_task_set_add_node(struct dm_task *dmt, dm_add_node_t add_node)
+{
+	switch (add_node) {
+	case DM_ADD_NODE_ON_RESUME:
+	case DM_ADD_NODE_ON_CREATE:
+		dmt->add_node = add_node;
+		return 1;
+	default:
+		log_error("Unknown add node parameter");
+		return 0;
+	}
+}
+
 int dm_task_set_newuuid(struct dm_task *dmt, const char *newuuid)
 {
 	if (strlen(newuuid) >= DM_UUID_LEN) {
@@ -2075,7 +2088,8 @@
 
 	switch (dmt->type) {
 	case DM_DEVICE_CREATE:
-		if (dmt->dev_name && *dmt->dev_name && !udev_only)
+	    if ((dmt->add_node == DM_ADD_NODE_ON_CREATE) &&
+		dmt->dev_name && *dmt->dev_name && !udev_only)
 			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
 				     MINOR(dmi->dev), dmt->uid, dmt->gid,
 				     dmt->mode, check_udev);
@@ -2094,6 +2108,11 @@
 		break;
 
 	case DM_DEVICE_RESUME:
+		if ((dmt->add_node == DM_ADD_NODE_ON_RESUME) &&
+		    dmt->dev_name && *dmt->dev_name && !udev_only)
+			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
+				     MINOR(dmi->dev), dmt->uid, dmt->gid,
+				     dmt->mode, check_udev);
 		/* FIXME Kernel needs to fill in dmi->name */
 		set_dev_node_read_ahead(dmt->dev_name, dmt->read_ahead,
 					dmt->read_ahead_flags);
--- LVM2/libdm/ioctl/libdm-targets.h	2011/02/04 16:08:12	1.28
+++ LVM2/libdm/ioctl/libdm-targets.h	2011/02/04 19:33:54	1.29
@@ -60,6 +60,7 @@
 	int skip_lockfs;
 	int query_inactive_table;
 	int suppress_identical_reload;
+	dm_add_node_t add_node;
 	uint64_t existing_table_size;
 	int cookie_set;
 	int new_uuid;
--- LVM2/man/dmsetup.8.in	2010/10/15 01:10:28	1.36
+++ LVM2/man/dmsetup.8.in	2011/02/04 19:33:54	1.37
@@ -8,6 +8,7 @@
 .br
 .B dmsetup create 
 .I device_name [-u uuid] [--notable | --table <table> | table_file]
+.I [{ --addnodeonresume | --addnodeoncreate }]
 .br
 .B dmsetup remove
 .I [-f|--force] device_name
@@ -139,6 +140,12 @@
 .IP \fB--notable
 .br
 When creating a device, don't load any table.
+.IP \fB--addnodeonresume
+.br
+Ensure /dev/mapper node exists after dmsetup resume (default with udev).
+.IP \fB--addnodeoncreate
+.br
+Ensure /dev/mapper node exists after dmsetup create.
 .IP \fB--udevcookie\ \fIcookie
 .br
 Use cookie for udev synchronisation.
--- LVM2/tools/dmsetup.c	2010/12/20 14:36:12	1.151
+++ LVM2/tools/dmsetup.c	2011/02/04 19:33:54	1.152
@@ -153,6 +153,8 @@
 	VERBOSE_ARG,
 	VERSION_ARG,
 	YES_ARG,
+	ADD_NODE_ON_RESUME_ARG,
+	ADD_NODE_ON_CREATE_ARG,
 	NUM_SWITCHES
 };
 
@@ -624,6 +626,14 @@
 		udev_flags |= DM_UDEV_DISABLE_DM_RULES_FLAG |
 			      DM_UDEV_DISABLE_SUBSYSTEM_RULES_FLAG;
 
+	if (_switches[ADD_NODE_ON_RESUME_ARG] &&
+	    !dm_task_set_add_node(dmt, DM_ADD_NODE_ON_RESUME))
+		goto out;
+
+	if (_switches[ADD_NODE_ON_CREATE_ARG] &&
+	    !dm_task_set_add_node(dmt, DM_ADD_NODE_ON_CREATE))
+		goto out;
+
 	if (_udev_cookie) {
 		cookie = _udev_cookie;
 		if (_udev_only)
@@ -2693,7 +2703,7 @@
 	{"help", "[-c|-C|--columns]", 0, 0, _help},
 	{"create", "<dev_name> [-j|--major <major> -m|--minor <minor>]\n"
 	  "\t                  [-U|--uid <uid>] [-G|--gid <gid>] [-M|--mode <octal_mode>]\n"
-	  "\t                  [-u|uuid <uuid>]\n"
+	  "\t                  [-u|uuid <uuid>] [{--addnodeonresume|--addnodeoncreate}]\n"
 	  "\t                  [--notable | --table <table> | <table_file>]",
 	 1, 2, _create},
 	{"remove", "[-f|--force] <device>", 0, 1, _remove},
@@ -3124,6 +3134,8 @@
 		{"verbose", 1, &ind, VERBOSE_ARG},
 		{"version", 0, &ind, VERSION_ARG},
 		{"yes", 0, &ind, YES_ARG},
+		{"addnodeonresume", 0, &ind, ADD_NODE_ON_RESUME_ARG},
+		{"addnodeoncreate", 0, &ind, ADD_NODE_ON_CREATE_ARG},
 		{0, 0, 0, 0}
 	};
 #else
@@ -3221,6 +3233,10 @@
 		}
 		if (c == 'y' || ind == YES_ARG)
 			_switches[YES_ARG]++;
+		if (ind == ADD_NODE_ON_RESUME_ARG)
+			_switches[ADD_NODE_ON_RESUME_ARG]++;
+		if (ind == ADD_NODE_ON_CREATE_ARG)
+			_switches[ADD_NODE_ON_CREATE_ARG]++;
 		if (ind == UDEVCOOKIE_ARG) {
 			_switches[UDEVCOOKIE_ARG]++;
 			_udev_cookie = _get_cookie_value(optarg);
@@ -3318,6 +3334,11 @@
 		return 0;
 	}
 
+	if (_switches[ADD_NODE_ON_RESUME_ARG] && _switches[ADD_NODE_ON_CREATE_ARG]) {
+		fprintf(stderr, "--addnodeonresume and --addnodeoncreate are incompatible.\n");
+		return 0;
+	}
+
 	*argv += optind;
 	*argc -= optind;
 	return 1;


