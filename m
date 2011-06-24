From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jun 2011 23:39:09 -0000
Subject: LVM2/lib/metadata mirror.c
Message-ID: <20110624233909.15553.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-24 23:39:09

Modified files:
	lib/metadata   : mirror.c 

Log message:
	remove unused var after recent patch

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/mirror.c.diff?cvsroot=lvm2&r1=1.156&r2=1.157

--- LVM2/lib/metadata/mirror.c	2011/06/23 14:00:59	1.156
+++ LVM2/lib/metadata/mirror.c	2011/06/24 23:39:09	1.157
@@ -1853,7 +1853,6 @@
 	percent_t sync_percent;
 	int in_sync;
 	struct logical_volume *log_lv;
-	struct lvinfo info;
 	unsigned old_log_count;
 	int r = 0;
 


