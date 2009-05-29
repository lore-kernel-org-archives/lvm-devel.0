From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 29 May 2009 18:34:11 -0000
Subject: LVM2 ./WHATS_NEW scripts/clvmd_init_red_hat.in
Message-ID: <20090529183411.18864.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2009-05-29 18:34:10

Modified files:
	.              : WHATS_NEW 
	scripts        : clvmd_init_red_hat.in 

Log message:
	Fix rpmlint in clvmd initscript
	
	Added missing LSB stanza lines.
	Added reload capability.
	Remaining warning (incoherent-init-script-name) is not relevant.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1132&r2=1.1133
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_red_hat.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2009/05/28 01:59:37	1.1132
+++ LVM2/WHATS_NEW	2009/05/29 18:34:10	1.1133
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Fix rpmlint in clvmd initscript
   When creating new LV, double-check that name is not already in use.
   Remove /dev/vgname/lvname symlink automatically if LV is no longer visible.
   Rename internal vorigin LV to match visible LV.
--- LVM2/scripts/clvmd_init_red_hat.in	2009/02/10 11:53:34	1.2
+++ LVM2/scripts/clvmd_init_red_hat.in	2009/05/29 18:34:10	1.3
@@ -6,7 +6,12 @@
 # For Red-Hat-based distributions such as Fedora, RHEL, CentOS.
 #	       
 ### BEGIN INIT INFO
-# Provides: 
+# Provides: clvmd
+# Required-Start: $local_fs
+# Required-Stop: $local_fs
+# Default-Start: 2 3 4 5
+# Default-Stop: 0 1 6
+# Short-Description: Clustered LVM Daemon
 ### END INIT INFO
 
 . /etc/init.d/functions
@@ -109,6 +114,19 @@
 	fi
 }
 
+reload() {
+	$DAEMON -R
+}
+
+rh_status() {
+	status $DAEMON
+}
+
+rh_status_q() {
+	rh_status >/dev/null 2>&1
+}
+
+
 rtrn=1
 
 # See how we were called.
@@ -134,15 +152,20 @@
 	rtrn=$?
 	;;
 
+  reload)
+	rh_status_q || exit 7
+	reload
+	;;
+
   status)
-	status $DAEMON
+	rh_status
 	rtrn=$?
 	vols=$( $LVDISPLAY -C --nohead 2> /dev/null | awk '($3 ~ /....a./) {print $1}' )
 	echo active volumes: ${vols:-"(none)"}
 	;;
 
   *)
-	echo $"Usage: $0 {start|stop|restart|status}"
+	echo $"Usage: $0 {start|stop|restart|reload|status}"
 	;;
 esac
 


