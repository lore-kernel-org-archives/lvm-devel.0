From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 25 Oct 2017 16:05:21 -0400
Subject: master - shellcheck: some apostrophe changes and cleanups
Message-ID: <201710252005.v9PK5LhO029406@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=35df4b10eb17065f893bbf96cba01efdb9f46e4a
Commit:        35df4b10eb17065f893bbf96cba01efdb9f46e4a
Parent:        34618c2d3061e7f9f563d4c9ad9a185c77935f0e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 25 17:02:31 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 25 22:02:54 2017 +0200

shellcheck: some apostrophe changes and cleanups

---
 scripts/blk_availability_init_red_hat.in      |    8 +++---
 scripts/blkdeactivate.sh.in                   |    2 +-
 scripts/clvmd_init_red_hat.in                 |   32 ++++++++++++------------
 scripts/cmirrord_init_red_hat.in              |   18 +++++++-------
 scripts/lvm2_cluster_activation_red_hat.sh.in |   16 ++++++------
 scripts/lvm2_lvmetad_init_red_hat.in          |   11 ++++----
 scripts/lvm2_lvmpolld_init_red_hat.in         |   11 ++++----
 scripts/lvm2_monitoring_init_red_hat.in       |   14 +++++-----
 scripts/vgimportclone.sh                      |    8 +++---
 9 files changed, 59 insertions(+), 61 deletions(-)

diff --git a/scripts/blk_availability_init_red_hat.in b/scripts/blk_availability_init_red_hat.in
index 52399fb..347c395 100644
--- a/scripts/blk_availability_init_red_hat.in
+++ b/scripts/blk_availability_init_red_hat.in
@@ -1,6 +1,6 @@
 #!/bin/bash
 #
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -40,12 +40,12 @@ LOCK_FILE="@DEFAULT_LOCK_DIR@/subsys/blk-availability"
 
 case "$1" in
   start)
-	touch $LOCK_FILE
+	touch "$LOCK_FILE"
 	;;
 
   stop)
