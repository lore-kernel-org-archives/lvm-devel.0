From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:56 +0000 (GMT)
Subject: dev-next - all: fix typos
Message-ID: <20210331214956.E701F3857C6F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=01d5e4d1ca27b5dbf4dce19be3da2ab83cefd40d
Commit:        01d5e4d1ca27b5dbf4dce19be3da2ab83cefd40d
Parent:        d5b0c72f40abc8caa199a0f484a9a0223f4a03dc
Author:        Samanta Navarro <ferivoz@riseup.net>
AuthorDate:    Sat Oct 3 11:52:37 2020 +0000
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 30 13:08:14 2021 +0200

all: fix typos

---
 WHATS_NEW                                     |  2 +-
 WHATS_NEW_DM                                  |  2 +-
 conf/example.conf.in                          | 14 +++++++-------
 daemons/dmeventd/plugins/raid/dmeventd_raid.c |  2 +-
 doc/kernel/integrity.txt                      |  2 +-
 lib/config/config_settings.h                  | 14 +++++++-------
 lib/locking/lvmlockd.c                        |  2 +-
 lib/metadata/raid_manip.c                     |  2 +-
 man/dmsetup.8_main                            |  2 +-
 man/dmstats.8_main                            |  4 ++--
 man/lvchange.8_pregen                         |  2 +-
 man/lvconvert.8_pregen                        |  2 +-
 man/lvcreate.8_pregen                         |  2 +-
 man/lvextend.8_pregen                         |  2 +-
 man/lvm.8_main                                |  4 ++--
 man/lvmraid.7_main                            | 10 +++++-----
 man/lvmreport.7_main                          | 10 +++++-----
 man/lvmsystemid.7_main                        |  2 +-
 man/lvresize.8_pregen                         |  2 +-
 man/pvcreate.8_des                            |  6 +++---
 man/pvcreate.8_pregen                         |  6 +++---
 man/pvmove.8_pregen                           |  2 +-
 man/vgchange.8_pregen                         |  2 +-
 man/vgcreate.8_des                            |  2 +-
 man/vgcreate.8_pregen                         |  4 ++--
 man/vgsplit.8_pregen                          |  2 +-
 test/shell/snapshot-merge-thin.sh             |  2 +-
 tools/args.h                                  |  6 +++---
 tools/command.c                               |  4 ++--
 tools/toollib.c                               |  2 +-
 30 files changed, 60 insertions(+), 60 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c08864bae..83c94701a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1769,7 +1769,7 @@ Version 2.02.105 - 20th January 2014
   Allow lvmetad to reuse stale socket.
   Only unlink lvmetad socket on error if created by the same process.
   Append missing newline to lvmetad missing socket path error message.
-  Check for non-zero aligment in _text_pv_add_metadata_area() to not div by 0.
+  Check for non-zero alignment in _text_pv_add_metadata_area() to not div by 0.
   Add allocation/use_blkid_wiping to lvm.conf to enable blkid wiping.
   Enable blkid_wiping by default if the blkid library is present.
   Add configure --disable-blkid_wiping to disable libblkid signature detection.
diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index ba0129a55..400e458b4 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -555,7 +555,7 @@ Version 1.02.86 - 23rd June 2014
   Add DM_REPORT_FIELD_TYPE_STRING_LIST: separate string and string list fields.
   Add dm_str_list to libdevmapper for string list type definition and its reuse.
   Add dmsetup -S/--select to define selection criteria for dmsetup reports.
-  Add dm_report_init_with_selection to intialize report with selection criteria.
+  Add dm_report_init_with_selection to initialize report with selection criteria.
   Add DM_REPORT_FIELD_TYPE_SIZE: separate number and size reporting fields.
   Use RemoveOnStop for dm-event.socket systemd unit.
   Document env var 'DM_DEFAULT_NAME_MANGLING_MODE' in dmsetup man page.
