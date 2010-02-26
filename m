From: fabbione@sourceware.org <fabbione@sourceware.org>
Date: 26 Feb 2010 13:07:44 -0000
Subject: LVM2 ./WHATS_NEW scripts/clvmd_init_red_hat.in
Message-ID: <20100226130744.20778.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	fabbione at sourceware.org	2010-02-26 13:07:43

Modified files:
	.              : WHATS_NEW 
	scripts        : clvmd_init_red_hat.in 

Log message:
	- fix whitespaces all over (tabs/spaces)
	- increase timeout to 30 secs (on Chrissie request)
	- source both cluster and clvmd for options (like all the other cluster
	init scripts)
	- add clustered_vgs and _lvs commodity fns
	- move rh_status* fns at the top, so they can be reused
	- heavily cleanup start and stop fns from redundant code and unnecessary
	loops
	- improve output from different operations
	- make the init script lsb compliant
	- don??t force kill of the daemon, send only a TERM signal and then wait
	for it to exit
	- Resolves rhbz#533247

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1439&r2=1.1440
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_red_hat.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/WHATS_NEW	2010/02/24 20:01:40	1.1439
+++ LVM2/WHATS_NEW	2010/02/26 13:07:43	1.1440
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Rewrite clvmd init script.
   Remove lvs_in_vg_activated_by_uuid_only call.
   Run device info query device by uuid only.
   Don't touch /dev in vgmknodes if activation is disabled.
--- LVM2/scripts/clvmd_init_red_hat.in	2009/05/29 18:54:48	1.4
+++ LVM2/scripts/clvmd_init_red_hat.in	2010/02/26 13:07:43	1.5
@@ -1,171 +1,196 @@
 #!/bin/bash
 #
+# clvmd - Clustered LVM Daemon init script
+#
 # chkconfig: - 24 76
-# description: Starts and stops clvmd
+# description: Cluster daemon for userland logical volume management tools.
 #
 # For Red-Hat-based distributions such as Fedora, RHEL, CentOS.
-#	       
+#
 ### BEGIN INIT INFO
-# Provides: clvmd
-# Required-Start: $local_fs
-# Required-Stop: $local_fs
-# Default-Start:
-# Default-Stop: 0 1 6
-# Short-Description: Clustered LVM Daemon
+# Provides:		clvmd
+# Required-Start:	$local_fs
+# Required-Stop:	$local_fs
+# Short-Description:	This service is Clusterd LVM Daemon.
+# Description:		Cluster daemon for userland logical volume management tools.
 ### END INIT INFO
 
-. /etc/init.d/functions
+. /etc/rc.d/init.d/functions
 
 DAEMON=clvmd
 
 exec_prefix=@exec_prefix@
 sbindir=@sbindir@
 
-LVDISPLAY=${sbindir}/lvdisplay
-VGCHANGE=${sbindir}/vgchange
-VGSCAN=${sbindir}/vgscan
-VGDISPLAY=${sbindir}/vgdisplay
-VGS=${sbindir}/vgs
+lvm_vgchange=${sbindir}/vgchange
+lvm_vgdisplay=${sbindir}/vgdisplay
+lvm_vgscan=${sbindir}/vgscan
+lvm_lvs=${sbindir}/lvs
 
-CLVMDOPTS="-T20"
+CLVMDOPTS="-T30"
 
 [ -f /etc/sysconfig/cluster ] && . /etc/sysconfig/cluster
+[ -f /etc/sysconfig/$DAEMON ] && . /etc/sysconfig/$DAEMON
 
 [ -n "$CLVMD_CLUSTER_IFACE" ] && CLVMDOPTS="$CLVMDOPTS -I $CLVMD_CLUSTER_IFACE" 
 
+# allow up to $CLVMD_STOP_TIMEOUT seconds to clvmd to complete exit operations
+# default to 10 seconds
+
+[ -z $CLMVD_STOP_TIMEOUT ] && CLVMD_STOP_TIMEOUT=10
+
 LOCK_FILE="/var/lock/subsys/$DAEMON"
 
-start()
-{
-	for rtrn in 0
-	do
-		if ! pidof $DAEMON > /dev/null 
-		then 
-			echo -n "Starting $DAEMON: "
-			daemon $DAEMON $CLVMDOPTS
-			rtrn=$?
-			echo
-			if [ $rtrn -ne 0 ]
-			then
-				break
-			fi
- 		fi	
-		# refresh cache
-		$VGSCAN  > /dev/null 2>&1
-		
-		if [ -n "$LVM_VGS" ]
-		then
-			for vg in $LVM_VGS
-			do
-				action "Activating VG $vg:" $VGCHANGE -ayl $vg || rtrn=$?
-			done
-		else
-			action "Activating VGs:" $VGCHANGE -ayl || rtrn=$?
-		fi
+# NOTE: replace this with vgs, once display filter per attr is implemented.
+clustered_vgs() {
+	${lvm_vgdisplay} 2>/dev/null | \
+		awk 'BEGIN {RS="VG Name"} {if (/Clustered/) print $1;}'
+}
+
+clustered_lvs() {
+	for i in $(clustered_vgs); do
+		${lvm_lvs} -o lv_name --noheadings $i
 	done
+}
 
-	return $rtrn
+rh_status() {
+	status $DAEMON
 }
 
-stop()
+rh_status_q() {
+	rh_status >/dev/null 2>&1
+}
+
+start()
 {
-	for rtrn in 0
-	do
-		if [ -n "$LVM_VGS" ]
-		then
-			for vg in $LVM_VGS
-			do
-				action "Deactivating VG $vg:" $VGCHANGE -anl $vg || rtrn=$?
-			done
-		else
-			# Hack to only deactivate clustered volumes
-			clustervgs=`$VGDISPLAY 2> /dev/null | awk 'BEGIN {RS="VG Name"} {if (/Clustered/) print $1;}'`
-			for vg in $clustervgs; do
-				action "Deactivating VG $vg:" $VGCHANGE -anl $vg || rtrn=$?
-			done
-		fi
-
-		[ $rtrn -ne 0 ] && break
-
-		echo -n "Stopping clvm:"
-		killproc $DAEMON -TERM
-		rtrn=$?
+	if ! rh_status_q; then
+		echo -n "Starting $DAEMON: "
+		daemon $DAEMON $CLVMDOPTS || return $?
 		echo
-	done
-	
-	return $rtrn
+	fi
+
+	# Refresh local cache.
+	#
+	# It's possible that new PVs were added to this, or other VGs
+	# while this node was down. So we run vgscan here to avoid
+	# any potential "Missing UUID" messages with subsequent
+	# LVM commands.
+
+	# The following step would be better and more informative to the user:
+	# 'action "Refreshing VG(s) local cache:" ${lvm_vgscan}'
+	# but it could show warnings such as:
+	# 'clvmd not running on node x-y-z  Unable to obtain global lock.'
+	# and the action would be shown as FAILED when in reality it didn't.
+	# Ideally vgscan should have a startup mode that would not print
+	# unnecessary warnings.
+
+	${lvm_vgscan} > /dev/null 2>&1
+
+	action "Activating VG(s):" ${lvm_vgchange} -ayl $LVM_VGS || return $?
+
+	touch $LOCK_FILE
+
+	return 0
 }
 
 wait_for_finish()
 {
 	count=0
-
-	while [ "$count" -le 10 -a -n "`pidof $DAEMON`" ]
-	do
+	while [ "$count" -le "$CLVMD_STOP_TIMEOUT" ] && \
+		 rh_status_q ]; do
 		sleep 1
-		count=$((count + 1))
+		count=$((count+1))
 	done
-	
-	if [ `pidof $DAEMON` ]
-	then
+
+	! rh_status_q
+}
+
+stop()
+{
+	rh_status_q || return 0
+
+	action "Deactivating clusterd VG(s):" ${lvm_vgchange} -anl ${LVM_VGS:-$(clustered_vgs)} || return $?
+
+	action "Signaling $DAEMON to exit" kill -TERM $(pidofproc $DAEMON) || return $?
+
+	# wait half second before we start the waiting loop or we will show
+	# the loop more time than really necessary
+	usleep 500000
+
+	# clvmd could take some time to stop
+	rh_status_q && action "Waiting for $DAEMON to exit:" wait_for_finish
+
+	if rh_status_q; then
+		echo -n "$DAEMON failed to exit"
+		failure
+		echo
 		return 1
 	else
-		return 0
+		echo -n "$DAEMON terminated"
+		success
+		echo
 	fi
-}
 
-reload() {
-	$DAEMON -R
-}
+	rm -f $LOCK_FILE
 
-rh_status() {
-	status $DAEMON
+	return 0
 }
 
-rh_status_q() {
-	rh_status >/dev/null 2>&1
+reload() {
+	rh_status_q || exit 7
+	action "Reloading $DAEMON configuration: " $DAEMON -R || return $?
 }
 
-
-rtrn=1
+restart() {
+	# if stop fails, restart will return the error and not attempt
+	# another start. Even if start is protected by rh_status_q,
+	# that would avoid spawning another daemon, it would try to
+	# reactivate the VGs.
+	stop && start
+}
 
 # See how we were called.
 case "$1" in
   start)
 	start
 	rtrn=$?
-	[ $rtrn = 0 ] && touch $LOCK_FILE
 	;;
 
   stop)
 	stop
 	rtrn=$?
-	[ $rtrn = 0 ] && rm -f $LOCK_FILE
 	;;
 
-  restart)
-	if stop
-	then
-		wait_for_finish
-		start
-	fi 
+  restart|force-reload)
+	restart
 	rtrn=$?
 	;;
 
+  condrestart|try-restart)
+	rh_status_q || exit 0
+	restart
+	rtrn=$? 
+	;;
+
   reload)
-	rh_status_q || exit 7
 	reload
+	rtrn=$?
 	;;
 
   status)
 	rh_status
 	rtrn=$?
-	vols=$( $LVDISPLAY -C --nohead 2> /dev/null | awk '($3 ~ /....a./) {print $1}' )
-	echo active volumes: ${vols:-"(none)"}
+	if [ $rtrn = 0 ]; then
+		cvgs="$(clustered_vgs)"
+		echo Active clustered Volume Groups: ${cvgs:-"(none)"}
+		clvs="$(clustered_lvs)"
+		echo Active clustered Logical Volumes: ${clvs:-"(none)"}
+	fi
 	;;
 
   *)
-	echo $"Usage: $0 {start|stop|restart|reload|status}"
+	echo $"Usage: $0 {start|stop|status|restart|condrestart|try-restart|reload|force-reload}"
+	rtrn=2
 	;;
 esac
 


