From: okozina <okozina@fedoraproject.org>
Date: Mon, 13 Apr 2015 18:54:02 +0000 (UTC)
Subject: master - tests: [new] check pvmove resume works as expected
Message-ID: <20150413185402.C1BDF606D9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=96124c6c0b866bc4d135074a7947e1a0911dd86f
Commit:        96124c6c0b866bc4d135074a7947e1a0911dd86f
Parent:        fe30658a4d5fe4e4e6bb346c9c9ee7142a98f49d
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Fri Apr 3 10:41:33 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Mon Apr 13 20:53:18 2015 +0200

tests: [new] check pvmove resume works as expected

various methods of resuming interrupted pvmove are tested:
- pvmove
- pvmove -b
- lvchange
- vgchange

tests for commits:
- c26d81d6e6939906729d91fae83cd8bbdd743bb7
- fe30658a4d5fe4e4e6bb346c9c9ee7142a98f49d
---
 test/lib/aux.sh                      |   20 +++
 test/shell/pvmove-abort-all.sh       |    8 +-
 test/shell/pvmove-abort.sh           |    8 +-
 test/shell/pvmove-basic.sh           |    4 +-
 test/shell/pvmove-resume-1.sh        |  227 ++++++++++++++++++++++++++++++++++
 test/shell/pvmove-resume-2.sh        |  186 ++++++++++++++++++++++++++++
 test/shell/pvmove-resume-multiseg.sh |  210 +++++++++++++++++++++++++++++++
 7 files changed, 658 insertions(+), 5 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 1b97bdc..bccc30c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -229,9 +229,29 @@ kill_sleep_kill_() {
 	fi
 }
 
