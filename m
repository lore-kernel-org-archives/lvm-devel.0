From: agk@sourceware.org <agk@sourceware.org>
Date: 16 Jan 2008 22:52:47 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20080116225247.11217.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-01-16 22:52:46

Modified files:
	lib/metadata   : metadata.c 

Log message:
	fix a _get_vgs return

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.150&r2=1.151

--- LVM2/lib/metadata/metadata.c	2008/01/16 19:54:39	1.150
+++ LVM2/lib/metadata/metadata.c	2008/01/16 22:52:46	1.151
@@ -1899,7 +1899,7 @@
 	if (pvslist) {
 		if (!(results = dm_pool_alloc(cmd->mem, sizeof(*results)))) {
 			log_error("PV list allocation failed");
-			return NULL;
+			return 0;
 		}
 
 		list_init(results);


