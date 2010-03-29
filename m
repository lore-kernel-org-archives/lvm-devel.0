From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2010 14:07:57 -0000
Subject: LVM2 Makefile.in
Message-ID: <20100329140757.17200.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-29 14:07:57

Modified files:
	.              : Makefile.in 

Log message:
	Use $(top_srcdir) for sources and add cscope.out to distclean targets.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/Makefile.in	2010/03/29 14:06:06	1.43
+++ LVM2/Makefile.in	2010/03/29 14:07:56	1.44
@@ -80,10 +80,11 @@
 endif
 
 ifneq ("@CSCOPE_CMD@", "")
-cscope.out: tools
-	@CSCOPE_CMD@ -b -R
+cscope.out:
+	@CSCOPE_CMD@ -b -R -s$(top_srcdir)
 all: cscope.out
 endif
+DISTCLEAN_TARGETS += cscope.out
 
 check: all
 	$(MAKE) -C test all


