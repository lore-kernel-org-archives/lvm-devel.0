From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 23 Feb 2012 14:24:31 -0000
Subject: LVM2/scripts lvm2_tmpfiles_red_hat.conf.in
Message-ID: <20120223142431.10525.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-02-23 14:24:30

Modified files:
	scripts        : lvm2_tmpfiles_red_hat.conf.in 

Log message:
	Use 'd' instead of 'D' in tmpfiles configuration to not overwrite any existing directory.
	
	...that happens when systemd creates it first (e.g. based on a .socket unit)
	before the tmpfiles.d content is executed.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/lvm2_tmpfiles_red_hat.conf.in.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/scripts/lvm2_tmpfiles_red_hat.conf.in	2012/02/22 18:02:31	1.1
+++ LVM2/scripts/lvm2_tmpfiles_red_hat.conf.in	2012/02/23 14:24:30	1.2
@@ -1,2 +1,2 @@
-D @DEFAULT_LOCK_DIR@ 0700 root root -
-D @DEFAULT_RUN_DIR@ 0700 root root -
+d @DEFAULT_LOCK_DIR@ 0700 root root -
+d @DEFAULT_RUN_DIR@ 0700 root root -


