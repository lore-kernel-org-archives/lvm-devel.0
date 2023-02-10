From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 10 Feb 2023 16:53:16 +0000 (GMT)
Subject: main - lvm: fix typos
Message-ID: <20230210165316.9C86A3858C5F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e3534d0f68c698532101eea211ece52b7aee315c
Commit:        e3534d0f68c698532101eea211ece52b7aee315c
Parent:        a1a1439215f56335a06ae5ac6ca73b5e0d734760
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 9 17:05:01 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Feb 10 17:50:27 2023 +0100

lvm: fix typos

Patch aec5e573afe610070eb2c6bed675d2a7c0efc7e8 was fixing some
of typos only in generated file, but they need to be fixed in
the source files.
---
 daemons/lvmlockd/lvmlockd-core.c |  2 +-
 lib/cache/lvmcache.c             |  2 +-
 lib/config/config_settings.h     | 12 ++++++------
 tools/args.h                     |  2 +-
 4 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index b2e98efa3..eb4334dcd 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1279,7 +1279,7 @@ static int res_lock(struct lockspace *ls, struct resource *r, struct action *act
 	 * be invalidated.  When we need to invalidate the lvmetad
 	 * cache, but don't have a usable r_version from the lvb,
 	 * send lvmetad new_version 0 which causes it to invalidate
-	 * the VG metdata without comparing against the currently
+	 * the VG metadata without comparing against the currently
 	 * cached VG seqno.
 	 */
 
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index ec32b3be9..b8a9eac25 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -2271,7 +2271,7 @@ int lvmcache_update_vgname_and_id(struct cmd_context *cmd, struct lvmcache_info
  * vginfo/info.  PVs that don't hold VG metadata weren't attached to the vginfo
  * during label scan, and PVs with outdated metadata (claiming to be in the VG,
  * but not listed in the latest metadata) were attached to the vginfo, but
- * shouldn't be.  After vg_read() gets the full metdata in the form of a 'vg',
+ * shouldn't be.  After vg_read() gets the full metadata in the form of a 'vg',
  * this function is called to fix up the lvmcache representation of the VG
  * using the 'vg'.
  */
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 699b40bd0..9d19a554e 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -824,7 +824,7 @@ cfg(allocation_vdo_max_discard_CFG, "vdo_max_discard", allocation_CFG_SECTION, C
 	"The default and minimum is 1. The maximum is UINT_MAX / 4096.\n")
 
 cfg(allocation_vdo_pool_header_size_CFG, "vdo_pool_header_size", allocation_CFG_SECTION, CFG_PROFILABLE | CFG_PROFILABLE_METADATA | CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_VDO_POOL_HEADER_SIZE_KB, vsn(2, 3, 12), NULL, 0, NULL,
-	"Specified the emptry header size in KiB at the front and end of vdo pool device.\n")
+	"Specified the empty header size in KiB at the front and end of vdo pool device.\n")
 
 cfg(log_report_command_log_CFG, "report_command_log", log_CFG_SECTION, CFG_PROFILABLE | CFG_DEFAULT_COMMENTED | CFG_DISALLOW_INTERACTIVE, CFG_TYPE_BOOL, DEFAULT_COMMAND_LOG_REPORT, vsn(2, 2, 158), NULL, 0, NULL,
 	"Enable or disable LVM log reporting.\n"
@@ -947,7 +947,7 @@ cfg(backup_archive_CFG, "archive", backup_CFG_SECTION, CFG_DEFAULT_COMMENTED, CF
 	"Think very hard before turning this off.\n")
 
 cfg_runtime(backup_archive_dir_CFG, "archive_dir", backup_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_STRING, vsn(1, 0, 0), 0, NULL,
-	"Location of the metdata archive files.\n"
+	"Location of the metadata archive files.\n"
 	"Remember to back up this directory regularly!\n")
 
 cfg(backup_retain_min_CFG, "retain_min", backup_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_ARCHIVE_NUMBER, vsn(1, 0, 0), NULL, 0, NULL,
@@ -1382,11 +1382,11 @@ cfg(activation_use_linear_target_CFG, "use_linear_target", activation_CFG_SECTIO
 
 cfg(activation_reserved_stack_CFG, "reserved_stack", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_RESERVED_STACK, vsn(1, 0, 0), NULL, 0, NULL,
 	"Stack size in KiB to reserve for use while devices are suspended.\n"
-	"Insufficent reserve risks I/O deadlock during device suspension.\n")
+	"Insufficient reserve risks I/O deadlock during device suspension.\n")
 
 cfg(activation_reserved_memory_CFG, "reserved_memory", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_RESERVED_MEMORY, vsn(1, 0, 0), NULL, 0, NULL,
 	"Memory size in KiB to reserve for use while devices are suspended.\n"
-	"Insufficent reserve risks I/O deadlock during device suspension.\n")
+	"Insufficient reserve risks I/O deadlock during device suspension.\n")
 
 cfg(activation_process_priority_CFG, "process_priority", activation_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, DEFAULT_PROCESS_PRIORITY, vsn(1, 0, 0), NULL, 0, NULL,
 	"Nice value used while devices are suspended.\n"
@@ -1512,7 +1512,7 @@ cfg(activation_raid_fault_policy_CFG, "raid_fault_policy", activation_CFG_SECTIO
 	"This includes LVs that have the following segment types:\n"
 	"raid1, raid4, raid5*, and raid6*.\n"
 	"If a device in the LV fails, the policy determines the steps\n"
-	"performed by dmeventd automatically, and the steps perfomed by the\n"
+	"performed by dmeventd automatically, and the steps performed by the\n"
 	"manual command lvconvert --repair --use-policies.\n"
 	"Automatic handling requires dmeventd to be monitoring the LV.\n"
 	"#\n"
@@ -1534,7 +1534,7 @@ cfg_runtime(activation_mirror_image_fault_policy_CFG, "mirror_image_fault_policy
 	"(copies) and a mirror log. A disk log ensures that a mirror LV does\n"
 	"not need to be re-synced (all copies made the same) every time a\n"
 	"machine reboots or crashes. If a device in the LV fails, this policy\n"
-	"determines the steps perfomed by dmeventd automatically, and the steps\n"
+	"determines the steps performed by dmeventd automatically, and the steps\n"
 	"performed by the manual command lvconvert --repair --use-policies.\n"
 	"Automatic handling requires dmeventd to be monitoring the LV.\n"
 	"#\n"
diff --git a/tools/args.h b/tools/args.h
index a7a0dd3d9..5819bb84e 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -507,7 +507,7 @@ arg(mknodes_ARG, '\0', "mknodes", 0, 0, 0,
 arg(monitor_ARG, '\0', "monitor", bool_VAL, 0, 0,
     "Start (yes) or stop (no) monitoring an LV with dmeventd.\n"
     "dmeventd monitors kernel events for an LV, and performs\n"
-    "automated maintenance for the LV in reponse to specific events.\n"
+    "automated maintenance for the LV in response to specific events.\n"
     "See \\fBdmeventd\\fP(8) for more information.\n")
 
 arg(nameprefixes_ARG, '\0', "nameprefixes", 0, 0, 0,

