From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Sep 2011 15:35:12 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20110906153512.15498.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-06 15:35:11

Modified files:
	tools          : lvcreate.c 

Log message:
	only thin volumes need converting

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.235&r2=1.236

--- LVM2/tools/lvcreate.c	2011/09/06 00:26:43	1.235
+++ LVM2/tools/lvcreate.c	2011/09/06 15:35:11	1.236
@@ -343,7 +343,7 @@
 		}
 	} else {
 		/* No virtual size given, so no thin LV to create. */
-		if (!seg_is_thin_pool(lp) && !(lp->segtype = get_segtype_from_string(cmd, "thin_pool")))
+		if (seg_is_thin_volume(lp) && !(lp->segtype = get_segtype_from_string(cmd, "thin_pool")))
 			return_0;
 
 		lp->thin = 0;


