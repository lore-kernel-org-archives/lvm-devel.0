From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 21 Jun 2010 23:06:08 -0400
Subject: [PATCH 35/35] Update tests to handle phase 2 (vg based) metadata balance.
In-Reply-To: <1277175968-9661-35-git-send-email-dwysocha@redhat.com>
References: <1277175968-9661-1-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-2-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-3-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-4-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-5-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-6-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-7-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-8-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-9-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-10-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-11-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-12-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-13-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-14-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-15-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-16-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-17-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-18-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-19-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-20-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-21-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-22-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-23-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-24-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-25-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-26-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-27-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-28-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-29-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-30-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-31-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-32-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-33-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-34-git-send-email-dwysocha@redhat.com>
	<1277175968-9661-35-git-send-email-dwysocha@redhat.com>
Message-ID: <1277175968-9661-36-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Test vgcreate/vgchange --vgmetadatacopies, vgextend, vgreduce,
vgsplit, vgmerge.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/t-metadata-balance.sh |  153 +++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 151 insertions(+), 2 deletions(-)

diff --git a/test/t-metadata-balance.sh b/test/t-metadata-balance.sh
index 2321771..95764a8 100755
--- a/test/t-metadata-balance.sh
+++ b/test/t-metadata-balance.sh
@@ -10,9 +10,9 @@
 
 . ./test-utils.sh
 
-aux prepare_devs 5
+aux prepare_devs 6
 
-#  Make sure we can ignore / un-ignore mdas on a per-PV basis
+echo Make sure we can ignore / un-ignore mdas on a per-PV basis
 for pv_in_vg in 1 0; do
 for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp $dev1 $dev2
@@ -28,6 +28,7 @@ for mdacp in 1 2; do
 	if [ $pv_in_vg = 1 ]; then
 		check_vg_field_ $vg vg_mda_count $(($mdacp * 2))
 		check_vg_field_ $vg vg_mda_count_ignored $mdacp
+		check_vg_field_ $vg vg_mda_copies 0
 	fi
 	pvchange --metadataignore n $dev1
 	check_pv_field_ $dev1 pv_mda_count $mdacp
@@ -35,7 +36,155 @@ for mdacp in 1 2; do
 	if [ $pv_in_vg = 1 ]; then
 		check_vg_field_ $vg vg_mda_count $(($mdacp * 2))
 		check_vg_field_ $vg vg_mda_count_ignored 0
+		check_vg_field_ $vg vg_mda_copies 0
 		vgremove -f $vg
 	fi
 done
 done
