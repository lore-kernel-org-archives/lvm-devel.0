From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Nov 2010 14:19:48 -0000
Subject: LVM2/include Makefile.in
Message-ID: <20101108141948.28165.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-11-08 14:19:48

Modified files:
	include        : Makefile.in 

Log message:
	Fix include commit and switch to use DISTCLEAN_TARGETS
	
	Fixing warning introduced by 'include make.tmpl' commit.
	Produced this warning:
	
	Makefile:29: warning: overriding commands for target `distclean'
	../make.tmpl:366: warning: ignoring old commands for target `distclean'

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/include/Makefile.in.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/include/Makefile.in	2010/11/05 16:10:08	1.15
+++ LVM2/include/Makefile.in	2010/11/08 14:19:48	1.16
@@ -25,12 +25,11 @@
 	for i in `cat $<`; do $(LN_S) $$i ; done
 	touch $@
 
-distclean:
-	find . -maxdepth 1 -type l -exec $(RM) \{\} \;
-	$(RM) Makefile .include_symlinks .symlinks_created .symlinks
-
 pofile: all
 
 device-mapper: all
 
 cflow: all
+
+DISTCLEAN_TARGETS += $(shell find . -maxdepth 1 -type l)
+DISTCLEAN_TARGETS += .include_symlinks .symlinks_created .symlinks


