From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 May 2010 13:21:13 -0000
Subject: LVM2/tools pvchange.c
Message-ID: <20100519132113.5655.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-05-19 13:21:11

Modified files:
	tools          : pvchange.c 

Log message:
	Remove hack in pvchange to unlock orphan VG.
	
	With agk's recent changes, the lock/unlock APIs can properly handle
	orphan VG names.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/tools/pvchange.c	2010/05/19 11:53:00	1.74
+++ LVM2/tools/pvchange.c	2010/05/19 13:21:09	1.75
@@ -263,9 +263,6 @@
 								 pvl->pv,
 								 NULL);
 				}
-				/* FIXME: we should be using #orphans_lvm2 everwhere */
-				if (is_orphan_vg(vg->name))
-					sll->str = VG_ORPHANS;
 				unlock_and_release_vg(cmd, vg, sll->str);
 			}
 		}


