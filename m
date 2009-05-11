From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 11 May 2009 10:35:01 -0000
Subject: LVM2/scripts Makefile.in
Message-ID: <20090511103501.24811.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-05-11 10:35:01

Modified files:
	scripts        : Makefile.in 

Log message:
	Fix previous commit (scripts/Makefile targets order)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/Makefile.in.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/scripts/Makefile.in	2009/05/11 10:28:46	1.7
+++ LVM2/scripts/Makefile.in	2009/05/11 10:35:00	1.8
@@ -17,8 +17,6 @@
 
 include $(top_srcdir)/make.tmpl
 
-install_lvm2: install
-
 install:
 	$(INSTALL) -D $(OWNER) $(GROUP) -m 555 $(STRIP) lvm_dump.sh \
 		$(sbindir)/lvmdump
@@ -27,4 +25,6 @@
 		$(sbindir)/fsadm
 endif
 
+install_lvm2: install
+
 DISTCLEAN_TARGETS += clvmd_init_red_hat


