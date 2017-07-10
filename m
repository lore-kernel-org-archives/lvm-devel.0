From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:37:40 -0400
Subject: master - tests: simplify and doublequote
Message-ID: <201707101237.v6ACbesh023484@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=85e5a8803cee25aa676d30b478e9a3bd02c7d9ca
Commit:        85e5a8803cee25aa676d30b478e9a3bd02c7d9ca
Parent:        1c9789b0ccabf95aae84d48d41322d8609ad8d51
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jul 8 18:23:07 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: simplify and doublequote

---
 test/shell/system_id.sh |  290 +++++++++++++++++------------------------------
 1 files changed, 102 insertions(+), 188 deletions(-)

diff --git a/test/shell/system_id.sh b/test/shell/system_id.sh
index 9e53a26..b7e61a9 100644
--- a/test/shell/system_id.sh
+++ b/test/shell/system_id.sh
@@ -14,27 +14,30 @@ test_description='Test system_id'
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
+print_lvmlocal() {
+	{ echo "local {"; printf "%s\n" "$@"; echo "}"; } >"$LVMLOCAL"
+}
+
 . lib/inittest
 
 aux prepare_devs 1
 
+SIDFILE="etc/lvm_test.conf"
+LVMLOCAL="etc/lvmlocal.conf"
+
 # with clvm enabled, vgcreate with no -c option creates a clustered vg,
 # which should have no system id
 
 if [ -e LOCAL_CLVMD ]; then
 SID1=sidfoolocal
 SID2=""
-LVMLOCAL=etc/lvmlocal.conf
-rm -f $LVMLOCAL
-echo "local {" > $LVMLOCAL
-echo "  system_id = $SID1" >> $LVMLOCAL
-echo "}" >> $LVMLOCAL
+print_lvmlocal "  system_id = $SID1"
 aux lvmconf "global/system_id_source = lvmlocal"
 vgcreate $vg1 "$dev1"
 vgs -o+systemid $vg1
-check vg_field $vg1 systemid $SID2
+check vg_field $vg1 systemid "$SID2"
 vgremove $vg1
-rm -f $LVMLOCAL
+rm -f "$LVMLOCAL"
 exit 0
 fi
 
@@ -45,74 +48,65 @@ fi
 SID=""
 aux lvmconf "global/system_id_source = none"
 vgcreate $vg1 "$dev1"
-check vg_field $vg1 systemid $SID
+check vg_field $vg1 systemid "$SID"
 vgremove $vg1
 
 # FIXME - print 'life' config data
-eval $(lvmconfig global/etc 2>/dev/null || lvmconfig --type default global/etc)
+eval "$(lvmconfig global/etc 2>/dev/null || lvmconfig --type default global/etc)"
 
 ## machineid
-if [ -e $etc/machine-id ]; then
-SID=$(cat $etc/machine-id)
+if [ -e "$etc/machine-id" ]; then
+SID=$(cat "$etc/machine-id")
 aux lvmconf "global/system_id_source = machineid"
 vgcreate $vg1 "$dev1"
 vgs -o+systemid $vg1
-check vg_field $vg1 systemid $SID
+check vg_field $vg1 systemid "$SID"
 vgremove $vg1
 fi
 
 ## uname
 
 SID1=$(uname -n)
-if [ -n $SID1 ]; then
+if [ -n "$SID1" ]; then
 aux lvmconf "global/system_id_source = uname"
 SID2=$(lvm systemid | awk '{ print $3 }')
 vgcreate $vg1 "$dev1"
 vgs -o+systemid $vg1
-check vg_field $vg1 systemid $SID2
+check vg_field $vg1 systemid "$SID2"
 vgremove $vg1
 fi
 
 ## lvmlocal
 
 SID=sidfoolocal
-LVMLOCAL=etc/lvmlocal.conf
-rm -f $LVMLOCAL
-echo "local {" > $LVMLOCAL
-echo "  system_id = $SID" >> $LVMLOCAL
-echo "}" >> $LVMLOCAL
+print_lvmlocal "  system_id = $SID"
 aux lvmconf "global/system_id_source = lvmlocal"
 vgcreate $vg1 "$dev1"
 vgs -o+systemid $vg1
