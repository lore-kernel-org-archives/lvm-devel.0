From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Nov 2018 07:18:37 -0500
Subject: master - tests: speed-up testing full of lvm2 metadata
Message-ID: <201811191218.wAJCIbf8012505@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=54de0d829b0e07ee48e92d68b428dfed8d6d7bf1
Commit:        54de0d829b0e07ee48e92d68b428dfed8d6d7bf1
Parent:        a53024cafccf1fd0eee02a63336247923dd72ce1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 19 13:15:05 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 19 13:16:03 2018 +0100

tests: speed-up testing full of lvm2 metadata

Generate faster full metadata condition.

FIXME: vgremove is extremaly slow with larger set of LVs.
---
 test/shell/metadata-full.sh |   69 ++++++++++++++++++++++++++++++++----------
 1 files changed, 52 insertions(+), 17 deletions(-)

diff --git a/test/shell/metadata-full.sh b/test/shell/metadata-full.sh
index 388ebcd..eb617ee 100644
--- a/test/shell/metadata-full.sh
+++ b/test/shell/metadata-full.sh
@@ -16,21 +16,22 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+# this test needs lot of memory
+test "$(aux total_mem)" -gt 524288 || skip
+
 LVM_TEST_PVS=${LVM_TEST_PVS:-64}
 
 # aux prepare_vg $LVM_TEST_PVS
 
 unset LVM_LOG_FILE_MAX_LINES
 
-aux prepare_devs 64
+aux prepare_devs 64 1000
 get_devs
 
 vgcreate $SHARED -s 512K --metadatacopies 8 $vg "${DEVICES[@]}"
 
-# have tested to see how many LVs can be created in a
-# vg set up like this and it's around 1190, so pick a
-# number less than that but over 1024 (in case there's
-# some issue at the number 1024 we want to find it.)
+
+# Create a large metadata set, that getting close to 1/2MiB in size
 #
 # uses long tags to increase the size of the metadata
 # more quickly
@@ -40,15 +41,46 @@ vgcreate $SHARED -s 512K --metadatacopies 8 $vg "${DEVICES[@]}"
 # based on how much metadata it produces at the time this
 # is written.
 
+vgcfgbackup -f data $vg
+TEST_DEVS=930
+# Generate a lot of LV devices (size of 1 extent)
+awk -v TEST_DEVS=$TEST_DEVS '/^\t\}/ {
+    printf("\t}\n\tlogical_volumes {\n");
+    cnt=0;
+    for (i = 0; i < TEST_DEVS; i++) {
+	printf("\t\tlvol%d  {\n", i);
+	printf("\t\t\tid = \"%06d-1111-2222-3333-2222-1111-%06d\"\n", i, i);
+	print "\t\t\tstatus = [\"READ\", \"WRITE\", \"VISIBLE\"]";
+        print "\t\t\ttags = [\"A123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789\"]";
+	print "\t\t\tsegment_count = 1";
+	print "\t\t\tsegment1 {";
+	print "\t\t\t\tstart_extent = 0";
+	print "\t\t\t\textent_count = 1";
+	print "\t\t\t\ttype = \"striped\"";
+	print "\t\t\t\tstripe_count = 1";
+	print "\t\t\t\tstripes = [";
+	print "\t\t\t\t\t\"pv0\", " cnt++;
+	printf("\t\t\t\t]\n\t\t\t}\n\t\t}\n");
+      }
+  }
+  {print}
+' data >data_new
+# Restoring big data set of LVs
+vgcfgrestore -f data_new $vg
 
-for i in `seq 1 1050`; do lvcreate -l1 -an --addtag A123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789 $vg; done
 
 # should show non-zero
 vgs -o+pv_mda_free
 
 # these addtag's will fail at some point when metadata space is full
 
-for i in `seq 1 1050`; do lvchange --addtag B123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789 $vg/lvol$i || true; done
+for i in $(seq 1 "$TEST_DEVS"); do
+	lvchange --addtag B123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789 $vg/lvol$i || break;
+done
+
+# test we hit 'out-of-metadata-space'
+test "$i" -gt 5
+test "$i" -lt "$TEST_DEVS"
 
 # should show 0
 vgs -o+pv_mda_free
@@ -57,14 +89,18 @@ check vg_field $vg vg_mda_free 0
 # remove some of the tags to check that we can reduce the size of the
 # metadata, and continue using the vg
 
-for i in `seq 1 50`; do lvchange --deltag B123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789 $vg/lvol$i || true; done
+for j in $(seq 1 "$i"); do
+	lvchange --deltag B123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789 $vg/lvol$j;
+done
 
 # should show non-zero
 vgs -o+pv_mda_free
 
 # these will fail at some point when metadata space is full again
 
-for i in `seq 1 50`; do lvcreate -l1 -an --addtag C123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789 $vg || true; done
+for i in $(seq 1 50); do
+	lvcreate -l1 -an --addtag C123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789 $vg || break;
+done
 
 # should show 0
 vgs -o+pv_mda_free
@@ -76,21 +112,20 @@ check vg_field $vg vg_mda_free 0
 
 time vgs
 
-vgchange -ay $vg
-
-time vgs
-
-vgchange -an $vg
+# Avoid activation of large set of volumes - this is tested in  vgchange-many.sh
+#vgchange -ay $vg
+#vgchange -an $vg
 
 # see if we can remove LVs to make more metadata space,
 # and then create more LVs
 
-for i in `seq 1 50`; do lvremove -y $vg/lvol$i; done
+for i in $(seq 1 30); do lvremove -y $vg/lvol$i; done
 
-for i in `seq 1 10`; do lvcreate -l1 $vg; done
+for i in $(seq 1 10); do lvcreate -l1 $vg; done
 
 # should show non-zero
 vgs -o+pv_mda_free
 
+# FIXME:
+#    takes extreme amount of time, despite the fact, there are only few LVs active.
 vgremove -ff $vg
-


