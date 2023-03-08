From: David Teigland <teigland@sourceware.org>
Date: Wed,  8 Mar 2023 22:34:41 +0000 (GMT)
Subject: main - vgchange: allow changing system ID with majority of PVs
Message-ID: <20230308223441.A32A53858D33@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=aa85ed1784b2b8e731ac7bd05a8988bac30405f0
Commit:        aa85ed1784b2b8e731ac7bd05a8988bac30405f0
Parent:        da44f2b6fe1e0edbd3ee875c831f3e467f242bc0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jul 7 16:06:01 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 8 16:30:54 2023 -0600

vgchange: allow changing system ID with majority of PVs

when used with --majoritypvs.  This allows the fail-over
of a VG between systems by changing the VG system ID when
a PV is missing.
---
 test/shell/system_id.sh | 69 ++++++++++++++++++++++++++++++++++++++++++++++++-
 tools/args.h            |  4 +++
 tools/command-lines.in  |  2 +-
 tools/vgchange.c        | 21 +++++++++++++++
 4 files changed, 94 insertions(+), 2 deletions(-)

diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 756c95add..14d2c6fd4 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -22,7 +22,7 @@ print_lvmlocal() {
 
 . lib/inittest
 
-aux prepare_devs 1
+aux prepare_devs 5
 
 SIDFILE="etc/lvm_test.conf"
 LVMLOCAL="etc/lvmlocal.conf"
@@ -541,6 +541,73 @@ echo "$SID1" > "$SIDFILE"
 clear_df_systemid
 vgremove $vg1
 
+# vgchange --systemid --majoritypvs
+SID1=sidfoofile1
+SID2=sidfoofile2
+rm -f "$LVMLOCAL"
+echo "$SID1" > "$SIDFILE"
+clear_df_systemid
+aux lvmconf "global/system_id_source = file" \
+	    "global/system_id_file = \"$SIDFILE\""
+# create a vg
+vgcreate $vg1 "$dev1" "$dev2" "$dev3"
+vgcreate $vg2 "$dev4" "$dev5"
+# normal vgs sees the vg
+# change the local system_id, making the vg foreign
+echo "$SID2" > "$SIDFILE"
+clear_df_systemid
+# normal vgs doesn't see the vg
+vgs >err
+not grep $vg1 err
+not grep $vg2 err
+# using --foreign we can see the vg
+vgs --foreign >err
+grep $vg1 err
+grep $vg2 err
+# cannot clear the system_id of the foreign vg
+not vgchange --yes --systemid "" $vg1
+not vgchange --yes --systemid "" $vg2
+# cannot set the system_id of the foreign vg
+not vgchange --yes --systemid foo $vg1
+not vgchange --yes --systemid foo $vg2
+# we are local node SID2, foreign node is SID1
+# use extra_system_ids to take over the foreign vg, making it local
+vgchange --config "local/extra_system_ids=[\"${SID1}\"]" --systemid $SID2 $vg1
+vgs $vg1
+# make it foreign again
+vgchange --yes --systemid sidfoofile1 $vg1
+not vgs $vg1
+# both vgs are foreign, drop dev1/dev4 so both vgs are missing a device
+aux hide_dev "$dev1"
+aux hide_dev "$dev4"
+not pvs "$dev1"
+not pvs "$dev4"
+# neither VG can be changed because both are missing a dev
+not vgchange --config "local/extra_system_ids=[\"${SID1}\"]" --systemid $SID2 $vg1
+not vgchange --config "local/extra_system_ids=[\"${SID1}\"]" --systemid $SID2 $vg2
+# using majoritypvs, vg1 can be changed because 2 of 3 PVs exist
+vgchange --majoritypvs --config "local/extra_system_ids=[\"${SID1}\"]" --systemid $SID2 $vg1
+vgs $vg1
+# using majoritypvs, vg2 cannot be changed because 1 of 2 PVs exist
+not vgchange --majoritypvs --config "local/extra_system_ids=[\"${SID1}\"]" --systemid $SID2 $vg2
+not vgs $vg2
+vgs --foreign $vg2
+# dev1/dev4 return so we can take over vg2 now
+# vg1 will complain about stale metadata on dev1
+aux unhide_dev "$dev1"
+aux unhide_dev "$dev4"
+vgs
+pvs
+vgchange --majoritypvs --config "local/extra_system_ids=[\"${SID1}\"]" --systemid $SID2 $vg2
+vgs $vg2
+# update metadata on dev1
+vgck --updatemetadata $vg1
+vgs $vg1
+clear_df_systemid
+vgremove $vg1
+vgremove $vg2
+
+
 # vgcfgbackup backs up foreign vg with --foreign
 SID1=sidfoofile1
 SID2=sidfoofile2
diff --git a/tools/args.h b/tools/args.h
index 5819bb84e..24dc8b339 100644
--- a/tools/args.h
+++ b/tools/args.h
@@ -416,6 +416,10 @@ arg(logonly_ARG, '\0', "logonly", 0, 0, 0,
 arg(longhelp_ARG, '\0', "longhelp", 0, 0, 0,
     "Display long help text.\n")
 
+arg(majoritypvs_ARG, '\0', "majoritypvs", 0, 0, 0,
+    "Change the VG system ID if the majority of PVs in the VG\n"
+    "are present (one more than half).\n")
+
 arg(maxrecoveryrate_ARG, '\0', "maxrecoveryrate", sizekb_VAL, 0, 0,
     "Sets the maximum recovery rate for a RAID LV.  The rate value\n"
     "is an amount of data per second for each device in the array.\n"
diff --git a/tools/command-lines.in b/tools/command-lines.in
index 4bbafd05d..1cf6bba23 100644
--- a/tools/command-lines.in
+++ b/tools/command-lines.in
@@ -1767,7 +1767,7 @@ ID: vgchange_refresh
 DESC: Reactivate LVs using the latest metadata.
 
 vgchange --systemid String VG|Tag|Select
-OO: --select String
+OO: --select String, --majoritypvs
 ID: vgchange_systemid
 DESC: Change the system ID of a VG.
 
diff --git a/tools/vgchange.c b/tools/vgchange.c
index 09ade96a6..f07b245bd 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -1383,6 +1383,24 @@ static int _vgchange_systemid_single(struct cmd_context *cmd, const char *vg_nam
 			             struct volume_group *vg,
 			             struct processing_handle *handle)
 {
+	if (arg_is_set(cmd, majoritypvs_ARG)) {
+		struct pv_list *pvl;
+		int missing_pvs = 0;
+		int found_pvs = 0;
+
+		dm_list_iterate_items(pvl, &vg->pvs) {
+			if (!pvl->pv->dev)
+				missing_pvs++;
+			else
+				found_pvs++;
+		}
+		if (found_pvs <= missing_pvs) {
+			log_error("Cannot change system ID without the majority of PVs (found %d of %d)",
+				  found_pvs, found_pvs+missing_pvs);
+			return ECMD_FAILED;
+		}
+	}
+
 	if (!_vgchange_system_id(cmd, vg))
 		return_ECMD_FAILED;
 
@@ -1415,6 +1433,9 @@ int vgchange_systemid_cmd(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_FAILED;
 	}
 
+	if (arg_is_set(cmd, majoritypvs_ARG))
+		cmd->handles_missing_pvs = 1;
+
 	ret = process_each_vg(cmd, argc, argv, NULL, NULL, READ_FOR_UPDATE, 0, handle, &_vgchange_systemid_single);
 
 	destroy_processing_handle(cmd, handle);

