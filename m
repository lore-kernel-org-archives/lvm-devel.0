From: David Teigland <teigland@sourceware.org>
Date: Thu, 31 May 2018 16:37:57 -0400
Subject: master - tests: enable metadata-balance with lvmlockd
Message-ID: <201805312037.w4VKbvRc027301@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4a01e4f3895a947c0c693d0336643a1287de6df5
Commit:        4a01e4f3895a947c0c693d0336643a1287de6df5
Parent:        08771bbbbf20298df0440dd8ca75ca10af60eb2f
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 31 15:12:34 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu May 31 15:12:34 2018 -0500

tests: enable metadata-balance with lvmlockd

---
 test/shell/metadata-balance.sh |   49 ++++++++++++++++++++++------------------
 1 files changed, 27 insertions(+), 22 deletions(-)

diff --git a/test/shell/metadata-balance.sh b/test/shell/metadata-balance.sh
index fe94aed..5f856a1 100644
--- a/test/shell/metadata-balance.sh
+++ b/test/shell/metadata-balance.sh
@@ -10,7 +10,6 @@
 # along with this program; if not, write to the Free Software Foundation,
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
-SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
@@ -23,7 +22,7 @@ for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp "$dev1" "$dev2"
         pvcreate --metadatacopies 0 "$dev3"
 	if [ $pv_in_vg = 1 ]; then
-		vgcreate $vg "$dev1" "$dev2" "$dev3"
+		vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 	fi
 	pvchange --metadataignore y "$dev1"
 	check pv_field "$dev1" pv_mda_count $mdacp
@@ -64,7 +63,7 @@ pvunignore_ () {
 	fi
 }
 
-echo Test of vgmetadatacopies with vgcreate and vgchange
+echo Test of vgmetadatacopies with vgcreate $SHARED and vgchange
 for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev4" "$dev5"
 	check pv_field "$dev1" pv_mda_used_count $mdacp
@@ -72,7 +71,7 @@ for mdacp in 1 2; do
 	check pv_field "$dev4" pv_mda_used_count $mdacp
 	check pv_field "$dev5" pv_mda_used_count $mdacp
 	pvcreate --metadatacopies 0 "$dev3"
-	vgcreate $vg "$dev1" "$dev2" "$dev3"
+	vgcreate $SHARED $vg "$dev1" "$dev2" "$dev3"
 	check vg_field $vg vg_mda_copies unmanaged
 	echo ensure both --vgmetadatacopies and --metadatacopies accepted
 	vgchange --metadatacopies $(( mdacp * 1 )) $vg
@@ -91,34 +90,34 @@ for mdacp in 1 2; do
 	vgchange --vgmetadatacopies unmanaged $vg
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
-	echo vgcreate succeeds even when creating a VG w/all ignored mdas
+	echo vgcreate $SHARED succeeds even when creating a VG w/all ignored mdas
 	pvchange --metadataignore y "$dev1" "$dev2"
 	check pv_field "$dev1" pv_mda_count $mdacp
 	check pv_field "$dev2" pv_mda_used_count 0
-	vgcreate $vg "$dev1" "$dev2"
+	vgcreate $SHARED $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
-	echo vgcreate succeeds with a specific number of metadata copies
-	vgcreate --vgmetadatacopies $(( mdacp * 2 )) $vg "$dev1" "$dev2"
+	echo vgcreate $SHARED succeeds with a specific number of metadata copies
+	vgcreate $SHARED --vgmetadatacopies $(( mdacp * 2 )) $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies $(( mdacp * 2 ))
 	vgremove -f $vg
-	vgcreate --vgmetadatacopies $(( mdacp * 1 )) $vg "$dev1" "$dev2"
+	vgcreate $SHARED --vgmetadatacopies $(( mdacp * 1 )) $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies $(( mdacp * 1 ))
 	vgremove -f $vg
-	echo vgcreate succeeds with a larger value than total metadatacopies
-	vgcreate --vgmetadatacopies $(( mdacp * 5 )) $vg "$dev1" "$dev2"
+	echo vgcreate $SHARED succeeds with a larger value than total metadatacopies
+	vgcreate $SHARED --vgmetadatacopies $(( mdacp * 5 )) $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies $(( mdacp * 5 ))
 	vgremove -f $vg
-	echo vgcreate succeeds with --vgmetadatacopies unmanaged
-	vgcreate --vgmetadatacopies unmanaged $vg "$dev1" "$dev2"
+	echo vgcreate $SHARED succeeds with --vgmetadatacopies unmanaged
+	vgcreate $SHARED --vgmetadatacopies unmanaged $vg "$dev1" "$dev2"
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
 	pvunignore_ "$dev1"
 	pvunignore_ "$dev2"
 	pvunignore_ "$dev4"
 	pvunignore_ "$dev5"
