From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  2 Jul 2014 08:49:02 +0000 (UTC)
Subject: master - tests: replace cat with $(<
Message-ID: <20140702084902.EDD01616E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d1094ec4c662bef5e11bc67578d3fa4607940b93
Commit:        d1094ec4c662bef5e11bc67578d3fa4607940b93
Parent:        b22ab4dab0dcf78d86ff64c3412cf175118d1785
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 30 21:00:08 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 2 10:45:44 2014 +0200

tests: replace cat with $(<

Use shell built-in $(<
Print lvm.conf in use for test.
---
 test/lib/aux.sh                    |   41 +++++++++++++++++------------------
 test/shell/dmeventd-restart.sh     |    2 +-
 test/shell/lvmetad-disabled.sh     |    4 +-
 test/shell/lvmetad-override.sh     |    2 +-
 test/shell/lvmetad-pvscan-nomda.sh |    2 +-
 test/shell/lvmetad-restart.sh      |    2 +-
 test/shell/lvmetad-warning.sh      |    2 +-
 test/shell/pvmove-restart.sh       |    4 +-
 test/shell/report-select.sh        |    2 +-
 9 files changed, 30 insertions(+), 31 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 76b93ef..7b96ad4 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -185,8 +185,8 @@ teardown_devs() {
 	if test -f SCSI_DEBUG_DEV; then
 		test "${LVM_TEST_PARALLEL:-0}" -eq 1 || modprobe -r scsi_debug
 	else
-		test ! -f LOOP || losetup -d $(cat LOOP) || true
-		test ! -f LOOPFILE || rm -f $(cat LOOPFILE)
+		test ! -f LOOP || losetup -d $(< LOOP) || true
+		test ! -f LOOPFILE || rm -f $(< LOOPFILE)
 	fi
 	rm -f DEVICES # devs is set in prepare_devs()
 	rm -f LOOP
@@ -207,9 +207,9 @@ teardown_devs() {
 
 kill_sleep_kill_() {
 	if test -s "$1" ; then
-		if kill -TERM "$(cat $1)" ; then
+		if kill -TERM "$(< $1)" ; then
 			if test "$2" -eq 0 ; then sleep .1 ; else sleep 1 ; fi
-			kill -KILL "$(cat $1)" 2>/dev/null || true
+			kill -KILL "$(< $1)" 2>/dev/null || true
 		fi
 	fi
 }
@@ -253,7 +253,7 @@ prepare_loop() {
 	local i
 	local slash
 
-	test -f LOOP && LOOP=$(cat LOOP)
+	test -f LOOP && LOOP=$(< LOOP)
 	echo -n "## preparing loop device..."
 
 	# skip if prepare_scsi_debug_dev() was used
@@ -598,8 +598,8 @@ generate_config() {
 	else
 	    LVM_VERIFY_UDEV=${LVM_VERIFY_UDEV:-1}
 	fi
-	test -f $config_values || {
-            cat > $config_values <<-EOF
+	test -f "$config_values" || {
+            cat > "$config_values" <<-EOF
 devices/dir = "$DM_DEV_DIR"
 devices/scan = "$DM_DEV_DIR"
 devices/filter = "a|.*|"
@@ -639,20 +639,19 @@ EOF
 
 	local v
 	for v in "$@"; do
-	    echo "$v" >> $config_values
-	done
+	    echo "$v"
+	done >> "$config_values"
 
-	rm -f $config
 	local s
-	for s in $(cat $config_values | cut -f1 -d/ | sort | uniq); do
-		echo "$s {" >> $config
+	for s in $(cut -f1 -d/ "$config_values" | sort | uniq); do
+		echo "$s {"
 		local k
-		for k in $(grep ^"$s"/ $config_values | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
-			grep "^$k" $config_values | tail -n 1 | sed -e "s,^$s/,	  ," >> $config
+		for k in $(grep ^"$s"/ "$config_values" | cut -f1 -d= | sed -e 's, *$,,' | sort | uniq); do
+			grep "^$k" "$config_values" | tail -n 1 | sed -e "s,^$s/,	  ,"
 		done
-		echo "}" >> $config
-		echo >> $config
-	done
+		echo "}"
+		echo
+	done | tee "$config"
 }
 
 lvmconf() {
@@ -666,7 +665,7 @@ profileconf() {
 	shift
 	generate_config "$@"
 	test -d etc/profile || mkdir etc/profile
-	mv -f PROFILE_$profile_name etc/profile/$profile_name.profile
+	mv -f "PROFILE_$profile_name" "etc/profile/$profile_name.profile"
 }
 
 prepare_profiles() {
@@ -690,7 +689,7 @@ api() {
 }
 
 mirror_recovery_works() {
-	case $(uname -r) in
+	case "$(uname -r)" in
 	  3.3.4-5.fc17.i686|3.3.4-5.fc17.x86_64) return 1 ;;
 	esac
 }
@@ -729,7 +728,7 @@ raid456_replace_works() {
 # http://www.redhat.com/archives/dm-devel/2014-March/msg00008.html
 # so we need to put here exlusion for kernes which do trace SLUB
 #
-	case $(uname -r) in
+	case "$(uname -r)" in
 	  3.6.*.fc18.i686*|3.6.*.fc18.x86_64) return 1 ;;
 	  3.9.*.fc19.i686*|3.9.*.fc19.x86_64) return 1 ;;
 	  3.1[0123].*.fc18.i686*|3.1[0123].*.fc18.x86_64) return 1 ;;
@@ -835,7 +834,7 @@ dmsetup_wrapped() {
 	dmsetup "$@"
 }
 
-test -f DEVICES && devs=$(cat DEVICES)
+test -f DEVICES && devs=$(< DEVICES)
 
 if test "$1" = dmsetup; then
     shift
diff --git a/test/shell/dmeventd-restart.sh b/test/shell/dmeventd-restart.sh
index 366b4d2..a94ede1 100644
--- a/test/shell/dmeventd-restart.sh
+++ b/test/shell/dmeventd-restart.sh
@@ -30,7 +30,7 @@ lvchange --monitor y --verbose $vg/4way 2>&1 | tee lvchange.out
 grep 'already monitored' lvchange.out
 
 # now try what happens if no dmeventd is running
-kill -9 $(cat LOCAL_DMEVENTD)
+kill -9 $(< LOCAL_DMEVENTD)
 rm LOCAL_DMEVENTD
 
 dmeventd -R -f &
diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index acb5f82..efdca16 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -12,7 +12,7 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
-kill $(cat LOCAL_LVMETAD)
+kill $(< LOCAL_LVMETAD)
 while test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait for the socket close
 test ! -e "$LVM_LVMETAD_PIDFILE"
 
@@ -25,5 +25,5 @@ pvs 2>&1 | not grep "lvmetad is running"
 aux lvmconf "global/use_lvmetad = 0"
 pvs 2>&1 | grep "lvmetad is running"
 
-kill $(cat "$LVM_LVMETAD_PIDFILE")
+kill $(< "$LVM_LVMETAD_PIDFILE")
 not ls "$LVM_LVMETAD_PIDFILE"
diff --git a/test/shell/lvmetad-override.sh b/test/shell/lvmetad-override.sh
index ff4ad18..27f15cb 100644
--- a/test/shell/lvmetad-override.sh
+++ b/test/shell/lvmetad-override.sh
@@ -16,7 +16,7 @@ aux prepare_pvs 2
 
 vgcreate $vg1 $dev1 $dev2
 lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
-kill $(cat LOCAL_LVMETAD)
+kill $(< LOCAL_LVMETAD)
 lvchange -ay $vg1 2>&1 | grep "Failed to connect"
 lvchange -aay $vg1 --sysinit 2>&1 | not grep "Failed to connect"
 lvchange -ay $vg1 --config 'global { use_lvmetad = 0 }' 2>&1 | not grep "Failed to connect"
diff --git a/test/shell/lvmetad-pvscan-nomda.sh b/test/shell/lvmetad-pvscan-nomda.sh
index c55cafb..39604d0 100644
--- a/test/shell/lvmetad-pvscan-nomda.sh
+++ b/test/shell/lvmetad-pvscan-nomda.sh
@@ -12,7 +12,7 @@
 . lib/inittest
 
 test -e LOCAL_LVMETAD || skip
-kill $(cat LOCAL_LVMETAD)
+kill $(< LOCAL_LVMETAD)
 rm LOCAL_LVMETAD
 
 aux prepare_devs 2
diff --git a/test/shell/lvmetad-restart.sh b/test/shell/lvmetad-restart.sh
index 6377c57..e4136df 100644
--- a/test/shell/lvmetad-restart.sh
+++ b/test/shell/lvmetad-restart.sh
@@ -17,7 +17,7 @@ aux prepare_pvs 2
 vgcreate $vg1 "$dev1" "$dev2"
 vgs | grep $vg1
 
-kill $(cat LOCAL_LVMETAD)
+kill $(< LOCAL_LVMETAD)
 aux prepare_lvmetad
 
 vgs | grep $vg1
diff --git a/test/shell/lvmetad-warning.sh b/test/shell/lvmetad-warning.sh
index 1c6c62b..52bd885 100644
--- a/test/shell/lvmetad-warning.sh
+++ b/test/shell/lvmetad-warning.sh
@@ -17,7 +17,7 @@ aux prepare_pvs 2
 vgcreate $vg1 "$dev1" "$dev2"
 lvchange -ay $vg1 2>&1 | not grep "Failed to connect"
 
-kill $(cat LOCAL_LVMETAD)
+kill $(< LOCAL_LVMETAD)
 lvchange -ay $vg1 2>&1 | grep "Failed to connect"
 lvchange -aay $vg1 --sysinit 2>&1 | tee sysinit.txt
 not grep "Failed to connect" sysinit.txt
diff --git a/test/shell/pvmove-restart.sh b/test/shell/pvmove-restart.sh
index af079ea..f480aaa 100644
--- a/test/shell/pvmove-restart.sh
+++ b/test/shell/pvmove-restart.sh
@@ -53,7 +53,7 @@ if test -e LOCAL_CLVMD ; then
 	# as clvmd starts to abort on internal errors on various
 	# errors, based on the fact pvmove is killed -9
 	# Restart clvmd
-	kill $(cat LOCAL_CLVMD)
+	kill $(< LOCAL_CLVMD)
 	for i in $(seq 1 100) ; do
 		test $i -eq 100 && die "Shutdown of clvmd is too slow."
 		test -e "$CLVMD_PIDFILE" || break
@@ -64,7 +64,7 @@ fi
 
 if test -e LOCAL_LVMETAD ; then
 	# Restart lvmetad
-	kill $(cat LOCAL_LVMETAD)
+	kill $(< LOCAL_LVMETAD)
 	aux prepare_lvmetad
 fi
 
diff --git a/test/shell/report-select.sh b/test/shell/report-select.sh
index 8181cd2..cdd45ed 100644
--- a/test/shell/report-select.sh
+++ b/test/shell/report-select.sh
@@ -58,7 +58,7 @@ function result()
 	# the number of lines on output must match
 	test $items_found -eq $# || {
 		echo "  >>> NUMBER OF ITEMS EXPECTED: $# ($@)"
-		echo "  >>> NUMBER OF ITEMS FOUND: $items_found ($(cat $OUT_LOG_FILE))"
+		echo "  >>> NUMBER OF ITEMS FOUND: $items_found ($(< $OUT_LOG_FILE))"
 		return 1
 	}
 


