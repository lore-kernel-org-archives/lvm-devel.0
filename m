From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 12 Aug 2011 07:57:24 -0000
Subject: LVM2 make.tmpl.in
Message-ID: <20110812075724.31653.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-08-12 07:57:24

Modified files:
	.              : make.tmpl.in 

Log message:
	Do not remove makefile during "make clean".

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.120&r2=1.121

--- LVM2/make.tmpl.in	2011/08/11 19:18:18	1.120
+++ LVM2/make.tmpl.in	2011/08/12 07:57:24	1.121
@@ -364,7 +364,7 @@
 	$(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(CLEAN_CFLOW) $(LDDEPS) \
 	  $(POTFILES) $(SOURCES:%.c=%.d) $(SOURCES:%.c=%.gcno) $(SOURCES:%.c=%.gcda) \
 	  $(SOURCES2:%.c=%.o) $(SOURCES2:%.c=%.d) $(SOURCES2:%.c=%.gcno) $(SOURCES2:%.c=%.gcda) \
-	  .exported_symbols_generated Makefile core
+	  .exported_symbols_generated core
 
 clean: $(SUBDIRS.clean) cleandir
 


