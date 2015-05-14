From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 14 May 2015 08:53:52 +0000 (UTC)
Subject: master - tests: do not use |&
Message-ID: <20150514085352.42C6D601FA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57a16abe2ce75f65306b70a4dd8e1cd45cbe385d
Commit:        57a16abe2ce75f65306b70a4dd8e1cd45cbe385d
Parent:        1406aba8da1a74cc038ae0a8e71e940341b4b7ba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 14 10:20:24 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 14 10:52:55 2015 +0200

tests: do not use |&

Bash 3.2  doesn't understand this syntax (i.e. RHEL5).
And it's even better - reports syntax error and return success.
---
 test/shell/lvconvert-thin.sh          |    8 ++++----
 test/shell/lvcreate-cache.sh          |    2 +-
 test/shell/lvcreate-usage.sh          |    4 ++--
 test/shell/pv-duplicate-uuid.sh       |    2 +-
 test/shell/snapshot-usage.sh          |    2 +-
 test/shell/system_id.sh               |   12 ++++++------
 test/shell/vgchange-usage.sh          |    6 +++---
 test/shell/vgextend-restoremissing.sh |    2 +-
 8 files changed, 19 insertions(+), 19 deletions(-)

diff --git a/test/shell/lvconvert-thin.sh b/test/shell/lvconvert-thin.sh
index b510589..b833362 100644
--- a/test/shell/lvconvert-thin.sh
+++ b/test/shell/lvconvert-thin.sh
@@ -72,7 +72,7 @@ lvremove -f $vg
 # Swaping of metadata volume
 lvcreate -L1T -n $lv1 $vg
 lvcreate -L32 -n $lv2 $vg
-lvconvert --yes -c 8M --type thin-pool $vg/$lv1 |& tee err
+lvconvert --yes -c 8M --type thin-pool $vg/$lv1 2>&1 | tee err
 # Check tther is warning for large chunk size and zeroing enabled
 grep "Pool zeroing and large" err
 UUID=$(get lv_field $vg/$lv2 uuid)
@@ -109,7 +109,7 @@ invalid lvconvert -c 88 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2
 invalid lvconvert --yes --thinpool $vg/$lv3 -T $vg/$lv3
 
 # Warning about smaller then suggested
-lvconvert --yes -c 256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 |& tee err
+lvconvert --yes -c 256 --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 2>&1 | tee err
 grep "WARNING: Chunk size is smaller" err
 lvremove -f $vg
 
@@ -117,7 +117,7 @@ lvremove -f $vg
 lvcreate -L1T -n $lv1 $vg
 lvcreate -L32G -n $lv2 $vg
 # Warning about bigger then needed
-lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 |& tee err
+lvconvert --yes --thinpool $vg/$lv1 --poolmetadata $vg/$lv2 2>&1 | tee err
 grep "WARNING: Maximum" err
 lvremove -f $vg
 
@@ -125,7 +125,7 @@ lvremove -f $vg
 if test "$TSIZE" = 64T; then
 lvcreate -L24T -n $lv1 $vg
 # Warning about bigger then needed (24T data and 16G -> 128K chunk)
-lvconvert --yes -c 64 --thinpool $vg/$lv1 |& tee err
+lvconvert --yes -c 64 --thinpool $vg/$lv1 2>&1 | tee err
 grep "WARNING: Chunk size is too small" err
 lvremove -f $vg
 fi
diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 9e245c6..aa0ab53 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -51,7 +51,7 @@ fail lvcreate -l 1 -H --name $vg/$lv4 --cachepool pool7
 fail lvcreate -l 1 --cachepool pool8 $vg
 
 # no size specified
-invalid lvcreate --cachepool pool $vg |& tee err
+invalid lvcreate --cachepool pool $vg 2>&1 | tee err
 grep "specify either size or extents" err
 
 # Check nothing has been created yet
diff --git a/test/shell/lvcreate-usage.sh b/test/shell/lvcreate-usage.sh
index 45fa850..d935503 100644
--- a/test/shell/lvcreate-usage.sh
+++ b/test/shell/lvcreate-usage.sh
@@ -125,7 +125,7 @@ lvcreate -aey -L 32m -n $lv --regionsize 4m --type mirror -m 1 $vg
 check lv_field $vg/$lv regionsize "4.00m"
 
 # -m0 is creating non-mirrored segment and give info about redundant option
-lvcreate -m 0 -l1 -n $lv1 $vg |& tee err
+lvcreate -m 0 -l1 -n $lv1 $vg 2>&1 | tee err
 grep "Redundant" err
 check lv_field $vg/$lv1 segtype "linear"
 lvremove -ff $vg
@@ -177,7 +177,7 @@ fail lvcreate --persistent n --minor 234 -l1 $vg
 fail lvcreate --minor 9999999 -l1 $vg
 if aux kernel_at_least 2 4 0; then
 # On >2.4 we ignore --major
-lvcreate --major 234 -l1 $vg |& tee err;
+lvcreate --major 234 -l1 $vg 2>&1 | tee err;
 grep "Ignoring" err
 # Try some bigger possibly unused minor
 if test ! -d /sys/block/dm-2345; then
diff --git a/test/shell/pv-duplicate-uuid.sh b/test/shell/pv-duplicate-uuid.sh
index cc98384..7b8b42e 100644
--- a/test/shell/pv-duplicate-uuid.sh
+++ b/test/shell/pv-duplicate-uuid.sh
@@ -21,7 +21,7 @@ UUID1=$(get pv_field "$dev1" uuid)
 pvcreate --config "devices{filter=[\"a|$dev2|\",\"r|.*|\"]}" -u "$UUID1" --norestorefile "$dev2"
 pvcreate --config "devices{filter=[\"a|$dev3|\",\"r|.*|\"]}" -u "$UUID1" --norestorefile "$dev3"
 
-pvs -o+uuid |& tee out
+pvs -o+uuid 2>&1 | tee out
 COUNT=$(should grep --count "Found duplicate" out)
 
 # FIXME  lvmetad is not able to serve properly this case
diff --git a/test/shell/snapshot-usage.sh b/test/shell/snapshot-usage.sh
index 68396aa..ed9d8cb 100644
--- a/test/shell/snapshot-usage.sh
+++ b/test/shell/snapshot-usage.sh
@@ -70,7 +70,7 @@ vgcreate -s 4M $vg $(cat DEVICES)
 # Play with 1 extent
 lvcreate -aey -l1 -n $lv $vg
 # 100%LV is not supported for snapshot
-fail lvcreate -s -l 100%LV -n snap $vg/$lv |& tee out
+fail lvcreate -s -l 100%LV -n snap $vg/$lv 2>&1 | tee out
 grep 'Please express size as %FREE, %ORIGIN, %PVS or %VG' out
 # 100%ORIGIN needs to have enough space for all data and needs to round-up
 lvcreate -s -l 100%ORIGIN -n $lv1 $vg/$lv
diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 78067e9..3e3fa94 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -612,7 +612,7 @@ rm -f $SIDFILE
 if [ ! -e /etc/machine-id ]; then
 SID=""
 aux lvmconf "global/system_id_source = machineid"
-vgcreate $vg1 "$dev1" |& tee err
+vgcreate $vg1 "$dev1" 2>&1 | tee err
 vgs -o+systemid $vg1
 check vg_field $vg1 systemid $SID
 grep "No system ID found from system_id_source" err
@@ -626,7 +626,7 @@ fi
 SID=""
 rm -f $LVMLOCAL
 aux lvmconf "global/system_id_source = lvmlocal"
-vgcreate $vg1 "$dev1" |& tee err
+vgcreate $vg1 "$dev1" 2>&1 | tee err
 vgs -o+systemid $vg1
 check vg_field $vg1 systemid $SID
 grep "No system ID found from system_id_source" err
