From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 16 Mar 2015 14:06:48 +0000 (UTC)
Subject: master - tests: fix select report
Message-ID: <20150316140648.38AC460F91@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=36bcbeadd08adf83740e123a475b4a30f4d4c456
Commit:        36bcbeadd08adf83740e123a475b4a30f4d4c456
Parent:        0e1d1aaca833813fb6cadd16c704c83bb8e94f09
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 16 14:55:58 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 16 15:02:39 2015 +0100

tests: fix select report

Simplify the function usage and clean up parameter parsing.

There were 2 significant changes made in the test itself
(they passed before because of incorrect shell string handling)

-pvs_sel 'tags="pv_tag1"' "$dev1 $dev2"
+sel pv 'tags="pv_tag1"' "$dev1" "$dev6"

-lvs_sel '(lv_name=vol1 || lv_name=vol2) || vg_tags=vg_tag1' "vol1 vol2
abc orig snap"
+sel lv '(lv_name=vol1 || lv_name=vol2) || vg_tags=vg_tag1' vol1 vol2
orig snap xyz
---
 test/shell/select-report.sh |  166 ++++++++++++++++++++-----------------------
 1 files changed, 76 insertions(+), 90 deletions(-)

diff --git a/test/shell/select-report.sh b/test/shell/select-report.sh
index 70e5366..f56aa21 100644
--- a/test/shell/select-report.sh
+++ b/test/shell/select-report.sh
@@ -1,5 +1,5 @@
 #!/bin/sh
-# Copyright (C) 2014 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2014-2015 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -38,22 +38,24 @@ lvcreate -L4m -s "$vg3/orig" -n "snap"
 OUT_LOG_FILE="out"
 ERR_LOG_FILE="err"
 
