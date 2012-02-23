From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 23 Feb 2012 10:01:13 -0000
Subject: LVM2 scripts/Makefile.in udev/Makefile.in
Message-ID: <20120223100113.15287.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-23 10:01:12

Modified files:
	scripts        : Makefile.in 
	udev           : Makefile.in 

Log message:
	Clean intermediate files.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.23&r2=1.24
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/Makefile.in.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/scripts/Makefile.in	2012/02/22 17:55:11	1.23
+++ LVM2/scripts/Makefile.in	2012/02/23 10:01:12	1.24
@@ -65,4 +65,5 @@
 	$(INSTALL_DATA) lvm2_tmpfiles_red_hat.conf $(tmpfiles_dir)/lvm2.conf
 
 DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat lvm2_monitoring_init_red_hat \
-		     dm_event_systemd_red_hat.service lvm2_monitoring_systemd_red_hat.service
+		     dm_event_systemd_red_hat.service lvm2_monitoring_systemd_red_hat.service \
+		     lvm2_tmpfiles_red_hat.conf
--- LVM2/udev/Makefile.in	2012/02/20 19:38:40	1.9
+++ LVM2/udev/Makefile.in	2012/02/23 10:01:12	1.10
@@ -25,7 +25,7 @@
 	BLKID_RULE=IMPORT{program}=\"\$$env{DM_SBIN_PATH}\/blkid -o udev -p \$$tempnode\"
 endif
 
-CLEAN_TARGETS=10-dm.rules
+CLEAN_TARGETS = 10-dm.rules 13-dm-disk.rules
 
 include $(top_builddir)/make.tmpl
 


