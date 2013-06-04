From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:26:22 +0000 (UTC)
Subject: dev-mornfall-activate - rephrasing: miscellaneous changes
Message-ID: <20130604192622.E7893612C2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2fbe1e6e00fc59f54ae11c19d51f2d7fc8425b16
Commit:        2fbe1e6e00fc59f54ae11c19d51f2d7fc8425b16
Parent:        2e4a66a7617de57cbf8462bdd1e555aef0b13c47
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed May 15 01:50:42 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed May 15 01:50:42 2013 +0100

rephrasing: miscellaneous changes

Miscellaneous changes to messages, man pages, comments and WHATS_NEW.
---
 WHATS_NEW                        |   24 +++++++++++++-----------
 daemons/clvmd/clvmd-singlenode.c |    1 -
 lib/activate/dev_manager.c       |    5 +++--
 lib/commands/toolcontext.c       |    2 +-
 man/lvconvert.8.in               |   11 +++++++----
 man/lvm.conf.5.in                |    2 +-
 man/vgcfgrestore.8.in            |    6 +++---
 7 files changed, 28 insertions(+), 23 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8f19310..0c7db4b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -71,8 +71,8 @@ Version 2.02.99 -
   Check for failing id_read_format() in _pv_populate_lvmcache.
   Fix memleak on error path for lvmetad's pv_found.
   Unlock vg mutex in error path when lvmetad tries to lock_vg.
-  Add check for key string duplication in config_make_nodes_v.
-  Add check for created fid in _scan_file.
+  Detect key string duplication failure in config_make_nodes_v in libdaemon.
+  Detect fid creation failure in _scan_file in format_text.
   Log output also to syslog when abort_on_internal_error is set.
   Add LV snapshot support to liblvm and python-lvm.
   Avoid a global lock in pvs when lvmetad is in use.
@@ -85,37 +85,39 @@ Version 2.02.99 -
   Add lvm.conf option global/thin_disabled_features.
   Add lvconvert support to swap thin pool metadata volume.
   Implement internal function detach_pool_metadata_lv().
-  Fix lvm2app to return all property sizes in bytes.
+  Fix lvm2app to return all property sizes in bytes (not sectors).
   Recognize DM_DISABLE_UDEV environment variable for a complete fallback.
   Do not verify udev operations if --noudevsync command option is used.
   Fix lvm2app and return lvseg discards property as string.
-  Allow forced vgcfgrestore of lvm2 metadata with thin volumes.
+  Allow vgcfgrestore of lvm2 metadata with thin volumes if --force is used.
   Recognise Storage Class Memory (IBM S/390) devices in filter.
   Recognise STEC skd devices in filter.
   Recognise Violin Memory vtms devices in filter.
-  Add lvm.conf thin pool defs thin_pool_{chunk_size|discards|zero}.
+  Add lvm.conf thin pool allocation settings thin_pool_{chunk_size|discards|zero}.
   Support discards for non-power-of-2 thin pool chunks.
   Automatically restore MISSING PVs with no MDAs.
-  When no '-i' argument is given for RAID10, default to 2 stripes.
-  Do not allow --splitmirrors on RAID10 logical volumes.
+  When no --stripes argument is given when creating a RAID10 volume, default to 2 stripes.
+  Do not allow lvconvert --splitmirrors on RAID10 logical volumes.
   Skip mlocking [vectors] on arm architecture.
   Support allocation of pool metadata with lvconvert command.
   Move common functionality for thin lvcreate and lvconvert to toollib.
-  Mirrored log is now fixed before its mirror when double-fault occurs.
+  Repair a mirrored log before the mirror itself when both fail.
   Add python-lvm unit test case
   Exit pvscan --cache immediately if cluster locking used or lvmetad not used.
   Don't use lvmetad in lvm2-monitor.service ExecStop to avoid a systemd issue.
   Remove dependency on fedora-storage-init.service in lvm2 systemd units.
   Depend on lvm2-lvmetad.socket in lvm2-monitor.service systemd unit.
   Hardcode use_lvmetad=0 if cluster locking used and issue a warning msg.
-  Avoid reading mirrors with failed devices in its mirrored log.
-  Avoid reading from mirrors that have failed devices if they block I/O.
+  Avoid LVM from trying to read a mirror that has a failed device in its mirrored log.
+  Relax ignore_suspended_devices to read from mirrors that don't have a device marked failed.
   Change lvs heading Copy% to Cpy%Sync and print RAID4/5/6 sync% there too.
   Fix clvmd support for option -d and properly use its argument.
   Support use of option --yes for lvchange --persistent.
   Fix memory leak on error path for pvcreate with invalid uuid.
+  Implement ref-counting for parents in python lib.
   Use lv_is_active() instead of lv_info() call.
-  Cleanup some log_error message and use log_warn instead.
+  Reduce some log_error messages to log_warn where we don't fail.
+  Remove python liblvm object. systemdir can only be changed using env var now.
   
 Version 2.02.98 - 15th October 2012
 ===================================
