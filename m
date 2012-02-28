From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 28 Feb 2012 11:10:46 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20120228111046.3812.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-28 11:10:45

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Check error from _lv_each_dependency
	
	_lv_mark_if_partial_collect cannot fail, however it's good to keep
	checking here as we do in all other cases.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.489&r2=1.490

--- LVM2/lib/metadata/metadata.c	2012/02/28 10:11:36	1.489
+++ LVM2/lib/metadata/metadata.c	2012/02/28 11:10:45	1.490
@@ -2186,7 +2186,8 @@
 	}
 
 	baton.partial = 0;
-	_lv_each_dependency(lv, _lv_mark_if_partial_collect, &baton);
+	if (!_lv_each_dependency(lv, _lv_mark_if_partial_collect, &baton))
+		return_0;
 
 	if (baton.partial)
 		lv->status |= PARTIAL_LV;


