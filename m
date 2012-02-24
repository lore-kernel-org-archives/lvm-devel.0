From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 24 Feb 2012 15:07:01 -0000
Subject: LVM2/scripts Makefile.in
Message-ID: <20120224150701.5639.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-24 15:07:01

Modified files:
	scripts        : Makefile.in 

Log message:
	Also remove intermediate lvmetad init script file.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.28&r2=1.29

--- LVM2/scripts/Makefile.in	2012/02/24 13:03:50	1.28
+++ LVM2/scripts/Makefile.in	2012/02/24 15:07:00	1.29
@@ -78,4 +78,4 @@
 DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat lvm2_monitoring_init_red_hat \
 		     dm_event_systemd_red_hat.service lvm2_monitoring_systemd_red_hat.service \
 		     lvm2_lvmetad_systemd_red_hat.socket lvm2_lvmetad_systemd_red_hat.service \
-		     lvm2_tmpfiles_red_hat.conf
+		     lvm2_lvmetad_init_red_hat lvm2_tmpfiles_red_hat.conf