-check vg_field $vg1 systemid $SID
+check vg_field $vg1 systemid "$SID"
 vgremove $vg1
-rm -f $LVMLOCAL
+rm -f "$LVMLOCAL"
 
 ## file
 
 SID=sidfoofile
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID" > $SIDFILE
+echo "$SID" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 vgcreate $vg1 "$dev1"
 vgs -o+systemid $vg1
-check vg_field $vg1 systemid $SID
+check vg_field $vg1 systemid "$SID"
 vgremove $vg1
-rm -f $SIDFILE
 
 # override system_id to create a foreign vg, then fail to use the vg
 
 SID1=sidfoofile1
 SID2=sidfoofile2
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg, overriding the local system_id so the vg looks foreign
-vgcreate --systemid $SID2 $vg1 "$dev1"
+vgcreate --systemid "$SID2" "$vg1" "$dev1"
 # normal vgs is not an error and does not see the vg
 vgs >err
 not grep $vg1 err
@@ -127,20 +121,17 @@ grep $vg1 err
 vgs --foreign $vg1 >err
 grep $vg1 err
 # change the local system_id to the second value, making the vg not foreign
-echo "$SID2" > $SIDFILE
+echo "$SID2" > "$SIDFILE"
 # we can now see and remove the vg
 vgs $vg1 >err
 grep $vg1 err
 vgremove $vg1
-rm -f $SIDFILE
 
 # create a vg, then change the local system_id, making the vg foreign
 
 SID1=sidfoofile1
 SID2=sidfoofile2
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -149,7 +140,7 @@ vgcreate $vg1 "$dev1"
 vgs >err
 grep $vg1 err
 # change the local system_id, making the vg foreign
-echo "$SID2" > $SIDFILE
+echo "$SID2" > "$SIDFILE"
 # normal vgs doesn't see the vg
 vgs >err
 not grep $vg1 err
@@ -157,19 +148,16 @@ not grep $vg1 err
 vgs --foreign >err
 grep $vg1 err
 # change the local system_id back to the first value, making the vg not foreign
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 vgs >err
 grep $vg1 err
 vgremove $vg1
-rm -f $SIDFILE
 
 # create a vg, then change the vg's system_id, making it foreign
 
 SID1=sidfoofile1
 SID2=sidfoofile2
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -178,7 +166,7 @@ vgcreate $vg1 "$dev1"
 vgs >err
 grep $vg1 err
 # change the vg's system_id, making the vg foreign
-echo "y" | vgchange --systemid $SID2 $vg1
+vgchange --yes --systemid "$SID2" $vg1
 # normal vgs doesn't see the vg
 vgs >err
 not grep $vg1 err
@@ -186,11 +174,10 @@ not grep $vg1 err
 vgs --foreign >err
 grep $vg1 err
 # change the local system_id to the second system_id so we can remove the vg
-echo "$SID2" > $SIDFILE
+echo "$SID2" > "$SIDFILE"
 vgs >err
 grep $vg1 err
 vgremove $vg1
-rm -f $SIDFILE
 
 # create a vg, create active lvs in it, change our system_id, making
 # the VG foreign, verify that we can still see the foreign VG,
@@ -198,9 +185,7 @@ rm -f $SIDFILE
 
 SID1=sidfoofile1
 SID2=sidfoofile2
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -211,7 +196,7 @@ vgs >err
 grep $vg1 err
 check lv_exists $vg1 $lv1
 # change our system_id, making the vg foreign, but accessible
-echo "$SID2" > $SIDFILE
+echo "$SID2" > "$SIDFILE"
 vgs >err
 grep $vg1 err
 check lv_exists $vg1 $lv1
@@ -221,19 +206,16 @@ lvchange -an $vg1/$lv1
 not lvremove $vg1/$lv1
 not vgremove $vg1
 # change our system_id back to match the vg so it's not foreign
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 vgs >err
 grep $vg1 err
 lvremove $vg1/$lv1
 vgremove $vg1
-rm -f $SIDFILE
 
 # local system has no system_id, so it can't access a vg with a system_id
 
 SID1=sidfoofile1
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -247,19 +229,17 @@ aux lvmconf "global/system_id_source = file"
 vgs >err
 grep $vg1 err
 vgremove $vg1
