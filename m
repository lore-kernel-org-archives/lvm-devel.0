From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Mar 2012 15:05:56 -0000
Subject: LVM2 Makefile.in
Message-ID: <20120312150556.11266.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-03-12 15:05:55

Modified files:
	.              : Makefile.in 

Log message:
	Add a toplevel check_lvmetad target.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.70&r2=1.71

--- LVM2/Makefile.in	2012/02/28 18:35:04	1.70
+++ LVM2/Makefile.in	2012/03/12 15:05:55	1.71
@@ -83,7 +83,7 @@
 endif
 DISTCLEAN_TARGETS += cscope.out
 
-check check_cluster check_local unit: all
+check check_cluster check_local check_lvmetad unit: all
 	$(MAKE) -C test $(@)
 
 install_system_dirs:


