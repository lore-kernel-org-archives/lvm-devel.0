From: agk@sourceware.org <agk@sourceware.org>
Date: 26 Mar 2012 23:23:32 -0000
Subject: LVM2 Makefile.in
Message-ID: <20120326232332.31822.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-03-26 23:23:32

Modified files:
	.              : Makefile.in 

Log message:
	add make install_verity

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/Makefile.in.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/Makefile.in	2012/03/26 23:09:37	1.73
+++ LVM2/Makefile.in	2012/03/26 23:23:31	1.74
@@ -109,6 +109,10 @@
 install_tmpfiles_configuration:
 	$(MAKE) -C scripts install_tmpfiles_configuration
 
+install_verity:
+	$(MAKE) -C verity install_verity
+	$(MAKE) -C man install_verity
+
 LCOV_TRACES = libdm.info lib.info tools.info \
 	daemons/dmeventd.info daemons/clvmd.info
 CLEAN_TARGETS += $(LCOV_TRACES)