-rm -f $SIDFILE
 
 # local system has a system_id, and can use a vg without a system_id
 
 SID1=sidfoofile1
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
+rm -f "$SIDFILE"
 # create a vg with no system_id
 aux lvmconf "global/system_id_source = none"
 vgcreate $vg1 "$dev1"
 check vg_field $vg1 systemid ""
 # set a local system_id
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # check we can see and use the vg with no system_id
@@ -268,14 +248,11 @@ grep $vg1 err
 vgs $vg1 >err
 grep $vg1 err
 vgremove $vg1
-rm -f $SIDFILE
 
 # vgexport clears system_id, vgimport sets system_id
 
 SID1=sidfoofile1
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -283,26 +260,23 @@ vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
 vgs -o+systemid >err
 grep $vg1 err
-grep $SID1 err
+grep "$SID1" err
 # after vgexport there is no systemid
 vgexport $vg1
 vgs -o+systemid >err
 grep $vg1 err
-not grep $SID1 err
+not grep "$SID1" err
 # after vgimport there is a systemid
 vgimport $vg1
 vgs -o+systemid >err
 grep $vg1 err
-grep $SID1 err
+grep "$SID1" err
 vgremove $vg1
-rm -f $SIDFILE
 
 # vgchange -cy clears system_id, vgchange -cn sets system_id
 
 SID1=sidfoofile1
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -310,33 +284,29 @@ vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
 vgs -o+systemid >err
 grep $vg1 err
-grep $SID1 err
+grep "$SID1" err
 # after vgchange -cy there is no systemid
-echo "y" | vgchange -cy $vg1
+vgchange --yes -cy $vg1
 vgs --config 'global { locking_type=0 }' -o+systemid $vg1 >err
 grep $vg1 err
-not grep $SID1 err
+not grep "$SID1" err
 # after vgchange -cn there is a systemid
 vgchange --config 'global { locking_type=0 }' -cn $vg1
 vgs -o+systemid >err
 grep $vg1 err
-grep $SID1 err
+grep "$SID1" err
 vgremove $vg1
-rm -f $SIDFILE
 
 # Test max system_id length (128) and invalid system_id characters.
 # The 128 length limit is imposed before invalid characters are omitted.
 
-SIDFILE=etc/lvm_test.conf
-
 # 120 numbers followed by 8 letters (max len)
 SID1=012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789abcdefgh
 # 120 numbers followed by 9 letters (too long by 1 character, the last is omitted)
 SID2=012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789abcdefghi
 
 # max len system_id should appear normally
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -344,13 +314,11 @@ vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
 vgs -o+systemid $vg1 >err
 grep $vg1 err
-grep $SID1 err
+grep "$SID1" err
 vgremove $vg1
-rm -f $SIDFILE
 
 # max+1 len system_id should be missing the last character
-rm -f $SIDFILE
-echo "$SID2" > $SIDFILE
+echo "$SID2" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -358,10 +326,9 @@ vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
 vgs -o+systemid $vg1 >err
 grep $vg1 err
-grep $SID1 err
-not grep $SID2 err
+grep "$SID1" err
+not grep "$SID2" err
 vgremove $vg1
-rm -f $SIDFILE
 
 # max len system_id containing an invalid character should appear without
 # the invalid character
@@ -370,8 +337,7 @@ SID1=012345678901234567890123456789012345678901234567890123456789012345678901234
 # After the invalid character is omitted from SID1
 # The string is truncated to max length (128) before the invalid character is omitted
 SID2=012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789abcdefg
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -382,15 +348,12 @@ grep $vg1 err
 not grep $SID1 err
 grep $SID2 err
 vgremove $vg1
-rm -f $SIDFILE
 
 # contains a bunch of invalid characters
 SID1="?%$&A. at 1]"
 # SID1 without the invalid characters
 SID2=A.1
-
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -398,10 +361,9 @@ vgcreate $vg1 "$dev1"
 # normal vgs sees the vg
 vgs -o+systemid $vg1 >err
 grep $vg1 err
-not grep $SID1 err
-grep $SID2 err
+not grep "$SID1" err
+grep "$SID2" err
 vgremove $vg1
-rm -f $SIDFILE
 
 
 # pvs: pv in a foreign vg not reported
