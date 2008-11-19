From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Nov 2008 19:33:31 -0000
Subject: LVM2 ./WHATS_NEW ./configure.in scripts/clvmd_ ...
Message-ID: <20081119193331.20438.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-11-19 19:33:28

Modified files:
	.              : WHATS_NEW configure.in 
Removed files:
	scripts        : clvmd_init clvmd_init_rhel4 

Log message:
	Generate clvmd init script at configuration time for Red Hat-based distros.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.997&r2=1.998
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/configure.in.diff?cvsroot=lvm2&r1=1.89&r2=1.90
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init.diff?cvsroot=lvm2&r1=1.1&r2=NONE
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/clvmd_init_rhel4.diff?cvsroot=lvm2&r1=1.12&r2=NONE

--- LVM2/WHATS_NEW	2008/11/19 14:14:52	1.997
+++ LVM2/WHATS_NEW	2008/11/19 19:33:25	1.998
@@ -1,5 +1,6 @@
 Version 2.02.44 - 
 ====================================
+  Generate Red Hat clvmd startup script at configuration time with correct paths.
   Fix clvmd & dmeventd builds after tree restructuring.
   Cope with snapshot dependencies when removing a whole VG with lvremove.
   Make man pages consistent with either-or options (use "|" everywhere).
--- LVM2/configure.in	2008/11/10 21:25:45	1.89
+++ LVM2/configure.in	2008/11/19 19:33:25	1.90
@@ -803,6 +803,7 @@
 libdm/libdevmapper.pc
 man/Makefile
 po/Makefile
+scripts/clvmd_init_red_hat
 scripts/Makefile
 test/Makefile
 tools/Makefile


