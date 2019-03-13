From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Mar 2019 17:05:48 -0400
Subject: master - pvscan: fix ignoring foreign PVs
Message-ID: <201903132105.x2DL5m0f024098@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d84134c75bf2f5e9d289da73f68a57d43f5976c3
Commit:        d84134c75bf2f5e9d289da73f68a57d43f5976c3
Parent:        9b2b0fef9c6c475a2023b9e5ca9525d850aed1cc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 13 16:03:02 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 13 16:03:02 2019 -0500

pvscan: fix ignoring foreign PVs

Fix to previous commit
  "pvscan: ignore online for shared and foreign PVs"

which was incorrectly considering a PV foreign if its
VG had no system ID when the host did have a system ID.
---
 test/shell/pvscan-autoactivate.sh |   27 ++++++++++++++++++++++++---
 tools/pvscan.c                    |    7 ++++++-
 2 files changed, 30 insertions(+), 4 deletions(-)

diff --git a/test/shell/pvscan-autoactivate.sh b/test/shell/pvscan-autoactivate.sh
index 20a0eeb..e48aeac 100644
--- a/test/shell/pvscan-autoactivate.sh
+++ b/test/shell/pvscan-autoactivate.sh
@@ -154,6 +154,7 @@ pvscan --cache -aay "$dev2"
 check lv_field $vg1/$lv1 lv_active "active"
 lvchange -an $vg1
 
+vgremove -f $vg1
 
 # pvscan cache ignores pv that's not used
 
@@ -174,17 +175,37 @@ not ls "$RUNDIR/lvm/pvs_online/$PVID3"
 
 aux lvmconf "global/system_id_source = uname"
 
+_clear_online_files
+
 vgcreate $vg2 "$dev3"
-lvcreate -an -n $lv1 -l1 $vg2
+lvcreate -an -n $lv2 -l1 $vg2
 pvscan --cache -aay "$dev3"
 ls "$RUNDIR/lvm/pvs_online/$PVID3"
-check lv_field $vg2/$lv1 lv_active "active"
+check lv_field $vg2/$lv2 lv_active "active"
 lvchange -an $vg2
 rm "$RUNDIR/lvm/pvs_online/$PVID3"
 
+# a vg without a system id is not foreign, not ignored
+vgchange -y --systemid "" "$vg2"
+
+_clear_online_files
+pvscan --cache -aay "$dev3"
+ls "$RUNDIR/lvm/pvs_online/$PVID3"
+check lv_field $vg2/$lv2 lv_active "active"
+lvchange -an $vg2
+rm "$RUNDIR/lvm/pvs_online/$PVID3"
+
+# make the vg foreign by assigning a system id different from ours
 vgchange -y --systemid "asdf" "$vg2"
 
+_clear_online_files
+
 pvscan --cache -aay "$dev3"
 not ls "$RUNDIR/lvm/pvs_online/$PVID3"
-check lv_field $vg2/$lv1 lv_active "" --foreign
+lvs --foreign $vg2 > tmp
+cat tmp
+grep $lv2 tmp
+check lv_field $vg2/$lv2 lv_active "" --foreign
+
+
 
diff --git a/tools/pvscan.c b/tools/pvscan.c
index 30f6fe8..d69d919 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -702,7 +702,12 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 		return 1;
 	}
 
-	if (baton.vg && vg_is_foreign(baton.vg)) {
+	if (baton.vg &&
+	    baton.vg->system_id && baton.vg->system_id[0] &&
+	    cmd->system_id && cmd->system_id[0] &&
+	    vg_is_foreign(baton.vg)) {
+		log_verbose("Ignore PV %s with VG system id %s with our system id %s",
+			    dev_name(dev), baton.vg->system_id, cmd->system_id);
 		log_print("pvscan[%d] PV %s ignore foreign VG.", getpid(), dev_name(dev));
 		release_vg(baton.vg);
 		return 1;