-	echo vgcreate succeds with small value of --metadatacopies, ignores mdas
-	vgcreate --vgmetadatacopies 1 $vg "$dev1" "$dev2" "$dev4" "$dev5"
+	echo vgcreate $SHARED succeds with small value of --metadatacopies, ignores mdas
+	vgcreate $SHARED --vgmetadatacopies 1 $vg "$dev1" "$dev2" "$dev4" "$dev5"
 	check vg_field $vg vg_mda_copies 1
 	check vg_field $vg vg_mda_count $(( mdacp * 4 ))
 	check vg_field $vg vg_mda_used_count 1
@@ -131,11 +130,11 @@ for mdacp in 1 2; do
 	check vg_field $vg vg_mda_count $(( mdacp * 4 ))
 	check vg_field $vg vg_mda_copies unmanaged
 	check vg_field $vg vg_mda_used_count $(( mdacp * 4 ))
-	echo --vgmetadatacopies 0 should be unmanaged for vgchange and vgcreate
+	echo --vgmetadatacopies 0 should be unmanaged for vgchange and vgcreate $SHARED
 	vgchange --vgmetadatacopies 0 $vg
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
-	vgcreate --vgmetadatacopies 0 $vg "$dev1" "$dev2" "$dev4" "$dev5"
+	vgcreate $SHARED --vgmetadatacopies 0 $vg "$dev1" "$dev2" "$dev4" "$dev5"
 	check vg_field $vg vg_mda_copies unmanaged
 	vgremove -f $vg
 done
@@ -145,7 +144,7 @@ for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev4" "$dev5"
 	pvcreate --metadatacopies 0 "$dev3"
 	echo Set a large value of vgmetadatacopies
-	vgcreate --vgmetadatacopies $(( mdacp * 5 )) $vg "$dev1" "$dev2" "$dev3"
+	vgcreate $SHARED --vgmetadatacopies $(( mdacp * 5 )) $vg "$dev1" "$dev2" "$dev3"
 	check vg_field $vg vg_mda_copies $(( mdacp * 5 ))
 	echo Ignore mdas on devices to be used for vgextend
 	echo Large value of vgetadatacopies should automatically un-ignore mdas
@@ -156,7 +155,7 @@ for mdacp in 1 2; do
 	check pv_field "$dev5" pv_mda_used_count $mdacp
 	vgremove -f $vg
 	echo Set a small value of vgmetadatacopies
-	vgcreate --vgmetadatacopies $(( mdacp * 1 )) $vg "$dev1" "$dev2" "$dev3"
+	vgcreate $SHARED --vgmetadatacopies $(( mdacp * 1 )) $vg "$dev1" "$dev2" "$dev3"
 	check vg_field $vg vg_mda_copies $(( mdacp * 1 ))
 	echo Ignore mdas on devices to be used for vgextend
 	echo Small value of vgetadatacopies should leave mdas as ignored
@@ -186,11 +185,15 @@ for mdacp in 1 2; do
 	vgremove -f $vg
 done
 
+if test -n "$LVM_TEST_LVMLOCKD"; then
+echo skip vgsplit and vgmerge with lvmlockd
+else
+
 echo Test special situations, vgsplit, vgmerge, etc
 for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-	vgcreate --vgmetadatacopies 2 $vg1 "$dev1" "$dev2" "$dev3"
-	vgcreate --vgmetadatacopies $(( mdacp * 1 )) $vg2 "$dev4" "$dev5"
+	vgcreate $SHARED --vgmetadatacopies 2 $vg1 "$dev1" "$dev2" "$dev3"
+	vgcreate $SHARED --vgmetadatacopies $(( mdacp * 1 )) $vg2 "$dev4" "$dev5"
 	echo vgsplit/vgmerge preserves value of metadata copies
 	check vg_field $vg1 vg_mda_copies 2
 	check vg_field $vg2 vg_mda_copies $(( mdacp * 1 ))
@@ -207,10 +210,12 @@ for mdacp in 1 2; do
 	vgremove -f $vg1 $vg2
 done
 
+fi
+
 echo Test combination of --vgmetadatacopies and pvchange --metadataignore
 for mdacp in 1 2; do
 	pvcreate --metadatacopies $mdacp "$dev1" "$dev2" "$dev3" "$dev4" "$dev5"
-	vgcreate --vgmetadatacopies $(( mdacp * 1 )) $vg1 "$dev1" "$dev2"
+	vgcreate $SHARED --vgmetadatacopies $(( mdacp * 1 )) $vg1 "$dev1" "$dev2"
 	check vg_field $vg1 vg_mda_copies $(( mdacp * 1 ))
 	check vg_field $vg1 vg_mda_used_count $(( mdacp * 1 ))
 	pvignore_ "$dev3"


