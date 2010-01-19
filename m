From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Jan 2010 02:04:36 -0000
Subject: LVM2 ./configure ./configure.in man/Makefile.i ...
Message-ID: <20100119020436.32242.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-01-19 02:04:35

Modified files:
	.              : configure configure.in 
	man            : Makefile.in 
	scripts        : Makefile.in cmirrord_init_red_hat.in 
Added files:
	man            : cmirrord.8.in 

Log message:
	And more fixes for cmirror build.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.diff?cvsroot=lvm2&r1=1.113&r2=1.114
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.122&r2=1.123
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/cmirrord.8.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/Makefile.in.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/cmirrord_init_red_hat.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/configure	2010/01/11 15:59:54	1.113
+++ LVM2/configure	2010/01/19 02:04:33	1.114
@@ -15531,7 +15531,7 @@
 
 
 ################################################################################
-ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
+ac_config_files="$ac_config_files Makefile make.tmpl daemons/Makefile daemons/clvmd/Makefile daemons/cmirrord/Makefile daemons/dmeventd/Makefile daemons/dmeventd/libdevmapper-event.pc daemons/dmeventd/plugins/Makefile daemons/dmeventd/plugins/mirror/Makefile daemons/dmeventd/plugins/snapshot/Makefile doc/Makefile include/.symlinks include/Makefile lib/Makefile lib/format1/Makefile lib/format_pool/Makefile lib/locking/Makefile lib/mirror/Makefile lib/misc/lvm-version.h lib/snapshot/Makefile libdm/Makefile libdm/libdevmapper.pc liblvm/Makefile liblvm/liblvm2app.pc man/Makefile po/Makefile scripts/clvmd_init_red_hat scripts/cmirrord_init_red_hat scripts/lvm2_monitoring_init_red_hat scripts/Makefile test/Makefile test/api/Makefile tools/Makefile udev/Makefile"
 
 cat >confcache <<\_ACEOF
 # This file is a shell script that caches the results of configure
@@ -16157,6 +16157,7 @@
     "man/Makefile") CONFIG_FILES="$CONFIG_FILES man/Makefile" ;;
     "po/Makefile") CONFIG_FILES="$CONFIG_FILES po/Makefile" ;;
     "scripts/clvmd_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/clvmd_init_red_hat" ;;
+    "scripts/cmirrord_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/cmirrord_init_red_hat" ;;
     "scripts/lvm2_monitoring_init_red_hat") CONFIG_FILES="$CONFIG_FILES scripts/lvm2_monitoring_init_red_hat" ;;
     "scripts/Makefile") CONFIG_FILES="$CONFIG_FILES scripts/Makefile" ;;
     "test/Makefile") CONFIG_FILES="$CONFIG_FILES test/Makefile" ;;
--- LVM2/configure.in	2010/01/11 15:51:44	1.122
+++ LVM2/configure.in	2010/01/19 02:04:34	1.123
@@ -1175,6 +1175,7 @@
 man/Makefile
 po/Makefile
 scripts/clvmd_init_red_hat
+scripts/cmirrord_init_red_hat
 scripts/lvm2_monitoring_init_red_hat
 scripts/Makefile
 test/Makefile
/cvs/lvm2/LVM2/man/cmirrord.8.in,v  -->  standard output
revision 1.1
--- LVM2/man/cmirrord.8.in
+++ -	2010-01-19 02:04:35.909141000 +0000
@@ -0,0 +1,5 @@
+.TH CMIRRORD 8 "LVM TOOLS #VERSION#" "Red Hat Inc" \" -*- nroff -*-
+.SH NAME
+cmirrord
+.SH SYNOPSIS
+.B cmirrord
--- LVM2/man/Makefile.in	2010/01/15 20:24:05	1.29
+++ LVM2/man/Makefile.in	2010/01/19 02:04:34	1.30
@@ -32,7 +32,16 @@
 	vgck.8 vgcreate.8 vgconvert.8 vgdisplay.8 vgexport.8 vgextend.8 \
 	vgimport.8 vgimportclone.8 vgmerge.8 vgmknodes.8 vgreduce.8 vgremove.8 \
 	vgrename.8 vgs.8 vgscan.8 vgsplit.8 $(FSADMMAN)
