From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Mar 2012 11:10:14 -0000
Subject: LVM2 ./make.tmpl.in test/Makefile.in test/lib/ ...
Message-ID: <20120328111014.24296.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-28 11:10:10

Modified files:
	.              : make.tmpl.in 
	test           : Makefile.in 
	test/lib       : aux.sh check.sh utils.sh 
	test/shell     : lvcreate-operation.sh lvcreate-repair.sh 
	                 mdata-strings.sh mirror-names.sh 
	                 mirror-vgreduce-removemissing.sh 
	                 pvmove-basic.sh snapshot-merge.sh 

Log message:
	Improve test suite
	
	Add make help target.
	Add LVM_TEST_PARALLEL to support parallel runs of tests
	Work around the problem the dmsetup table/info may return error
	by using dmtable and dminfo function that will use 'should'.
	(Error happens when some concurently running process removes table
	entry while dmsetup command resolves table entries inside the loop.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.133&r2=1.134
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.68&r2=1.69
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/aux.sh.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/check.sh.diff?cvsroot=lvm2&r1=1.7&r2=1.8
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/utils.sh.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-operation.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/lvcreate-repair.sh.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/mdata-strings.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/mirror-names.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/mirror-vgreduce-removemissing.sh.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/pvmove-basic.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/shell/snapshot-merge.sh.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/make.tmpl.in	2012/03/26 23:09:37	1.133
+++ LVM2/make.tmpl.in	2012/03/28 11:10:08	1.134
@@ -197,7 +197,7 @@
 .PHONY: verity install_verity $(SUBDIRS.install_verity)
 .PHONY: install install_cluster install_device-mapper install_lvm2
 .PHONY: install_lib_shared install_dm_plugin install_lvm2_plugin
-.PHONY: install_ocf
+.PHONY: install_ocf help
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
 .PHONY: $(SUBDIRS.device-mapper) $(SUBDIRS.install-device-mapper)
@@ -401,7 +401,8 @@
 		 sed "s/^/		/;s/$$/;/" < $<; \
 		 echo "	local:"; echo "		*;"; echo "};") > $@
 
-ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov))
+ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \
+ help check check_local check_cluster check_lvmetad))
     ifdef SOURCES
        -include $(SOURCES:.c=.d)
     endif
--- LVM2/test/Makefile.in	2012/03/14 17:14:33	1.68
+++ LVM2/test/Makefile.in	2012/03/28 11:10:08	1.69
@@ -45,6 +45,27 @@
 
 all: check
 
+help:
+	@echo -e "\nAvailable targets:"
+	@echo "  all			Default target, run check."
+	@echo "  check			Run all tests."
+	@echo "  check_local		Run tests without clvmd and lvmetad."
+	@echo "  check_cluster		Run tests with cluster daemon."
+	@echo "  check_lvmetad		Run tests with lvmetad daemon."
+	@echo "  clean			Clean dir."
+	@echo "  help			Display callable targets."
+	@echo -e "\nSupported variables:"
+	@echo "  LVM_TEST_DEVDIR	Set to '/dev' to run on real /dev."
+	@echo "  LVM_TEST_DIR		Where to create test files [TMPDIR]."
+	@echo "  LVM_TEST_LOCKING	Normal (1), Cluster (3)."
+	@echo "  LVM_TEST_LVMETAD	Start lvmetad (1)."
+	@echo "  LVM_TEST_NODEBUG	Do not debug lvm commands."
+	@echo "  LVM_TEST_PARALLEL	May skip agresive wipe of LVMTEST resources."
+	@echo "  LVM_VERIFY_UDEV	Default verify state for lvm.conf."
+	@echo "  S			Skip given test (regex)."
+	@echo "  T			Run given test (regex)."
+	@echo "  VERBOSE		Verbose output (1), timing (2)."
+
 check: check_local check_cluster check_lvmetad
 
 check_cluster: .tests-stamp
--- LVM2/test/lib/aux.sh	2012/03/23 09:41:20	1.48
+++ LVM2/test/lib/aux.sh	2012/03/28 11:10:09	1.49
@@ -89,7 +89,7 @@
 	local dm
 
 	# Resume suspended devices first
-	for dm in $(dmsetup info -c -o suspended,name --noheadings | grep "^Suspended:.*$prefix"); do
+	for dm in $(dm_info suspended,name | grep "^Suspended:.*$prefix"); do
 		echo "dmsetup resume \"${dm#Suspended:}\""
 		dmsetup resume "${dm#Suspended:}" || true
 	done
