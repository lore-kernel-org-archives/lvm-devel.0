From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 5 Jan 2011 12:27:57 -0000
Subject: LVM2/lib/mirror mirrored.c
Message-ID: <20110105122757.845.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-01-05 12:27:57

Modified files:
	lib/mirror     : mirrored.c 

Log message:
	Remove unused variable mirr_state and its assignment

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.82&r2=1.83

--- LVM2/lib/mirror/mirrored.c	2010/12/20 13:32:49	1.82
+++ LVM2/lib/mirror/mirrored.c	2011/01/05 12:27:56	1.83
@@ -184,7 +184,6 @@
 				    uint64_t *total_numerator,
 				    uint64_t *total_denominator)
 {
-	struct mirror_state *mirr_state;
 	uint64_t numerator, denominator;
 	unsigned mirror_count, m;
 	int used;
@@ -193,8 +192,6 @@
 	if (!*target_state)
 		*target_state = _mirrored_init_target(mem, cmd);
 
-	mirr_state = *target_state;
-
 	/* Status line: <#mirrors> (maj:min)+ <synced>/<total_regions> */
 	log_debug("Mirror status: %s", params);
 