-MAN8CLUSTER=clvmd.8 cmirrord.8
+
+ifneq ("@CLVMD@", "none")
+  MAN8CLUSTER=clvmd.8
+else
+  MAN8CLUSTER=
+endif
+ifeq ("@BUILD_CMIRRORD@", "yes")
+  MAN8CLUSTER+=cmirrord.8
+endif
+
 MAN8DM=dmsetup.8
 MAN5DIR=${mandir}/man5
 MAN8DIR=${mandir}/man8
--- LVM2/scripts/Makefile.in	2009/10/02 19:10:37	1.11
+++ LVM2/scripts/Makefile.in	2010/01/19 02:04:35	1.12
@@ -30,4 +30,4 @@
 
 install_lvm2: install
 
-DISTCLEAN_TARGETS += clvmd_init_red_hat lvm2_monitoring_init_red_hat
+DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat lvm2_monitoring_init_red_hat
--- LVM2/scripts/cmirrord_init_red_hat.in	2010/01/15 21:48:03	1.2
+++ LVM2/scripts/cmirrord_init_red_hat.in	2010/01/19 02:04:35	1.3
@@ -1,71 +1,71 @@
 #!/bin/bash
 #
 # chkconfig: - 22 78
-# description: Loads/Unloads dm-log-clustered module
+# description: Starts and stops cmirrord
 #
+# For Red-Hat-based distributions such as Fedora, RHEL, CentOS.
 #
 ### BEGIN INIT INFO
 # Provides: cmirrord
-# Required-Start:       $network $time
-# Required-Stop:        $network $time
+# Required-Start:       $network $time $local_fs
+# Required-Stop:	$network $time $local_fs
 # Short-Description:    Starts and stops cmirrord
-# Description:          Starts and stops the cluster mirror log daemon
+# Description:	  Starts and stops the cluster mirror log daemon
 ### END INIT INFO
 
 . /etc/init.d/functions
 
-# set secure PATH
-PATH="/bin:/usr/bin:/sbin:/usr/sbin:/usr/sbin"
+DAEMON=cmirrord
+
+LOCK_FILE="/var/lock/subsys/$DAEMON"
 
 start()
 {
-	echo -n "Starting clustered mirror log server:"
-	ps -C cmirrord >& /dev/null || cmirrord >& /dev/null
+	if ! pidof $DAEMON > /dev/null 
+	then 
+		echo -n "Starting $DAEMON: "
+		daemon $DAEMON $CLVMDOPTS
+		rtrn=$?
+		echo
+		if [ $rtrn -ne 0 ]
+		then
+			break
+		fi
+	fi      
 
+	return $rtrn
+}
+
+stop()
+{
+	echo -n "Stopping $DAEMON:"
+	killproc $DAEMON -TERM
 	rtrn=$?
-	if [ $rtrn -eq 0 ]; then
-		success "startup"
-	else
-		failure "startup"
-	fi
 
-	# need the extra echo to properly terminate the line
-	echo
 	return $rtrn
 }
 
-stop()
+wait_for_finish()
 {
-	echo -n "Stopping clustered mirror log server:"
-	killall cmirrord >& /dev/null
-	for ((i=0; $i < 10; i++)); do
-		if ! ps -C cmirrord >& /dev/null; then
-			break;
-		fi
+	count=0
+
+	while [ "$count" -le 10 -a -n "`pidof $DAEMON`" ]
+	do
 		sleep 1
+		count=$((count + 1))
 	done
-
-	if [ $i -ge 10 ]; then
-		failure "shutdown"
-		echo
+	
+	if [ `pidof $DAEMON` ]
+	then
 		return 1
 	else
-		success "shutdown"
+		return 0
 	fi
-
-	echo
-	return $rtrn
 }
 
 cmirror_status()
 {
-	ps -C cmirrord >& /dev/null
-	if [ $? -ne 0 ]; then
-		echo "Cluster log server is not running.  (Cluster mirrors will not work.)"
-		return 1
-	fi
-
-	return 0
+	status $DAEMON
 }
 
 rtrn=1
@@ -75,16 +75,21 @@
 	start)
 		start
 		rtrn=$?
+		[ $rtrn = 0 ] && touch $LOCK_FILE
 		;;
 
 	stop)
 		stop
 		rtrn=$?
+		[ $rtrn = 0 ] && rm -f $LOCK_FILE
 		;;
 
 	restart)
-		$0 stop
-		$0 start
+		if stop
+		then
+			wait_for_finish
+			start
+		fi
 		rtrn=$?
 		;;
 