@@ -409,9 +371,7 @@ rm -f $SIDFILE
 
 SID1=sidfoofile1
 SID2=sidfoofile2
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -421,7 +381,7 @@ pvs >err
 grep $vg1 err
 grep "$dev1" err
 # change the local system_id, making the vg foreign
-echo "$SID2" > $SIDFILE
+echo "$SID2" > "$SIDFILE"
 # normal pvs does not see the vg or pv
 pvs >err
 not grep $vg1 err
@@ -431,18 +391,16 @@ pvs --foreign >err
 grep $vg1 err
 grep "$dev1" err
 # change the local system_id back so the vg can be removed
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 vgremove $vg1
-rm -f $SIDFILE
+rm -f "$SIDFILE"
 
 # lvs: lvs in a foreign vg not reported
 # lvs --foreign: lvs in a foreign vg are reported
 
 SID1=sidfoofile1
 SID2=sidfoofile2
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -454,7 +412,7 @@ lvs >err
 grep $vg1 err
 grep $lv1 err
 # change the local system_id, making the vg foreign
-echo "$SID2" > $SIDFILE
+echo "$SID2" > "$SIDFILE"
 # normal lvs does not see the vg or lv
 lvs >err
 not grep $vg1 err
@@ -464,20 +422,17 @@ lvs --foreign >err
 grep $vg1 err
 grep $lv1 err
 # change the local system_id back so the vg can be removed
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 lvremove $vg1/$lv1
 vgremove $vg1
-rm -f $SIDFILE
+rm -f "$SIDFILE"
 
 # use extra_system_ids to read a foreign VG
 
 SID1=sidfoofile1
 SID2=sidfoofile2
-SIDFILE=etc/lvm_test.conf
-LVMLOCAL=etc/lvmlocal.conf
-rm -f $LVMLOCAL
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+rm -f "$LVMLOCAL"
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -486,7 +441,7 @@ vgcreate $vg1 "$dev1"
 vgs >err
 grep $vg1 err
 # change the local system_id, making the vg foreign
-echo "$SID2" > $SIDFILE
+echo "$SID2" > "$SIDFILE"
 # normal vgs doesn't see the vg
 vgs >err
 not grep $vg1 err
@@ -494,20 +449,15 @@ not grep $vg1 err
 vgs --foreign >err
 grep $vg1 err
 # add the first system_id to extra_system_ids so we can see the vg
-echo "local {" > $LVMLOCAL
-echo "  extra_system_ids = [ $SID1" ] >> $LVMLOCAL
-echo "}" >> $LVMLOCAL
+print_lvmlocal "  extra_system_ids = [ $SID1 ] "
 vgs >err
 grep $vg1 err
 vgremove $vg1
-rm -f $SIDFILE
-rm -f $LVMLOCAL
+rm -f "$LVMLOCAL"
 
 # vgcreate --systemid "" creates a vg without a system_id even if source is set
 SID1=sidfoofile1
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -517,15 +467,13 @@ vgs >err
 grep $vg1 err
 # our system_id is not displayed for the vg
 vgs -o+systemid >err
-not grep $SID1 err
+not grep "$SID1" err
 vgremove $vg1
-rm -f $SIDFILE
+rm -f "$SIDFILE"
 
 # vgchange --systemid "" clears the system_id on owned vg
 SID1=sidfoofile1
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -543,17 +491,14 @@ vgs >err
 grep $vg1 err
 # the vg does not have our system_id
 vgs -o+systemid >err
-not grep $SID1 err
+not grep "$SID1" err
 vgremove $vg1
-rm -f $SIDFILE
 
 # vgchange --systemid does not set the system_id on foreign vg
 SID1=sidfoofile1
 SID2=sidfoofile2
-SIDFILE=etc/lvm_test.conf
-rm -f $LVMLOCAL
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+rm -f "$LVMLOCAL"
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -562,7 +507,7 @@ vgcreate $vg1 "$dev1"
 vgs >err
 grep $vg1 err
 # change the local system_id, making the vg foreign
-echo "$SID2" > $SIDFILE
+echo "$SID2" > "$SIDFILE"
 # normal vgs doesn't see the vg
 vgs >err
 not grep $vg1 err
