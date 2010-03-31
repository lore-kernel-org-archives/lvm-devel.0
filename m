From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 31 Mar 2010 07:40:22 -0000
Subject: LVM2/udev Makefile.in
Message-ID: <20100331074022.6640.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-31 07:40:21

Modified files:
	udev           : Makefile.in 

Log message:
	Install generated 10-dm.rules from builddir.
	
	Patch just check whether file is generated in builddir otherwise srcdir file
	is used.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/Makefile.in.diff?cvsroot=lvm2&r1=1.5&r2=1.6

--- LVM2/udev/Makefile.in	2010/03/04 09:51:42	1.5
+++ LVM2/udev/Makefile.in	2010/03/31 07:40:20	1.6
@@ -40,7 +40,8 @@
 	@for f in $(DM_RULES); \
 	do \
 	   $(RM) $(udevdir)/$$f; \
-	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $(srcdir)/$$f $(udevdir)/$$f; \
+	   if test -f $$f; then file=$$f; else file=$(srcdir)/$$f; fi; \
+	   $(INSTALL) -c -D $(OWNER) $(GROUP) -m 644 $$file $(udevdir)/$$f; \
 	done
 
 install: install_lvm2 install_device-mapper


