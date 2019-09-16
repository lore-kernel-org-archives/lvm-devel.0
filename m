From: Mikulas Patocka <mpatocka@redhat.com>
Date: Mon, 16 Sep 2019 05:58:10 -0400 (EDT)
Subject: [PATCH] lvm: introduce DM_GET_TARGET_VERSION
In-Reply-To: <alpine.LRH.2.02.1909160553360.11421@file01.intranet.prod.int.rdu2.redhat.com>
References: <alpine.LRH.2.02.1909160553360.11421@file01.intranet.prod.int.rdu2.redhat.com>
Message-ID: <alpine.LRH.2.02.1909160555580.11421@file01.intranet.prod.int.rdu2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This is userspace patch that adds support for the DM_GET_TARGET_VERSION to 
dmsetup. It introduces a new comman "target-version" that will accept list 
of targets and print their version.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 device_mapper/all.h               |    4 +++-
 device_mapper/ioctl/libdm-iface.c |    3 +++
 device_mapper/misc/dm-ioctl.h     |    3 +++
 libdm/dm-tools/dmsetup.c          |   28 ++++++++++++++++++++++++++++
 libdm/ioctl/libdm-iface.c         |    3 +++
 libdm/libdevmapper.h              |    4 +++-
 libdm/misc/dm-ioctl.h             |    2 ++
 7 files changed, 45 insertions(+), 2 deletions(-)

Index: lvm2/libdm/dm-tools/dmsetup.c
===================================================================
--- lvm2.orig/libdm/dm-tools/dmsetup.c	2019-09-16 10:11:12.000000000 +0200
+++ lvm2/libdm/dm-tools/dmsetup.c	2019-09-16 10:35:21.000000000 +0200
@@ -2587,6 +2587,33 @@ out:
 	return r;
 }
 
+/* Show target names and their version numbers */
+static int _target_version(CMD_ARGS)
+{
+	int r = 0;
+	struct dm_task *dmt;
+	struct dm_versions *target;
+
+	if (!(dmt = dm_task_create(DM_GET_TARGET_VERSION)))
+		return_0;
+
+	if (!dm_task_set_name(dmt, argv[0]))
+		goto_out;
+
+	if (!_task_run(dmt))
+		goto_out;
+
+	target = dm_task_get_versions(dmt);
+	printf("%-16s v%d.%d.%d\n", target->name, target->version[0],
+	       target->version[1], target->version[2]);
+
+	r = 1;
+
+out:
+	dm_task_destroy(dmt);
+	return r;
+}
+
 static int _info(CMD_ARGS)
 {
 	int r = 0;
@@ -6239,6 +6266,7 @@ static struct command _dmsetup_commands[
 	{"udevcomplete", "<cookie>", 1, 1, 0, 0, _udevcomplete},
 	{"udevcomplete_all", "[<age_in_minutes>]", 0, 1, 0, 0, _udevcomplete_all},
 	{"udevcookies", "", 0, 0, 0, 0, _udevcookies},
+	{"target-version", "[<target>...]", 1, -1, 1, 0, _target_version},
 	{"targets", "", 0, 0, 0, 0, _targets},
 	{"version", "", 0, 0, 0, 0, _version},
 	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, 0, 0, _setgeometry},
Index: lvm2/device_mapper/all.h
===================================================================
--- lvm2.orig/device_mapper/all.h	2019-09-16 09:58:45.000000000 +0200
+++ lvm2/device_mapper/all.h	2019-09-16 10:19:16.000000000 +0200
@@ -121,7 +121,9 @@ enum {
 
 	DM_DEVICE_SET_GEOMETRY,
 
-	DM_DEVICE_ARM_POLL
+	DM_DEVICE_ARM_POLL,
+
+	DM_GET_TARGET_VERSION
 };
 
 /*
Index: lvm2/libdm/libdevmapper.h
===================================================================
--- lvm2.orig/libdm/libdevmapper.h	2019-09-16 09:58:45.000000000 +0200
+++ lvm2/libdm/libdevmapper.h	2019-09-16 10:18:50.000000000 +0200
@@ -121,7 +121,9 @@ enum {
 
 	DM_DEVICE_SET_GEOMETRY,
 
-	DM_DEVICE_ARM_POLL
+	DM_DEVICE_ARM_POLL,
+
+	DM_GET_TARGET_VERSION
 };
 
 /*
Index: lvm2/device_mapper/ioctl/libdm-iface.c
===================================================================
--- lvm2.orig/device_mapper/ioctl/libdm-iface.c	2019-09-16 09:58:45.000000000 +0200
+++ lvm2/device_mapper/ioctl/libdm-iface.c	2019-09-16 10:23:48.000000000 +0200
@@ -119,6 +119,9 @@ static struct cmd_data _cmd_data_v4[] =
 #ifdef DM_DEV_ARM_POLL
 	{"armpoll",	DM_DEV_ARM_POLL,	{4, 36, 0}},
 #endif
+#ifdef DM_GET_TARGET_VERSION
+	{"target-version", DM_GET_TARGET_VERSION, {4, 41, 0}},
+#endif
 };
 /* *INDENT-ON* */
 
Index: lvm2/libdm/ioctl/libdm-iface.c
===================================================================
--- lvm2.orig/libdm/ioctl/libdm-iface.c	2019-09-16 09:58:45.000000000 +0200
+++ lvm2/libdm/ioctl/libdm-iface.c	2019-09-16 10:30:24.000000000 +0200
@@ -118,6 +118,9 @@ static struct cmd_data _cmd_data_v4[] =
 #ifdef DM_DEV_ARM_POLL
 	{"armpoll",	DM_DEV_ARM_POLL,	{4, 36, 0}},
 #endif
+#ifdef DM_GET_TARGET_VERSION
+	{"target-version", DM_GET_TARGET_VERSION, {4, 41, 0}},
+#endif
 };
 /* *INDENT-ON* */
 
