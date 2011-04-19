From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Apr 2011 15:28:17 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20110419152817.12327.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-04-19 15:28:17

Modified files:
	test           : Makefile.in 

Log message:
	Always copy all tests to builddir regardless of T/S, since subsequent runs
	(possibly with different T or S) skip that step.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/test/Makefile.in	2011/01/17 15:18:10	1.53
+++ LVM2/test/Makefile.in	2011/04/19 15:28:17	1.54
@@ -29,6 +29,7 @@
 T ?= .
 S ?= @ # never match anything by default
 VERBOSE ?= 0
+ALL = $(shell find $(srcdir) \( -name t-\*.sh -or -path */api/\*.sh \) | sort)
 RUN = $(shell find $(srcdir) -regextype posix-egrep \( -name t-\*.sh -or -path */api/\*.sh \) -and -regex "$(srcdir)/.*($(T)).*" -and -not -regex "$(srcdir)/.*($(S)).*" | sort)
 RUN_BASE = $(shell echo $(RUN) | xargs -n 1 echo | sed -e s,^$(srcdir)/,,)
 
@@ -80,10 +81,10 @@
       lib/check lib/aux lib/test lib/utils lib/get lib/lvm-wrapper \
       lib/paths
 
-.tests-stamp: $(RUN) $(LIB)
+.tests-stamp: $(ALL) $(LIB)
 	@if test "$(srcdir)" != . ; then \
 	    echo "Copying tests to builddir."; \
-	    for f in $(RUN); do cp $$f `echo $$f | sed -e s,^$(srcdir)/,,`; done; \
+	    for f in $(ALL); do cp $$f `echo $$f | sed -e s,^$(srcdir)/,,`; done; \
 	fi
 	touch .tests-stamp
 


