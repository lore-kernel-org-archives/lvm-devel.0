From: Milan Broz <mbroz@redhat.com>
Date: Wed, 26 May 2010 15:01:06 +0200
Subject: [PATCH] fix some issues in clvmd initscript
Message-ID: <4BFD1B92.9080403@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

- if daemon is already running, do nothing (and not reactivate VGs)

- always explicitly return exit code in reload()

- fix restart() so it really tries full start & stop and returns exit code
  if clvmd -S fails and also touch lockfile afterwards

--- clvmd.old	2010-05-26 14:21:15.000000000 +0200
+++ clvmd	2010-05-26 14:55:17.671245376 +0200
@@ -63,11 +63,12 @@ rh_status_q() {
 
 start()
 {
-	if ! rh_status_q; then
-		echo -n "Starting $DAEMON: "
-		daemon $DAEMON $CLVMDOPTS || return $?
-		echo
-	fi
+
+	rh_status_q && return 0
+
+	echo -n "Starting $DAEMON: "
+	daemon $DAEMON $CLVMDOPTS || return $?
+	echo
 
 	# Refresh local cache.
 	#
@@ -141,7 +142,8 @@ stop()
 
 reload() {
 	rh_status_q || exit 7
-	action "Reloading $DAEMON configuration: " $DAEMON -R || return $?
+	action "Reloading $DAEMON configuration: " $DAEMON -R
+	return $?
 }
 
 restart() {
@@ -152,13 +154,15 @@ restart() {
 
 	# Try to get clvmd to restart itself. This will preserve 
 	# exclusive LV locks
-	action "Restarting $DAEMON: " $DAEMON -S || return $?
+	action "Restarting $DAEMON: " $DAEMON -S
 
 	# If that fails then do a normal stop & restart
 	if  [ $? != 0 ]; then
 	    stop && start
+	    return $?
 	else
 	    touch $LOCK_FILE
+	    return 0
 	fi
 }
 



