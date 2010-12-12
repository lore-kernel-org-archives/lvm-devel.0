From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 12 Dec 2010 21:17:25 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20101212211725.27076.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-12-12 21:17:25

Modified files:
	test           : Makefile.in 

Log message:
	Fix the sed expression to get "base" names of tests.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/test/Makefile.in	2010/12/12 21:08:00	1.46
+++ LVM2/test/Makefile.in	2010/12/12 21:17:25	1.47
@@ -29,7 +29,7 @@
 S ?= @ # never match anything by default
 VERBOSE ?= 0
 RUN = $(shell find $(srcdir) -regextype posix-egrep \( -name t-\*.sh -or -path */api/\*.sh \) -and -regex "$(srcdir)/.*($(T)).*" -and -not -regex "$(srcdir)/.*($(S)).*" | sort)
-RUN_BASE = $(shell echo $(RUN) | sed -e s,$(srcdir)/,,g)
+RUN_BASE = $(shell echo $(RUN) | sed -e s,^$(srcdir)/,,)
 
 # Shell quote;
 SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))


