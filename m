From: agk@sourceware.org <agk@sourceware.org>
Date: 12 Aug 2011 12:56:39 -0000
Subject: LVM2 make.tmpl.in
Message-ID: <20110812125639.12212.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-12 12:56:38

Modified files:
	.              : make.tmpl.in 

Log message:
	core removed with clean not distclean

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.121&r2=1.122

--- LVM2/make.tmpl.in	2011/08/12 07:57:24	1.121
+++ LVM2/make.tmpl.in	2011/08/12 12:56:38	1.122
@@ -370,7 +370,7 @@
 
 distclean: cleandir $(SUBDIRS.distclean)
 	test -z "$(DISTCLEAN_DIRS)" || $(RM) -r $(DISTCLEAN_DIRS)
-	$(RM) $(DISTCLEAN_TARGETS) Makefile core
+	$(RM) $(DISTCLEAN_TARGETS) Makefile 
 
 .exported_symbols_generated: $(EXPORTED_HEADER) .exported_symbols
 	set -e; \