+
+# Check if a PV has non-ignored mdas, and if so, ignore
+pvignore_ () {
+	pv_ignored=$(get_pv_field "$1" pv_mda_count_ignored)
+	if [ $pv_ignored = 0 ]; then
+	    pvchange --metadataignore y $1
+	fi
+}
+
+pvunignore_ () {
+	pv_ignored=$(get_pv_field "$1" pv_mda_count_ignored)
+	if [ $pv_ignored != 0 ]; then
+	    pvchange --metadataignore n $1
+	fi
+}
+
+echo Test of vgmetadatacopies with vgcreate and vgchange
+for mdacp in 1 2; do
+	pvcreate --metadatacopies $mdacp $dev1 $dev2 $dev4 $dev5
+	check_pv_field_ $dev1 pv_mda_count_ignored 0
+	check_pv_field_ $dev2 pv_mda_count_ignored 0
+	check_pv_field_ $dev4 pv_mda_count_ignored 0
+	check_pv_field_ $dev5 pv_mda_count_ignored 0
+	pvcreate --metadatacopies 0 $dev3
+	vgcreate -c n "$vg" $dev1 $dev2 $dev3
+	check_vg_field_ $vg vg_mda_copies 0
+	echo ensure both --vgmetadatacopies and --metadatacopies accepted
+	vgchange --metadatacopies $(($mdacp * 1)) $vg
+	echo --vgmetadatacopies is persistent on disk
+	echo --vgmetadatacopies affects underlying pv mda ignore
+	check_vg_field_ $vg vg_mda_copies $(($mdacp * 1))
+	check_vg_field_ $vg vg_mda_count_ignored $(($mdacp * 1))
+	vgchange --vgmetadatacopies $(($mdacp * 2)) $vg
+	check_vg_field_ $vg vg_mda_copies $(($mdacp * 2))
+	check_vg_field_ $vg vg_mda_count_ignored 0
+	echo allow setting metadatacopies larger than number of PVs
+	vgchange --vgmetadatacopies $(($mdacp * 5)) $vg
+	check_vg_field_ $vg vg_mda_copies $(($mdacp * 5))
+	check_vg_field_ $vg vg_mda_count_ignored 0
+	echo setting to 0 disables automatic balancing
+	vgchange --vgmetadatacopies 0 $vg
+	check_vg_field_ $vg vg_mda_copies 0
+	vgremove -f $vg
+	echo vgcreate succeeds even when creating a VG w/all ignored mdas
+	pvchange --metadataignore y $dev1 $dev2
+	check_pv_field_ $dev1 pv_mda_count $mdacp
+	check_pv_field_ $dev2 pv_mda_count_ignored $mdacp
+	vgcreate -c n "$vg" $dev1 $dev2
+	check_vg_field_ $vg vg_mda_copies 0
+	vgremove -f $vg
+	echo vgcreate succeeds with a specific number of metadata copies
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 2)) "$vg" $dev1 $dev2
+	check_vg_field_ $vg vg_mda_copies $(($mdacp * 2))
+	vgremove -f $vg
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) "$vg" $dev1 $dev2
+	check_vg_field_ $vg vg_mda_copies $(($mdacp * 1))
+	vgremove -f $vg
+	echo vgcreate succeeds with a larger value than total metadatacopies
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 5)) "$vg" $dev1 $dev2
+	check_vg_field_ $vg vg_mda_copies $(($mdacp * 5))
+	vgremove -f $vg
+	echo vgcreate succeeds with --vgmetadatacopies 0
+	vgcreate -c n --vgmetadatacopies 0 "$vg" $dev1 $dev2
+	check_vg_field_ $vg vg_mda_copies 0
+	vgremove -f $vg
+	pvunignore_ $dev1
+	pvunignore_ $dev2
+	pvunignore_ $dev4
+	pvunignore_ $dev5
+	echo vgcreate succeds with small value of --metadatacopies, ignores mdas
+	vgcreate -c n --vgmetadatacopies 1 "$vg" $dev1 $dev2 $dev4 $dev5
+	check_vg_field_ $vg vg_mda_copies 1
+	check_vg_field_ $vg vg_mda_count $(($mdacp * 4))
+	check_vg_field_ $vg vg_mda_count_ignored $(($mdacp * 4 - 1))
+	echo Setting a larger value should trigger non-ignore of mdas
+	vgchange --metadatacopies 3 $vg
+	check_vg_field_ $vg vg_mda_copies 3
+	check_vg_field_ $vg vg_mda_count_ignored $(($mdacp * 4 - 3))
+	echo Setting a smaller value should trigger ignore of mdas
+	vgremove -f $vg
+done
+
+echo Test vgextend / vgreduce with vgmetadatacopies
+for mdacp in 1 2; do
+	pvcreate --metadatacopies $mdacp $dev1 $dev2 $dev4 $dev5
+	pvcreate --metadatacopies 0 $dev3
+	echo Set a large value of vgmetadatacopies
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 5)) "$vg" $dev1 $dev2 $dev3
+	check_vg_field_ $vg vg_mda_copies $(($mdacp * 5))
+	echo Ignore mdas on devices to be used for vgextend
+	echo Large value of vgetadatacopies should automatically un-ignore mdas
+	pvchange --metadataignore y $dev4 $dev5
+	check_pv_field_ $dev4 pv_mda_count_ignored $mdacp
+	vgextend $vg $dev4 $dev5
+	check_pv_field_ $dev4 pv_mda_count_ignored 0
+	check_pv_field_ $dev5 pv_mda_count_ignored 0
+	vgremove -f $vg
+	echo Set a small value of vgmetadatacopies
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) "$vg" $dev1 $dev2 $dev3
+	check_vg_field_ $vg vg_mda_copies $(($mdacp * 1))
+	echo Ignore mdas on devices to be used for vgextend
+	echo Small value of vgetadatacopies should leave mdas as ignored
+	pvchange --metadataignore y $dev4 $dev5
+	check_pv_field_ $dev4 pv_mda_count_ignored $mdacp
+	vgextend $vg $dev4 $dev5
+	check_pv_field_ $dev4 pv_mda_count_ignored $mdacp
+	check_pv_field_ $dev5 pv_mda_count_ignored $mdacp
+	echo vgreduce of ignored pv w/mda should not trigger any change to ignore bits
+	vgreduce $vg $dev4
+	check_pv_field_ $dev4 pv_mda_count_ignored $mdacp
+	check_pv_field_ $dev5 pv_mda_count_ignored $mdacp
+	echo vgreduce of un-ignored pv w/mda should trigger un-ignore on an mda
+	vgreduce $vg $dev1 $dev2 $dev3
+	check_pv_field_ $dev5 pv_mda_count_ignored 0
+	check_vg_field_ $vg vg_mda_copies $(($mdacp * 1))
+	pvunignore_ $dev1
+	pvunignore_ $dev2
+	echo setting vgmetadatacopies to 0 should allow vgextend to add w/out balancing
+	vgchange --vgmetadatacopies 0 $vg
+	vgextend $vg $dev1 $dev2
+	check_vg_field_ $vg vg_mda_copies 0
+	check_vg_field_ $vg vg_mda_count $(($mdacp * 3))
+	check_vg_field_ $vg vg_mda_count_ignored 0
+	check_pv_field_ $dev1 pv_mda_count_ignored 0
+	check_pv_field_ $dev2 pv_mda_count_ignored 0
+	vgremove -f $vg
+done
+
+echo Test special situations, vgsplit, vgmerge, etc
+for mdacp in 1 2; do
+	pvcreate --metadatacopies $mdacp $dev1 $dev2 $dev3 $dev4 $dev5
+	vgcreate -c n --vgmetadatacopies 2 $vg1 $dev1 $dev2 $dev3
+	vgcreate -c n --vgmetadatacopies $(($mdacp * 1)) $vg2 $dev4 $dev5
+	echo vgsplit/vgmerge preserves value of metadata copies
+	check_vg_field_ $vg1 vg_mda_copies 2
+	check_vg_field_ $vg2 vg_mda_copies $(($mdacp * 1))
+	vgsplit $vg1 $vg2 $dev1
+	check_vg_field_ $vg2 vg_mda_copies $(($mdacp * 1))
+	vgmerge $vg1 $vg2
+	check_vg_field_ $vg1 vg_mda_copies 2
+	check_vg_field_ $vg1 vg_mda_count $(($mdacp * 5))
+	echo vgsplit into new vg sets proper value of vgmetadatacopies
+	vgsplit --vgmetadatacopies $(($mdacp * 2)) $vg1 $vg2 $dev1 $dev2
+	check_vg_field_ $vg2 vg_mda_copies $(($mdacp * 2))
+	vgremove -f $vg1
+	vgremove -f $vg2
+done
-- 
1.6.0.6


