From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 8 Mar 2012 09:49:09 -0000
Subject: LVM2/scripts lvm2_lvmetad_systemd_red_hat.serv ...
Message-ID: <20120308094909.1478.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-08 09:49:09

Modified files:
	scripts        : lvm2_lvmetad_systemd_red_hat.service.in 

Log message:
	Add 'Restart: on-abort' for lvmetad systemd service.
	
	Restart lvmetad automatically if it exits due to reception of uncaught signal,
	leaving a track in systemd log/syslog.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in.diff?cvsroot=lvm2&r1=1.3&r2=1.4

--- LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in	2012/02/28 13:07:03	1.3
+++ LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in	2012/03/08 09:49:09	1.4
@@ -11,6 +11,7 @@
 ExecStart=@sbindir@/lvmetad
 ExecStartPost=@sbindir@/vgscan
 ExecReload=@sbindir@/lvmetad -R
+Restart=on-abort
 PIDFile=@DEFAULT_RUN_DIR@/lvmetad.pid
 
 [Install]


