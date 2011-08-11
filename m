From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 11 Aug 2011 15:27:47 -0000
Subject: LVM2 ./WHATS_NEW lib/locking/locking.c scripts ...
Message-ID: <20110811152747.2052.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-08-11 15:27:47

Modified files:
	.              : WHATS_NEW 
	lib/locking    : locking.c 
	scripts        : lvm2_monitoring_init_red_hat.in 
	                 lvm2_monitoring_systemd_red_hat.service.in 

Log message:
	Suppress locking error messages in monitoring init scripts.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2062&r2=1.2063
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/locking/locking.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_init_red_hat.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_monitoring_systemd_red_hat.service.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2011/08/11 12:57:10	1.2062
+++ LVM2/WHATS_NEW	2011/08/11 15:27:46	1.2063
@@ -1,5 +1,6 @@
 Version 2.02.87 - 
 ===============================
+  Suppress locking error messages in monitoring init scripts.
   If pipe in clvmd fails, return busy instead of using uninitialised descriptors.
   Add dmeventd monitoring shared library for RAID.
   Add RAID metadata devices to considered devices in _add_lv_to_dtree.
--- LVM2/lib/locking/locking.c	2011/08/10 16:07:54	1.97
+++ LVM2/lib/locking/locking.c	2011/08/11 15:27:46	1.98
@@ -221,7 +221,7 @@
  */
 int init_locking(int type, struct cmd_context *cmd, int suppress_messages)
 {
-	if (ignorelockingfailure() && getenv("LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES"))
+	if (getenv("LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES"))
 		suppress_messages = 1;
 
 	if (type < 0)
--- LVM2/scripts/lvm2_monitoring_init_red_hat.in	2010/04/15 19:15:04	1.4
+++ LVM2/scripts/lvm2_monitoring_init_red_hat.in	2011/08/11 15:27:46	1.5
@@ -42,6 +42,7 @@
 LOCK_FILE="/var/lock/subsys/$DAEMON"
 
 WARN=1
+export LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1
 
 start()
 {
--- LVM2/scripts/lvm2_monitoring_systemd_red_hat.service.in	2011/07/28 12:54:28	1.1
+++ LVM2/scripts/lvm2_monitoring_systemd_red_hat.service.in	2011/08/11 15:27:46	1.2
@@ -8,6 +8,7 @@
 
 [Service]
 Type=oneshot
+Environment=LVM_SUPPRESS_LOCKING_FAILURE_MESSAGES=1
 ExecStart=@sbindir@/lvm vgchange --monitor y
 ExecStop=@sbindir@/lvm vgchange --monitor n
 RemainAfterExit=yes