@@ -106,7 +106,7 @@
 	local remfail=no
 	local need_udev_wait=0
 	init_udev_transaction
-	for dm in $(dmsetup info -c -o name --sort open --noheadings | grep "$prefix"); do
+	for dm in $(dm_info name --sort open | grep "$prefix"); do
 		dmsetup remove "$dm" &>/dev/null || remfail=yes
 		need_udev_wait=1
 	done
@@ -116,10 +116,10 @@
 	if test $remfail = yes; then
 		local num_devs
 		local num_remaining_devs=999
-		while num_devs=$(dmsetup table | grep "$prefix" | wc -l) && \
+		while num_devs=$(dm_table | grep "$prefix" | wc -l) && \
 		    test $num_devs -lt $num_remaining_devs -a $num_devs -ne 0; do
 			test "$stray" -eq 0 || echo "Removing $num_devs stray mapped devices with names beginning with $prefix: "
-			for dm in $(dmsetup info -c -o name --sort open --noheadings | grep "$prefix") ; do
+			for dm in $(dm_info name --sort open | grep "$prefix") ; do
 				dmsetup remove -f "$dm" || true
 			done
 			num_remaining_devs=$num_devs
@@ -139,7 +139,7 @@
 	# NOTE: SCSI_DEBUG_DEV test must come before the LOOP test because
 	# prepare_scsi_debug_dev() also sets LOOP to short-circuit prepare_loop()
 	if test -f SCSI_DEBUG_DEV; then
-		modprobe -r scsi_debug
+		test ${LVM_TEST_PARALLEL:-0} -eq 1 || modprobe -r scsi_debug
 	else
 		test ! -f LOOP || losetup -d $(cat LOOP) || true
 		test ! -f LOOPFILE || rm -f $(cat LOOPFILE)
@@ -148,7 +148,7 @@
 	rm -f LOOP
 
 	# Attempt to remove any loop devices that failed to get torn down if earlier tests aborted