-	action "Stopping block device availability:" $sbindir/$script $options
-	rm -f $LOCK_FILE
+	action "Stopping block device availability:" "$sbindir/$script" $options
+	rm -f "$LOCK_FILE"
 	;;
 
   status)
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index 4680f16..cfec0af 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -300,7 +300,7 @@ deactivate_md () {
 	echo -n "  [MD]: deactivating $devtype device $kname... "
 
 	test "$MDRAID_DO_WAIT" -eq 1 && {
-		sync_action="$(cat $SYS_BLK_DIR/$kname/md/sync_action)"
+		sync_action=$(cat "$SYS_BLK_DIR/$kname/md/sync_action")
 		test "$sync_action" != "idle" && {
 			echo -n "$sync_action action in progress... "
 			if eval "$MDADM" $MDADM_OPTS -W "$DEV_DIR/$kname" "$OUT" "$ERR"; then
diff --git a/scripts/clvmd_init_red_hat.in b/scripts/clvmd_init_red_hat.in
index e5fbe04..fff7912 100644
--- a/scripts/clvmd_init_red_hat.in
+++ b/scripts/clvmd_init_red_hat.in
@@ -23,15 +23,15 @@ DAEMON=clvmd
 sbindir="@SBINDIR@"
 usrsbindir="@USRSBINDIR@"
 
-lvm_vgchange=${sbindir}/vgchange
-lvm_vgs=${sbindir}/vgs
-lvm_vgscan=${sbindir}/vgscan
-lvm_lvs=${sbindir}/lvs
+lvm_vgchange="$sbindir/vgchange"
+lvm_vgs="$sbindir/vgs"
+lvm_vgscan="$sbindir/vgscan"
+lvm_lvs="$sbindir/lvs"
 
 CLVMDOPTS="-T30"
 
 [ -f /etc/sysconfig/cluster ] && . /etc/sysconfig/cluster
-[ -f /etc/sysconfig/$DAEMON ] && . /etc/sysconfig/$DAEMON
+[ -f "/etc/sysconfig/$DAEMON" ] && . "/etc/sysconfig/$DAEMON"
 
 [ -n "$CLVMD_CLUSTER_IFACE" ] && CLVMDOPTS="$CLVMDOPTS -I $CLVMD_CLUSTER_IFACE" 
 
@@ -43,15 +43,15 @@ CLVMDOPTS="-T30"
 LOCK_FILE="/var/lock/subsys/$DAEMON"
 
 clustered_vgs() {
-	${lvm_vgs} --noheadings -o vg_name -S 'vg_clustered=1' 2>/dev/null
+	"$lvm_vgs" --noheadings -o vg_name -S 'vg_clustered=1' 2>/dev/null
 }
 
 clustered_active_lvs() {
-	${lvm_lvs} --noheadings -o lv_name -S 'vg_clustered=1 && lv_active!=""' 2>/dev/null
+	"$lvm_lvs" --noheadings -o lv_name -S 'vg_clustered=1 && lv_active!=""' 2>/dev/null
 }
 
 rh_status() {
-	status $DAEMON
+	status "$DAEMON"
 }
 
 rh_status_q() {
@@ -81,11 +81,11 @@ start()
 	# Ideally vgscan should have a startup mode that would not print
 	# unnecessary warnings.
 
-	${lvm_vgscan} > /dev/null 2>&1
+	"$lvm_vgscan" > /dev/null 2>&1
 
-	action "Activating VG(s):" ${lvm_vgchange} -aay $LVM_VGS || return $?
+	action "Activating VG(s):" "$lvm_vgchange" -aay $LVM_VGS || return $?
 
-	touch $LOCK_FILE
+	touch "$LOCK_FILE"
 
 	return 0
 }
@@ -108,10 +108,10 @@ stop()
 
 	[ -z "$LVM_VGS" ] && LVM_VGS="$(clustered_vgs)"
 	if [ -n "$LVM_VGS" ]; then
-		action "Deactivating clustered VG(s):" ${lvm_vgchange} -anl $LVM_VGS || return $?
+		action "Deactivating clustered VG(s):" "$lvm_vgchange" -anl $LVM_VGS || return $?
 	fi
 
-	action "Signaling $DAEMON to exit" kill -TERM $(pidofproc $DAEMON) || return $?
+	action "Signaling $DAEMON to exit" kill -TERM "$(pidofproc "$DAEMON")" || return $?
 
 	# wait half second before we start the waiting loop or we will show
 	# the loop more time than really necessary
@@ -131,7 +131,7 @@ stop()
 		echo
 	fi
 
-	rm -f $LOCK_FILE
+	rm -f "$LOCK_FILE"
 
 	return 0
 }
@@ -156,7 +156,7 @@ restart() {
 	    stop && start
 	    return $?
 	else
-	    touch $LOCK_FILE
+	    touch "$LOCK_FILE"
 	    return 0
 	fi
 }
@@ -197,7 +197,7 @@ case "$1" in
   status)
 	rh_status
 	rtrn=$?
-	if [ $rtrn = 0 ]; then
+	if [ "$rtrn" = 0 ]; then
 		cvgs="$(clustered_vgs)"
 		echo Clustered Volume Groups: ${cvgs:-"(none)"}
 		clvs="$(clustered_active_lvs)"
diff --git a/scripts/cmirrord_init_red_hat.in b/scripts/cmirrord_init_red_hat.in
index 7b1df06..c82f8f5 100755
--- a/scripts/cmirrord_init_red_hat.in
+++ b/scripts/cmirrord_init_red_hat.in
@@ -25,8 +25,8 @@ LOCK_FILE="@DEFAULT_SYS_LOCK_DIR@/subsys/$DAEMON"
 start()
 {
 	rtrn=0
-	if ! pidof $DAEMON > /dev/null 
-	then 
+	if ! pidof "$DAEMON" > /dev/null
+	then
 		echo -n "Starting $DAEMON: "
 		daemon "$usrsbindir/$DAEMON"
 		rtrn=$?
@@ -39,7 +39,7 @@ start()
 stop()
 {
 	echo -n "Stopping $DAEMON:"
-	killproc $DAEMON -TERM
+	killproc "$DAEMON" -TERM
 	rtrn=$?
 	echo
 
@@ -55,8 +55,8 @@ wait_for_finish()
 		sleep 1
 		count=$((count + 1))
 	done
-	
-	if [ `pidof $DAEMON` ]
+
+	if [ "$(pidof "$DAEMON")" ]
 	then
 		return 1
 	else
@@ -66,7 +66,7 @@ wait_for_finish()
 
 cmirror_status()
 {
-	status $DAEMON
+	status "$DAEMON"
 }
 
 rtrn=1
@@ -76,13 +76,13 @@ case "$1" in
 	start)
 		start
 		rtrn=$?
-		[ $rtrn = 0 ] && touch $LOCK_FILE
+		[ "$rtrn" = 0 ] && touch "$LOCK_FILE"
 		;;
 
 	stop)
 		stop
 		rtrn=$?
-		[ $rtrn = 0 ] && rm -f $LOCK_FILE
+		[ "$rtrn" = 0 ] && rm -f "$LOCK_FILE"
 		;;
 
 	restart)
