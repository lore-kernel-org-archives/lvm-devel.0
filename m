From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 27 Feb 2015 14:39:02 +0000 (UTC)
Subject: master - initscripts: lvm2-monitor: implement status action
Message-ID: <20150227143902.78F9A602FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=57e9e76da4a678957e2db07a4b6b5f75385d4539
Commit:        57e9e76da4a678957e2db07a4b6b5f75385d4539
Parent:        379fb90b05b9fae0559fb697981198d8bb58e0f9
Author:        Jose Castillo <jcastillo@redhat.com>
AuthorDate:    Fri Feb 27 15:38:34 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Feb 27 15:38:34 2015 +0100

initscripts: lvm2-monitor: implement status action

Two new functions added in the init script: rh_status and rh_status_q.
First one to be used in status() and second one to be used in start(),
stop(), force_stop(). Check for 'dmeventd' added and print list of
lvs being monitored in status().
---
 WHATS_NEW                               |    1 +
 scripts/lvm2_monitoring_init_red_hat.in |   17 ++++++++++++++++-
 2 files changed, 17 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bc2630c..87ea7b6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Implement status action for lvm2-monitor initscript to display monitored LVs.
   Allow lvchange -p to change kernel state only if metadata state differs.
   Fix incorrect persistent .cache after report with label fields only (2.02.106).
   Reinstate PV tag recognition for pvs if reporting label fields only (2.02.105).
diff --git a/scripts/lvm2_monitoring_init_red_hat.in b/scripts/lvm2_monitoring_init_red_hat.in
index 44de07f..90b6edc 100644
--- a/scripts/lvm2_monitoring_init_red_hat.in
+++ b/scripts/lvm2_monitoring_init_red_hat.in
@@ -32,18 +32,28 @@
 . /etc/init.d/functions
 
 DAEMON=lvm2-monitor
+DMEVENTD_DAEMON=dmeventd
 
 exec_prefix=@exec_prefix@
 sbindir=@sbindir@
 
 VGCHANGE=${sbindir}/vgchange
 VGS=${sbindir}/vgs
+LVS=${sbindir}/lvs
 
 LOCK_FILE="/var/lock/subsys/$DAEMON"
+PID_FILE="/var/run/dmeventd.pid"
 
 WARN=1
 export LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1
 
+rh_status() {
+	status -p $PID_FILE $DMEVENTD_DAEMON
+}
+
+rh_status_q() {
+	rh_status >/dev/null 2>&1
+}
 start()
 {
 	ret=0
@@ -79,12 +89,14 @@ rtrn=1
 # See how we were called.
 case "$1" in
   start)
+	rh_status_q && exit 0
 	start
 	rtrn=$?
 	[ $rtrn = 0 ] && touch $LOCK_FILE
 	;;
 
   force-stop)
+	rh_status_q || exit 0
 	WARN=0
 	stop
 	rtrn=$?
@@ -92,6 +104,7 @@ case "$1" in
 	;;
 
   stop)
+	rh_status_q || exit 0
 	test "$runlevel" = "0" && WARN=0
 	test "$runlevel" = "6" && WARN=0
 	stop
@@ -109,7 +122,9 @@ case "$1" in
 	;;
 
   status)
-	# TODO anyone with an idea how to dump monitored volumes?
+	rh_status
+	rtrn=$?
+	[ $rtrn = 0 ] && $LVS -S 'seg_monitor=monitored' -o lv_full_name,seg_monitor
 	;;
 
   *)


