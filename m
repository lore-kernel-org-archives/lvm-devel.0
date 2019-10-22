From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 22 Oct 2019 07:32:31 -0400
Subject: stable-2.02 - dm: introduce DM_GET_TARGET_VERSION
Message-ID: <201910221132.x9MBWV2C025356@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=889c88e9dab33195efc4dc0400a4b0aaa3383948
Commit:        889c88e9dab33195efc4dc0400a4b0aaa3383948
Parent:        f50af80199f723f7b1970ee33ddf959ea79fcbef
Author:        Mikulas Patocka <mpatocka@redhat.com>
AuthorDate:    Mon Sep 16 05:58:10 2019 -0400
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Oct 21 15:21:29 2019 +0200

dm: introduce DM_GET_TARGET_VERSION

Adds support for the DM_GET_TARGET_VERSION to dmsetup.
It introduces a new comman "target-version" that will accept list
of targets and print their version.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
(cherry picked from commit 667b33dd3be1068ffb92783e189cbc1b41c9ac28)

Conflicts:
	device_mapper/all.h
	device_mapper/ioctl/libdm-iface.c
	device_mapper/misc/dm-ioctl.h
---
 libdm/ioctl/libdm-iface.c |    3 +++
 libdm/libdevmapper.h      |    4 +++-
 libdm/misc/dm-ioctl.h     |    2 ++
 tools/dmsetup.c           |   28 ++++++++++++++++++++++++++++
 4 files changed, 36 insertions(+), 1 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 79ea51d..77bdd07 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -118,6 +118,9 @@ static struct cmd_data _cmd_data_v4[] = {
 #ifdef DM_DEV_ARM_POLL
 	{"armpoll",	DM_DEV_ARM_POLL,	{4, 36, 0}},
 #endif
+#ifdef DM_GET_TARGET_VERSION
+	{"target-version", DM_GET_TARGET_VERSION, {4, 41, 0}},
+#endif
 };
 /* *INDENT-ON* */
 
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index e885f52..81c67dc 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -121,7 +121,9 @@ enum {
 
 	DM_DEVICE_SET_GEOMETRY,
 
-	DM_DEVICE_ARM_POLL
+	DM_DEVICE_ARM_POLL,
+
+	DM_GET_TARGET_VERSION
 };
 
 /*
diff --git a/libdm/misc/dm-ioctl.h b/libdm/misc/dm-ioctl.h
index 79f574c..52a7a93 100644
--- a/libdm/misc/dm-ioctl.h
+++ b/libdm/misc/dm-ioctl.h
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
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 15a09c6..dfa9e34 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2588,6 +2588,33 @@ out:
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
@@ -6240,6 +6267,7 @@ static struct command _dmsetup_commands[] = {
 	{"udevcomplete", "<cookie>", 1, 1, 0, 0, _udevcomplete},
 	{"udevcomplete_all", "[<age_in_minutes>]", 0, 1, 0, 0, _udevcomplete_all},
 	{"udevcookies", "", 0, 0, 0, 0, _udevcookies},
+	{"target-version", "[<target>...]", 1, -1, 1, 0, _target_version},
 	{"targets", "", 0, 0, 0, 0, _targets},
 	{"version", "", 0, 0, 0, 0, _version},
 	{"setgeometry", "<device> <cyl> <head> <sect> <start>", 5, 5, 0, 0, _setgeometry},


