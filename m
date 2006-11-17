From: agk@sourceware.org <agk@sourceware.org>
Date: 17 Nov 2006 02:45:52 -0000
Subject: LVM2 ./WHATS_NEW tools/pvremove.c
Message-ID: <20061117024552.15928.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2006-11-17 02:45:52

Modified files:
	.              : WHATS_NEW 
	tools          : pvremove.c 

Log message:
	Fix pvremove error path for case when PV is in use.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.499&r2=1.500
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvremove.c.diff?cvsroot=lvm2&r1=1.10&r2=1.11

--- LVM2/WHATS_NEW	2006/11/16 17:36:00	1.499
+++ LVM2/WHATS_NEW	2006/11/17 02:45:51	1.500
@@ -1,5 +1,6 @@
 Version 2.02.15 -
 ====================================
+  Fix pvremove error path for case when PV is in use.
   Warn if certain duplicate config file entries are seen.
   Enhance lvm_dump.sh for sysreport integration and add man page.
   Fix --autobackup argument which could never disable backups.
--- LVM2/tools/pvremove.c	2006/05/09 21:23:51	1.10
+++ LVM2/tools/pvremove.c	2006/11/17 02:45:51	1.11
@@ -92,9 +92,9 @@
 	}
 
 	if (!dev_test_excl(dev)) {
-		log_error("Can't open %s exclusively.  Mounted filesystem?",
-			  dev_name(dev));
-		return 0;
+		log_error("Can't open %s exclusively - not removing. "
+			  "Mounted filesystem?", dev_name(dev));
+		goto error;
 	}
 
 	/* Wipe existing label(s) */