@@ -574,17 +519,14 @@ not vgchange --yes --systemid "" $vg1
 # cannot set the system_id of the foreign vg
 not vgchange --yes --systemid foo $vg1
 # change our system_id back so we can remove the vg
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 vgremove $vg1
-rm -f $SIDFILE
 
 # vgcfgbackup backs up foreign vg with --foreign
 SID1=sidfoofile1
 SID2=sidfoofile2
-SIDFILE=etc/lvm_test.conf
-rm -f $LVMLOCAL
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+rm -f "$LVMLOCAL"
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg
@@ -593,7 +535,7 @@ vgcreate $vg1 "$dev1"
 vgs >err
 grep $vg1 err
 # change the local system_id, making the vg foreign
-echo "$SID2" > $SIDFILE
+echo "$SID2" > "$SIDFILE"
 # normal vgs doesn't see the vg
 vgs >err
 not grep $vg1 err
@@ -601,10 +543,9 @@ not grep $vg1 err
 not vgcfgbackup $vg1
 vgcfgbackup --foreign $vg1
 # change our system_id back so we can remove the vg
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 vgremove $vg1
-rm -f $SIDFILE
-
+rm -f "$SIDFILE"
 
 
 # Test handling of bad system_id source configurations
@@ -612,7 +553,7 @@ rm -f $SIDFILE
 # Look at the warning/error messages.
 
 # vgcreate with source machineid, where no $etc/machine-id file exists
-if [ ! -e $etc/machine-id ]; then
+if [ ! -e "$etc/machine-id" ]; then
 SID=""
 aux lvmconf "global/system_id_source = machineid"
 vgcreate $vg1 "$dev1" 2>&1 | tee err
@@ -634,62 +575,48 @@ vgs -o+systemid $vg1
 check vg_field $vg1 systemid $SID
 grep "No system ID found from system_id_source" err
 vgremove $vg1
-rm -f $LVMLOCAL
 
 # vgcreate with source lvmlocal, but no system_id = "x" entry
 SID=""
-LVMLOCAL=etc/lvmlocal.conf
-rm -f $LVMLOCAL
-echo "local {" > $LVMLOCAL
-# echo "  system_id = $SID" >> $LVMLOCAL
-echo "}" >> $LVMLOCAL
+print_lvmlocal   # "  system_id = $SID"
 aux lvmconf "global/system_id_source = lvmlocal"
 vgcreate $vg1 "$dev1" 2>&1 | tee err
 vgs -o+systemid $vg1
 check vg_field $vg1 systemid $SID
 grep "No system ID found from system_id_source" err
 vgremove $vg1
-rm -f $LVMLOCAL
 
 # vgcreate with source lvmlocal, and empty string system_id = ""
 SID=""
-LVMLOCAL=etc/lvmlocal.conf
-rm -f $LVMLOCAL
-echo "local {" > $LVMLOCAL
-echo "  system_id = \"\"" >> $LVMLOCAL
-echo "}" >> $LVMLOCAL
+print_lvmlocal "  system_id = \"\""
 aux lvmconf "global/system_id_source = lvmlocal"
 vgcreate $vg1 "$dev1" 2>&1 | tee err
 vgs -o+systemid $vg1
-check vg_field $vg1 systemid $SID
+check vg_field $vg1 systemid "$SID"
 grep "No system ID found from system_id_source" err
 vgremove $vg1
 rm -f $LVMLOCAL
 
 # vgcreate with source file, but no system_id_file config
 SID=""
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
+rm -f "$SIDFILE"
 aux lvmconf "global/system_id_source = file"
 vgcreate $vg1 "$dev1" 2>&1 | tee err
 vgs -o+systemid $vg1
-check vg_field $vg1 systemid $SID
+check vg_field $vg1 systemid "$SID"
 grep "No system ID found from system_id_source" err
 vgremove $vg1
-rm -f $SIDFILE
 
 # vgcreate with source file, but system_id_file does not exist
 SID=""
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
+rm -f "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 vgcreate $vg1 "$dev1" 2>&1 | tee err
 vgs -o+systemid $vg1
-check vg_field $vg1 systemid $SID
+check vg_field $vg1 systemid "$SID"
 grep "No system ID found from system_id_source" err
 vgremove $vg1
-rm -f $SIDFILE
 
 
 # Test cases where lvmetad cache of a foreign VG are out of date
