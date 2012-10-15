From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Oct 2012 10:59:48 +0000 (UTC)
Subject: master - Remove pvscan --cache from lvm2-lvmetad init script.
Message-ID: <20121015105948.2409C25CA@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4dace48f51dce7a7473934f7f7ff8d74e478cd8f
Commit:        4dace48f51dce7a7473934f7f7ff8d74e478cd8f
Parent:        08ba1b447205913a1979143d9bf3b6afbdc5c742
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 15 12:58:23 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Oct 15 12:58:23 2012 +0200

Remove pvscan --cache from lvm2-lvmetad init script.

This is not needed anymore as the scan is called transparently
within the first LVM command that queries lvmetad.
---
 WHATS_NEW                            |    1 +
 scripts/lvm2_lvmetad_init_red_hat.in |    5 +----
 2 files changed, 2 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 179e52c..2780834 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -26,6 +26,7 @@ Version 2.02.98 -
   Allow non power of 2 thin chunk sizes if thin pool driver supports that.
   Allow limited metadata changes when PVs are missing via [vg|lv]change.
   Do not start dmeventd for lvchange --resync when monitoring is off.
+  Remove pvscan --cache from lvm2-lvmetad init script.
   Remove ExecStartPost with pvscan --cache from lvm2-lvmetad.service.
   Report invalid percentage for property snap_percent of non-snaphot LVs.
   Disallow convertion of thins to mirrors.
diff --git a/scripts/lvm2_lvmetad_init_red_hat.in b/scripts/lvm2_lvmetad_init_red_hat.in
index 888c730..08e920e 100644
--- a/scripts/lvm2_lvmetad_init_red_hat.in
+++ b/scripts/lvm2_lvmetad_init_red_hat.in
@@ -38,12 +38,9 @@ DAEMON=lvmetad
 exec_prefix=@exec_prefix@
 sbindir=@sbindir@
 
-lvm_pvscan="${sbindir}/lvm pvscan --cache"
-
 LOCK_FILE="/var/lock/subsys/$DAEMON"
 PID_FILE="@LVMETAD_PIDFILE@"
 
-
 rh_status() {
 	status -p $PID_FILE $DAEMON
 }
@@ -55,7 +52,7 @@ rh_status_q() {
 start()
 {
 	ret=0
-	action "Starting LVM metadata daemon:" $DAEMON && ${lvm_pvscan} > /dev/null || ret=$?
+	action "Starting LVM metadata daemon:" $DAEMON || ret=$?
 	return $ret
 }
 