-function result()
-{
+sel() {
 	local items_found
 
-	test -f $OUT_LOG_FILE || {
+	${1}s --noheadings -o ${1}_name --select "$2" 2>"$ERR_LOG_FILE" | tee "$OUT_LOG_FILE"
+        shift 2
+
+	test -f "$OUT_LOG_FILE" || {
 		echo "  >>> Missing log file to check!"
 		return 1
 	}
 
 	# there shouldn't be any selection syntax error
-	grep "Selection syntax error at" $ERR_LOG_FILE > /dev/null && {
+	grep "Selection syntax error at" "$ERR_LOG_FILE" >/dev/null && {
 		echo "  >>> Selection syntax error hit!"
 		return 1
 	}
 
-	items_found=$(wc -l $OUT_LOG_FILE | cut -f 1 -d " ")
+	items_found=$(wc -l "$OUT_LOG_FILE" | cut -f 1 -d ' ')
 
 	# the number of lines on output must match
 	test $items_found -eq $# || {
@@ -65,87 +67,71 @@ function result()
 	# the names selected must be correct
 	# each pv, vg and lv name is unique so just check
 	# the presence of the names given as arg
-	for name in $1; do
-		grep $name $OUT_LOG_FILE > /dev/null || {
+	for name in "$@" ; do
+		grep "$name" "$OUT_LOG_FILE" >/dev/null || {
 			echo "  >>> $name not found in the output log"
 			return 1
 		}
 	done
 
-	rm -f $OUT_LOG_FILE
-	rm -f $ERR_LOG_FILE
-}
-
-function pvs_sel()
-{
-	pvs 1>$OUT_LOG_FILE 2>$ERR_LOG_FILE --noheadings -o pv_name --select "$1" && result $2
-}
-
-function vgs_sel()
-{
-	vgs &>$OUT_LOG_FILE 2>$ERR_LOG_FILE --noheadings -o vg_name --select "$1" && result $2
-}
-
-function lvs_sel()
-{
-	lvs &>$OUT_LOG_FILE 2>$ERR_LOG_FILE --noheadings -o lv_name --select "$1" && result $2
+	rm -f "$OUT_LOG_FILE" "$ERR_LOG_FILE"
 }
 
 ##########################
 # STRING FIELD SELECTION #
 ##########################
 #$LVS 'lv_name="vol1"' && result vol1
-lvs_sel 'lv_name="vol1"' "vol1"
+sel lv 'lv_name="vol1"' vol1
 #$LVS 'lv_name!="vol1"' && result vol2 abc xyz
-lvs_sel 'lv_name!="vol1"' "vol2 abc xyz orig snap"
+sel lv 'lv_name!="vol1"' vol2 abc xyz orig snap
 # check string values are accepted without quotes too
-lvs_sel 'lv_name=vol1' "vol1"
+sel lv 'lv_name=vol1' vol1
 # check single quotes are also accepted instead of double quotes
-lvs_sel "lv_name='vol1'" "vol1"
+sel lv "lv_name='vol1'" vol1
 
 ###############################
 # STRING LIST FIELD SELECTION #
 ###############################
-pvs_sel 'tags=["pv_tag1"]' ""
+sel pv 'tags=["pv_tag1"]'
 # for one item, no need to use []
-pvs_sel 'tags="pv_tag1"' "$dev1 $dev2"
+sel pv 'tags="pv_tag1"' "$dev1" "$dev6"
 # no match
-pvs_sel 'tags=["pv_tag1" && "pv_tag2"]'
-pvs_sel 'tags=["pv_tag1" && "pv_tag2" && "pv_tag3"]' "$dev1"
+sel pv 'tags=["pv_tag1" && "pv_tag2"]'
+sel pv 'tags=["pv_tag1" && "pv_tag2" && "pv_tag3"]' "$dev1"
 # check the order has no effect on selection result
-pvs_sel 'tags=["pv_tag3" && "pv_tag2" && "pv_tag1"]' "$dev1"
-pvs_sel 'tags=["pv_tag4" || "pv_tag3"]' "$dev1 $dev6"
-pvs_sel 'tags!=["pv_tag1"]' "$dev1 $dev2 $dev3 $dev4 $dev5 $dev6"
+sel pv 'tags=["pv_tag3" && "pv_tag2" && "pv_tag1"]' "$dev1"
+sel pv 'tags=["pv_tag4" || "pv_tag3"]' "$dev1" "$dev6"
+sel pv 'tags!=["pv_tag1"]' "$dev1" "$dev2" "$dev3" "$dev4" "$dev5" "$dev6"
 # check mixture of && and || - this is not allowed
-not pvs_sel 'tags=["pv_tag1" && "pv_tag2" || "pv_tag3"]'
+not sel pv 'tags=["pv_tag1" && "pv_tag2" || "pv_tag3"]'
 
 ##########################
 # NUMBER FIELD SELECTION #
 ##########################
-vgs_sel 'pv_count=3' "$vg1"
-vgs_sel 'pv_count!=3' "$vg3 $vg2"
-vgs_sel 'pv_count<2' "$vg3"
-vgs_sel 'pv_count<=2' "$vg3 $vg2"
-vgs_sel 'pv_count>2' "$vg1"
-vgs_sel 'pv_count>=2' "$vg1 $vg2"
+sel vg 'pv_count=3' $vg1
+sel vg 'pv_count!=3' $vg3 $vg2
+sel vg 'pv_count<2' $vg3
+sel vg 'pv_count<=2' $vg3 $vg2
+sel vg 'pv_count>2' $vg1
+sel vg 'pv_count>=2' $vg1 $vg2
 
 ########################
 # SIZE FIELD SELECTION #
 ########################
 # check size units are accepted as well as floating point numbers for sizes
-lvs_sel 'size=8388608b' "vol1"
-lvs_sel 'size=8192k' "vol1"
-lvs_sel 'size=8m' "vol1"
-lvs_sel 'size=8.00m' "vol1"
-lvs_sel 'size=0.0078125g' "vol1"
-lvs_sel 'size=0.00000762939453125t' "vol1"
-lvs_sel 'size=0.000000007450580596923828125p' "vol1"
-lvs_sel 'size=0.0000000000072759576141834259033203125e' "vol1"
-
-lvs_sel 'size>8m' "abc"
-lvs_sel 'size>=8m' "abc vol1"
-lvs_sel 'size<8m' "vol2 xyz orig snap"
-lvs_sel 'size<=8m' "vol2 xyz vol1 orig snap"
+sel lv 'size=8388608b' vol1
+sel lv 'size=8192k' vol1
+sel lv 'size=8m' vol1
+sel lv 'size=8.00m' vol1
+sel lv 'size=0.0078125g' vol1
+sel lv 'size=0.00000762939453125t' vol1
+sel lv 'size=0.000000007450580596923828125p' vol1
+sel lv 'size=0.0000000000072759576141834259033203125e' vol1
+
+sel lv 'size>8m' abc
+sel lv 'size>=8m' abc vol1
+sel lv 'size<8m' vol2 xyz orig snap
+sel lv 'size<=8m' vol2 xyz vol1 orig snap
 
 ###########################
 # PERCENT FIELD SELECTION #
@@ -153,69 +139,69 @@ lvs_sel 'size<=8m' "vol2 xyz vol1 orig snap"
 if aux target_at_least dm-snapshot 1 10 0; then
 	# Test zero percent only if snapshot can be zero.
 	# Before 1.10.0, the snap percent included metadata size.
-	lvs_sel 'snap_percent=0' "snap"
+	sel lv 'snap_percent=0' snap
 fi
-dd if=/dev/zero of=$DM_DEV_DIR/$vg3/snap bs=1M count=1
-lvs_sel 'snap_percent<50' "snap"
-lvs_sel 'snap_percent>50'
-dd if=/dev/zero of=$DM_DEV_DIR/$vg3/snap bs=1M count=4
-lvs_sel 'snap_percent=100' "snap"
+dd if=/dev/zero of="$DM_DEV_DIR/$vg3/snap" bs=1M count=1
+sel lv 'snap_percent<50' snap
+sel lv 'snap_percent>50'
+dd if=/dev/zero of="$DM_DEV_DIR/$vg3/snap" bs=1M count=4
+sel lv 'snap_percent=100' snap
 # % char is accepted as suffix for percent values
-lvs_sel 'snap_percent=100%' "snap"
+sel lv 'snap_percent=100%' snap
 # percent values over 100% are not accepted
-not lvs_sel 'snap_percent=101%'
+not sel lv 'snap_percent=101%'
 
 #########################
 # REGEX FIELD SELECTION #
 #########################
-lvs_sel 'lv_name=~"^vol[12]"' "vol1 vol2"
-lvs_sel 'lv_name!~"^vol[12]"' "abc xyz orig snap"
+sel lv 'lv_name=~"^vol[12]"' vol1 vol2
+sel lv 'lv_name!~"^vol[12]"' abc xyz orig snap
 # check regex is accepted without quotes too
-lvs_sel 'lv_name=~^vol[12]' "vol1 vol2"
+sel lv 'lv_name=~^vol[12]' vol1 vol2
 
 ###########
 # GENERIC #
 ###########
 # check prefix works for selection too
-lvs_sel 'lv_name="vol1"' "vol1"
-lvs_sel 'name="vol1"' "vol1"
+sel lv 'lv_name="vol1"' vol1
+sel lv 'name="vol1"' vol1
 
 # check reserved values are accepted for certain fields as well as usual values
-vgs_sel 'vg_mda_copies=unmanaged' "$vg2 $vg3"
-vgs_sel 'vg_mda_copies=2' "$vg1"
+sel vg 'vg_mda_copies=unmanaged' $vg2 $vg3
+sel vg 'vg_mda_copies=2' $vg1
 # also, we must match only vg1, not including vg2 and vg3
 # when comparing ranges - unamanged is mapped onto 2^64 - 1 internally,
 # so we need to skip this internal value if it matches with selection criteria!
-vgs_sel 'vg_mda_copies>=2' "$vg1"
-not vgs_sel 'vg_mda_copies=18446744073709551615'
+sel vg 'vg_mda_copies>=2' $vg1
+not sel vg 'vg_mda_copies=18446744073709551615'
 
-lvs_sel 'lv_read_ahead=auto' "vol1 vol2 orig snap"
-lvs_sel 'lv_read_ahead=256k' "abc xyz"
+sel lv 'lv_read_ahead=auto' vol1 vol2 orig snap
+sel lv 'lv_read_ahead=256k' abc xyz
 
-lvs_sel 'lv_minor=-1' "vol1 vol2 abc orig snap"
-lvs_sel 'lv_minor=undefined' "vol1 vol2 abc orig snap"
-lvs_sel 'lv_minor=undef' "vol1 vol2 abc orig snap"
-lvs_sel 'lv_minor=unknown' "vol1 vol2 abc orig snap"
-lvs_sel 'lv_minor=254' "xyz"
+sel lv 'lv_minor=-1' vol1 vol2 abc orig snap
+sel lv 'lv_minor=undefined' vol1 vol2 abc orig snap
+sel lv 'lv_minor=undef' vol1 vol2 abc orig snap
+sel lv 'lv_minor=unknown' vol1 vol2 abc orig snap
+sel lv 'lv_minor=254' xyz
 
 # if size unit not spefied, the 'm' (MiB) unit is used by default
-lvs_sel 'lv_size=8' "vol1"
+sel lv 'lv_size=8' vol1
 
 # no need to use quotes for the whole selection string if it does not clash with shell
-lvs_sel name=vol1 vol1
+sel lv name=vol1 vol1
 
 ##########################################
 # FORMING MORE COMPLEX SELECTION CLAUSES #
 ##########################################
 # AND clause
-lvs_sel 'lv_tags=lv_tag1 && lv_size=4m' "vol2"
+sel lv 'lv_tags=lv_tag1 && lv_size=4m' vol2
 # OR clause
-lvs_sel 'lv_name=vol1 || lv_name=vol2' "vol1 vol2"
+sel lv 'lv_name=vol1 || lv_name=vol2' vol1 vol2
 # grouping by using ( )
-lvs_sel '(lv_name=vol1 || lv_name=vol2) || vg_tags=vg_tag1' "vol1 vol2 abc orig snap"
-lvs_sel '(lv_name=vol1 && lv_size=100m) || vg_tags=vg_tag1' "xyz orig snap"
-lvs_sel '(lv_name=vol1 || lv_name=vol2) && vg_tags=vg_tag1'
-lvs_sel '(lv_name=vol1 || lv_name=vol2) && lv_size < 8m' "vol2"
-lvs_sel '(lv_name=vol1 && lv_size=8m) && vg_tags=vg_tag2' "vol1"
+sel lv '(lv_name=vol1 || lv_name=vol2) || vg_tags=vg_tag1' vol1 vol2 orig snap xyz
+sel lv '(lv_name=vol1 && lv_size=100m) || vg_tags=vg_tag1' xyz orig snap
+sel lv '(lv_name=vol1 || lv_name=vol2) && vg_tags=vg_tag1'
+sel lv '(lv_name=vol1 || lv_name=vol2) && lv_size < 8m' vol2
+sel lv '(lv_name=vol1 && lv_size=8m) && vg_tags=vg_tag2' vol1
 # negation of clause grouped by ( )
-lvs_sel '!(lv_name=vol1 || lv_name=vol2)' "abc xyz orig snap"
+sel lv '!(lv_name=vol1 || lv_name=vol2)' abc xyz orig snap


