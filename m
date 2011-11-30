From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 30 Nov 2011 08:46:26 -0600
Subject: [PATCH - first draft] dmeventd handling of RAID device failures
Message-ID: <1322664386.20158.26.camel@f14.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

** First Draft **
I've previously added all the necessary conversion code to handle RAID
failures manually.  This code adds the ability for dmeventd to call
'lvconvert --repair' and use policies set by the user in lvm.conf.  I
welcome comments on the documentation, new RAID fault policies, or the
code itself.

 brassow

Index: LVM2/daemons/dmeventd/plugins/raid/dmeventd_raid.c
===================================================================
--- LVM2.orig/daemons/dmeventd/plugins/raid/dmeventd_raid.c
+++ LVM2/daemons/dmeventd/plugins/raid/dmeventd_raid.c
@@ -24,6 +24,41 @@
 /* FIXME Replace most syslogs with log_error() style messages and add complete context. */
 /* FIXME Reformat to 80 char lines. */
 
+/*
+ * run_repair is a close copy to
+ * plugins/mirror/dmeventd_mirror.c:_remove_failed_devices()
+ */
+static int run_repair(const char *device)
+{
+	int r;
+#define CMD_SIZE 256	/* FIXME Use system restriction */
+	char cmd_str[CMD_SIZE];
+	char *vg = NULL, *lv = NULL, *layer = NULL;
+
+	if (strlen(device) > 200)  /* FIXME Use real restriction */
+		return -1;
+
+	if (!dm_split_lvm_name(dmeventd_lvm2_pool(), device, &vg, &lv, &layer)) {
+		syslog(LOG_ERR, "Unable to determine VG name from %s.",
+		       device);
+		return -1;
+	}
+
+	/* FIXME Is any sanity-checking required on %s? */
+	if (CMD_SIZE <= snprintf(cmd_str, CMD_SIZE, "lvconvert --config devices{ignore_suspended_devices=1} --repair --use-policies %s/%s", vg, lv)) {
+		/* this error should be caught above, but doesn't hurt to check again */
+		syslog(LOG_ERR, "Unable to form LVM command: Device name too long.");
+		return -1;
+	}
+
+	r = dmeventd_lvm2_run(cmd_str);
+
+	if (r != ECMD_PROCESSED)
+		syslog(LOG_INFO, "Repair of RAID LV %s/%s failed.", vg, lv);
+
+	return (r == ECMD_PROCESSED) ? 0 : -1;
+}
+
 static int _process_raid_event(char *params, const char *device)
 {
 	int i, n, failure = 0;
@@ -71,7 +106,7 @@ static int _process_raid_event(char *par
 			break;
 		}
 		if (failure)
-			return 0; /* Don't bother parsing rest of status */
+			return run_repair(device);
 	}
 
 	p = strstr(resync_ratio, "/");
