From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Apr 2010 09:15:39 -0000
Subject: LVM2 make.tmpl.in
Message-ID: <20100408091539.5924.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-04-08 09:15:38

Modified files:
	.              : make.tmpl.in 

Log message:
	Add cleandir target.
	
	Using non-recursive cleandir target for resursive distclean and clean.
	Avoids duplicated clean invocation during distclean.
	Indent $(RM) parameters.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.87&r2=1.88

--- LVM2/make.tmpl.in	2010/04/06 09:54:11	1.87
+++ LVM2/make.tmpl.in	2010/04/08 09:15:37	1.88
@@ -144,8 +144,8 @@
 OBJECTS = $(SOURCES:%.c=%.o)
 POTFILES = $(SOURCES:%.c=%.pot)
 
-.PHONY: all install install_cluster pofile distclean clean cflow device-mapper 
-.PHONY: install_device-mapper install_lvm2
+.PHONY: all pofile distclean clean cleandir cflow device-mapper
+.PHONY: install install_cluster install_device-mapper install_lvm2
 .PHONY: $(SUBDIRS) $(SUBDIRS.install) $(SUBDIRS.clean) $(SUBDIRS.distclean)
 .PHONY: $(SUBDIRS.pofile) $(SUBDIRS.install_cluster) $(SUBDIRS.cflow)
 .PHONY: $(SUBDIRS.device-mapper) $(SUBDIRS.install-device-mapper)
@@ -300,12 +300,14 @@
 %.mo: %.po
 	$(MSGFMT) -o $@ $<
 
-clean: $(SUBDIRS.clean)
+cleandir:
 	$(RM) $(OBJECTS) $(TARGETS) $(CLEAN_TARGETS) $(CLEAN_CFLOW) $(LDDEPS) \
-	$(POTFILES) $(SOURCES:%.c=%.d) $(SOURCES:%.c=%.gcno) $(SOURCES:%.c=%.gcda) \
-	$(SOURCES2:%.c=%.o) $(SOURCES2:%.c=%.d) $(SOURCES2:%.c=%.gcno) $(SOURCES2:%.c=%.gcda)
+	  $(POTFILES) $(SOURCES:%.c=%.d) $(SOURCES:%.c=%.gcno) $(SOURCES:%.c=%.gcda) \
+	  $(SOURCES2:%.c=%.o) $(SOURCES2:%.c=%.d) $(SOURCES2:%.c=%.gcno) $(SOURCES2:%.c=%.gcda)
 
-distclean: clean $(SUBDIRS.distclean)
+clean: $(SUBDIRS.clean) cleandir
+
+distclean: cleandir $(SUBDIRS.distclean)
 	test -z "$(DISTCLEAN_DIRS)" || $(RM) -r $(DISTCLEAN_DIRS)
 	$(RM) $(DISTCLEAN_TARGETS) Makefile core
 


