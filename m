From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Nov 2008 20:14:25 -0000
Subject: LVM2/scripts clvmd_init_red_hat.in
Message-ID: <20081119201425.3209.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-19 20:14:25

Added files:
	scripts        : clvmd_init_red_hat.in 

Log message:
	generate init script

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_red_hat.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/scripts/clvmd_init_red_hat.in,v  -->  standard output
revision 1.1
--- LVM2/scripts/clvmd_init_red_hat.in
+++ -	2008-11-19 20:14:25.838796000 +0000
@@ -0,0 +1,147 @@
+#!/bin/bash
+#
+# chkconfig: - 24 76
+# description: Starts and stops clvmd
+#
+# For Red-Hat-based distributions such as Fedora, RHEL, CentOS.
+#	       
+### BEGIN INIT INFO
+# Provides: 
+### END INIT INFO
+
+. /etc/init.d/functions
+
+DAEMON=clvmd
+
+exec_prefix=@exec_prefix@
+sbindir=@sbindir@
+
+LVDISPLAY=${sbindir}/lvdisplay
+VGCHANGE=${sbindir}/vgchange
+VGSCAN=${sbindir}/vgscan
+VGDISPLAY=${sbindir}/vgdisplay
+VGS=${sbindir}/vgs
+
+CLVMDOPTS="-T20"
+
+[ -f /etc/sysconfig/cluster ] && . /etc/sysconfig/cluster
+
+LOCK_FILE="/var/lock/subsys/$DAEMON"
+
+start()
+{
+	for rtrn in 0
+	do
+		if ! pidof $DAEMON > /dev/null 
+		then 
+			echo -n "Starting $DAEMON: "
+			daemon $DAEMON $CLVMDOPTS
+			rtrn=$?
+			echo
+			if [ $rtrn -ne 0 ]
+			then
+				break
+			fi
+ 		fi	
+		# refresh cache
+		$VGSCAN  > /dev/null 2>&1
+		
+		if [ -n "$LVM_VGS" ]
+		then
+			for vg in $LVM_VGS
+			do
+				action "Activating VG $vg:" $VGCHANGE -ayl $vg || rtrn=$?
+			done
+		else
+			action "Activating VGs:" $VGCHANGE -ayl || rtrn=$?
+		fi
+	done
+
+	return $rtrn
+}
+
+stop()
+{
+	for rtrn in 0
+	do
+		if [ -n "$LVM_VGS" ]
+		then
+			for vg in $LVM_VGS
+			do
+				action "Deactivating VG $vg:" $VGCHANGE -anl $vg || rtrn=$?
+			done
+		else
+			# Hack to only deactivate clustered volumes
+			clustervgs=`$VGDISPLAY 2> /dev/null | awk 'BEGIN {RS="VG Name"} {if (/Clustered/) print $1;}'`
+			for vg in $clustervgs; do
+				action "Deactivating VG $vg:" $VGCHANGE -anl $vg || rtrn=$?
+			done
+		fi
+
+		[ $rtrn -ne 0 ] && break
+
+		echo -n "Stopping clvm:"
+		killproc $DAEMON -TERM
+		rtrn=$?
+		echo
+	done
+	
+	return $rtrn
+}
+
+wait_for_finish()
+{
+	count=0
+
+	while [ "$count" -le 10 -a -n "`pidof $DAEMON`" ]
+	do
+		sleep 1
+		count=$((count + 1))
+	done
+	
+	if [ `pidof $DAEMON` ]
+	then
+		return 1
+	else
+		return 0
+	fi
+}
+
+rtrn=1
+
+# See how we were called.
+case "$1" in
+  start)
+	start
+	rtrn=$?
+	[ $rtrn = 0 ] && touch $LOCK_FILE
+	;;
+
+  stop)
+	stop
+	rtrn=$?
+	[ $rtrn = 0 ] && rm -f $LOCK_FILE
+	;;
+
+  restart)
+	if stop
+	then
+		wait_for_finish
+		start
+	fi 
+	rtrn=$?
+	;;
+
+  status)
+	status $DAEMON
+	rtrn=$?
+	vols=$( $LVDISPLAY -C --nohead 2> /dev/null | awk '($3 ~ /....a./) {print $1}' )
+	echo active volumes: ${vols:-"(none)"}
+	;;
+
+  *)
+	echo $"Usage: $0 {start|stop|restart|status}"
+	;;
+esac
+
+exit $rtrn


