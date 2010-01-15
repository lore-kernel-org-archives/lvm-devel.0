From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 15 Jan 2010 21:48:04 -0000
Subject: LVM2/scripts cmirrord_init_red_hat.in
Message-ID: <20100115214804.3374.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-01-15 21:48:04

Modified files:
	scripts        : cmirrord_init_red_hat.in 

Log message:
	Use tabs, not spaces.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/cmirrord_init_red_hat.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/scripts/cmirrord_init_red_hat.in	2010/01/15 20:47:52	1.1
+++ LVM2/scripts/cmirrord_init_red_hat.in	2010/01/15 21:48:03	1.2
@@ -19,42 +19,42 @@
 
 start()
 {
-        echo -n "Starting clustered mirror log server:"
+	echo -n "Starting clustered mirror log server:"
 	ps -C cmirrord >& /dev/null || cmirrord >& /dev/null
 
 	rtrn=$?
-        if [ $rtrn -eq 0 ]; then
-                success "startup"
-        else
-                failure "startup"
-        fi
-
-        # need the extra echo to properly terminate the line
-        echo
-        return $rtrn
+	if [ $rtrn -eq 0 ]; then
+		success "startup"
+	else
+		failure "startup"
+	fi
+
+	# need the extra echo to properly terminate the line
+	echo
+	return $rtrn
 }
 
 stop()
 {
-        echo -n "Stopping clustered mirror log server:"
+	echo -n "Stopping clustered mirror log server:"
 	killall cmirrord >& /dev/null
 	for ((i=0; $i < 10; i++)); do
-	    if ! ps -C cmirrord >& /dev/null; then
-		break;
-	    fi
-	    sleep 1
+		if ! ps -C cmirrord >& /dev/null; then
+			break;
+		fi
+		sleep 1
 	done
 
 	if [ $i -ge 10 ]; then
-	    failure "shutdown"
-	    echo
-	    return 1
+		failure "shutdown"
+		echo
+		return 1
 	else
-	    success "shutdown"
+		success "shutdown"
 	fi
 
 	echo
-        return $rtrn
+	return $rtrn
 }
 
 cmirror_status()
@@ -72,33 +72,33 @@
 
 # See how we were called.
 case "$1" in
-  start)
-        start
-        rtrn=$?
-        ;;
-
-  stop)
-        stop
-        rtrn=$?
-        ;;
-
-  restart)
-        $0 stop
-        $0 start
-        rtrn=$?
-        ;;
-
-  status)
-	cmirror_status
-        rtrn=$?
-	if [ $rtrn -eq 0 ]; then
-		echo "cmirror is running."
-	fi
-        ;;
-
-  *)
-        echo $"Usage: $0 {start|stop|restart|status}"
-        ;;
+	start)
+		start
+		rtrn=$?
+		;;
+
+	stop)
+		stop
+		rtrn=$?
+		;;
+
+	restart)
+		$0 stop
+		$0 start
+		rtrn=$?
+		;;
+
+	status)
+		cmirror_status
+		rtrn=$?
+		if [ $rtrn -eq 0 ]; then
+			echo "cmirror is running."
+		fi
+		;;
+
+	*)
+		echo $"Usage: $0 {start|stop|restart|status}"
+		;;
 esac
 
 exit $rtrn


