From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 22 Feb 2012 18:02:32 -0000
Subject: LVM2/scripts lvm2_tmpfiles_red_hat.conf.in
Message-ID: <20120222180232.32367.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-22 18:02:32

Added files:
	scripts        : lvm2_tmpfiles_red_hat.conf.in 

Log message:
	Add lvm2 tmpfiles.d configuration file.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_tmpfiles_red_hat.conf.in.diff?cvsroot=lvm2&r1=NONE&r2=1.1

/cvs/lvm2/LVM2/scripts/lvm2_tmpfiles_red_hat.conf.in,v  -->  standard output
revision 1.1
--- LVM2/scripts/lvm2_tmpfiles_red_hat.conf.in
+++ -	2012-02-22 18:02:32.476785000 +0000
@@ -0,0 +1,2 @@
+D @DEFAULT_LOCK_DIR@ 0700 root root -
+D @DEFAULT_RUN_DIR@ 0700 root root -


