From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 25 Oct 2017 16:04:57 -0400
Subject: master - scripts: paths update
Message-ID: <201710252004.v9PK4vHc029369@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=34618c2d3061e7f9f563d4c9ad9a185c77935f0e
Commit:        34618c2d3061e7f9f563d4c9ad9a185c77935f0e
Parent:        d809fbb541a63002214ed1d77914c7a4c7d02c60
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Oct 25 17:08:00 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 25 22:02:54 2017 +0200

scripts: paths update

Correct usage of sbindir also for scripts so the path
no longer needs resolving more vars like exec_prefix & prefix.
---
 scripts/blk_availability_init_red_hat.in      |    8 +++-----
 scripts/blkdeactivate.sh.in                   |   12 +++++++-----
 scripts/clvmd_init_red_hat.in                 |   10 +++++-----
 scripts/cmirrord_init_red_hat.in              |    6 ++++--
 scripts/lvm2_cluster_activation_red_hat.sh.in |    2 +-
 scripts/lvm2_lvmetad_init_red_hat.in          |    7 +++----
 scripts/lvm2_lvmpolld_init_red_hat.in         |    7 +++----
 scripts/lvm2_monitoring_init_red_hat.in       |   11 +++++------
 8 files changed, 31 insertions(+), 32 deletions(-)

diff --git a/scripts/blk_availability_init_red_hat.in b/scripts/blk_availability_init_red_hat.in
index 73d52ac..52399fb 100644
--- a/scripts/blk_availability_init_red_hat.in
+++ b/scripts/blk_availability_init_red_hat.in
@@ -31,14 +31,12 @@
 
 . /etc/init.d/functions
 
-sbindir=@sbindir@
 script=blkdeactivate
-options="-u -l wholevg -m disablequeueing -r wait"
-
-LOCK_FILE="/var/lock/subsys/blk-availability"
 
+sbindir=@SBINDIR@
+options="-u -l wholevg -m disablequeueing -r wait"
 
-rtrn=1
+LOCK_FILE="@DEFAULT_LOCK_DIR@/subsys/blk-availability"
 
 case "$1" in
   start)
diff --git a/scripts/blkdeactivate.sh.in b/scripts/blkdeactivate.sh.in
index daa53df..4680f16 100644
--- a/scripts/blkdeactivate.sh.in
+++ b/scripts/blkdeactivate.sh.in
@@ -31,14 +31,16 @@ shopt -s dotglob nullglob
 
 TOOL=blkdeactivate
 
-DEV_DIR='/dev'
-SYS_BLK_DIR='/sys/block'
+sbindir="@SBINDIR@"
+
+DEV_DIR="/dev"
+SYS_BLK_DIR="/sys/block"
 
 MOUNTPOINT="/bin/mountpoint"
 UMOUNT="/bin/umount"
-DMSETUP="@sbindir@/dmsetup"
-LVM="@sbindir@/lvm"
-MDADM="@sbindir@/mdadm"
+DMSETUP="$sbindir/dmsetup"
+LVM="$sbindir/lvm"
+MDADM="$sbindir/mdadm"
 MPATHD="/sbin/multipathd"
 
 if "$UMOUNT" --help | grep -- "--all-targets" >"$DEV_DIR/null"; then
diff --git a/scripts/clvmd_init_red_hat.in b/scripts/clvmd_init_red_hat.in
index d7f3392..e5fbe04 100644
--- a/scripts/clvmd_init_red_hat.in
+++ b/scripts/clvmd_init_red_hat.in
@@ -20,8 +20,8 @@
 
 DAEMON=clvmd
 
-exec_prefix=@exec_prefix@
-sbindir=@sbindir@
+sbindir="@SBINDIR@"
+usrsbindir="@USRSBINDIR@"
 
 lvm_vgchange=${sbindir}/vgchange
 lvm_vgs=${sbindir}/vgs