@@ -702,9 +629,7 @@ test ! -e LOCAL_LVMETAD && exit 0
 # foreign vg by turning off lvmetad when we create an lv in the vg.
 SID1=sidfoofile1
 SID2=sidfoofile2
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg with an lv
@@ -724,7 +649,7 @@ lvs $vg1 >err
 grep $lv1 err
 not grep $lv2 err
 # change our system_id, making the vg foreign
-echo "$SID2" > $SIDFILE
+echo "$SID2" > "$SIDFILE"
 vgs >err
 not grep $vg1 err
 # using --foreign, we will get the latest vg from disk
@@ -733,19 +658,16 @@ grep $vg1 err
 grep $lv1 err
 grep $lv2 err
 # change our system_id back to match the vg so it's not foreign
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 lvremove $vg1/$lv1
 lvremove $vg1/$lv2
 vgremove $vg1
-rm -f $SIDFILE
 
 # vgimport should find the exported vg on disk even though
 # lvmetad's copy of the vg shows it's foreign.
 SID1=sidfoofile1
 SID2=sidfoofile2
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg with an lv
@@ -761,7 +683,7 @@ aux lvmconf 'global/use_lvmetad = 0'
 vgexport $vg1
 aux lvmconf 'global/use_lvmetad = 1'
 # change the local system_id so the lvmetad copy of the vg is foreign
-echo "$SID2" > $SIDFILE
+echo "$SID2" > "$SIDFILE"
 # verify that lvmetad thinks the vg is foreign
 # (don't use --foreign to verify this because that will cause
 # the lvmetad cache to be updated, which we don't want yet)
@@ -776,16 +698,14 @@ grep $SID2 err
 check lv_exists $vg1 $lv1
 lvremove $vg1/$lv1
 vgremove $vg1
-rm -f $SIDFILE
+rm -f "$SIDFILE"
 
 # pvscan --cache should cause the latest version of a foreign VG to be
 # cached in lvmetad.  Without the --cache option, pvscan will see the old
 # version of the VG.
 SID1=sidfoofile1
 SID2=sidfoofile2
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg with an lv
@@ -811,7 +731,7 @@ lvs $vg1 >err
 grep $lv1 err
 not grep $lv2 err
 # change our system_id, making the vg foreign
-echo "$SID2" > $SIDFILE
+echo "$SID2" > "$SIDFILE"
 not vgs $vg1 >err
 not grep $vg1 err
 # use pvscan --cache to update the foreign vg in lvmetad
@@ -821,7 +741,7 @@ not grep $vg1 err
 # change our system_id back to SID1 so we can check that
 # lvmetad has the latest copy of the vg (without having
 # to use --foreign to check)
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 vgs $vg1 >err
 grep $vg1 err
 lvs $vg1 >err
@@ -830,14 +750,11 @@ grep $lv2 err
 lvremove $vg1/$lv1
 lvremove $vg1/$lv2
 vgremove $vg1
-rm -f $SIDFILE
 
 # repeat the same test for vgscan instead of pvscan
 SID1=sidfoofile1
 SID2=sidfoofile2
-SIDFILE=etc/lvm_test.conf
-rm -f $SIDFILE
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 aux lvmconf "global/system_id_source = file" \
 	    "global/system_id_file = \"$SIDFILE\""
 # create a vg with an lv
@@ -863,7 +780,7 @@ lvs $vg1 >err
 grep $lv1 err
 not grep $lv2 err
 # change our system_id, making the vg foreign
-echo "$SID2" > $SIDFILE
+echo "$SID2" > "$SIDFILE"
 not vgs $vg1 >err
 not grep $vg1 err
 # use vgscan --cache to update the foreign vg in lvmetad
@@ -873,7 +790,7 @@ not grep $vg1 err
 # change our system_id back to SID1 so we can check that
 # lvmetad has the latest copy of the vg (without having
 # to use --foreign to check)
-echo "$SID1" > $SIDFILE
+echo "$SID1" > "$SIDFILE"
 vgs $vg1 >err
 grep $vg1 err
 lvs $vg1 >err
@@ -882,6 +799,3 @@ grep $lv2 err
 lvremove $vg1/$lv1
 lvremove $vg1/$lv2
 vgremove $vg1
-rm -f $SIDFILE
-
-


