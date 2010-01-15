From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 15 Jan 2010 20:47:53 -0000
Subject: LVM2 ./WHATS_NEW scripts/cmirrord_init_red_hat.in
Message-ID: <20100115204753.18844.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-15 20:47:52

Modified files:
	.              : WHATS_NEW 
Added files:
	scripts        : cmirrord_init_red_hat.in 

Log message:
	Initial version of the cmirrord init script
	
	Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1393&r2=1.1394
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/cmirrord_init_red_hat.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/WHATS_NEW	2010/01/15 20:24:04	1.1393
+++ LVM2/WHATS_NEW	2010/01/15 20:47:52	1.1394
@@ -1,5 +1,6 @@
 Version 2.02.59 - 
 ===================================
+  Initial version of the cmirror init script (Red Hat).
   Initial version of the cmirrord man page.
   Make cluster log communication structures architecture independant.
   Fix cluster log issues with in-memory bitmaps.
/cvs/lvm2/LVM2/scripts/cmirrord_init_red_hat.in,v  -->  standard output
revision 1.1
--- LVM2/scripts/cmirrord_init_red_hat.in
+++ -	2010-01-15 20:47:53.109405000 +0000
@@ -0,0 +1,104 @@
+#!/bin/bash
+#
+# chkconfig: - 22 78
+# description: Loads/Unloads dm-log-clustered module
+#
+#
+### BEGIN INIT INFO
+# Provides: cmirrord
+# Required-Start:       $network $time
+# Required-Stop:        $network $time
+# Short-Description:    Starts and stops cmirrord
+# Description:          Starts and stops the cluster mirror log daemon
+### END INIT INFO
+
+. /etc/init.d/functions
+
+# set secure PATH
+PATH="/bin:/usr/bin:/sbin:/usr/sbin:/usr/sbin"
+
+start()
+{
+        echo -n "Starting clustered mirror log server:"
+	ps -C cmirrord >& /dev/null || cmirrord >& /dev/null
+
+	rtrn=$?
+        if [ $rtrn -eq 0 ]; then
+                success "startup"
+        else
+                failure "startup"
+        fi
+
+        # need the extra echo to properly terminate the line
+        echo
+        return $rtrn
+}
+
+stop()
+{
+        echo -n "Stopping clustered mirror log server:"
+	killall cmirrord >& /dev/null
+	for ((i=0; $i < 10; i++)); do
+	    if ! ps -C cmirrord >& /dev/null; then
+		break;
+	    fi
+	    sleep 1
+	done
+
+	if [ $i -ge 10 ]; then
+	    failure "shutdown"
+	    echo
+	    return 1
+	else
+	    success "shutdown"
+	fi
+
+	echo
+        return $rtrn
+}
+
+cmirror_status()
+{
+	ps -C cmirrord >& /dev/null
+	if [ $? -ne 0 ]; then
+		echo "Cluster log server is not running.  (Cluster mirrors will not work.)"
+		return 1
+	fi
+
+	return 0
+}
+
+rtrn=1
+
+# See how we were called.
+case "$1" in
+  start)
+        start
+        rtrn=$?
+        ;;
+
+  stop)
+        stop
+        rtrn=$?
+        ;;
+
+  restart)
+        $0 stop
+        $0 start
+        rtrn=$?
+        ;;
+
+  status)
+	cmirror_status
+        rtrn=$?
+	if [ $rtrn -eq 0 ]; then
+		echo "cmirror is running."
+	fi
+        ;;
+
+  *)
+        echo $"Usage: $0 {start|stop|restart|status}"
+        ;;
+esac
+
+exit $rtrn


