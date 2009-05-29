From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 29 May 2009 14:14:47 -0400
Subject: [PATCH] Fix rpmlint in clvmd initscript
Message-ID: <1243620887-9963-1-git-send-email-snitzer@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Added missing LSB stanza lines.
Added reload capability.

Remaining warning (incoherent-init-script-name) is not relevant.

Signed-off-by: Mike Snitzer <snitzer@redhat.com>

--
Index: WHATS_NEW
===================================================================
RCS file: /cvs/lvm2/LVM2/WHATS_NEW,v
retrieving revision 1.1132
diff -a -u -p -r1.1132 WHATS_NEW
--- LVM2/WHATS_NEW	28 May 2009 01:59:37 -0000	1.1132
+++ LVM2/WHATS_NEW	29 May 2009 18:12:31 -0000
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Fix rpmlint in clvmd initscript
   When creating new LV, double-check that name is not already in use.
   Remove /dev/vgname/lvname symlink automatically if LV is no longer visible.
   Rename internal vorigin LV to match visible LV.
Index: scripts/clvmd_init_red_hat.in
===================================================================
RCS file: /cvs/lvm2/LVM2/scripts/clvmd_init_red_hat.in,v
retrieving revision 1.2
diff -a -u -p -r1.2 clvmd_init_red_hat.in
--- LVM2/scripts/clvmd_init_red_hat.in	10 Feb 2009 11:53:34 -0000	1.2
+++ LVM2/scripts/clvmd_init_red_hat.in	29 May 2009 18:12:31 -0000
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
@@ -109,6 +114,19 @@ wait_for_finish()
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
@@ -134,15 +152,20 @@ case "$1" in
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
 


