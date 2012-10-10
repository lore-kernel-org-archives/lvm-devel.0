From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 10 Oct 2012 16:35:58 +0000 (UTC)
Subject: master - [lv|vg]change: Allow limited metadata changes when PVs are missing
Message-ID: <20121010163558.94B5A16CA@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3501f17fd0fcec2a1fbb8aeecf228e86ee022d99
Commit:        3501f17fd0fcec2a1fbb8aeecf228e86ee022d99
Parent:        3af43af493dabf0dda0527f96c617b0947deb83c
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Oct 10 11:33:10 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Oct 10 11:33:10 2012 -0500

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
---
 WHATS_NEW        |    1 +
 tools/lvchange.c |   26 +++++++++++++++++++-------
 tools/vgchange.c |   11 ++++++++---
 3 files changed, 28 insertions(+), 10 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b1ed58c..ed6464f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Allow limited metadata changes when PVs are missing via [vg|lv]change.
   Do not start dmeventd for lvchange --resync when monitoring is off.
   Remove ExecStartPost with pvscan --cache from lvm2-lvmetad.service.
   Report invalid percentage for property snap_percent of non-snaphot LVs.
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 3525617..8fb8d3a 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -927,12 +927,24 @@ static int lvchange_single(struct cmd_context *cmd, struct logical_volume *lv,
 
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
@@ -954,7 +966,7 @@ int lvchange(struct cmd_context *cmd, int argc, char **argv)
 		return EINVALID_CMD_LINE;
 	}
 
-	if (!update)
+	if (!update || !update_partial_unsafe)
 		cmd->handles_missing_pvs = 1;
 
 	if (!argc) {
diff --git a/tools/vgchange.c b/tools/vgchange.c
index fa129f8..a897a85 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -539,17 +539,19 @@ static int vgchange_single(struct cmd_context *cmd, const char *vg_name,
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
@@ -613,6 +615,9 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_PROCESSED;
 	}
 
+	if (!update || !update_partial_unsafe)
+		cmd->handles_missing_pvs = 1;
+
 	return process_each_vg(cmd, argc, argv, update ? READ_FOR_UPDATE : 0,
 			       NULL, &vgchange_single);
 }


