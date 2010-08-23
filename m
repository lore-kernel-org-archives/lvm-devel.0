From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 23 Aug 2010 11:34:45 -0000
Subject: LVM2 ./WHATS_NEW tools/polldaemon.c
Message-ID: <20100823113445.5215.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-08-23 11:34:43

Modified files:
	.              : WHATS_NEW 
	tools          : polldaemon.c 

Log message:
	Fix pvmove --abort <dev> return code
	
	It prints error code even if abort operation succeeds:
	
	pvmove --abort /dev/sdb
	Command failed with status code 5.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1721&r2=1.1722
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/polldaemon.c.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2010/08/23 11:34:10	1.1721
+++ LVM2/WHATS_NEW	2010/08/23 11:34:40	1.1722
@@ -1,5 +1,6 @@
 Version 2.02.74 - 
 ==================================
+  Fix return code of pvmove --abort PV.
   Fix pvmove --abort to remove even for empty pvmove LV.
   Add configure --with-default-data-alignment.
   Update heuristic used for default and detected data alignment.
--- LVM2/tools/polldaemon.c	2010/08/23 11:34:10	1.35
+++ LVM2/tools/polldaemon.c	2010/08/23 11:34:41	1.36
@@ -120,8 +120,10 @@
 				  "can't abort.");
 			return 0;
 		}
-		parms->poll_fns->finish_copy(cmd, vg, lv, lvs_changed);
-		return 0;
+		if (!parms->poll_fns->finish_copy(cmd, vg, lv, lvs_changed))
+			return_0;
+
+		return 1;
 	}
 
 	progress = parms->poll_fns->poll_progress(cmd, lv, name, parms);