@@ -97,7 +97,7 @@ case "$1" in
 	status)
 		cmirror_status
 		rtrn=$?
-		if [ $rtrn -eq 0 ]; then
+		if [ "$rtrn" -eq 0 ]; then
 			echo "cmirror is running."
 		fi
 		;;
diff --git a/scripts/lvm2_cluster_activation_red_hat.sh.in b/scripts/lvm2_cluster_activation_red_hat.sh.in
index 6dacf91..e600745 100644
--- a/scripts/lvm2_cluster_activation_red_hat.sh.in
+++ b/scripts/lvm2_cluster_activation_red_hat.sh.in
@@ -2,13 +2,13 @@
 
 sbindir="@SBINDIR@"
 
-lvm_vgchange="${sbindir}/vgchange"
-lvm_vgscan="${sbindir}/vgscan"
-lvm_vgs="${sbindir}/vgs"
-lvm_lvm="${sbindir}/lvm"
+lvm_vgchange="$sbindir/vgchange"
+lvm_vgscan="$sbindir/vgscan"
+lvm_vgs="$sbindir/vgs"
+lvm_lvm="$sbindir/lvm"
 
 clustered_vgs() {
-	"${lvm_vgs}" --noheadings -o vg_name -S 'vg_clustered=1' 2>/dev/null
+	"$lvm_vgs" --noheadings -o vg_name -S 'vg_clustered=1' 2>/dev/null
 }
 
 activate() {
@@ -19,13 +19,13 @@ activate() {
 
 	if [ -z "$obtain_device_list_from_udev" ] || [ "$obtain_device_list_from_udev" -ne 1 ]; then
 		echo -n "lvm.conf option obtain_device_list_from_udev!=1: Executing vgscan"
-		"${lvm_vgscan}" > /dev/null 2>&1
+		"$lvm_vgscan" > /dev/null 2>&1
 	fi
 
 	echo -n "Activating ${LVM_VGS:-"all VG(s)"}: "
 	# Respect activation/auto_activation_volume_list!
 	# Call "-aay" which is equal to "-aly" but respects this list.
-        "${lvm_vgchange}" -aay $LVM_VGS || return 1
+        "$lvm_vgchange" -aay $LVM_VGS || return 1
 
 	return 0
 }
@@ -38,7 +38,7 @@ deactivate()
 	[ -z "$LVM_VGS" ] && LVM_VGS="$(clustered_vgs)"
 	if [ -n "$LVM_VGS" ]; then
 		echo -n "Deactivating clustered VG(s): "
-		"${lvm_vgchange}" -anl $LVM_VGS || return 1
+		"$lvm_vgchange" -anl $LVM_VGS || return 1
 	fi
 
 	return 0
diff --git a/scripts/lvm2_lvmetad_init_red_hat.in b/scripts/lvm2_lvmetad_init_red_hat.in
index 9a6c4f8..daec7ac 100644
--- a/scripts/lvm2_lvmetad_init_red_hat.in
+++ b/scripts/lvm2_lvmetad_init_red_hat.in
@@ -1,6 +1,6 @@
 #!/bin/bash
 #
-# Copyright (C) 2012 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2012-2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -41,7 +41,7 @@ LOCK_FILE="@DEFAULT_SYS_LOCK_DIR@/subsys/$DAEMON"
 PID_FILE="@LVMETAD_PIDFILE@"
 
 rh_status() {
-	status -p $PID_FILE $DAEMON
+	status -p "$PID_FILE" "$DAEMON"
 }
 
 rh_status_q() {
@@ -55,11 +55,10 @@ start()
 	return $ret
 }
 
-
 stop()
 {
 	ret=0
-	action "Signaling LVM metadata daemon to exit:" killproc -p $PID_FILE $DAEMON -TERM || ret=$?
+	action "Signaling LVM metadata daemon to exit:" killproc -p "$PID_FILE" "$DAEMON" -TERM || ret=$?
 	return $ret
 }
 
@@ -71,14 +70,14 @@ case "$1" in
 	rh_status_q && exit 0
 	start
 	rtrn=$?
-	[ $rtrn = 0 ] && touch $LOCK_FILE
+	[ "$rtrn" = 0 ] && touch "$LOCK_FILE"
 	;;
 
   stop|force-stop)
 	rh_status_q || exit 0
 	stop
 	rtrn=$?
-	[ $rtrn = 0 ] && rm -f $LOCK_FILE
+	[ "$rtrn" = 0 ] && rm -f "$LOCK_FILE"
 	;;
 
   restart)
diff --git a/scripts/lvm2_lvmpolld_init_red_hat.in b/scripts/lvm2_lvmpolld_init_red_hat.in
index 05f8b08..176ff5d 100644
--- a/scripts/lvm2_lvmpolld_init_red_hat.in
+++ b/scripts/lvm2_lvmpolld_init_red_hat.in
@@ -43,7 +43,7 @@ LOCK_FILE="@DEFAULT_LOCK_DIR@/subsys/$DAEMON"
 PID_FILE="@LVMPOLLD_PIDFILE@"
 
 rh_status() {
-	status -p $PID_FILE $DAEMON
+	status -p "$PID_FILE" "$DAEMON"
 }
 
 rh_status_q() {
@@ -57,12 +57,11 @@ start()
 	return $ret
 }
 
-
 stop()
 {
 	ret=0
-	action "Signaling LVM poll daemon to exit:" killproc -p $PID_FILE $DAEMON -TERM || ret=$?
-	return $ret
+	action "Signaling LVM poll daemon to exit:" killproc -p "$PID_FILE" "$DAEMON" -TERM || ret=$?
+	return "$ret"
 }
 
 rtrn=1
@@ -73,14 +72,14 @@ case "$1" in
 	rh_status_q && exit 0
 	start
 	rtrn=$?
-	[ $rtrn = 0 ] && touch $LOCK_FILE
+	[ $rtrn = 0 ] && touch "$LOCK_FILE"
 	;;
 
   stop|force-stop)
 	rh_status_q || exit 0
 	stop
 	rtrn=$?
-	[ $rtrn = 0 ] && rm -f $LOCK_FILE
+	[ $rtrn = 0 ] && rm -f "$LOCK_FILE"
 	;;
 
   restart)
