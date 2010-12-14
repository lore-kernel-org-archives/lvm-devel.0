From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 14 Dec 2010 17:38:44 -0000
Subject: LVM2/test Makefile.in
Message-ID: <20101214173844.18697.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2010-12-14 17:38:42

Modified files:
	test           : Makefile.in 

Log message:
	Hack up the RUN_BASE computation in the test Makefile.in a bit more (so that it
	actually works... sometimes).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/test/Makefile.in	2010/12/12 21:17:25	1.47
+++ LVM2/test/Makefile.in	2010/12/14 17:38:42	1.48
@@ -29,7 +29,7 @@
 S ?= @ # never match anything by default
 VERBOSE ?= 0
 RUN = $(shell find $(srcdir) -regextype posix-egrep \( -name t-\*.sh -or -path */api/\*.sh \) -and -regex "$(srcdir)/.*($(T)).*" -and -not -regex "$(srcdir)/.*($(S)).*" | sort)
-RUN_BASE = $(shell echo $(RUN) | sed -e s,^$(srcdir)/,,)
+RUN_BASE = $(shell echo $(RUN) | xargs -n 1 echo | sed -e s,^$(srcdir)/,,)
 
 # Shell quote;
 SHELL_PATH_SQ = $(subst ','\'',$(SHELL_PATH))