diff --git a/conf/example.conf.in b/conf/example.conf.in
index 215a30f86..5275e76c5 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -270,16 +270,16 @@ devices {
 	# Configuration option devices/md_chunk_alignment.
 	# Align the start of a PV data area with md device's stripe-width.
 	# This applies if a PV is placed directly on an md device.
-	# default_data_alignment will be overriden if it is not aligned
+	# default_data_alignment will be overridden if it is not aligned
 	# with the value detected for this setting.
-	# This setting is overriden by data_alignment_detection,
+	# This setting is overridden by data_alignment_detection,
 	# data_alignment, and the --dataalignment option.
 	md_chunk_alignment = 1
 
 	# Configuration option devices/default_data_alignment.
 	# Align the start of a PV data area with this number of MiB.
 	# Set to 1 for 1MiB, 2 for 2MiB, etc. Set to 0 to disable.
-	# This setting is overriden by data_alignment and the --dataalignment
+	# This setting is overridden by data_alignment and the --dataalignment
 	# option.
 	# This configuration option has an automatic default value.
 	# default_data_alignment = 1
@@ -293,9 +293,9 @@ devices {
 	# preferred unit of receiving I/O, e.g. MD stripe width.
 	# minimum_io_size is used if optimal_io_size is undefined (0).
 	# If md_chunk_alignment is enabled, that detects the optimal_io_size.
-	# default_data_alignment and md_chunk_alignment will be overriden
+	# default_data_alignment and md_chunk_alignment will be overridden
 	# if they are not aligned with the value detected for this setting.
-	# This setting is overriden by data_alignment and the --dataalignment
+	# This setting is overridden by data_alignment and the --dataalignment
 	# option.
 	data_alignment_detection = 1
 
@@ -304,7 +304,7 @@ devices {
 	# When non-zero, this setting overrides default_data_alignment.
 	# Set to 0 to disable, in which case default_data_alignment
 	# is used to align the first PE in units of MiB.
-	# This setting is overriden by the --dataalignment option.
+	# This setting is overridden by the --dataalignment option.
 	data_alignment = 0
 
 	# Configuration option devices/data_alignment_offset_detection.
@@ -315,7 +315,7 @@ devices {
 	# partitioning will have an alignment_offset of 3584 bytes (sector 7
 	# is the lowest aligned logical block, the 4KiB sectors start at
 	# LBA -1, and consequently sector 63 is aligned on a 4KiB boundary).
-	# This setting is overriden by the --dataalignmentoffset option.
+	# This setting is overridden by the --dataalignmentoffset option.
 	data_alignment_offset_detection = 1
 
 	# Configuration option devices/ignore_suspended_devices.
diff --git a/daemons/dmeventd/plugins/raid/dmeventd_raid.c b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
index 525b72150..5be605a35 100644
--- a/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ b/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -77,7 +77,7 @@ static int _process_raid_event(struct dso_state *state, char *params, const char
 
 	if (dead) {
 		/*
-		 * Use the first event to run a repair ignoring any additonal ones.
+		 * Use the first event to run a repair ignoring any additional ones.
 		 *
 		 * We presume lvconvert to do pre-repair
 		 * checks to avoid bloat in this plugin.
diff --git a/doc/kernel/integrity.txt b/doc/kernel/integrity.txt
index f33e3ade7..03a3b956a 100644
--- a/doc/kernel/integrity.txt
+++ b/doc/kernel/integrity.txt
@@ -94,7 +94,7 @@ journal_watermark:number
 
 commit_time:number
 	Commit time in milliseconds. When this time passes, the journal is
-	written. The journal is also written immediatelly if the FLUSH
+	written. The journal is also written immediately if the FLUSH
 	request is received.
 
 internal_hash:algorithm(:key)	(the key is optional)
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 3000a4be1..a19402d9d 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -427,15 +427,15 @@ cfg(devices_fw_raid_component_detection_CFG, "fw_raid_component_detection", devi
 cfg(devices_md_chunk_alignment_CFG, "md_chunk_alignment", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_MD_CHUNK_ALIGNMENT, vsn(2, 2, 48), NULL, 0, NULL,
 	"Align the start of a PV data area with md device's stripe-width.\n"
 	"This applies if a PV is placed directly on an md device.\n"
-	"default_data_alignment will be overriden if it is not aligned\n"
+	"default_data_alignment will be overridden if it is not aligned\n"
 	"with the value detected for this setting.\n"
-	"This setting is overriden by data_alignment_detection,\n"
+	"This setting is overridden by data_alignment_detection,\n"
 	"data_alignment, and the --dataalignment option.\n")
 
 cfg(devices_default_data_alignment_CFG, "default_data_alignment", devices_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_INT, FIRST_PE_AT_ONE_MB_IN_MB, vsn(2, 2, 75), NULL, 0, NULL,
 	"Align the start of a PV data area with this number of MiB.\n"
 	"Set to 1 for 1MiB, 2 for 2MiB, etc. Set to 0 to disable.\n"
-	"This setting is overriden by data_alignment and the --dataalignment\n"
+	"This setting is overridden by data_alignment and the --dataalignment\n"
 	"option.\n")
 
 cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_DETECTION, vsn(2, 2, 51), NULL, 0, NULL,
@@ -447,9 +447,9 @@ cfg(devices_data_alignment_detection_CFG, "data_alignment_detection", devices_CF
 	"preferred unit of receiving I/O, e.g. MD stripe width.\n"
 	"minimum_io_size is used if optimal_io_size is undefined (0).\n"
 	"If md_chunk_alignment is enabled, that detects the optimal_io_size.\n"
-	"default_data_alignment and md_chunk_alignment will be overriden\n"
+	"default_data_alignment and md_chunk_alignment will be overridden\n"
 	"if they are not aligned with the value detected for this setting.\n"
-	"This setting is overriden by data_alignment and the --dataalignment\n"
+	"This setting is overridden by data_alignment and the --dataalignment\n"
 	"option.\n")
 
 cfg(devices_data_alignment_CFG, "data_alignment", devices_CFG_SECTION, 0, CFG_TYPE_INT, 0, vsn(2, 2, 45), NULL, 0, NULL,
@@ -457,7 +457,7 @@ cfg(devices_data_alignment_CFG, "data_alignment", devices_CFG_SECTION, 0, CFG_TY
 	"When non-zero, this setting overrides default_data_alignment.\n"
 	"Set to 0 to disable, in which case default_data_alignment\n"
 	"is used to align the first PE in units of MiB.\n"
-	"This setting is overriden by the --dataalignment option.\n")
+	"This setting is overridden by the --dataalignment option.\n")
 
 cfg(devices_data_alignment_offset_detection_CFG, "data_alignment_offset_detection", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_DATA_ALIGNMENT_OFFSET_DETECTION, vsn(2, 2, 50), NULL, 0, NULL,
 	"Shift the start of an aligned PV data area based on sysfs information.\n"
@@ -467,7 +467,7 @@ cfg(devices_data_alignment_offset_detection_CFG, "data_alignment_offset_detectio
 	"partitioning will have an alignment_offset of 3584 bytes (sector 7\n"
 	"is the lowest aligned logical block, the 4KiB sectors start at\n"
 	"LBA -1, and consequently sector 63 is aligned on a 4KiB boundary).\n"
-	"This setting is overriden by the --dataalignmentoffset option.\n")
+	"This setting is overridden by the --dataalignmentoffset option.\n")
 
 cfg(devices_ignore_suspended_devices_CFG, "ignore_suspended_devices", devices_CFG_SECTION, 0, CFG_TYPE_BOOL, DEFAULT_IGNORE_SUSPENDED_DEVICES, vsn(1, 2, 19), NULL, 0, NULL,
 	"Ignore DM devices that have I/O suspended while scanning devices.\n"
diff --git a/lib/locking/lvmlockd.c b/lib/locking/lvmlockd.c
index 3b9abd6bf..9a1b4f476 100644
--- a/lib/locking/lvmlockd.c
+++ b/lib/locking/lvmlockd.c
@@ -1289,7 +1289,7 @@ int lockd_start_wait(struct cmd_context *cmd)
  * can provide in the lock-gl call.
  *
  * lockd_gl() and lockd_gl_create() differ in the specific cases where
- * ENOLS (no lockspace found) is overriden.  In the vgcreate case, the
+ * ENOLS (no lockspace found) is overridden.  In the vgcreate case, the
  * override cases are related to sanlock bootstrap, and the lock_type of
  * the vg being created is needed.
  *
diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 05b7caf9c..74adf0231 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -5463,7 +5463,7 @@ static int _takeover_upconvert_wrapper(TAKEOVER_FN_ARGS)
 	extents_copied = seg->extents_copied;
 	seg_len = seg->len;
 
-	/* In case of raid4/5, adjust to allow for allocation of additonal image pairs */
+	/* In case of raid4/5, adjust to allow for allocation of additional image pairs */
 	if (seg_is_raid4(seg) || seg_is_any_raid5(seg)) {
 		if (!(seg->segtype = get_segtype_from_flag(lv->vg->cmd, SEG_RAID0_META)))
 			return_0;
diff --git a/man/dmsetup.8_main b/man/dmsetup.8_main
index 8317e23a2..2e15e699c 100644
--- a/man/dmsetup.8_main
+++ b/man/dmsetup.8_main
@@ -510,7 +510,7 @@ Suppress the headings line when using columnar output.
 .
 .HP
 .BR --noflush
-Do not flush outstading I/O when suspending a device, or do not
+Do not flush outstanding I/O when suspending a device, or do not
 commit thin-pool metadata when obtaining thin-pool status.
 .
 .HP
diff --git a/man/dmstats.8_main b/man/dmstats.8_main
index da9d93490..db9f31904 100644
--- a/man/dmstats.8_main
+++ b/man/dmstats.8_main
@@ -553,7 +553,7 @@ Can also specify custom units e.g. \fB--units\ 3M\fP.
 .IR user_data
 .br
 Specify user data (a word) to be stored with a new region. The value
-is added to any internal auxilliary data (for example, group
+is added to any internal auxiliary data (for example, group
 information), and stored with the region in the aux_data field provided
 by the kernel. Whitespace is not permitted.
 .
@@ -1022,7 +1022,7 @@ Group identifier. This is a non-negative integer returned by the dmstats
 .TP
 .B interval_ns
 The estimated interval over which the current counter values have
-accumulated. The value is reported as an interger expressed in units
+accumulated. The value is reported as an integer expressed in units
 of nanoseconds.
 .TP
 .B interval
diff --git a/man/lvchange.8_pregen b/man/lvchange.8_pregen
index 572f84aa8..fa7bdada0 100644
--- a/man/lvchange.8_pregen
+++ b/man/lvchange.8_pregen
@@ -678,7 +678,7 @@ multiple tags at once. See \fBlvm\fP(8) for information about tags.
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
-which can be changed with vgchange/lvchange, or overriden on the
+which can be changed with vgchange/lvchange, or overridden on the
 command line.
 \fBnormal\fP applies common sense rules such as not placing parallel stripes
 on the same PV.
diff --git a/man/lvconvert.8_pregen b/man/lvconvert.8_pregen
index 5be4321c6..f6b364611 100644
--- a/man/lvconvert.8_pregen
+++ b/man/lvconvert.8_pregen
@@ -1192,7 +1192,7 @@ Common options for lvm:
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
-which can be changed with vgchange/lvchange, or overriden on the
+which can be changed with vgchange/lvchange, or overridden on the
 command line.
 \fBnormal\fP applies common sense rules such as not placing parallel stripes
 on the same PV.
diff --git a/man/lvcreate.8_pregen b/man/lvcreate.8_pregen
index 79441c128..c19b7da7b 100644
--- a/man/lvcreate.8_pregen
+++ b/man/lvcreate.8_pregen
@@ -1269,7 +1269,7 @@ multiple tags at once. See \fBlvm\fP(8) for information about tags.
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
-which can be changed with vgchange/lvchange, or overriden on the
+which can be changed with vgchange/lvchange, or overridden on the
 command line.
 \fBnormal\fP applies common sense rules such as not placing parallel stripes
 on the same PV.
diff --git a/man/lvextend.8_pregen b/man/lvextend.8_pregen
index 5e0a89ffd..cf7925ee0 100644
--- a/man/lvextend.8_pregen
+++ b/man/lvextend.8_pregen
@@ -362,7 +362,7 @@ Common options for lvm:
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
-which can be changed with vgchange/lvchange, or overriden on the
+which can be changed with vgchange/lvchange, or overridden on the
 command line.
 \fBnormal\fP applies common sense rules such as not placing parallel stripes
 on the same PV.
diff --git a/man/lvm.8_main b/man/lvm.8_main
index ba151e367..1e03b8cb9 100644
--- a/man/lvm.8_main
+++ b/man/lvm.8_main
@@ -427,12 +427,12 @@ File descriptor to use for report output from LVM commands.
 .TP
 .B LVM_COMMAND_PROFILE
 Name of default command profile to use for LVM commands. This profile
-is overriden by direct use of \fB--commandprofile\fP command line option.
+is overridden by direct use of \fB--commandprofile\fP command line option.
 .TP
 .B LVM_RUN_BY_DMEVENTD
 This variable is normally set by dmeventd plugin to inform lvm2 command
 it is running from dmeventd plugin so lvm2 takes some extra action
-to avoid comunication and deadlocks with dmeventd.
+to avoid communication and deadlocks with dmeventd.
 .TP
 .B LVM_SYSTEM_DIR
 Directory containing \fBlvm.conf\fP(5) and other LVM system files.
diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index aedd16a27..2335f5dbe 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -180,7 +180,7 @@ parity 0 with data restart.)  See \fBRAID5 variants\fP below.
 
 raid6 is a form of striping like raid5, but uses two extra devices for
 parity blocks.  LV data and parity blocks are stored on each device, typically
-in a rotating pattern for perfomramce reasons.  The
+in a rotating pattern for performance reasons.  The
 LV data remains available if up to two devices fail.  The parity is used
 to recalculate data that is lost from one or two devices.  The minimum
 number of devices required is 5.
@@ -376,7 +376,7 @@ The \fBrepair\fP mode can make the RAID LV data consistent, but it does
 not know which data is correct.  The result may be consistent but
 incorrect data.  When two different blocks of data must be made
 consistent, it chooses the block from the device that would be used during
-RAID intialization.  However, if the PV holding corrupt data is known,
+RAID initialization.  However, if the PV holding corrupt data is known,
 lvchange --rebuild can be used in place of scrubbing to reconstruct the
 data on the bad device.
 
@@ -475,7 +475,7 @@ holds parity.  Each rmeta SubLV holds RAID metadata.
 
 .B raid5
 .br
-At least three rimage SubLVs each typcially hold a portion of LV data and parity
+At least three rimage SubLVs each typically hold a portion of LV data and parity
 (see section on raid5)
 Each rmeta SubLV holds RAID metadata.
 
@@ -1347,7 +1347,7 @@ The 'R' in the same column of the attribute field shows the freed image Sub LVs
                            lv_rimage_6:0-33   8192
 .fi
 
-Now that the reshape is finished the 'R' atribute on the RaidLV shows images can be removed.
+Now that the reshape is finished the 'R' attribute on the RaidLV shows images can be removed.
 
 .nf
 # lvs -o lv_name,attr,segtype,seg_pe_ranges,dataoffset vg
@@ -1584,7 +1584,7 @@ conversion.
 
 Now we'll change the number of data stripes from 1 to 5 and request 128K stripe size
 in one command.  This will grow the size of the LV by a factor of 5 (we add 4 data stripes
-to the one given).  That additonal space can be used by e.g. growing any contained filesystem
+to the one given).  That additional space can be used by e.g. growing any contained filesystem
 or the LV can be reduced in size after the reshaping conversion has finished.
 
 .nf
diff --git a/man/lvmreport.7_main b/man/lvmreport.7_main
index 7167df0ea..aca1b4940 100644
--- a/man/lvmreport.7_main
+++ b/man/lvmreport.7_main
@@ -129,7 +129,7 @@ Definition of the set set of fields to use
 .br
 Field set to use. See \fBmain report specifics\fP and
 \fBlog report specifics\fP for information about field sets configured with
-global configuratin settings that this option overrides.
+global configuration settings that this option overrides.
 .IP - 3
 --options|-o+ FieldSet
 .br
@@ -240,7 +240,7 @@ this option suppresses the \fBmain report\fP output and it causes the
 .IP - 3
 --unbuffered
 .br
-Overrides report/bufffered configuration setting.
+Overrides report/buffered configuration setting.
 .RE
 
 .RE
@@ -1337,7 +1337,7 @@ field which is of type "size" - it's =, !=, >=, >, <= and <. You can find
 applicable comparison operators for other fields and other field types the
 same way.
 
-To demostrate selection functionality in LVM, we will create more LVs in
+To demonstrate selection functionality in LVM, we will create more LVs in
 addition to lvol0 and lvol1 we used in our previous examples.
 
 .nf
@@ -1686,9 +1686,9 @@ subreport here.
 Below is an extended example with \fBlvm fullreport\fP to illustrate
 combination of various options. The report output is in JSON format.
 Also, we configure "vg", "pvseg", "seg" and "log" subreport to contain
-only specified fields. For the "pvseg" subreport, we're intested only
+only specified fields. For the "pvseg" subreport, we're interested only
 in PV names having "sda" in their name. For the "log" subreport we're
-intested only in log lines related to either "lvol0" object or object
+interested only in log lines related to either "lvol0" object or object
 having "sda" in its name. Also, for the log subreport we define ordering
 to be based on "log_object_type" field.
 
diff --git a/man/lvmsystemid.7_main b/man/lvmsystemid.7_main
index 688d16b77..7d6e96ed6 100644
--- a/man/lvmsystemid.7_main
+++ b/man/lvmsystemid.7_main
@@ -122,7 +122,7 @@ accessible to any host.
 
 .B Owned:
 A local VG that has a system ID set, as viewed from the host with a
-matching system ID (the owner).  This VG type is acessible to the host.
+matching system ID (the owner).  This VG type is accessible to the host.
 
 .B Foreign:
 A local VG that has a system ID set, as viewed from any host with an
diff --git a/man/lvresize.8_pregen b/man/lvresize.8_pregen
index bc0b440db..8c115198a 100644
--- a/man/lvresize.8_pregen
+++ b/man/lvresize.8_pregen
@@ -310,7 +310,7 @@ Common options for lvm:
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
-which can be changed with vgchange/lvchange, or overriden on the
+which can be changed with vgchange/lvchange, or overridden on the
 command line.
 \fBnormal\fP applies common sense rules such as not placing parallel stripes
 on the same PV.
diff --git a/man/pvcreate.8_des b/man/pvcreate.8_des
index 60205c785..22fb26bf3 100644
--- a/man/pvcreate.8_des
+++ b/man/pvcreate.8_des
@@ -54,7 +54,7 @@ default_data_alignment 1 (MiB), setting --metadatasize 2048k results in
 pe_start of 3 MiB and mda_size of 3068 KiB.  Alternatively, --metadatasize
 2044k results in pe_start at 2 MiB and mda_size of 2044 KiB.
 
-The alignment of pe_start described above may be automatically overriden
+The alignment of pe_start described above may be automatically overridden
 based on md device properties or device i/o properties reported in sysfs.
 These automatic adjustments can be enabled/disabled using lvm.conf
 settings md_chunk_alignment and data_alignment_offset_detection.
@@ -72,7 +72,7 @@ provides at least 2048 KiB of metadata space.
 Always check the resulting alignment and metadata size when using
 these options.
 
-To shift an aligned pe_start value, use the --dataaligmentoffset option.
+To shift an aligned pe_start value, use the --dataalignmentoffset option.
 The pe_start alignment is calculated as described above, and then the
-value specified with --dataaligmentoffset is added to produce the final
+value specified with --dataalignmentoffset is added to produce the final
 pe_start value.
diff --git a/man/pvcreate.8_pregen b/man/pvcreate.8_pregen
index b43dbdd16..0df67bd5d 100644
--- a/man/pvcreate.8_pregen
+++ b/man/pvcreate.8_pregen
@@ -64,7 +64,7 @@ default_data_alignment 1 (MiB), setting --metadatasize 2048k results in
 pe_start of 3 MiB and mda_size of 3068 KiB.  Alternatively, --metadatasize
 2044k results in pe_start at 2 MiB and mda_size of 2044 KiB.
 
-The alignment of pe_start described above may be automatically overriden
+The alignment of pe_start described above may be automatically overridden
 based on md device properties or device i/o properties reported in sysfs.
 These automatic adjustments can be enabled/disabled using lvm.conf
 settings md_chunk_alignment and data_alignment_offset_detection.
@@ -82,9 +82,9 @@ provides at least 2048 KiB of metadata space.
 Always check the resulting alignment and metadata size when using
 these options.
 
-To shift an aligned pe_start value, use the --dataaligmentoffset option.
+To shift an aligned pe_start value, use the --dataalignmentoffset option.
 The pe_start alignment is calculated as described above, and then the
-value specified with --dataaligmentoffset is added to produce the final
+value specified with --dataalignmentoffset is added to produce the final
 pe_start value.
 .SH USAGE
 \fBpvcreate\fP \fIPV\fP ...
diff --git a/man/pvmove.8_pregen b/man/pvmove.8_pregen
index 0fc745009..a370e75ba 100644
--- a/man/pvmove.8_pregen
+++ b/man/pvmove.8_pregen
@@ -172,7 +172,7 @@ destination PV, while unmoved segments will remain on the source PV.
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
-which can be changed with vgchange/lvchange, or overriden on the
+which can be changed with vgchange/lvchange, or overridden on the
 command line.
 \fBnormal\fP applies common sense rules such as not placing parallel stripes
 on the same PV.
diff --git a/man/vgchange.8_pregen b/man/vgchange.8_pregen
index cb3c3500a..04cc23b8b 100644
--- a/man/vgchange.8_pregen
+++ b/man/vgchange.8_pregen
@@ -697,7 +697,7 @@ multiple tags at once. See \fBlvm\fP(8) for information about tags.
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
-which can be changed with vgchange/lvchange, or overriden on the
+which can be changed with vgchange/lvchange, or overridden on the
 command line.
 \fBnormal\fP applies common sense rules such as not placing parallel stripes
 on the same PV.
diff --git a/man/vgcreate.8_des b/man/vgcreate.8_des
index bc636609f..e2861c3a0 100644
--- a/man/vgcreate.8_des
+++ b/man/vgcreate.8_des
@@ -1,5 +1,5 @@
 vgcreate creates a new VG on block devices. If the devices were not
-previously intialized as PVs with \fBpvcreate\fP(8), vgcreate will
+previously initialized as PVs with \fBpvcreate\fP(8), vgcreate will
 inititialize them, making them PVs. The pvcreate options for initializing
 devices are also available with vgcreate.
 
diff --git a/man/vgcreate.8_pregen b/man/vgcreate.8_pregen
index 91fa6a67e..0b7802ed7 100644
--- a/man/vgcreate.8_pregen
+++ b/man/vgcreate.8_pregen
@@ -9,7 +9,7 @@ vgcreate - Create a volume group
 .br
 .SH DESCRIPTION
 vgcreate creates a new VG on block devices. If the devices were not
-previously intialized as PVs with \fBpvcreate\fP(8), vgcreate will
+previously initialized as PVs with \fBpvcreate\fP(8), vgcreate will
 inititialize them, making them PVs. The pvcreate options for initializing
 devices are also available with vgcreate.
 
@@ -191,7 +191,7 @@ multiple tags at once. See \fBlvm\fP(8) for information about tags.
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
-which can be changed with vgchange/lvchange, or overriden on the
+which can be changed with vgchange/lvchange, or overridden on the
 command line.
 \fBnormal\fP applies common sense rules such as not placing parallel stripes
 on the same PV.
diff --git a/man/vgsplit.8_pregen b/man/vgsplit.8_pregen
index fe680982d..9aa79e890 100644
--- a/man/vgsplit.8_pregen
+++ b/man/vgsplit.8_pregen
@@ -145,7 +145,7 @@ Common options for lvm:
 .br
 Determines the allocation policy when a command needs to allocate
 Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy
-which can be changed with vgchange/lvchange, or overriden on the
+which can be changed with vgchange/lvchange, or overridden on the
 command line.
 \fBnormal\fP applies common sense rules such as not placing parallel stripes
 on the same PV.
diff --git a/test/shell/snapshot-merge-thin.sh b/test/shell/snapshot-merge-thin.sh
index 4e4577ca9..a74567b85 100644
--- a/test/shell/snapshot-merge-thin.sh
+++ b/test/shell/snapshot-merge-thin.sh
@@ -54,7 +54,7 @@ aux delay_dev "$dev1" 0 400 "$(get first_extent_sector "$dev1"):"
 # Initiate background merge
 lvconvert -b --merge $vg/$lv2
 
-# Query status of snapshot immediatelly after start
+# Query status of snapshot immediately after start
 # - may hit race of checking already in-progress merge
 #lvs -a -o+lv_merging,lv_merge_failed $vg
 check lv_field $vg/$lv1 lv_merging "merging"
diff --git a/tools/args.h b/tools/args.h
index ca8f9ec51..c1d32be32 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -59,7 +59,7 @@ arg(aligned_ARG, '\0', "aligned", 0, 0, 0,
 arg(alloc_ARG, '\0', "alloc", alloc_VAL, 0, 0,
     "Determines the allocation policy when a command needs to allocate\n"
     "Physical Extents (PEs) from the VG. Each VG and LV has an allocation policy\n"
-    "which can be changed with vgchange/lvchange, or overriden on the\n"
+    "which can be changed with vgchange/lvchange, or overridden on the\n"
     "command line.\n"
     "\\fBnormal\\fP applies common sense rules such as not placing parallel stripes\n"
     "on the same PV.\n"
@@ -1138,7 +1138,7 @@ arg(maxlogicalvolumes_ARG, 'l', "maxlogicalvolumes", uint32_VAL, 0, 0,
     "Sets the maximum number of LVs allowed in a VG.\n")
 
 /*
- * The extents_VAL is overriden in configure_command_option_values()
+ * The extents_VAL is overridden in configure_command_option_values()
  * according to the command being run.  Different commands accept
  * different signs with the value.
  */
@@ -1197,7 +1197,7 @@ arg(lvmpartition_ARG, 'l', "lvmpartition", 0, 0, 0,
     "Only report PVs.\n")
 
 /*
- * The sizemb_VAL is overriden in configure_command_option_values()
+ * The sizemb_VAL is overridden in configure_command_option_values()
  * according to the command being run.  Different commands accept
  * different signs with the value.
  */
diff --git a/tools/command.c b/tools/command.c
index bb707d66f..38b11b8eb 100644
--- a/tools/command.c
+++ b/tools/command.c
@@ -1650,14 +1650,14 @@ int define_commands(struct cmd_context *cmdtool, const char *run_name)
  *
  * This function overrides default opt_names[] entries@run time according
  * to the command name, adjusting the value types accepted by various options.
- * So, for lvresize, opt_names[sizemb_VAL] is overriden to accept
+ * So, for lvresize, opt_names[sizemb_VAL] is overridden to accept
  * the relative (+ or -) value type ssizemb_VAL, instead of the default
  * sizemb_VAL.  This way, when lvresize processes the --size value, it
  * will use the ssize_mb_arg() function which accepts relative size values.
  * When lvcreate processes the --size value, it uses size_mb_arg() which
  * rejects signed values.
  *
- * The command defs in commands[] do not need to be overriden because
+ * The command defs in commands[] do not need to be overridden because
  * the command-lines.in defs have the context of a command, and are
  * described using the proper value type, e.g. this cmd def already
  * uses the relative size value: "lvresize --size SSizeMB LV",
diff --git a/tools/toollib.c b/tools/toollib.c
index 67fbbdaa0..5ce2ff346 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4827,7 +4827,7 @@ static void _check_pvcreate_prompt(struct cmd_context *cmd,
 	}
 
 	if (answer_yes && answer_no) {
-		log_warn("WARNING: prompt answer yes is overriden by prompt answer no.");
+		log_warn("WARNING: prompt answer yes is overridden by prompt answer no.");
 		answer_yes = 0;
 	}
 


