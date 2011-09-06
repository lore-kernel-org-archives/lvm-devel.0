From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Sep 2011 15:39:47 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20110906153947.13869.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-06 15:39:47

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	else

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.278&r2=1.279

--- LVM2/lib/metadata/lv_manip.c	2011/09/06 00:26:43	1.278
+++ LVM2/lib/metadata/lv_manip.c	2011/09/06 15:39:46	1.279
@@ -2354,7 +2354,7 @@
 		// lv->status |= THIN_POOL;
 		// status = THIN_IMAGE;
 		layer_name = "tdata";
-	}
+	} else
 		return_0;
 
 	/*


