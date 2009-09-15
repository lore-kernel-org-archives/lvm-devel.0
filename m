From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Sep 2009 15:37:13 -0000
Subject: LVM2 Makefile.in
Message-ID: <20090915153713.32111.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-15 15:37:13

Modified files:
	.              : Makefile.in 

Log message:
	Remove test/api which should only be under 'make test'.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.37&r2=1.38

--- LVM2/Makefile.in	2009/09/04 12:54:23	1.37
+++ LVM2/Makefile.in	2009/09/15 15:37:12	1.38
@@ -30,7 +30,6 @@
 
 ifeq ("@APPLIB@", "yes")
   SUBDIRS += liblvm
-  SUBDIRS += test/api
 endif
 
 ifeq ($(MAKECMDGOALS),distclean)


