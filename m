From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:01:01 +0000 (UTC)
Subject: master - test: process-each-duplicate-pvs
Message-ID: <20160506140101.1A14F60722@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=708eca39eac23af1a4a889de40d69151168d18f1
Commit:        708eca39eac23af1a4a889de40d69151168d18f1
Parent:        e84fb639f03b018b7b6f09778f863c50a7f9e045
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 20 16:45:53 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:00:00 2016 -0500

test: process-each-duplicate-pvs

Update for new duplicate processing.
---
 test/shell/process-each-duplicate-pvs.sh |  590 ++++++++++++++++++++++++------
 1 files changed, 476 insertions(+), 114 deletions(-)

diff --git a/test/shell/process-each-duplicate-pvs.sh b/test/shell/process-each-duplicate-pvs.sh
index 47e1043..41d844d 100644
--- a/test/shell/process-each-duplicate-pvs.sh
+++ b/test/shell/process-each-duplicate-pvs.sh
@@ -9,130 +9,492 @@ test_description='Test duplicate PVs'
 
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
+SKIP_WITH_CLVMD=1
 
 . lib/inittest
 
-aux prepare_devs 2
+aux prepare_devs 6 16
+
+aux lvmconf 'devices/allow_changes_with_duplicate_pvs = 0'
 
 pvcreate "$dev1"
+pvcreate "$dev2"
 vgcreate $vg1 "$dev1"
+vgcreate $vg2 "$dev2"
+pvresize --setphysicalvolumesize 8m "$dev2"
+lvcreate -an -l1 -n $lv1 $vg1
+
+# Both devs are shown and used by the VG
+
+pvs 2>&1 | tee out
+
+grep "$dev1" out
+grep "$dev2" out
+grep "$dev1" out | grep $vg1
+grep "$dev2" out | grep $vg2
+check pv_field "$dev1" pv_allocatable "allocatable"
+check pv_field "$dev2" pv_allocatable "allocatable"
+not grep WARNING out
+
+UUID1=$(pvs --noheadings -o uuid $dev1 | xargs)
+UUID2=$(pvs --noheadings -o uuid $dev2 | xargs)
+
+SIZE1=$(pvs --noheadings -o dev_size $dev1)
+SIZE2=$(pvs --noheadings -o dev_size $dev2)
+
+MINOR1=$(pvs --noheadings -o minor $dev1)
+MINOR2=$(pvs --noheadings -o minor $dev2)
+
+check pv_field "$dev1" dev_size $SIZE1
+check pv_field "$dev2" dev_size $SIZE2
+
+# Copy dev1 over dev2.
+dd if="$dev1" of="$dev2" bs=1M iflag=direct oflag=direct,sync
+pvscan --cache
+
+# The single preferred dev is shown from 'pvs'.
+pvs -o+uuid,duplicate 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+# Don't know yet if dev1 or dev2 is preferred, so count just one is.
+test $(grep $vg1 main | wc -l) -eq 1
+test $(grep $UUID1 main | wc -l) -eq 1
+not grep duplicate main
+not grep $vg2 main
+not grep $UUID2 main
+
+grep "was already found on" warn
+grep "prefers device" warn
+
+# Find which is the preferred dev and which is the duplicate.
+PV=$(pvs --noheadings -o name -S uuid=$UUID1)
+if [ $PV == "$dev1" ]; then
+	DUP=$dev2
+else
+	DUP=$dev1
+fi
+
+echo PV is $PV
+echo DUP is $DUP
+
+grep $PV main
+not grep $DUP main
+
+# Repeat above checking preferred/dup in output
+pvs 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+grep $PV main
+not grep $DUP main
+
+# The duplicate dev is included in 'pvs -a'
+pvs -a -o+uuid,duplicate 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+grep "$dev1" main
+grep "$dev2" main
+grep $PV main
+grep $DUP main
+test $(grep duplicate main | wc -l) -eq 1
+grep $DUP main | grep duplicate
+not grep $vg2 main
+not grep $UUID2 main
+grep "$dev1" main | grep $vg1
+grep "$dev2" main | grep $vg1
+grep "$dev1" main | grep $UUID1
+grep "$dev2" main | grep $UUID1
+
+grep "was already found on" warn
+grep "prefers device" warn
+
+#
+# Passing a dev name arg always includes that dev.
+#
+
+pvs -o+uuid "$dev1" 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+grep "$dev1" main
+not grep "$dev2" main
+grep $UUID1 main
+grep $vg1 main
+grep "was already found on" warn
+grep "prefers device" warn
+
+pvs -o+uuid "$dev2" 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+grep "$dev2" main
+not grep "$dev1" main
+grep $UUID1 main
+grep $vg1 main
+grep "was already found on" warn
+grep "prefers device" warn
 