diff --git a/scripts/lvm2_monitoring_init_red_hat.in b/scripts/lvm2_monitoring_init_red_hat.in
index 3b0d542..95e4125 100644
--- a/scripts/lvm2_monitoring_init_red_hat.in
+++ b/scripts/lvm2_monitoring_init_red_hat.in
@@ -47,7 +47,7 @@ WARN=1
 export LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1
 
 rh_status() {
-	status -p $PID_FILE $DMEVENTD_DAEMON
+	status -p "$PID_FILE" "$DMEVENTD_DAEMON"
 }
 
 rh_status_q() {
@@ -60,7 +60,7 @@ start()
 	VGSLIST=`$VGS --noheadings -o name --ignoreskippedcluster --config 'log{command_names=0 prefix="  "}' 2> /dev/null`
 	for vg in $VGSLIST
 	do
-	    action "Starting monitoring for VG $vg:" $VGCHANGE --monitor y --poll y --ignoreskippedcluster --config 'log{command_names=0 prefix="  "}' $vg || ret=$?
+	    action "Starting monitoring for VG $vg:" "$VGCHANGE" --monitor y --poll y --ignoreskippedcluster --config 'log{command_names=0 prefix="  "}' $vg || ret=$?
 	done
 
 	return $ret
@@ -78,7 +78,7 @@ stop()
 	VGSLIST=`$VGS --noheadings -o name --ignoreskippedcluster --config 'log{command_names=0 prefix="  "}' 2> /dev/null`
 	for vg in $VGSLIST
 	do
-	    action "Stopping monitoring for VG $vg:" $VGCHANGE --monitor n --ignoreskippedcluster --config 'log{command_names=0 prefix="  "}' $vg || ret=$?
+	    action "Stopping monitoring for VG $vg:" "$VGCHANGE" --monitor n --ignoreskippedcluster --config 'log{command_names=0 prefix="  "}' $vg || ret=$?
 	done
 	return $ret
 }
@@ -91,7 +91,7 @@ case "$1" in
 	rh_status_q && exit 0
 	start
 	rtrn=$?
-	[ $rtrn = 0 ] && touch $LOCK_FILE
+	[ "$rtrn" = 0 ] && touch "$LOCK_FILE"
 	;;
 
   force-stop)
@@ -99,7 +99,7 @@ case "$1" in
 	WARN=0
 	stop
 	rtrn=$?
-	[ $rtrn = 0 ] && rm -f $LOCK_FILE
+	[ "$rtrn" = 0 ] && rm -f "$LOCK_FILE"
 	;;
 
   stop)
@@ -108,7 +108,7 @@ case "$1" in
 	test "$runlevel" = "6" && WARN=0
 	stop
 	rtrn=$?
-	[ $rtrn = 0 ] && rm -f $LOCK_FILE
+	[ "$rtrn" = 0 ] && rm -f "$LOCK_FILE"
 	;;
 
   restart)
@@ -123,7 +123,7 @@ case "$1" in
   status)
 	rh_status
 	rtrn=$?
-	[ $rtrn = 0 ] && $LVS -S 'seg_monitor=monitored' -o lv_full_name,seg_monitor
+	[ "$rtrn" = 0 ] && "$LVS" -S 'seg_monitor=monitored' -o lv_full_name,seg_monitor
 	;;
 
   *)
diff --git a/scripts/vgimportclone.sh b/scripts/vgimportclone.sh
index 061d0d3..d56827f 100755
--- a/scripts/vgimportclone.sh
+++ b/scripts/vgimportclone.sh
@@ -83,12 +83,12 @@ function usage {
 
 function cleanup {
     #set to use old lvm.conf
-    LVM_SYSTEM_DIR=${ORIG_LVM_SYS_DIR}
+    LVM_SYSTEM_DIR=$ORIG_LVM_SYS_DIR
 
     if [ "$KEEP_TMP_LVM_SYSTEM_DIR" -eq 1 ]; then
         echo "${SCRIPTNAME}: LVM_SYSTEM_DIR (${TMP_LVM_SYSTEM_DIR}) must be cleaned up manually."
     else
-        "$RM" -rf -- "${TMP_LVM_SYSTEM_DIR}"
+        "$RM" -rf -- "$TMP_LVM_SYSTEM_DIR"
     fi
 }
 
@@ -309,11 +309,11 @@ done <<< "$(echo "$VGLIST")"
 ### Restore the old environment
 #####################################################################
 ### set to use old lvm.conf
-if [ -z "${ORIG_LVM_SYS_DIR}" ]
+if [ -z "$ORIG_LVM_SYS_DIR" ]
 then
     unset LVM_SYSTEM_DIR
 else
-    LVM_SYSTEM_DIR=${ORIG_LVM_SYS_DIR}
+    LVM_SYSTEM_DIR=$ORIG_LVM_SYS_DIR
 fi
 
 ### update the device cache and make sure all


