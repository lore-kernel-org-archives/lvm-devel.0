From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 16 Mar 2012 15:12:05 -0000
Subject: LVM2/scripts lvm2_lvmetad_init_red_hat.in lvm2 ...
Message-ID: <20120316151205.12667.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-16 15:12:04

Modified files:
	scripts        : lvm2_lvmetad_init_red_hat.in 
	                 lvm2_lvmetad_systemd_red_hat.service.in 

Log message:
	Use pvscan --cache instead of vgscan in lvmetad init script and systemd unit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_lvmetad_init_red_hat.in.diff?cvsroot=lvm2&r1=1.4&r2=1.5
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/scripts/lvm2_lvmetad_init_red_hat.in	2012/02/27 08:56:46	1.4
+++ LVM2/scripts/lvm2_lvmetad_init_red_hat.in	2012/03/16 15:12:04	1.5
@@ -38,7 +38,7 @@
 exec_prefix=@exec_prefix@
 sbindir=@sbindir@
 
-lvm_vgscan=${sbindir}/vgscan
+lvm_pvscan="${sbindir}/lvm pvscan --cache"
 
 LOCK_FILE="/var/lock/subsys/$DAEMON"
 PID_FILE="@DEFAULT_RUN_DIR@/${DAEMON}.pid"
@@ -55,7 +55,7 @@
 start()
 {
 	ret=0
-	action "Starting LVM metadata daemon:" $DAEMON && ${lvm_vgscan} || ret=$?
+	action "Starting LVM metadata daemon:" $DAEMON && ${lvm_pvscan} > /dev/null || ret=$?
 	return $ret
 }
 
--- LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in	2012/03/14 15:51:52	1.5
+++ LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in	2012/03/16 15:12:04	1.6
@@ -9,7 +9,7 @@
 Type=forking
 NonBlocking=true
 ExecStart=@sbindir@/lvmetad
-ExecStartPost=@sbindir@/vgscan
+ExecStartPost=@sbindir@/lvm pvscan --cache
 ExecReload=@sbindir@/lvmetad -R
 Environment=SD_ACTIVATION=1
 Restart=on-abort