-# Clone the PV
-dd if="$dev1" of="$dev2" bs=256K count=1 iflag=direct oflag=direct
-aux notify_lvmetad "$dev2"
+pvs -o+uuid,duplicate "$dev1" "$dev2" 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+grep "$dev1" main
+grep "$dev2" main
+grep "$dev1" main | grep $vg1
+grep "$dev2" main | grep $vg1
+grep "$dev1" main | grep $UUID1
+grep "$dev2" main | grep $UUID1
+test $(grep duplicate main | wc -l) -eq 1
+grep $DUP main | grep duplicate
 
-# When there are cloned devices (same pvid), one will be referenced in
-# lvmcache as pv->dev, and the other will not be referenced from lvmcache,
-# it'll only be in device cache.  The one referenced by lvmcache is
-# referred to as the "preferred" one, and is the one that is printed by a
-# standard 'pvs' command.
 #
-# We don't know if dev1 or dev2 will be preferred, so we first check that
-# and save it as PV1, the other as PV2.
+# Test specific report fields for each dev.
 #
-# The rules that 'pvs' follows to choose which PVs to display are
-# somewhat strange and seem arbitrary from a user perspective;
-# the choice is driven largely by what's most practical in the code,
-# but also by what vgimportclone needs.
+
+pvs --noheadings -o vg_name,vg_uuid "$dev1" 2>&1 | tee out1
+pvs --noheadings -o vg_name,vg_uuid "$dev2" 2>&1 | tee out2
+
+grep -v WARNING out1 > main1 || true
+grep -v WARNING out2 > main2 || true
+diff main1 main2
+rm out1 out2 main1 main2 || true
+
+check pv_field "$dev1" pv_in_use "used"
+check pv_field "$dev2" pv_in_use "used"
+
+check pv_field $PV  pv_allocatable "allocatable"
+check pv_field $DUP pv_allocatable ""
+
+check pv_field $PV  pv_duplicate ""
+check pv_field $DUP pv_duplicate "duplicate"
+
+pvs --noheadings -o name,pv_allocatable "$dev1" "$dev2" 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+grep $PV main
+grep $DUP main
+grep $dev1 main
+grep $dev2 main
+test $(grep allocatable main | wc -l) -eq 1
+
+pvs --noheadings -o name,pv_duplicate "$dev1" "$dev2" 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+grep $PV main
+grep $DUP main
+grep $dev1 main
+grep $dev2 main
+test $(grep duplicate main | wc -l) -eq 1
+
 #
-# Some of the rules that process_each_pv is using:
-# - When no pv arg is specified, print the one preferred dev.
-# - When pv args are specified, print one line per specified arg,
-#   i.e. don't print all duplicate pvs when one is specified.
-# - Always print the preferred duplicate, even if it was not the
-#   one specified, e.g. If there are two duplicates on A and B,
-#   and A is the preferred device, then 'pvs A' will show A and
-#   'pvs B' will show A.
-# - If multiple duplicates are specified, then print each, e.g.
-#   'pvs A B' will show both A and B.
-# - If three duplicates exist on A, B, C, and the preferred is A,
-#   and the command 'pvs B C' is run, then the A will be printed
-#   first since we always print the preferred device, and then
-#   either B or C will be printed.  'pvs A B C' will print all.
-# - 'pvs -a' should print all the duplicates and should show
-#   the same VG for each.
-# - 'pvs -o+size ...' should show the correct size of the
-#   devices being printed if they differ among the duplicates.
-# - By using 'pvs --config' with a filter, you can filter out
-#   the duplicate devs you don't want so that pvs will
-#   print the devs you do want to see.
+# A filter can be used to show only one.
 #
