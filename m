From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Mar 2011 03:03:04 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c
Message-ID: <20110310030304.29678.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-03-10 03:03:04

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 

Log message:
	Avoid possible endless loop in _free_vginfo when 4 or more VGs have same name.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1939&r2=1.1940
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.104&r2=1.105

--- LVM2/WHATS_NEW	2011/03/09 12:44:42	1.1939
+++ LVM2/WHATS_NEW	2011/03/10 03:03:03	1.1940
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Avoid possible endless loop in _free_vginfo when 4 or more VGs have same name.
   Use empty string instead of /dev// for LV path when there's no VG.
   Don't allocate unused VG mempool in _pvsegs_sub_single.
   Remove uninitialised byte from end of local clvmd messages.
--- LVM2/lib/cache/lvmcache.c	2011/02/21 12:07:03	1.104
+++ LVM2/lib/cache/lvmcache.c	2011/03/10 03:03:04	1.105
@@ -845,7 +845,7 @@
 			vginfo2->next = vginfo->next;
 			break;
 		}
- 	while ((vginfo2 = primary_vginfo->next));
+ 	while ((vginfo2 = vginfo2->next));
 
 	if (vginfo->vgname)
 		dm_free(vginfo->vgname);