Index: LVM2/doc/example.conf.in
===================================================================
--- LVM2.orig/doc/example.conf.in
+++ LVM2/doc/example.conf.in
@@ -522,9 +522,31 @@ activation {
     # "auto" - Use default value chosen by kernel.
     readahead = "auto"
 
+    # 'raid_fault_policy' defines how a device failure in a RAID logical
+    # volume is handled.  This includes logical volumes that have the following
+    # segment types: raid1, raid4, raid5*, and raid6*.
+    #
+    # In the event of a failure, the following policies will determine what
+    # actions are performed during the automated response to failures (when
+    # dmeventd is monitoring the RAID logical volume) and when 'lvconvert' is
+    # called manually with the options '--repair' and '--use-policies'.
+    #
+    # "warn"	- Use the system log to warn the user that a device in the RAID
+    # 		  logical volume has failed.  It is left to the user to run
+    #		  'lvconvert --repair' manually to remove or replace the failed
+    #		  device.  As long as the number of failed devices does not
+    #		  exceed the redundancy of the logical volume (1 device for
+    #		  raid4/5, 2 for raid6, etc) the logical volume will remain
+    #		  usable.
+    #
+    # "allocate" - Attempt to use any extra physical volumes in the volume
+    # 		  group as spares and replace faulty devices.
+    #
+    raid_fault_policy = "warn"
+
     # 'mirror_image_fault_policy' and 'mirror_log_fault_policy' define
-    # how a device failure affecting a mirror is handled.
-    # A mirror is composed of mirror images (copies) and a log.
+    # how a device failure affecting a mirror (of "mirror" segment type) is
+    # handled.  A mirror is composed of mirror images (copies) and a log.
     # A disk log ensures that a mirror does not need to be re-synced
     # (all copies made the same) every time a machine reboots or crashes.
     #
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -1424,9 +1424,44 @@ static int is_valid_raid_conversion(cons
 	return 1;
 }
 
+static void _lvconvert_raid_repair_ask(struct cmd_context *cmd, int *replace_dev)
+{
+	const char *dev_policy = NULL;
+
+	int force = arg_count(cmd, force_ARG);
+	int yes = arg_count(cmd, yes_ARG);
+
+	*replace_dev = 0;
+
+	if (arg_count(cmd, use_policies_ARG)) {
+		dev_policy = find_config_tree_str(cmd, "activation/raid_fault_policy", DEFAULT_RAID_FAULT_POLICY);
+
+		if (!strcmp(dev_policy, "allocate") ||
+		    !strcmp(dev_policy, "replace"))
+			*replace_dev = 1;
+		/* else if (!strcmp(dev_policy, "anything_else")) -- ignore */
+		return;
+	}
+
+	if (yes) {
+		*replace_dev = 1;
+		return;
+	}
+
+	if (force != PROMPT)
+		return;
+
+	if (yes_no_prompt("Attempt to replace failed RAID images "
+			  "(requires full device resync)? [y/n]: ") == 'y') {
+		*replace_dev = 1;
+	}
+}
+
 static int lvconvert_raid(struct logical_volume *lv, struct lvconvert_params *lp)
 {
+	int replace = 0;
 	int image_count;
+	struct dm_list *failed_pvs;
 	struct cmd_context *cmd = lv->vg->cmd;
 	struct lv_segment *seg = first_seg(lv);
 
@@ -1485,6 +1520,24 @@ static int lvconvert_raid(struct logical
 	if (arg_count(cmd, replace_ARG))
 		return lv_raid_replace(lv, lp->replace_pvh, lp->pvh);
 
+	if (arg_count(cmd, repair_ARG)) {
+		_lvconvert_raid_repair_ask(cmd, &replace);
+
+		/* "warn" if policy not set to replace */
+		if (replace) {
+			if (!(failed_pvs = _failed_pv_list(lv->vg))) {
+				stack;
+				return ECMD_FAILED;
+			}
+			return lv_raid_replace(lv, failed_pvs, lp->pvh);
+		}
+		if (arg_count(cmd, use_policies_ARG))
+			log_error("Issue 'lvconvert --repair %s/%s' to "
+				  "replace failed device",
+				  lv->vg->name, lv->name);
+		return 0;
+	}
+
 	log_error("Conversion operation not yet supported.");
 	return 0;
 }
Index: LVM2/lib/config/defaults.h
===================================================================
--- LVM2.orig/lib/config/defaults.h
+++ LVM2/lib/config/defaults.h
@@ -55,6 +55,7 @@
 #define DEFAULT_MIRROR_LOG_FAULT_POLICY "allocate"
 #define DEFAULT_MIRROR_IMAGE_FAULT_POLICY "remove"
 #define DEFAULT_MIRROR_MAX_IMAGES 8 /* limited by kernel DM_KCOPYD_MAX_REGIONS */
+#define DEFAULT_RAID_FAULT_POLICY "warn"
 #define DEFAULT_DMEVENTD_RAID_LIB "libdevmapper-event-lvm2raid.so"
 #define DEFAULT_DMEVENTD_MIRROR_LIB "libdevmapper-event-lvm2mirror.so"
 #define DEFAULT_DMEVENTD_SNAPSHOT_LIB "libdevmapper-event-lvm2snapshot.so"
Index: LVM2/doc/lvm2-raid.txt
===================================================================
--- LVM2.orig/doc/lvm2-raid.txt
+++ LVM2/doc/lvm2-raid.txt
@@ -380,7 +380,7 @@ until all possible changes have been mad
 intermediate stages being left due to a failure of operation or machine crash.
 
 RAID1 '--splitmirrors', '--trackchanges', and '--merge' operations
------------------------------------------------------------------
+------------------------------------------------------------------
 This suite of operations is only available to the "raid1" segment type.
 
 Splitting an image from a RAID1 array is almost identical to the removal of
@@ -404,3 +404,71 @@ set as "hidden" again.  Recycling the ar
 to its position in the array and begins the process of sync'ing the changes that
 were made since the time it was split from the array.
 
+RAID device replacement with '--replace'
+----------------------------------------
+This option is available to all RAID segment types.
+
+The '--replace' option can be used to remove a particular device from a RAID
+logical volume and replace it with a different one in one action (CLI command).
+The device device to be removed is specified as the argument to the '--replace'
+option.  This option can be specified more than once in a single command,
+allowing multiple devices to be replaced at the same time - provided the RAID
+logical volume has the necessary redundancy to allow the action.  The devices
+to be used as replacements can also be specified in the command; similar to the
+way allocatable devices are specified during an up-convert.
+
+Example> lvconvert --replace /dev/sdd1 --replace /dev/sde1 vg/lv /dev/sd[bc]1
+
+RAID '--repair'
+---------------
+This 'lvconvert' option is available to all RAID segment types and is described
+under "RAID Fault Handling".
+
+
+RAID Fault Handling
+===================
+RAID is not like traditional LVM mirroring (i.e. the "mirror" segment type).
+LVM mirroring required failed devices to be removed or the logical volume would
+simply hang.  RAID arrays can keep on running with failed devices.  In fact, for
+RAID types other than RAID1 removing a device would mean substituting an error
+target or converting to a lower level RAID (e.g. RAID6 -> RAID5, or RAID4/5 to
+RAID0).  Therefore, rather than removing a failed device unconditionally, the
+user has a couple of options to choose from.
+
+The automated response to a device failure is handled according to the user's
+preference defined in lvm.conf:activation.raid_fault_policy.  The options are:
+    # "warn"    - Use the system log to warn the user that a device in the RAID
+    #             logical volume has failed.  It is left to the user to run
+    #             'lvconvert --repair' manually to remove or replace the failed
+    #             device.  As long as the number of failed devices does not
+    #             exceed the redundancy of the logical volume (1 device for
+    #             raid4/5, 2 for raid6, etc) the logical volume will remain
+    #             usable.
+    #
+    # "remove"  - NOT CURRENTLY IMPLEMENTED OR DOCUMENTED IN example.conf.in.
+    #             Remove the failed device and reduce the RAID logical volume
+    #             accordingly.  If a single device dies in a 3-way mirror,
+    #             remove it and reduce the mirror to 2-way.  If a single device
+    #             dies in a RAID 4/5 logical volume, reshape it to a striped
+    #             volume, etc - RAID 6 -> RAID 4/5 -> RAID 0.  If devices
+    #             cannot be removed for lack of redundancy, fail.
+    #             THIS OPTION CANNOT YET BE IMPLEMENTED BECAUSE RESHAPE IS NOT
+    #             YET SUPPORTED BY THE KERNEL.
+    #
+    # "allocate" - Attempt to use any extra physical volumes in the volume
+    #             group as spares and replace faulty devices.
+
+If manual intervention is taken, either in response to the automated solution's
+"warn" mode or simply because dmeventd hadn't run, then the user can call
+'lvconvert --repair vg/lv' and follow the prompts.  They will be prompted
+whether or not to replace the device and cause a full recovery of the failed
+device.
+
+If replacement is chosen via the manual method or "allocate" is the policy taken
+by the automated response, then 'lvconvert --replace' is the mechanism used to
+attempt the replacement of the failed device.
+
+'vgreduce --removemissing' is ineffectual at repairing RAID logical volumes.  It
+will remove the failed device, but the RAID logical volume will simply continue
+to operate with an <unknown> sub-LV.  The user should clear the failed device
+with 'lvconvert --repair'.
Index: LVM2/doc/lvm_fault_handling.txt
===================================================================
--- LVM2.orig/doc/lvm_fault_handling.txt
+++ LVM2/doc/lvm_fault_handling.txt
@@ -15,6 +15,12 @@ from (e.g. a power failure, intermittent
 relocation, etc).  The policies for handling both types of failures
 is described herein.
 
+Users need to be aware that there are two implementations of RAID1 in LVM.
+The first is defined by the "mirror" segment type.  The second is defined by
+the "raid1" segment type.  The characteristics of each of these are defined
+in lvm.conf under 'mirror_segtype_default' - the configuration setting used to
+identify the default RAID1 implementation used for LVM operations.
+
 Available Operations During a Device Failure
 --------------------------------------------
 When there is a device failure, LVM behaves somewhat differently because
@@ -51,30 +57,36 @@ are as follows:
   a linear, stripe, or snapshot device is located on the failed device
   the command will not proceed without a '--force' option.  The result
   of using the '--force' option is the entire removal and complete
-  loss of the non-redundant logical volume.  Once this operation is
-  complete, the volume group will again have a complete and consistent
-  view of the devices it contains.  Thus, all operations will be
-  permitted - including creation, conversion, and resizing operations.
+  loss of the non-redundant logical volume.  If an image or metadata area
+  of a RAID logical volume is on the failed device, the sub-LV affected is
+  replace with an error target device - appearing as <unknown> in 'lvs'
+  output.  RAID logical volumes cannot be completely repaired by vgreduce -
+  'lvconvert --repair' (listed below) must be used.  Once this operation is
+  complete on volume groups not containing RAID logical volumes, the volume
+  group will again have a complete and consistent view of the devices it
+  contains.  Thus, all operations will be permitted - including creation,
+  conversion, and resizing operations.  It is currently the preferred method
+  to call 'lvconvert --repair' on the individual logical volumes to repair
+  them followed by 'vgreduce --removemissing' to extract the physical volume's
+  representation in the volume group.
 
 - 'lvconvert --repair <VG/LV>':  This action is designed specifically
-  to operate on mirrored logical volumes.  It is used on logical volumes
-  individually and does not remove the faulty device from the volume
-  group.  If, for example, a failed device happened to contain the
-  images of four distinct mirrors, it would be necessary to run
-  'lvconvert --repair' on each of them.  The ultimate result is to leave
-  the faulty device in the volume group, but have no logical volumes
-  referencing it.  In addition to removing mirror images that reside
-  on failed devices, 'lvconvert --repair' can also replace the failed
-  device if there are spare devices available in the volume group.  The
-  user is prompted whether to simply remove the failed portions of the
-  mirror or to also allocate a replacement, if run from the command-line.
-  Optionally, the '--use-policies' flag can be specified which will
-  cause the operation not to prompt the user, but instead respect
+  to operate on individual logical volumes.  If, for example, a failed
+  device happened to contain the images of four distinct mirrors, it would
+  be necessary to run 'lvconvert --repair' on each of them.  The ultimate
+  result is to leave the faulty device in the volume group, but have no logical
+  volumes referencing it.  (This allows for 'vgreduce --removemissing' to
+  removed the physical volumes cleanly.)  In addition to removing mirror or
+  RAID images that reside on failed devices, 'lvconvert --repair' can also
+  replace the failed device if there are spare devices available in the
+  volume group.  The user is prompted whether to simply remove the failed
+  portions of the mirror or to also allocate a replacement, if run from the
+  command-line.  Optionally, the '--use-policies' flag can be specified which
+  will cause the operation not to prompt the user, but instead respect
   the policies outlined in the LVM configuration file - usually,
-  /etc/lvm/lvm.conf.  Once this operation is complete, mirrored logical
-  volumes will be consistent and I/O will be allowed to continue.
-  However, the volume group will still be inconsistent -  due to the
-  refernced-but-missing device/PV - and operations will still be
+  /etc/lvm/lvm.conf.  Once this operation is complete, the logical volumes
+  will be consistent.  However, the volume group will still be inconsistent -
+  due to the refernced-but-missing device/PV - and operations will still be
   restricted to the aformentioned actions until either the device is
   restored or 'vgreduce --removemissing' is run.
 
@@ -98,13 +110,15 @@ following possible exceptions exist:
 
 Automated Target Response to Failures:
 --------------------------------------
-The only LVM target type (i.e. "personality") that has an automated
-response to failures is a mirrored logical volume.  The other target
+The only LVM target types (i.e. "personalities") that have an automated
+response to failures are the mirror and RAID logical volumes.  The other target
 types (linear, stripe, snapshot, etc) will simply propagate the failure.
 [A snapshot becomes invalid if its underlying device fails, but the
 origin will remain valid - presuming the origin device has not failed.]
-There are three types of errors that a mirror can suffer - read, write,
-and resynchronization errors.  Each is described in depth below.
+
+Starting with the "mirror" segment type, there are three types of errors that
+a mirror can suffer - read, write, and resynchronization errors.  Each is
+described in depth below.
 
 Mirror read failures:
 If a mirror is 'in-sync' (i.e. all images have been initialized and
@@ -184,38 +198,5 @@ command are set in the LVM configuration
   choice of when to incure the extra performance costs of replacing
   the failed image.
 
-TODO...
-The appropriate time to take permanent corrective action on a mirror
-should be driven by policy.  There should be a directive that takes
-a time or percentage argument.  Something like the following:
-- mirror_fault_policy_WHEN = "10sec"/"10%"
-A time value would signal the amount of time to wait for transient
-failures to resolve themselves.  The percentage value would signal the
-amount a mirror could become out-of-sync before the faulty device is
-removed.
-
-A mirror cannot be used unless /some/ corrective action is taken,
-however.  One option is to replace the failed mirror image with an
-error target, forgo the use of 'handle_errors', and simply let the
-out-of-sync regions accumulate and be tracked by the log.  Mirrors
-that have more than 2 images would have to "stack" to perform the
-tracking, as each failed image would have to be associated with a
-log.  If the failure is transient, the device would replace the
-error target that was holding its spot and the log that was tracking
-the deltas would be used to quickly restore the portions that changed.
-
-One unresolved issue with the above scheme is how to know which
-regions of the mirror are out-of-sync when a problem occurs.  When
-a write failure occurs in the kernel, the log will contain those
-regions that are not in-sync.  If the log is a disk log, that log
-could continue to be used to track differences.  However, if the
-log was a core log - or if the log device failed at the same time
-as an image device - there would be no way to determine which
-regions are out-of-sync to begin with as we start to track the
-deltas for the failed image.  I don't have a solution for this
-problem other than to only be able to handle errors in this way
-if conditions are right.  These issues will have to be ironed out
-before proceeding.  This could be another case, where it is better
-to handle failures in the kernel by allowing the kernel to store
-updates in various metadata areas.
-...TODO
+RAID logical volume device failures are handled differently from the "mirror"
+segment type.  Discussion of this can be found in lvm2-raid.txt.