@@ -62,7 +62,7 @@ start()
 {
 	if ! rh_status_q; then
 		echo -n "Starting $DAEMON: "
-		$DAEMON $CLVMDOPTS || return $?
+		"$usrsbindir/$DAEMON" $CLVMDOPTS || return $?
 		echo
 	fi
 
@@ -138,7 +138,7 @@ stop()
 
 reload() {
 	rh_status_q || exit 7
-	action "Reloading $DAEMON configuration: " $DAEMON -R || return $?
+	action "Reloading $DAEMON configuration: " "$usrsbindir/$DAEMON" -R || return $?
 }
 
 restart() {
@@ -149,7 +149,7 @@ restart() {
 
 	# Try to get clvmd to restart itself. This will preserve 
 	# exclusive LV locks
-	action "Restarting $DAEMON: " $DAEMON -S
+	action "Restarting $DAEMON: " "$usrsbindir/$DAEMON" -S
 
 	# If that fails then do a normal stop & restart
 	if  [ $? != 0 ]; then
diff --git a/scripts/cmirrord_init_red_hat.in b/scripts/cmirrord_init_red_hat.in
index d4b7e37..7b1df06 100755
--- a/scripts/cmirrord_init_red_hat.in
+++ b/scripts/cmirrord_init_red_hat.in
@@ -18,7 +18,9 @@
 
 DAEMON=cmirrord
 
-LOCK_FILE="/var/lock/subsys/$DAEMON"
+usrsbindir="@USRSBINDIR@"
+
+LOCK_FILE="@DEFAULT_SYS_LOCK_DIR@/subsys/$DAEMON"
 
 start()
 {
@@ -26,7 +28,7 @@ start()
 	if ! pidof $DAEMON > /dev/null 
 	then 
 		echo -n "Starting $DAEMON: "
-		daemon $DAEMON
+		daemon "$usrsbindir/$DAEMON"
 		rtrn=$?
 		echo
 	fi
diff --git a/scripts/lvm2_cluster_activation_red_hat.sh.in b/scripts/lvm2_cluster_activation_red_hat.sh.in
index 04d2cc6..6dacf91 100644
--- a/scripts/lvm2_cluster_activation_red_hat.sh.in
+++ b/scripts/lvm2_cluster_activation_red_hat.sh.in
@@ -1,6 +1,6 @@
 #!/bin/bash
 
-sbindir=@sbindir@
+sbindir="@SBINDIR@"
 
 lvm_vgchange="${sbindir}/vgchange"
 lvm_vgscan="${sbindir}/vgscan"
diff --git a/scripts/lvm2_lvmetad_init_red_hat.in b/scripts/lvm2_lvmetad_init_red_hat.in
index b2f5d50..9a6c4f8 100644
--- a/scripts/lvm2_lvmetad_init_red_hat.in
+++ b/scripts/lvm2_lvmetad_init_red_hat.in
@@ -35,10 +35,9 @@
 
 DAEMON=lvmetad
 
-exec_prefix=@exec_prefix@
-sbindir=@sbindir@
+sbindir="@SBINDIR@"
 
-LOCK_FILE="/var/lock/subsys/$DAEMON"
+LOCK_FILE="@DEFAULT_SYS_LOCK_DIR@/subsys/$DAEMON"
 PID_FILE="@LVMETAD_PIDFILE@"
 
 rh_status() {
@@ -52,7 +51,7 @@ rh_status_q() {
 start()
 {
 	ret=0
-	action "Starting LVM metadata daemon:" $DAEMON || ret=$?
+	action "Starting LVM metadata daemon:" "$sbindir/$DAEMON" || ret=$?
 	return $ret
 }
 
diff --git a/scripts/lvm2_lvmpolld_init_red_hat.in b/scripts/lvm2_lvmpolld_init_red_hat.in
index c521955..05f8b08 100644
--- a/scripts/lvm2_lvmpolld_init_red_hat.in
+++ b/scripts/lvm2_lvmpolld_init_red_hat.in
@@ -37,10 +37,9 @@
 
 DAEMON=lvmpolld
 
-exec_prefix=@exec_prefix@
-sbindir=@sbindir@
+sbindir="@SBINDIR@"
 
-LOCK_FILE="/var/lock/subsys/$DAEMON"
+LOCK_FILE="@DEFAULT_LOCK_DIR@/subsys/$DAEMON"
 PID_FILE="@LVMPOLLD_PIDFILE@"
 
 rh_status() {
@@ -54,7 +53,7 @@ rh_status_q() {
 start()
 {
 	ret=0
-	action "Starting LVM poll daemon:" $DAEMON || ret=$?
+	action "Starting LVM poll daemon:" "$sbindir/$DAEMON" || ret=$?
 	return $ret
 }
 
diff --git a/scripts/lvm2_monitoring_init_red_hat.in b/scripts/lvm2_monitoring_init_red_hat.in
index de7ff0d..3b0d542 100644
--- a/scripts/lvm2_monitoring_init_red_hat.in
+++ b/scripts/lvm2_monitoring_init_red_hat.in
@@ -34,14 +34,13 @@
 DAEMON=lvm2-monitor
 DMEVENTD_DAEMON=dmeventd
 
-exec_prefix=@exec_prefix@
-sbindir=@sbindir@
+sbindir=@SBINDIR@
 
-VGCHANGE=${sbindir}/vgchange
-VGS=${sbindir}/vgs
-LVS=${sbindir}/lvs
+VGCHANGE="$sbindir/vgchange"
+VGS="$sbindir/vgs"
+LVS="$sbindir/lvs"
 
-LOCK_FILE="/var/lock/subsys/$DAEMON"
+LOCK_FILE="@DEFAULT_SYS_LOCK_DIR@/subsys/$DAEMON"
 PID_FILE="@DMEVENTD_PIDFILE@"
 
 WARN=1


