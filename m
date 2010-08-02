From: agk@sourceware.org <agk@sourceware.org>
Date: 2 Aug 2010 12:44:22 -0000
Subject: LVM2 WHATS_NEW make.tmpl.in
Message-ID: <20100802124422.12019.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-08-02 12:44:21

Modified files:
	.              : WHATS_NEW make.tmpl.in 

Log message:
	Fix exported_symbols generation to use standard compiler arguments.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1682&r2=1.1683
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.107&r2=1.108

--- LVM2/WHATS_NEW	2010/08/02 12:23:01	1.1682
+++ LVM2/WHATS_NEW	2010/08/02 12:44:21	1.1683
@@ -1,5 +1,6 @@
 Version 2.02.73 - 
 ================================
+  Fix exported_symbols generation to use standard compiler arguments.
   Use #include <> not "" in lvm2app.h which gets installed on the system.
   Make liblvm.device-mapper wait for include file generation.
   Drop explicit 'Base' version from exported symbols.
--- LVM2/make.tmpl.in	2010/07/31 14:13:59	1.107
+++ LVM2/make.tmpl.in	2010/08/02 12:44:21	1.108
@@ -360,7 +360,7 @@
 	set -e; \
 	( cat $(srcdir)/.exported_symbols; \
 	  if test x$(EXPORTED_HEADER) != x; then \
-        	$(CC) -E -P $(EXPORTED_HEADER) | \
+        	$(CC) -E -P $(INCLUDES) $(DEFS) $(CFLAGS) $(EXPORTED_HEADER) | \
         	$(SED) -ne "/^typedef|}/!s/.*[ \*]\(\$(EXPORTED_FN_PREFIX)_[a-z0-9_]*\)(.*/\1/p"; \
 	  fi \
 	) > $@


