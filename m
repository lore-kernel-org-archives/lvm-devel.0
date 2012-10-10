From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 09 Oct 2012 22:46:55 -0500
Subject: [PATCH]: Allow limited metadata changes when PVs are missing
Message-ID: <1349840815.32340.6.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch replaces the one submitted under the subject:
"[PATCH]: Add new configurable to allow metadata changes when PVs are
missing"

 brassow

[lv|vg]change:  Allow limited metadata changes when PVs are missing

A while back, the behavior of LVM changed from allowing metadata changes
when PVs were missing to not allowing changes.  Until recently, this
change was tolerated by HA-LVM by forcing a 'vgreduce --removemissing'
before trying (again) to add tags to an LV and then activate it.  LVM
mirroring requires that failed devices are removed anyway, so this was
largely harmless.  However, RAID LVs do not require devices to be removed
from the array in order to be activated.  In fact, in an HA-LVM
environment this would be very undesirable.  Device failures in such an
environment can often be transient and it would be much better to restore
the device to the array than synchronize an entirely new device.

There are two methods that can be used to setup an HA-LVM environment:
"clvm" or "tagging".  For RAID LVs, "clvm" is out of the question because
RAID LVs are not supported in clustered VGs - not even in an exclusively
activated manner.  That leaves "tagging".  HA-LVM uses tagging - coupled
with 'volume_list' - to ensure that only one machine can have an LV active
at a time.  If updates are not allowed when a PV is missing, it is
impossible to add or remove tags to allow for activation.  This removes
one of the most basic functionalities of HA-LVM - site redundancy.  If
mirroring or RAID is used to replicate the storage in two data centers
and one of them goes down, a server and a storage device are lost.  When
the service fails-over to the alternate site, the VG will be "partial".
Unable to add a tag to the VG/LV, the RAID device will be unable to
activate.

The solution is to allow vgchange and lvchange to alter the LVM metadata
for a limited set of options - --[add|del]tag included.  The set of
allowable options are ones that do not cause changes to the DM kernel
target (like --resync would) or could alter the structure of the LV
(like allocation or conversion).

Index: lvm2/tools/lvchange.c
===================================================================
--- lvm2.orig/tools/lvchange.c
+++ lvm2/tools/lvchange.c
@@ -927,12 +927,24 @@ static int lvchange_single(struct cmd_co
 
 int lvchange(struct cmd_context *cmd, int argc, char **argv)
 {
-	int update = /* options other than -a, --refresh, --monitor or --poll */
-		arg_count(cmd, contiguous_ARG) || arg_count(cmd, permission_ARG) ||
-		arg_count(cmd, readahead_ARG) || arg_count(cmd, persistent_ARG) ||
-		arg_count(cmd, addtag_ARG) || arg_count(cmd, deltag_ARG) ||
-		arg_count(cmd, resync_ARG) || arg_count(cmd, alloc_ARG) ||
-		arg_count(cmd, discards_ARG) || arg_count(cmd, zero_ARG);
+	/*
+	 * Options that update metadata should be listed in one of
+	 * the two lists below (i.e. options other than -a, --refresh,
+	 * --monitor or --poll).
+	 */
+	int update_partial_safe = /* options safe to update if partial */
+		arg_count(cmd, contiguous_ARG) ||
+		arg_count(cmd, permission_ARG) ||
+		arg_count(cmd, readahead_ARG) ||
+		arg_count(cmd, persistent_ARG) ||
+		arg_count(cmd, addtag_ARG) ||
+		arg_count(cmd, deltag_ARG);
+	int update_partial_unsafe =
+		arg_count(cmd, resync_ARG) ||
+		arg_count(cmd, alloc_ARG) ||
+		arg_count(cmd, discards_ARG) ||
+		arg_count(cmd, zero_ARG);
+	int update = update_partial_safe || update_partial_unsafe;
 
 	if (!update &&
             !arg_count(cmd, activate_ARG) && !arg_count(cmd, refresh_ARG) &&
@@ -954,7 +966,7 @@ int lvchange(struct cmd_context *cmd, in
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!update)
+	if (!update || (update_partial_safe && !update_partial_unsafe))
 		cmd->handles_missing_pvs = 1;
 
 	if (!argc) {
Index: lvm2/tools/vgchange.c
===================================================================
--- lvm2.orig/tools/vgchange.c
+++ lvm2/tools/vgchange.c
@@ -539,17 +539,19 @@ static int vgchange_single(struct cmd_co
 int vgchange(struct cmd_context *cmd, int argc, char **argv)
 {
 	/* Update commands that can be combined */
-	int update = 
+	int update_partial_safe =
+		arg_count(cmd, deltag_ARG) ||
+		arg_count(cmd, addtag_ARG);
+	int update_partial_unsafe =
 		arg_count(cmd, logicalvolume_ARG) ||
 		arg_count(cmd, maxphysicalvolumes_ARG) ||
 		arg_count(cmd, resizeable_ARG) ||
-		arg_count(cmd, deltag_ARG) ||
-		arg_count(cmd, addtag_ARG) ||
 		arg_count(cmd, uuid_ARG) ||
 		arg_count(cmd, physicalextentsize_ARG) ||
 		arg_count(cmd, clustered_ARG) ||
 		arg_count(cmd, alloc_ARG) ||
 		arg_count(cmd, vgmetadatacopies_ARG);
+	int update = update_partial_safe || update_partial_unsafe;
 
 	if (!update &&
 	    !arg_count(cmd, activate_ARG) &&
@@ -613,6 +615,9 @@ int vgchange(struct cmd_context *cmd, in
 		return ECMD_PROCESSED;
 	}
 
+	if (!update || (update_partial_safe && !update_partial_unsafe))
+		cmd->handles_missing_pvs = 1;
+
 	return process_each_vg(cmd, argc, argv, update ? READ_FOR_UPDATE : 0,
 			       NULL, &vgchange_single);
 }