diff --git a/daemons/clvmd/clvmd-singlenode.c b/daemons/clvmd/clvmd-singlenode.c
index a79100f..756c589 100644
--- a/daemons/clvmd/clvmd-singlenode.c
+++ b/daemons/clvmd/clvmd-singlenode.c
@@ -284,7 +284,6 @@ static int _cluster_send_message(const void *buf, int msglen,
 
 static int _get_cluster_name(char *buf, int buflen)
 {
-	/* FIXME - cluster_ops API is broken - swap 1/0 */
 	return dm_strncpy(buf, "localcluster", buflen) ? 0 : 1;
 }
 
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8e3cbb7..cd50fa0 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -138,7 +138,8 @@ static int _info_run(const char *name, const char *dlid, struct dm_info *info,
  * @mirror_status_string
  * @image_health:  return for allocated copy of image health characters
  * @log_device: return for 'dev_t' of log device
- * @log_health: NULL if corelog, otherwise alloc'ed log health char
+ * @log_health: NULL if corelog, otherwise dm_malloc'ed log health char which
+ *              the caller must free
  *
  * This function takes the mirror status string, breaks it up and returns
  * its components.  For now, we only return the health characters.  This
@@ -184,7 +185,7 @@ static int _parse_mirror_status(char *mirror_status_str,
 			return 0;
 		}
 		if (sscanf(log_args[1], "%d:%d", &major, &minor) != 2) {
-			log_error("Parsing of log's major minor failed.");
+			log_error("Failed to parse log's device number from %s.", log_args[1]);
 			goto out;
 		}
 		*log_dev = MKDEV((dev_t)major, minor);
diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index 2ea877a..5c1719b 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -428,7 +428,7 @@ static int _process_config(struct cmd_context *cmd)
 
 	if (find_config_tree_int(cmd, global_locking_type_CFG) == 3 &&
 	    find_config_tree_bool(cmd, global_use_lvmetad_CFG)) {
-		log_warn("WARNING: configuration setting use_lvmetad overriden to 0 due to locking_type 3. "
+		log_warn("WARNING: configuration setting use_lvmetad overridden to 0 due to locking_type 3. "
 			 "Clustered environment not supported by lvmetad yet.");
 		lvmetad_set_active(0);
 	} else
diff --git a/man/lvconvert.8.in b/man/lvconvert.8.in
index d7300d8..d4faf27 100644
--- a/man/lvconvert.8.in
+++ b/man/lvconvert.8.in
@@ -210,12 +210,15 @@ For thin pools the value must be between 64KiB and
 1GiB and the default value starts with 64 and scales
 up to fit the pool metadata size within 128MiB,
 if the pool metadata size is not specified.
-Thin pool target version <1.4 requires the value to be a power of 2.
-The newer target version relaxes limitation to be a multiple of 64KiB.
-For target version <1.5 discard is not supported for non power of 2 values.
+The value must be a multiple of 64KiB. 
+(Early kernel support until thin target version 1.4 required the value
+to be a power of 2.  Discards weren't supported for non-power of 2 values
+until thin target version 1.5.)
+Default unit is in kilobytes.
 .TP
 .BR \-\-discards " {" \fIignore | \fInopassdown | \fIpassdown }
-Sets discards behavior for thin pool.
+Specifies whether or not discards will be processed by the thin layer in the
+kernel and passed down to the Physical Volume.
 Default is \fIpassdown\fP.
 .TP
 .BR \-Z ", " \-\-zero " {" \fIy | \fIn }
diff --git a/man/lvm.conf.5.in b/man/lvm.conf.5.in
index 5592f34..f47cc17 100644
--- a/man/lvm.conf.5.in
+++ b/man/lvm.conf.5.in
@@ -104,7 +104,7 @@ otherwise it is accepted.  As an example, to ignore /dev/cdrom you could use:
 .br
 \fBdevices { filter=["r|cdrom|"] }\fP
 .IP
-\fBglobal_filter\fP \(em Since "filter" is often overriden from command line, it
+\fBglobal_filter\fP \(em Since "filter" might get overridden from the command line, it
 is not suitable for system-wide device filtering (udev rules, lvmetad). To hide
 devices from LVM-specific udev processing and/or from lvmetad, you need to set
 global_filter. The syntax is the same as for normal "filter" above. Devices that
diff --git a/man/vgcfgrestore.8.in b/man/vgcfgrestore.8.in
index 7b8dd59..a5c8194 100644
--- a/man/vgcfgrestore.8.in
+++ b/man/vgcfgrestore.8.in
@@ -36,10 +36,10 @@ VolumeGroupName.  Often this file has been created with \fBvgcfgbackup\fP.
 .TP
 .B \-\-force
 To restore metadata with thin pool volumes, user currently
-needs to use this flag. The tool DOES NOT make any validation.
+needs to use this flag. The tool DOES NOT perform any validation.
 .br
-WARNING: Restoring lvm2 metadata that are not matching thin pool
-kernel metadata may lead to the destruction of the pool content.
+WARNING: Restoring lvm2 metadata that does not exactly match the 
+thin pool kernel metadata may lead to the destruction of the pool content.
 Use with extreme caution.
 .SH REPLACING PHYSICAL VOLUMES
 \fBvgdisplay \-\-partial \-\-verbose\fP will show you the UUIDs and sizes of


