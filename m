From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 4 Mar 2010 09:53:09 -0000
Subject: LVM2 ./WHATS_NEW ./make.tmpl.in tools/Makefile.in
Message-ID: <20100304095309.22953.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-03-04 09:53:08

Modified files:
	.              : WHATS_NEW make.tmpl.in 
	tools          : Makefile.in 

Log message:
	Replace CFLOW_CMD only in make.tmpl and use it as variable elsewhere.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1445&r2=1.1446
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.76&r2=1.77
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.104&r2=1.105

--- LVM2/WHATS_NEW	2010/03/04 09:51:37	1.1445
+++ LVM2/WHATS_NEW	2010/03/04 09:53:08	1.1446
@@ -1,5 +1,6 @@
 Version 2.02.62 -
 ====================================
+  Replace CFLOW_CMD only in make.tmpl and use it as variable elsewhere.
   Use $(top_builddir) for inclusion of make.tmpl in Makefiles.
   Fix autoconf warning about ignored datarootdir.
   Increase AC_PREREQ version to 2.61 (for AC_PROC_SED, AC_PROG_MKDIR_P).
--- LVM2/make.tmpl.in	2010/03/04 09:48:19	1.76
+++ LVM2/make.tmpl.in	2010/03/04 09:53:08	1.77
@@ -27,6 +27,7 @@
 GENHTML = @GENHTML@
 LN_S = @LN_S@
 SED = @SED@
+CFLOW_CMD = @CFLOW_CMD@
 
 LIBS = @LIBS@
 DEFS += @DEFS@
--- LVM2/tools/Makefile.in	2010/03/04 09:51:42	1.104
+++ LVM2/tools/Makefile.in	2010/03/04 09:53:08	1.105
@@ -147,20 +147,20 @@
 .PHONY: install_cmdlib_dynamic install_cmdlib_static \
 	install_tools_dynamic install_tools_static
 
-ifneq ("@CFLOW_CMD@", "")
+ifneq ("$(CFLOW_CMD)", "")
 CFLOW_FLAGS += --cpp="$(CC) -E"
 .PHONY: lvm.cflow
 -include $(top_srcdir)/lib/liblvm-internal.cflow
 lvm.cflow: $(SOURCES)
-	@CFLOW_CMD@ -o$@ $(CFLOW_FLAGS) $(INCLUDES) $(DEFS) $(SOURCES)
+	$(CFLOW_CMD) -o$@ $(CFLOW_FLAGS) $(INCLUDES) $(DEFS) $(SOURCES)
 lvm.rxref: $(SOURCES)
-	@CFLOW_CMD@ -o$@ --cpp="$(CC) -E" -r --omit-arguments -x $(INCLUDES) $(DEFS) $(SOURCES)
+	$(CFLOW_CMD) -o$@ --cpp="$(CC) -E" -r --omit-arguments -x $(INCLUDES) $(DEFS) $(SOURCES)
 lvm.xref: $(SOURCES)
-	@CFLOW_CMD@ -o$@ --cpp="$(CC) -E" --omit-arguments -x $(INCLUDES) $(DEFS) $(SOURCES)
+	$(CFLOW_CMD) -o$@ --cpp="$(CC) -E" --omit-arguments -x $(INCLUDES) $(DEFS) $(SOURCES)
 lvm.rtree: $(SOURCES)
-	@CFLOW_CMD@ -o$@ --cpp="$(CC) -E" -r --omit-arguments -T -b $(INCLUDES) $(DEFS) $(SOURCES)
+	$(CFLOW_CMD) -o$@ --cpp="$(CC) -E" -r --omit-arguments -T -b $(INCLUDES) $(DEFS) $(SOURCES)
 lvm.tree: $(SOURCES)
-	@CFLOW_CMD@ -o$@ --cpp="$(CC) -E" --omit-arguments -T -b $(INCLUDES) $(DEFS) $(SOURCES)
+	$(CFLOW_CMD) -o$@ --cpp="$(CC) -E" --omit-arguments -T -b $(INCLUDES) $(DEFS) $(SOURCES)
 cflow: lvm.cflow lvm.xref lvm.tree lvm.rtree lvm.rxref
 endif
 