+# $1 cmd line
+# $2 optional parms for pgrep
+add_to_kill_list() {
+	local p=$(pgrep $2 -f "$1" 2>/dev/null)
+	test -z $p || echo $p:$1 >> kill_list
+}
+
+kill_remaining_processes() {
+	local line
+	while read line; do
+		local pid=$(echo $line | awk -F':' '{ print $1 }')
+		local cmd=$(echo $line | awk -F':' '{ print $2 }')
+		for tmp in $(pgrep -f "$cmd" -d ' '); do
+			test $tmp = $pid && kill -9 $tmp
+		done
+	done
+}
+
 teardown() {
 	echo -n "## teardown..."
 
+	test -f kill_list && kill_remaining_processes < kill_list
+
 	kill_sleep_kill_ LOCAL_LVMETAD ${LVM_VALGRIND_LVMETAD:-0}
 
 	dm_table | not egrep -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
diff --git a/test/shell/pvmove-abort-all.sh b/test/shell/pvmove-abort-all.sh
index afdd3c8..0fd9659 100644
--- a/test/shell/pvmove-abort-all.sh
+++ b/test/shell/pvmove-abort-all.sh
@@ -37,9 +37,11 @@ lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
 lvcreate -an -Zn -l30 -n $lv1 $vg1 "$dev4"
 lvextend -l+30 -n $vg1/$lv1 "$dev5"
 
-pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode &
+cmd1=$(echo pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode)
+$cmd1 &
 aux wait_pvmove_lv_ready "$vg-pvmove0"
-pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode &
+cmd2=$(echo pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode)
+$cmd2 &
 aux wait_pvmove_lv_ready "$vg-pvmove1"
 
 pvmove -i1 $backgroundarg -n $vg1/$lv1 "$dev4" "$dev6" $mode &
@@ -57,6 +59,8 @@ not grep "^\[pvmove" out
 lvremove -ff $vg $vg1
 
 wait
+aux add_to_kill_list "$cmd1" "-P 1"
+aux add_to_kill_list "$cmd2" "-P 1"
 done
 done
 
diff --git a/test/shell/pvmove-abort.sh b/test/shell/pvmove-abort.sh
index 3664deb..da98a34 100644
--- a/test/shell/pvmove-abort.sh
+++ b/test/shell/pvmove-abort.sh
@@ -31,9 +31,11 @@ do
 lvcreate -an -Zn -l30 -n $lv1 $vg "$dev1"
 lvcreate -an -Zn -l30 -n $lv2 $vg "$dev2"
 
-pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode &
+cmd1=$(echo pvmove -i1 $backgroundarg "$dev1" "$dev3" $mode)
+$cmd1 &
 aux wait_pvmove_lv_ready "$vg-pvmove0"
-pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode &
+cmd2=$(echo pvmove -i1 $backgroundarg "$dev2" "$dev3" $mode)
+$cmd2 &
 aux wait_pvmove_lv_ready "$vg-pvmove1"
 
 # remove specific device
@@ -50,6 +52,8 @@ pvmove --abort
 lvremove -ff $vg
 
 wait
+aux add_to_kill_list "$cmd1" "-P 1"
+aux add_to_kill_list "$cmd2" "-P 1"
 done
 done
 
diff --git a/test/shell/pvmove-basic.sh b/test/shell/pvmove-basic.sh
index 1b9b63f..e93a04e 100644
--- a/test/shell/pvmove-basic.sh
+++ b/test/shell/pvmove-basic.sh
@@ -334,7 +334,9 @@ check_and_cleanup_lvs_
 
 #COMM "pvmove abort"
 restore_lvs_
-pvmove $mode -i100 -b "$dev1" "$dev3"
+cmd=$(echo -n pvmove $mode -i100 -b "$dev1" "$dev3")
+$cmd
+aux add_to_kill_list "$cmd" "-P 1"
 pvmove --abort
 check_and_cleanup_lvs_
 
diff --git a/test/shell/pvmove-resume-1.sh b/test/shell/pvmove-resume-1.sh
new file mode 100644
index 0000000..0731c48
--- /dev/null
+++ b/test/shell/pvmove-resume-1.sh
@@ -0,0 +1,227 @@
+#!/bin/sh
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Check whether all available pvmove resume methods works as expected.
+# lvchange is able to resume pvmoves in progress.
+
+# 2 pvmove LVs in 2 VGs (1 per VG)
+
+. lib/inittest
+
+aux prepare_pvs 4 30
+
+vgcreate -s 128k $vg "$dev1"
+vgcreate -s 128k $vg1 "$dev2"
+pvcreate --metadatacopies 0 "$dev3"
+pvcreate --metadatacopies 0 "$dev4"
+vgextend $vg "$dev3"
+vgextend $vg1 "$dev4"
+
+# $1 resume fn
+test_pvmove_resume() {
+	lvcreate -an -Zn -l30 -n $lv1 $vg
+	lvcreate -an -Zn -l30 -n $lv1 $vg1
+
+	aux delay_dev "$dev3" 0 1000 $(get first_extent_sector "$dev3"):
+	aux delay_dev "$dev4" 0 1000 $(get first_extent_sector "$dev4"):
+
+	pvmove -i5 "$dev1" &
+	PVMOVE=$!
+	aux wait_pvmove_lv_ready "$vg-pvmove0" 300
+	kill -9 $PVMOVE
+
+	pvmove -i5 "$dev2" &
+	PVMOVE=$!
+	aux wait_pvmove_lv_ready "$vg1-pvmove0" 300
+	kill -9 $PVMOVE
+
+	if test -e LOCAL_LVMPOLLD ; then
+		# inforestart lvmpolld
+		kill $(< LOCAL_LVMPOLLD)
+		for i in $(seq 1 100) ; do
+			test $i -eq 100 && die "Shutdown of lvmpolld is too slow."
+			test -e "$LVM_LVMPOLLD_PIDFILE" || break
+			sleep .1
+		done # wait for the pid removal
+		aux prepare_lvmpolld
+	fi
+
+	wait
+
+	while dmsetup status "$vg-$lv1"; do dmsetup remove "$vg-$lv1" || true; done
+	while dmsetup status "$vg1-$lv1"; do dmsetup remove "$vg1-$lv1" || true; done
+	while dmsetup status "$vg-pvmove0"; do dmsetup remove "$vg-pvmove0" || true; done
+	while dmsetup status "$vg1-pvmove0"; do dmsetup remove "$vg1-pvmove0" || true; done
+
+	check lv_attr_bit type $vg/pvmove0 "p"
+	check lv_attr_bit type $vg1/pvmove0 "p"
+
+	if test -e LOCAL_CLVMD ; then
+		# giveup all clvmd locks (faster then restarting clvmd)
+		# no deactivation happen, nodes are already removed
+		#vgchange -an $vg
+		# FIXME: However above solution has one big problem
+		# as clvmd starts to abort on internal errors on various
+		# errors, based on the fact pvmove is killed -9
+		# Restart clvmd
+		kill $(< LOCAL_CLVMD)
+		for i in $(seq 1 100) ; do
+			test $i -eq 100 && die "Shutdown of clvmd is too slow."
+			test -e "$CLVMD_PIDFILE" || break
+			sleep .1
+		done # wait for the pid removal
+		aux prepare_clvmd
+	fi
+
+	if test -e LOCAL_LVMETAD ; then
+		# Restart lvmetad
+		kill $(< LOCAL_LVMETAD)
+		aux prepare_lvmetad
+	fi
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# call resume function (see below)
+	# with expected number of spawned
+	# bg polling as parameter
+	$1 2
+
+	aux enable_dev "$dev3"
+	aux enable_dev "$dev4"
+
+	i=0
+	while get lv_field $vg name -a | grep "^\[pvmove"; do
+		# wait for 30 secs at max
+		test $i -ge 300 && die "Pvmove is too slow or does not progress."
+		sleep .1
+		i=$((i + 1))
+	done
+	while get lv_field $vg1 name -a | grep "^\[pvmove"; do
+		# wait for 30 secs at max
+		test $i -ge 300 && die "Pvmove is too slow or does not progress."
+		sleep .1
+		i=$((i + 1))
+	done
+
+	lvremove -ff $vg $vg1
+}
+
+lvchange_single() {
+	lvchange -aey $vg/$lv1
+	lvchange -aey $vg1/$lv1
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq $1
+}
+
+lvchange_all() {
+	lvchange -aey $vg/$lv1 $vg1/$lv1
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq $1
+}
+
+vgchange_single() {
+	vgchange -aey $vg
+	vgchange -aey $vg1
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq $1
+}
+
+vgchange_all()  {
+	vgchange -aey $vg $vg1
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq $1
+}
+
+pvmove_fg() {
+	# pvmove resume requires LVs active
+	vgchange -aey --poll n $vg $vg1
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# vgchange must not spawn (thus finish) background polling
+	get lv_field $vg name -a | grep "^\[pvmove0\]"
+	get lv_field $vg1 name -a | grep "^\[pvmove0\]"
+
+	# disable delay device
+	# fg pvmove would take ages to complete otherwise
+	aux enable_dev "$dev3"
+	aux enable_dev "$dev4"
+
+	pvmove -i0
+}
+
+pvmove_bg() {
+	# pvmove resume requires LVs active
+	vgchange -aey --poll n $vg $vg1
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# vgchange must not spawn (thus finish) background polling
+	get lv_field $vg name -a | grep "^\[pvmove0\]"
+	get lv_field $vg1 name -a | grep "^\[pvmove0\]"
+
+	pvmove -b -i0
+}
+
+pvmove_fg_single() {
+	# pvmove resume requires LVs active
+	vgchange -aey --poll n $vg
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# vgchange must not spawn (thus finish) background polling
+	get lv_field $vg name -a | grep "^\[pvmove0\]"
+	get lv_field $vg1 name -a | grep "^\[pvmove0\]"
+
+	# disable delay device
+	# fg pvmove would take ages to complete otherwise
+	aux enable_dev "$dev3"
+	aux enable_dev "$dev4"
+
+	pvmove -i0 "$dev1"
+	pvmove -i0 "$dev2"
+}
+
+pvmove_bg_single() {
+	# pvmove resume requires LVs active
+	vgchange -aey --poll n $vg
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# vgchange must not spawn (thus finish) background polling
+	get lv_field $vg name -a | grep "^\[pvmove0\]"
+	get lv_field $vg1 name -a | grep "^\[pvmove0\]"
+
+	pvmove -i0 -b "$dev1"
+	pvmove -i0 -b "$dev2"
+}
+
+test -e LOCAL_CLVMD && skip
+
+test_pvmove_resume lvchange_single
+test_pvmove_resume lvchange_all
+test_pvmove_resume vgchange_single
+test_pvmove_resume vgchange_all
+test_pvmove_resume pvmove_fg
+test_pvmove_resume pvmove_fg_single
+test_pvmove_resume pvmove_bg
+test_pvmove_resume pvmove_bg_single
+
+vgremove -ff $vg $vg1
diff --git a/test/shell/pvmove-resume-2.sh b/test/shell/pvmove-resume-2.sh
new file mode 100644
index 0000000..0b938f8
--- /dev/null
+++ b/test/shell/pvmove-resume-2.sh
@@ -0,0 +1,186 @@
+#!/bin/sh
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Check whether all available pvmove resume methods works as expected.
+# lvchange is able to resume pvmoves in progress.
+
+# Moving 2 LVs in VG variant
+
+. lib/inittest
+
+aux prepare_pvs 9 30
+
+vgcreate -s 128k $vg "$dev1"
+pvcreate --metadatacopies 0 "$dev2"
+vgextend $vg "$dev2"
+
+test_pvmove_resume() {
+	# 2 LVs on same device
+	lvcreate -an -Zn -l15 -n $lv1 $vg "$dev1"
+	lvcreate -an -Zn -l15 -n $lv2 $vg "$dev1"
+
+	aux delay_dev "$dev2" 0 1000 $(get first_extent_sector "$dev2"):
+
+	pvmove -i5 "$dev1" &
+	PVMOVE=$!
+	aux wait_pvmove_lv_ready "$vg-pvmove0" 300
+	kill -9 $PVMOVE
+
+	if test -e LOCAL_LVMPOLLD ; then
+		# inforestart lvmpolld
+		kill $(< LOCAL_LVMPOLLD)
+		for i in $(seq 1 100) ; do
+			test $i -eq 100 && die "Shutdown of lvmpolld is too slow."
+			test -e "$LVM_LVMPOLLD_PIDFILE" || break
+			sleep .1
+		done # wait for the pid removal
+		aux prepare_lvmpolld
+	fi
+
+	wait
+
+	while dmsetup status "$vg-$lv1"; do dmsetup remove "$vg-$lv1" || true; done
+	while dmsetup status "$vg-$lv2"; do dmsetup remove "$vg-$lv2" || true; done
+	while dmsetup status "$vg-pvmove0"; do dmsetup remove "$vg-pvmove0" || true; done
+
+	check lv_attr_bit type $vg/pvmove0 "p"
+
+	if test -e LOCAL_CLVMD ; then
+		# giveup all clvmd locks (faster then restarting clvmd)
+		# no deactivation happen, nodes are already removed
+		#vgchange -an $vg
+		# FIXME: However above solution has one big problem
+		# as clvmd starts to abort on internal errors on various
+		# errors, based on the fact pvmove is killed -9
+		# Restart clvmd
+		kill $(< LOCAL_CLVMD)
+		for i in $(seq 1 100) ; do
+			test $i -eq 100 && die "Shutdown of clvmd is too slow."
+			test -e "$CLVMD_PIDFILE" || break
+			sleep .1
+		done # wait for the pid removal
+		aux prepare_clvmd
+	fi
+
+	if test -e LOCAL_LVMETAD ; then
+		# Restart lvmetad
+		kill $(< LOCAL_LVMETAD)
+		aux prepare_lvmetad
+	fi
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# call resume function (see below)
+	# with expected number of spawned
+	# bg polling as parameter
+	$1 1
+
+	aux enable_dev "$dev2"
+
+	i=0
+	while get lv_field $vg name -a | grep "^\[pvmove"; do
+		# wait for 30 secs at max
+		test $i -ge 300 && die "Pvmove is too slow or does not progress."
+		sleep .1
+		i=$((i + 1))
+	done
+
+	lvremove -ff $vg
+}
+
+lvchange_single() {
+	lvchange -aey $vg/$lv1
+	lvchange -aey $vg/$lv2
+}
+
+lvchange_all() {
+	lvchange -aey $vg/$lv1 $vg/$lv2
+
+	# we don't want to spawn more than $1 background pollings
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq $1 || should false
+}
+
+vgchange_single() {
+	vgchange -aey $vg
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq $1
+}
+
+pvmove_fg() {
+	# pvmove resume requires LVs active
+	vgchange -aey --poll n $vg
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# vgchange must not spawn (thus finish) background polling
+	get lv_field $vg name -a | grep "^\[pvmove0\]"
+
+	aux enable_dev "$dev2"
+
+	pvmove -i0
+}
+
+pvmove_bg() {
+	# pvmove resume requires LVs active
+	vgchange -aey --poll n $vg
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# vgchange must not spawn (thus finish) background polling
+	get lv_field $vg name -a | grep "^\[pvmove0\]"
+
+	pvmove -b -i0
+}
+
+pvmove_fg_single() {
+	# pvmove resume requires LVs active
+	vgchange -aey --poll n $vg
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# vgchange must not spawn (thus finish) background polling
+	get lv_field $vg name -a | grep "^\[pvmove0\]"
+
+	aux enable_dev "$dev2"
+
+	pvmove -i0 "$dev1"
+}
+
+pvmove_bg_single() {
+	# pvmove resume requires LVs active
+	vgchange -aey --poll n $vg
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# vgchange must not spawn (thus finish) background polling
+	get lv_field $vg name -a | grep "^\[pvmove0\]"
+
+	pvmove -i0 -b "$dev1"
+}
+
+test -e LOCAL_CLVMD && skip
+
+test_pvmove_resume lvchange_single
+test_pvmove_resume lvchange_all
+test_pvmove_resume vgchange_single
+test_pvmove_resume pvmove_fg
+test_pvmove_resume pvmove_fg_single
+test_pvmove_resume pvmove_bg
+test_pvmove_resume pvmove_bg_single
+
+vgremove -ff $vg
diff --git a/test/shell/pvmove-resume-multiseg.sh b/test/shell/pvmove-resume-multiseg.sh
new file mode 100644
index 0000000..829178c
--- /dev/null
+++ b/test/shell/pvmove-resume-multiseg.sh
@@ -0,0 +1,210 @@
+#!/bin/sh
+# Copyright (C) 2015 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# Check whether all available pvmove resume methods works as expected.
+# lvchange is able to resume pvmoves in progress.
+
+# Multisegment variant w/ 2 pvmoves LVs per VG
+
+. lib/inittest
+
+aux prepare_pvs 5 30
+
+vgcreate -s 128k $vg "$dev1" "$dev2" "$dev3"
+pvcreate --metadatacopies 0 "$dev4" "$dev5"
+vgextend $vg "$dev4" "$dev5"
+
+# $1 resume fn
+test_pvmove_resume() {
+	# Create multisegment LV
+	lvcreate -an -Zn -l30 -n $lv1 $vg "$dev1"
+	lvextend -l+30 $vg/$lv1 "$dev2"
+	# next LV on same VG and differetnt PV (we want to test 2 pvmoves per VG)
+	lvcreate -an -Zn -l30 -n $lv2 $vg "$dev3"
+
+	aux delay_dev "$dev4" 0 250
+	aux delay_dev "$dev5" 0 250
+
+	pvmove -i5 "$dev1" "$dev4" &
+	PVMOVE=$!
+	aux wait_pvmove_lv_ready "$vg-pvmove0" 300
+	kill -9 $PVMOVE
+
+	pvmove -i5 -n $vg/$lv2 "$dev3" "$dev5" &
+	PVMOVE=$!
+	aux wait_pvmove_lv_ready "$vg-pvmove1" 300
+	kill -9 $PVMOVE
+
+	if test -e LOCAL_LVMPOLLD ; then
+		# inforestart lvmpolld
+		kill $(< LOCAL_LVMPOLLD)
+		for i in $(seq 1 100) ; do
+			test $i -eq 100 && die "Shutdown of lvmpolld is too slow."
+			test -e "$LVM_LVMPOLLD_PIDFILE" || break
+			sleep .1
+		done # wait for the pid removal
+		aux prepare_lvmpolld
+	fi
+
+	wait
+
+	while dmsetup status "$vg-$lv1"; do dmsetup remove "$vg-$lv1" || true; done
+	while dmsetup status "$vg-$lv2"; do dmsetup remove "$vg-$lv2" || true; done
+	while dmsetup status "$vg-pvmove0"; do dmsetup remove "$vg-pvmove0" || true; done
+	while dmsetup status "$vg-pvmove1"; do dmsetup remove "$vg-pvmove1" || true; done
+
+	check lv_attr_bit type $vg/pvmove0 "p"
+	check lv_attr_bit type $vg/pvmove1 "p"
+
+	if test -e LOCAL_CLVMD ; then
+		# giveup all clvmd locks (faster then restarting clvmd)
+		# no deactivation happen, nodes are already removed
+		#vgchange -an $vg
+		# FIXME: However above solution has one big problem
+		# as clvmd starts to abort on internal errors on various
+		# errors, based on the fact pvmove is killed -9
+		# Restart clvmd
+		kill $(< LOCAL_CLVMD)
+		for i in $(seq 1 100) ; do
+			test $i -eq 100 && die "Shutdown of clvmd is too slow."
+			test -e "$CLVMD_PIDFILE" || break
+			sleep .1
+		done # wait for the pid removal
+		aux prepare_clvmd
+	fi
+
+	if test -e LOCAL_LVMETAD ; then
+		# Restart lvmetad
+		kill $(< LOCAL_LVMETAD)
+		aux prepare_lvmetad
+	fi
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# call resume function (see below)
+	# with expected number of spawned
+	# bg polling as parameter
+	$1 2
+
+	aux enable_dev "$dev4"
+	aux enable_dev "$dev5"
+
+	i=0
+	while get lv_field $vg name -a | grep "^\[pvmove"; do
+		# wait for 30 secs@max
+		test $i -ge 300 && die "Pvmove is too slow or does not progress."
+		sleep .1
+		i=$((i + 1))
+	done
+
+	lvremove -ff $vg
+}
+
+lvchange_single() {
+	lvchange -aey $vg/$lv1
+	lvchange -aey $vg/$lv2
+}
+
+lvchange_all() {
+	lvchange -aey $vg/$lv1 $vg/$lv2
+
+	# we don't want to spawn more than $1 background pollings
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq $1 || should false
+}
+
+vgchange_single() {
+	vgchange -aey -vvvv $vg
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq $1
+}
+
+pvmove_fg() {
+	# pvmove resume requires LVs active
+	vgchange -aey --poll n $vg
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# vgchange must not spawn (thus finish) background polling
+	get lv_field $vg name -a | grep "^\[pvmove0\]"
+	get lv_field $vg name -a | grep "^\[pvmove1\]"
+
+	# disable delay device
+	# fg pvmove would take ages to complete otherwise
+	aux enable_dev "$dev4"
+	aux enable_dev "$dev5"
+
+	pvmove -i0
+}
+
+pvmove_bg() {
+	# pvmove resume requires LVs active
+	vgchange -aey --poll n $vg
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# vgchange must not spawn (thus finish) background polling
+	get lv_field $vg name -a | grep "^\[pvmove0\]"
+	get lv_field $vg name -a | grep "^\[pvmove1\]"
+
+	pvmove -b -i0
+}
+
+pvmove_fg_single() {
+	# pvmove resume requires LVs active
+	vgchange -aey --poll n $vg
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# vgchange must not spawn (thus finish) background polling
+	get lv_field $vg name -a | grep "^\[pvmove0\]"
+	get lv_field $vg name -a | grep "^\[pvmove1\]"
+
+	# disable delay device
+	# fg pvmove would take ages to complete otherwise
+	aux enable_dev "$dev4"
+	aux enable_dev "$dev5"
+
+	pvmove -i0 "$dev1"
+	pvmove -i0 "$dev3"
+}
+
+pvmove_bg_single() {
+	# pvmove resume requires LVs active
+	vgchange -aey --poll n $vg
+
+	ps h -C lvm | tee out || true
+	test $(wc -l < out) -eq 0
+
+	# vgchange must not spawn (thus finish) background polling
+	get lv_field $vg name -a | grep "^\[pvmove0\]"
+	get lv_field $vg name -a | grep "^\[pvmove1\]"
+
+	pvmove -i0 -b "$dev1"
+	pvmove -i0 -b "$dev3"
+}
+
+test -e LOCAL_CLVMD && skip
+
+test_pvmove_resume lvchange_single
+test_pvmove_resume lvchange_all
+test_pvmove_resume vgchange_single
+test_pvmove_resume pvmove_fg
+test_pvmove_resume pvmove_fg_single
+test_pvmove_resume pvmove_bg
+test_pvmove_resume pvmove_bg_single
+
+vgremove -ff $vg