-# The tests below check these behaviors on up to two duplicates,
-# so if the process_each_pv logic changes regarding which
-# duplicates are chosen, then this test will need adjusting.
-
-# Verify that there is only one PV printed, i.e. the preferred
-pvs --noheading | tee out
-test $(wc -l < out) -eq 1
-
-# Set PV1 to the perferred/cached PV, and PV2 to the other.
-# Cannot use pvs -o pv_name because that command goes to
-# disk and does not represent what lvmetad thinks.
-PV1=$(pvs --noheading | awk '{ print $1 }')
-echo PV1 is $PV1
-if [ $PV1 == $dev1 ]; then
-	PV2=$dev2
-else
-	PV2=$dev1
-fi
-echo PV2 is $PV2
-
-# check listed pvs
-pvs --noheading | tee out
-grep $PV1 out
-not grep $PV2 out
-
-# check error messages
-pvs --noheading 2>&1 | tee out
-grep "Found duplicate" out >err
-grep "using $PV1 not $PV2" err
-
-# check listed pvs
-pvs --noheading "$dev1" | tee out
-grep $PV1 out
-not grep $PV2 out
-
-# check error messages
-pvs --noheading "$dev1" 2>&1 | tee out
-grep "Found duplicate" out >err
-grep "using $PV1 not $PV2" err
-
-# check listed pvs
-pvs --noheading "$dev2" | tee out
-grep $PV1 out
-not grep $PV2 out
-
-# check error messages
-pvs --noheading "$dev2" 2>&1 | tee out
-grep "Found duplicate" out >err
-grep "using $PV1 not $PV2" err
-
-# check listed pvs
-pvs --noheading "$dev1" "$dev2" | tee out
-grep $PV1 out
-grep $PV2 out
-
-# check error messages
-pvs --noheading "$dev1" "$dev2" 2>&1 | tee out
-grep "Found duplicate" out >err
-grep "using $PV1 not $PV2" err
-
-# check listed pvs
-pvs --noheading -a | tee out
-grep $PV1 out
-grep $PV2 out
-grep $PV1 out | grep $vg1
-grep $PV2 out | grep $vg1
-
-# check error messages
-pvs --noheading -a 2>&1 | tee out
-grep "Found duplicate" out >err
-grep "using $PV1 not $PV2" err
-
-
-# TODO: I'd like to test that a subsystem device is preferred
-# over a non-subsystem device, but all the devices used here
-# are DM devices, i.e. they are already subsystem devices,
-# so I can't just wrap a standard block device with a DM
-# identity mapping.
+
+pvs --config "devices { filter=[ \"a|$dev2|\", \"r|.*|\" ] }" 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+not grep $dev1 main
+grep $dev2 main
+
+not grep "was already found on" warn
+not grep "prefers device" warn
+
+
+pvs --config "devices { filter=[ \"a|$dev1|\", \"r|.*|\"] }" 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+grep $dev1 main
+not grep $dev2 main
+
+not grep "was already found on" warn
+not grep "prefers device" warn
+
+# PV size and minor is still reported correctly for each.
+
+check pv_field "$dev1" dev_size $SIZE1
+check pv_field "$dev2" dev_size $SIZE2
+
+check pv_field "$dev1" minor $MINOR1
+check pv_field "$dev2" minor $MINOR2
+
+# With allow_changes_with_duplicate_pvs=0, a VG with duplicate devs
+# cannot be modified or activated.
+
+not lvcreate -an -l1 -n $lv2 $vg1
+not lvremove $vg1/$lv1
+not lvchange -ay $vg1/$lv1
+not vgremove $vg1
+
+
+# With allow_changes_with_duplicate_pvs=1, changes above are permitted.
+
+aux lvmconf 'devices/allow_changes_with_duplicate_pvs = 1'
+
+lvcreate -an -l1 -n $lv2 $vg1
+lvremove $vg1/$lv1
+lvchange -ay $vg1/$lv2
+lvchange -an $vg1/$lv2
+lvremove $vg1/$lv2
+vgremove -f $vg1
+pvremove -ff -y "$dev1"
+pvremove -ff -y "$dev2"
+
+
+# dev3 and dev4 are copies, orphans
+
+pvcreate "$dev3"
+pvcreate "$dev4"
+pvresize --setphysicalvolumesize 8m "$dev4"
+
+UUID3=$(pvs --noheadings -o uuid $dev3 | xargs)
+UUID4=$(pvs --noheadings -o uuid $dev4 | xargs)
+
+SIZE3=$(pvs --noheadings -o dev_size $dev3)
+SIZE4=$(pvs --noheadings -o dev_size $dev4)
+
+check pv_field "$dev3" dev_size $SIZE3
+check pv_field "$dev4" dev_size $SIZE4
+
+pvs 2>&1 | tee out
+
+grep "$dev3" out
+grep "$dev4" out
+
+dd if="$dev3" of="$dev4" bs=1M iflag=direct oflag=direct,sync
+pvscan --cache
+
+# One appears with 'pvs'
+
+pvs -o+uuid 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+test $(grep $UUID3 main | wc -l) -eq 1
+not grep $UUID4 main
+
+grep "was already found on" warn
+grep "prefers device" warn
+
+# Both appear with 'pvs -a'
+
+pvs -a -o+uuid 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+test $(grep $UUID3 main | wc -l) -eq 2
+
+grep "$dev3" main
+grep "$dev4" main
+
+grep $UUID3 main
+not grep $UUID4 main
+
+grep "was already found on" warn
+grep "prefers device" warn
+
+# Show each dev individually and both together
+
+pvs -o+uuid "$dev3" 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+grep "$dev3" main
+not grep "$dev4" main
+
+grep "was already found on" warn
+grep "prefers device" warn
+
+pvs -o+uuid "$dev4" 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+not grep "$dev3" main
+grep "$dev4" main
+
+grep "was already found on" warn
+grep "prefers device" warn
+
+pvs -o+uuid "$dev3" "$dev4" 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+grep "$dev3" main
+grep "$dev4" main
+
+grep "was already found on" warn
+grep "prefers device" warn
+
+# Same sizes shown.
+
+check pv_field "$dev3" dev_size $SIZE3
+check pv_field "$dev4" dev_size $SIZE4
+
+# Verify that devs being used by an active LV are
+# preferred over duplicates that are not used by an LV.
+
+dd if=/dev/zero of="$dev3" bs=1M oflag=direct,sync || true
+dd if=/dev/zero of="$dev4" bs=1M oflag=direct,sync || true
+pvscan --cache
+
+vgcreate $vg2 $dev3 $dev4
+lvcreate -l1 -n $lv1 $vg2 "$dev3"
+lvcreate -l1 -n $lv2 $vg2 "$dev4"
+
+dd if="$dev3" of="$dev5" bs=1M iflag=direct oflag=direct,sync
+dd if="$dev4" of="$dev6" bs=1M iflag=direct oflag=direct,sync
+pvscan --cache
+
+pvs -o+uuid,duplicate 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+grep "$dev3" main
+grep "$dev4" main
+not grep duplicate main
+check pv_field "$dev3" pv_duplicate ""
+check pv_field "$dev4" pv_duplicate ""
+check pv_field "$dev5" pv_duplicate "duplicate"
+check pv_field "$dev6" pv_duplicate "duplicate"
+
+grep "prefers device $dev3" warn
+grep "prefers device $dev4" warn
+not grep "prefers device $dev5" warn
+not grep "prefers device $dev6" warn
+
+pvs -a -o+uuid,duplicate 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+test $(grep duplicate main | wc -l) -eq 2
+grep "$dev3" main
+grep "$dev4" main
+grep "$dev5" main
+grep "$dev6" main
+
+grep "prefers device $dev3" warn
+grep "prefers device $dev4" warn
+not grep "prefers device $dev5" warn
+not grep "prefers device $dev6" warn
+
+pvs -o+uuid,duplicate "$dev3" "$dev4" "$dev5" "$dev6" 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+test $(grep duplicate main | wc -l) -eq 2
+grep "$dev3" main
+grep "$dev4" main
+grep "$dev5" main
+grep "$dev6" main
+
+grep "prefers device $dev3" warn
+grep "prefers device $dev4" warn
+not grep "prefers device $dev5" warn
+not grep "prefers device $dev6" warn
+
+
+dd if=/dev/zero of="$dev5" bs=1M oflag=direct,sync || true
+dd if=/dev/zero of="$dev6" bs=1M oflag=direct,sync || true
+pvscan --cache
+
+lvremove -y $vg2/$lv1
+lvremove -y $vg2/$lv2
+vgremove $vg2
+pvremove -ff -y "$dev3"
+pvremove -ff -y "$dev4"
+
+dd if=/dev/zero of="$dev3" bs=1M oflag=direct,sync || true
+dd if=/dev/zero of="$dev4" bs=1M oflag=direct,sync || true
+pvscan --cache
+
+# Reverse devs in the previous in case dev3/dev4 would be
+# preferred even without an active LV using them.
+
+vgcreate $vg2 "$dev5" "$dev6"
+lvcreate -l1 -n $lv1 $vg2 "$dev5"
+lvcreate -l1 -n $lv2 $vg2 "$dev6"
+
+dd if="$dev5" of="$dev3" bs=1M iflag=direct oflag=direct,sync
+dd if="$dev6" of="$dev4" bs=1M iflag=direct oflag=direct,sync
+pvscan --cache
+
+pvs -o+uuid,duplicate 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+grep "$dev5" main
+grep "$dev6" main
+not grep duplicate main
+check pv_field "$dev5" pv_duplicate ""
+check pv_field "$dev6" pv_duplicate ""
+check pv_field "$dev3" pv_duplicate "duplicate"
+check pv_field "$dev4" pv_duplicate "duplicate"
+
+pvs -a -o+uuid,duplicate 2>&1 | tee out
+
+rm warn main || true
+grep    WARNING out > warn || true
+grep -v WARNING out > main || true
+
+test $(grep duplicate main | wc -l) -eq 2
+grep "$dev3" main
+grep "$dev4" main
+grep "$dev5" main
+grep "$dev6" main
+
+grep "prefers device $dev5" warn
+grep "prefers device $dev6" warn
+not grep "prefers device $dev3" warn
+not grep "prefers device $dev4" warn
+
+dd if=/dev/zero of="$dev3" bs=1M oflag=direct,sync || true
+dd if=/dev/zero of="$dev4" bs=1M oflag=direct,sync || true
+pvscan --cache
+
+lvremove -y $vg2/$lv1
+lvremove -y $vg2/$lv2
+vgremove $vg2
 


