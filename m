From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Feb 2012 19:03:48 -0000
Subject: LVM2/lib/cache lvmetad.c
Message-ID: <20120223190348.13838.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-23 19:03:48

Modified files:
	lib/cache      : lvmetad.c 

Log message:
	Fix regression from cleanup commit
	
	baton is being modified, so needs to be cleared before each use.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/lib/cache/lvmetad.c	2012/02/23 17:59:32	1.2
+++ LVM2/lib/cache/lvmetad.c	2012/02/23 19:03:48	1.3
@@ -229,7 +229,7 @@
 	char mda_id[128], *num;
 	struct pv_list *pvl;
 	struct lvmcache_info *info;
-	struct _fixup_baton baton = { .i = 0 };
+	struct _fixup_baton baton;
 
 	if (!vg)
 		return 0;
@@ -264,6 +264,7 @@
 			*num = 0;
 			++num;
 			if ((info = lvmcache_info_from_pvid(mda_id, 0))) {
+				memset(&baton, 0, sizeof(baton));
 				baton.find = atoi(num);
 				baton.ignore = mda_is_ignored(mda);
 				lvmcache_foreach_mda(info, _fixup_ignored, &baton);