Index: lvm2/device_mapper/misc/dm-ioctl.h
===================================================================
--- lvm2.orig/device_mapper/misc/dm-ioctl.h	2019-09-16 09:58:45.000000000 +0200
+++ lvm2/device_mapper/misc/dm-ioctl.h	2019-09-16 10:29:24.000000000 +0200
@@ -244,6 +244,7 @@ enum {
 	DM_TARGET_MSG_CMD,
 	DM_DEV_SET_GEOMETRY_CMD,
 	DM_DEV_ARM_POLL_CMD,
+	DM_GET_TARGET_VERSION_CMD,
 };
 
 #define DM_IOCTL 0xfd
@@ -270,6 +271,8 @@ enum {
 #define DM_TARGET_MSG	 _IOWR(DM_IOCTL, DM_TARGET_MSG_CMD, struct dm_ioctl)
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
 
+#define DM_GET_TARGET_VERSION	_IOWR(DM_IOCTL, DM_GET_TARGET_VERSION_CMD, struct dm_ioctl)
+
 #define DM_VERSION_MAJOR	4
 #define DM_VERSION_MINOR	36
 #define DM_VERSION_PATCHLEVEL	0
Index: lvm2/libdm/misc/dm-ioctl.h
===================================================================
--- lvm2.orig/libdm/misc/dm-ioctl.h	2019-09-16 09:58:45.000000000 +0200
+++ lvm2/libdm/misc/dm-ioctl.h	2019-09-16 10:30:04.000000000 +0200
@@ -244,6 +244,7 @@ enum {
 	DM_TARGET_MSG_CMD,
 	DM_DEV_SET_GEOMETRY_CMD,
 	DM_DEV_ARM_POLL_CMD,
+	DM_GET_TARGET_VERSION_CMD,
 };
 
 #define DM_IOCTL 0xfd
@@ -269,6 +270,7 @@ enum {
 
 #define DM_TARGET_MSG	 _IOWR(DM_IOCTL, DM_TARGET_MSG_CMD, struct dm_ioctl)
 #define DM_DEV_SET_GEOMETRY	_IOWR(DM_IOCTL, DM_DEV_SET_GEOMETRY_CMD, struct dm_ioctl)
+#define DM_GET_TARGET_VERSION	_IOWR(DM_IOCTL, DM_GET_TARGET_VERSION_CMD, struct dm_ioctl)
 
 #define DM_VERSION_MAJOR	4
 #define DM_VERSION_MINOR	36


