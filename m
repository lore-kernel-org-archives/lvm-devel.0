From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 28 Feb 2012 13:07:04 -0000
Subject: LVM2/scripts lvm2_lvmetad_systemd_red_hat.serv ...
Message-ID: <20120228130704.29500.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-28 13:07:03

Modified files:
	scripts        : lvm2_lvmetad_systemd_red_hat.service.in 

Log message:
	LVMetaD socket operates in non-blocking mode.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in	2012/02/23 13:31:49	1.2
+++ LVM2/scripts/lvm2_lvmetad_systemd_red_hat.service.in	2012/02/28 13:07:03	1.3
@@ -7,6 +7,7 @@
 
 [Service]
 Type=forking
+NonBlocking=true
 ExecStart=@sbindir@/lvmetad
 ExecStartPost=@sbindir@/vgscan
 ExecReload=@sbindir@/lvmetad -R