@@ -641,7 +641,7 @@ echo "local {" > $LVMLOCAL
 # echo "  system_id = $SID" >> $LVMLOCAL
 echo "}" >> $LVMLOCAL
 aux lvmconf "global/system_id_source = lvmlocal"
-vgcreate $vg1 "$dev1" |& tee err
+vgcreate $vg1 "$dev1" 2>&1 | tee err
 vgs -o+systemid $vg1
 check vg_field $vg1 systemid $SID
 grep "No system ID found from system_id_source" err
@@ -656,7 +656,7 @@ echo "local {" > $LVMLOCAL
 echo "  system_id = \"\"" >> $LVMLOCAL
 echo "}" >> $LVMLOCAL
 aux lvmconf "global/system_id_source = lvmlocal"
-vgcreate $vg1 "$dev1" |& tee err
+vgcreate $vg1 "$dev1" 2>&1 | tee err
 vgs -o+systemid $vg1
 check vg_field $vg1 systemid $SID
 grep "No system ID found from system_id_source" err
@@ -668,7 +668,7 @@ SID=""
 SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 aux lvmconf "global/system_id_source = file"
-vgcreate $vg1 "$dev1" |& tee err
+vgcreate $vg1 "$dev1" 2>&1 | tee err
 vgs -o+systemid $vg1
 check vg_field $vg1 systemid $SID
 grep "No system ID found from system_id_source" err
@@ -681,7 +681,7 @@ SIDFILE=etc/lvm_test.conf
 rm -f $SIDFILE
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
-vgcreate $vg1 "$dev1" |& tee err
+vgcreate $vg1 "$dev1" 2>&1 | tee err
 vgs -o+systemid $vg1
 check vg_field $vg1 systemid $SID
 grep "No system ID found from system_id_source" err
diff --git a/test/shell/vgchange-usage.sh b/test/shell/vgchange-usage.sh
index 7ee42a9..077b447 100644
--- a/test/shell/vgchange-usage.sh
+++ b/test/shell/vgchange-usage.sh
@@ -87,7 +87,7 @@ vgremove -ff $vg
 # set cluster bit
 vgcreate -cn $vg "$dev1" "$dev2" "$dev3"
 # check prompt to change cluster bit without giving explicit vg name
-fail vgchange -cy |& tee out
+fail vgchange -cy 2>&1 | tee out
 grep "y/n" out
 check vg_attr_bit cluster $vg "-"
 
@@ -115,9 +115,9 @@ else
 	# can't switch with active LV
 	vgchange --yes -cy $vg
 	fail vgchange --yes -cy $vg
-	fail vgs $vg |& tee out
+	fail vgs $vg 2>&1 | tee out
 	grep "Skipping clustered volume group" out
-	vgs --ignoreskippedcluster $vg |& tee out
+	vgs --ignoreskippedcluster $vg 2>&1 | tee out
 	not grep "Skipping clustered volume group" out
 	# reset back to non-clustered VG with disabled locking
 	vgchange -cn $vg --config 'global{locking_type=0}' $vg
diff --git a/test/shell/vgextend-restoremissing.sh b/test/shell/vgextend-restoremissing.sh
index 5af5520..d8de96d 100644
--- a/test/shell/vgextend-restoremissing.sh
+++ b/test/shell/vgextend-restoremissing.sh
@@ -21,7 +21,7 @@ lvcreate -l 1 -n lv1 $vg "$dev1"
 # vgextend require vgname
 invalid vgextend
 # --metadatacopies => use --pvmetadatacopies
-invalid vgextend --metadatacopies 3 $vg "$dev1" |& tee out
+invalid vgextend --metadatacopies 3 $vg "$dev1" 2>&1 | tee out
 grep -- "use --pvmetadatacopies" out
 
 # VG name should exist


