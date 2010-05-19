From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 19 May 2010 15:34:11 -0000
Subject: LVM2/tools pvchange.c
Message-ID: <20100519153411.4823.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-05-19 15:34:10

Modified files:
	tools          : pvchange.c 

Log message:
	Remove another pvchange hack involving orphan VG names.
	
	Unnecessary as a result of recent changes.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/tools/pvchange.c	2010/05/19 13:21:09	1.75
+++ LVM2/tools/pvchange.c	2010/05/19 15:34:10	1.76
@@ -229,9 +229,6 @@
 			total++;
 			done += _pvchange_single(cmd, vg,
 						 pvl->pv, NULL);
-			/* FIXME: we should be using #orphans_lvm2 everwhere */
-			if (is_orphan_vg(vg->name))
-				vg_name = VG_ORPHANS;
 			unlock_and_release_vg(cmd, vg, vg_name);
 		}
 	} else {


