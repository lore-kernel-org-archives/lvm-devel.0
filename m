From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Mar 2012 09:40:00 -0000
Subject: LVM2/daemons/dmeventd/plugins/thin dmeventd_thin.c
Message-ID: <20120323094000.13160.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-23 09:40:00

Modified files:
	daemons/dmeventd/plugins/thin: dmeventd_thin.c 

Log message:
	Update debug message
	
	(compiled only with special debug define)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c.diff?cvsroot=lvm2&r1=1.4&r2=1.5

--- LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c	2012/01/20 10:59:26	1.4
+++ LVM2/daemons/dmeventd/plugins/thin/dmeventd_thin.c	2012/03/23 09:39:59	1.5
@@ -178,7 +178,7 @@
 #if THIN_DEBUG
 	syslog(LOG_INFO, "%p: Got status %" PRIu64 " / %" PRIu64
 	       " %" PRIu64  " / %" PRIu64 ".\n", state,
-	       tps->used_meta_blocks, tps->total_meta_blocks,
+	       tps->used_metadata_blocks, tps->total_metadata_blocks,
 	       tps->used_data_blocks, tps->total_data_blocks);
 #endif
 


