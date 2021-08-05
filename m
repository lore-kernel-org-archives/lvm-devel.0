From: David Teigland <teigland@sourceware.org>
Date: Thu,  5 Aug 2021 18:21:23 +0000 (GMT)
Subject: main - devices file: limit warnings about devices file entries not found
Message-ID: <20210805182123.8DDEE3858415@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d3d6a0e820ff930a5a7c137e7bbeb0225e251df7
Commit:        d3d6a0e820ff930a5a7c137e7bbeb0225e251df7
Parent:        bf6dfc248a1de0250eebe8229cae40d55c247ddd
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jul 27 15:28:34 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 5 13:20:26 2021 -0500

devices file: limit warnings about devices file entries not found

All commands were printing a warning if a devices file
entry was not found.  Limit this to commands that report/display
lvm state.
---
 lib/commands/toolcontext.h |  1 +
 lib/device/device_id.c     |  3 +++
 tools/command.c            |  1 +
 tools/commands.h           | 24 ++++++++++++------------
 tools/lvmcmdline.c         |  2 ++
 tools/pvscan.c             |  2 ++
 tools/tools.h              |  2 ++
 7 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/lib/commands/toolcontext.h b/lib/commands/toolcontext.h
index 34808ce46..4dbc75cfc 100644
--- a/lib/commands/toolcontext.h
+++ b/lib/commands/toolcontext.h
@@ -193,6 +193,7 @@ struct cmd_context {
 	unsigned run_by_dmeventd:1;		/* command is being run by dmeventd */
 	unsigned sysinit:1;			/* --sysinit is used */
 	unsigned check_devs_used:1;		/* check devs used by LVs */
+	unsigned print_device_id_not_found;	/* print devices file entries not found */
 
 	/*
 	 * Devices and filtering.
diff --git a/lib/device/device_id.c b/lib/device/device_id.c
index baba48c05..6ac646a16 100644
--- a/lib/device/device_id.c
+++ b/lib/device/device_id.c
@@ -1511,6 +1511,9 @@ void device_ids_match(struct cmd_context *cmd)
 		dev_iter_destroy(iter);
 	}
 
+	if (!cmd->print_device_id_not_found)
+		return;
+
 	/*
 	 * Look for entries in devices file for which we found no device.
 	 */
diff --git a/tools/command.c b/tools/command.c
index b987e49b0..0d37de7f6 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -142,6 +142,7 @@ static inline int dumptype_arg(struct cmd_context *cmd __attribute__((unused)),
 #define ALLOW_HINTS              0x00004000
 #define ALLOW_EXPORTED           0x00008000
 #define CHECK_DEVS_USED          0x00010000
+#define DEVICE_ID_NOT_FOUND      0x00020000
 
 /* create foo_CMD enums for command def ID's in command-lines.in */
 
diff --git a/tools/commands.h b/tools/commands.h
index a38d2b4f5..4de335a95 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -31,7 +31,7 @@ xx(formats,
 
 xx(fullreport,
    "Display full report",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED | DEVICE_ID_NOT_FOUND)
 
 xx(help,
    "Display help for commands",
@@ -55,7 +55,7 @@ xx(lvcreate,
 
 xx(lvdisplay,
    "Display information about a logical volume",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | CHECK_DEVS_USED)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | CHECK_DEVS_USED | DEVICE_ID_NOT_FOUND)
 
 xx(lvextend,
    "Add space to a logical volume",
@@ -71,11 +71,11 @@ xx(lvmconfig,
 
 xx(lvmdevices,
    "Manage the devices file",
-   0)
+   DEVICE_ID_NOT_FOUND)
 
 xx(lvmdiskscan,
    "List devices that may be used as physical volumes",
-   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ALLOW_EXPORTED | CHECK_DEVS_USED)
+   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ALLOW_EXPORTED | CHECK_DEVS_USED | DEVICE_ID_NOT_FOUND)
 
 xx(lvmsadc,
    "Collect activity data",
@@ -107,11 +107,11 @@ xx(lvresize,
 
 xx(lvs,
    "Display information about logical volumes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | CHECK_DEVS_USED)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | CHECK_DEVS_USED | DEVICE_ID_NOT_FOUND)
 
 xx(lvscan,
    "List all logical volumes in all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CHECK_DEVS_USED)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CHECK_DEVS_USED | DEVICE_ID_NOT_FOUND)
 
 xx(pvchange,
    "Change attributes of physical volume(s)",
@@ -131,7 +131,7 @@ xx(pvdata,
 
 xx(pvdisplay,
    "Display various attributes of physical volume(s)",
-   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED)
+   PERMITTED_READ_ONLY | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED | DEVICE_ID_NOT_FOUND)
 
 /* ALL_VGS_IS_DEFAULT is for polldaemon to find pvmoves in-progress using process_each_vg. */
 
@@ -149,11 +149,11 @@ xx(pvresize,
 
 xx(pvs,
    "Display information about physical volumes",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | ENABLE_ALL_DEVS | ENABLE_DUPLICATE_DEVS | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED | DEVICE_ID_NOT_FOUND)
 
 xx(pvscan,
    "List all physical volumes",
-   PERMITTED_READ_ONLY | LOCKD_VG_SH | ALLOW_EXPORTED | CHECK_DEVS_USED)
+   PERMITTED_READ_ONLY | LOCKD_VG_SH | ALLOW_EXPORTED | CHECK_DEVS_USED | DEVICE_ID_NOT_FOUND)
 
 xx(segtypes,
    "List available segment types",
@@ -197,7 +197,7 @@ xx(vgcreate,
 
 xx(vgdisplay,
    "Display volume group information",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED | DEVICE_ID_NOT_FOUND)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
@@ -241,11 +241,11 @@ xx(vgrename,
 
 xx(vgs,
    "Display information about volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | CAN_USE_ONE_SCAN | ALLOW_HINTS | ALLOW_EXPORTED | CHECK_DEVS_USED | DEVICE_ID_NOT_FOUND)
 
 xx(vgscan,
    "Search for all volume groups",
-   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_EXPORTED | CHECK_DEVS_USED)
+   PERMITTED_READ_ONLY | ALL_VGS_IS_DEFAULT | LOCKD_VG_SH | ALLOW_EXPORTED | CHECK_DEVS_USED | DEVICE_ID_NOT_FOUND)
 
 xx(vgsplit,
    "Move physical volumes into a new or existing volume group",
diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index 134697aa3..4b63d48e3 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -2475,6 +2475,8 @@ static int _get_current_settings(struct cmd_context *cmd)
 
 	cmd->check_devs_used = (cmd->cname->flags & CHECK_DEVS_USED) ? 1 : 0;
 
+	cmd->print_device_id_not_found = (cmd->cname->flags & DEVICE_ID_NOT_FOUND) ? 1 : 0;
+
 	/*
 	 * enable_hints is set to 1 if any commands are using hints.
 	 * use_hints is set to 1 if this command should use the hints.
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 6787c4cfc..46d0786bc 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1620,6 +1620,8 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 
 	cmd->check_devs_used = 0;
 
+	cmd->print_device_id_not_found = 0;
+
 	event_activation = find_config_tree_bool(cmd, global_event_activation_CFG, NULL);
 
 	if (do_activate && !event_activation) {
diff --git a/tools/tools.h b/tools/tools.h
index d4d3b9866..708a78d1c 100644
--- a/tools/tools.h
+++ b/tools/tools.h
@@ -141,6 +141,8 @@ struct arg_value_group_list {
 #define ALLOW_EXPORTED           0x00008000
 /* Command checks and reports warning if devs used by LV are incorrect. */
 #define CHECK_DEVS_USED		 0x00010000
+/* Command prints devices file entries that were not found. */
+#define DEVICE_ID_NOT_FOUND      0x00020000
 
 
 void usage(const char *name);