-	test -z "$COMMON_PREFIX" || {
+	test ${LVM_TEST_PARALLEL:-0} -eq 1 -o -z "$COMMON_PREFIX" || {
 		teardown_devs_prefixed "$COMMON_PREFIX" 1
 		local stray_loops=( $(losetup -a | grep "$COMMON_PREFIX" | cut -d: -f1) )
 		test ${#stray_loops[@]} -eq 0 || {
@@ -161,9 +161,9 @@
 teardown() {
 	echo -n "## teardown..."
 
-	dmsetup table | not egrep -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
+	dm_table | not egrep -q "$vg|$vg1|$vg2|$vg3|$vg4" || {
 		# Avoid activation of dmeventd if there is no pid
-		cfg=$(test -s LOCAL_DMEVENTD || echo "--config 'activation { monitoring = 0 }'")
+		cfg=$(test -s LOCAL_DMEVENTD || echo "--config activation{monitoring=0}")
 		vgremove -ff $cfg  \
 			$vg $vg1 $vg2 $vg3 $vg4 &>/dev/null || rm -f debug.log
 	}
@@ -194,7 +194,7 @@
 
 	echo "ok"
 
-	test -n "$RUNNING_DMEVENTD" || not pgrep dmeventd &>/dev/null
+	test ${LVM_TEST_PARALLEL:-0} -eq 1 -o -n "$RUNNING_DMEVENTD" || not pgrep dmeventd #&>/dev/null
 }
 
 make_ioerror() {
--- LVM2/test/lib/check.sh	2012/03/16 12:59:43	1.7
+++ LVM2/test/lib/check.sh	2012/03/28 11:10:09	1.8
@@ -153,12 +153,11 @@
 
 active() {
 	local lv=$1/$2
-	(get lv_field $lv attr $lv | grep "^....a...$" >/dev/null) || \
+	(get lv_field $lv attr | grep "^....a...$" >/dev/null) || \
 		die "$lv expected active, but lvs says it's not:" \
 			$(lvl $lv -o+devices)
-	(dmsetup table | egrep "$1-$2: *[^ ]+" >/dev/null) || \
-		die "$lv expected active, lvs thinks it is but there are no mappings!" \
-			$(dmsetup table | grep $1-$2:)
+	dmsetup info $1-$2 >/dev/null ||
+		die "$lv expected active, lvs thinks it is but there are no mappings!"
 }
 
 inactive() {
@@ -166,9 +165,8 @@
 	(get lv_field $lv attr | grep "^....[-isd]...$" >/dev/null) || \
 		die "$lv expected inactive, but lvs says it's not:" \
 			$(lvl $lv -o+devices)
-	(dmsetup table | not egrep "$1-$2: *[^ ]+" >/dev/null) || \
-		die "$lv expected inactive, lvs thinks it is but there are mappings!" \
-			$(dmsetup table | grep $1-$2:)
+	not dmsetup info $1-$2 2>/dev/null || \
+		die "$lv expected inactive, lvs thinks it is but there are mappings!" 
 }
 
 # Check for list of LVs from given VG
--- LVM2/test/lib/utils.sh	2012/03/20 10:51:57	1.11
+++ LVM2/test/lib/utils.sh	2012/03/28 11:10:09	1.12
@@ -109,7 +109,7 @@
 		i=$(($i + 1))
 	done
 
-	test -n "$RUNNING_DMEVENTD" -o -f LOCAL_DMEVENTD || {
+	test ${LVM_TEST_PARALLEL:-0} -eq 1 -o -n "$RUNNING_DMEVENTD" -o -f LOCAL_DMEVENTD || {
 		pgrep dmeventd &>/dev/null && \
 			die "** During test dmeventd has been started!"
 	}
@@ -157,6 +157,14 @@
 	fi
 }
 
+dm_info() {
+	should dmsetup info --noheadings -c -o "$@"
+}
+
+dm_table() {
+	should dmsetup table "$@"
+}
+
 skip() {
 	touch SKIP_THIS_TEST
 	exit 200
--- LVM2/test/shell/lvcreate-operation.sh	2012/03/16 13:00:06	1.2
+++ LVM2/test/shell/lvcreate-operation.sh	2012/03/28 11:10:09	1.3
@@ -15,10 +15,8 @@
 
 cleanup_lvs() {
 	lvremove -ff $vg
-	if dmsetup table|grep $vg; then
-		echo "ERROR: lvremove did leave some some mappings in DM behind!"
-		return 1
-	fi
+	(dm_table | not grep $vg) || \
+		die "ERROR: lvremove did leave some some mappings in DM behind!"
 }
 
 aux prepare_pvs 2
--- LVM2/test/shell/lvcreate-repair.sh	2012/03/16 13:00:06	1.5
+++ LVM2/test/shell/lvcreate-repair.sh	2012/03/28 11:10:09	1.6
@@ -29,7 +29,7 @@
 		vgreduce --removemissing --force $vg
 
 		# check if reduced device was removed
-		test "$i" = "$dev1" && dmsetup table | not egrep "$vg-$lv1: *[^ ]+" >/dev/null
+		test "$i" = "$dev1" && dm_table | not egrep "$vg-$lv1: *[^ ]+"
 
 		lvcreate -l1 -n $lv2 $vg
 
--- LVM2/test/shell/mdata-strings.sh	2012/03/16 13:00:06	1.2
+++ LVM2/test/shell/mdata-strings.sh	2012/03/28 11:10:09	1.3
@@ -23,7 +23,7 @@
 dmsetup rename "$name" "$PREFIX$pv_ugly"
 dev1=$(dirname "$dev1")/"$PREFIX$pv_ugly"
 
-dmsetup table | grep -F "$pv_ugly"
+dm_table | grep -F "$pv_ugly"
 
 # 'pvcreate, vgcreate on filename with backslashed chars'
 created="$dev1"
--- LVM2/test/shell/mirror-names.sh	2012/03/16 13:00:06	1.2
+++ LVM2/test/shell/mirror-names.sh	2012/03/28 11:10:09	1.3
@@ -43,21 +43,11 @@
 # ---------------------------------------------------------------------
 # Common environment setup/cleanup for each sub testcases
 
-prepare_lvs_() {
-	lvremove -ff $vg
-	(dmsetup table | not grep $vg) || {
-		echo "ERROR: lvremove did leave some some mappings in DM behind!"
-		return 1
-	}
-}
-
 check_and_cleanup_lvs_() {
 	lvs -a -o+devices $vg
 	lvremove -ff $vg
-	(dmsetup table | not grep $vg) || {
-		echo "ERROR: lvremove did leave some some mappings in DM behind!"
-		return 1
-	}
+	(dm_table | not grep $vg) || \
+		die "ERROR: lvremove did leave some some mappings in DM behind!"
 }
 
 # ---------------------------------------------------------------------
@@ -65,14 +55,12 @@
 
 aux prepare_vg 5 80
 
-prepare_lvs_
 check_and_cleanup_lvs_
 
 # ---------------------------------------------------------------------
 # basic
 
 #COMM "init: lvcreate"
-prepare_lvs_
 
 #COMM "mirror images are ${lv1}_mimage_x"
 lvcreate -l2 -m1 -n $lv1 $vg
@@ -94,7 +82,6 @@
 # lvrename
 
 #COMM "init: lvrename"
-prepare_lvs_
 
 #COMM "renamed mirror names: $lv1 to $lv2"
 lvcreate -l2 -m1 -n $lv1 $vg
@@ -109,7 +96,6 @@
 # lvconvert
 
 #COMM "init: lvconvert"
-prepare_lvs_
 
 #COMM "converting mirror names is ${lv1}_mimagetmp_2"
 lvcreate -l2 -m1 -n $lv1 $vg
--- LVM2/test/shell/mirror-vgreduce-removemissing.sh	2012/03/16 13:00:06	1.2
+++ LVM2/test/shell/mirror-vgreduce-removemissing.sh	2012/03/28 11:10:09	1.3
@@ -93,20 +93,15 @@
 
 prepare_lvs_()
 {
-	lvremove -ff $vg;
-	if (dmsetup table | grep -v -- "-missing_" | grep $vg); then
+	lvremove -ff $vg
+	(dm_table | not grep $vg) || \
 		die "ERROR: lvremove did leave some some mappings in DM behind!"
-	fi
-	:
 }
 
 check_and_cleanup_lvs_()
 {
 	lvs -a -o+devices $vg
-	lvremove -ff $vg
-	if (dmsetup table | grep $vg); then
-		die "ERROR: lvremove did leave some some mappings in DM behind!"
-	fi
+	prepare_lvs_
 }
 
 recover_vg_()
--- LVM2/test/shell/pvmove-basic.sh	2012/03/16 13:00:06	1.3
+++ LVM2/test/shell/pvmove-basic.sh	2012/03/28 11:10:09	1.4
@@ -93,10 +93,8 @@
   check_dev_sum_ $(lvdev_ $vg $lv3)
   lvs -a -o name $vg > out && ! grep ^pvmove out
   lvremove -ff $vg
-  if ! dmsetup table|not grep $vg; then
-	echo "ERROR: lvremove did leave some some mappings in DM behind!" && \
-		return 1
-  fi
+  (dm_table | not grep $vg) || \
+	die "ERROR: lvremove did leave some some mappings in DM behind!"
 }
 
 #COMM "check environment setup/cleanup"
--- LVM2/test/shell/snapshot-merge.sh	2012/03/16 13:00:06	1.3
+++ LVM2/test/shell/snapshot-merge.sh	2012/03/28 11:10:09	1.4
@@ -67,13 +67,13 @@
 #    verify 'snapshot-origin' target is still being used
 lvchange --refresh $vg/$lv1
 umount test_mnt
-dmsetup table $vg-$lv1 | grep " snapshot-origin "
+dm_table $vg-$lv1 | grep " snapshot-origin "
 
 # -- refresh LV to start merge (now that FS is unmounted),
 #    an active merge uses the 'snapshot-merge' target
 lvchange --refresh $vg/$lv1
 # check whether it's still merging - or maybe got already merged (slow test)
-dmsetup table $vg-$lv1 | grep " snapshot-merge " || dmsetup table $vg-$lv1 | grep " linear "
+dm_table $vg-$lv1 | grep " snapshot-merge " || dm_table $vg-$lv1 | grep " linear "
 # -- don't care if merge is still active; lvremove at this point
 #    may test stopping an active merge
 lvremove -f $vg/$lv1
@@ -89,7 +89,7 @@
 #    verify 'snapshot-origin' target is still being used
 lvchange --refresh $vg/$lv1
 umount test_mnt
-dmsetup table $vg-$lv1 | grep " snapshot-origin " >/dev/null
+dm_table $vg-$lv1 | grep " snapshot-origin " >/dev/null
 lvremove -f $vg/$lv1
 
 


