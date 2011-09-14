From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Sep 2011 10:03:15 -0000
Subject: LVM2/lib/metadata lv.c
Message-ID: <20110914100315.5591.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-14 10:03:15

Modified files:
	lib/metadata   : lv.c 

Log message:
	Add suggest parentheses around '&&'
	
	Follow gcc suggestion.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/lib/metadata/lv.c	2011/09/09 01:15:18	1.27
+++ LVM2/lib/metadata/lv.c	2011/09/14 10:03:15	1.28
@@ -406,8 +406,8 @@
 	else
 		repstr[6] = '-';
 
-	if ((lv_is_thin_volume(lv) && (seg = first_seg(lv)) && seg->pool_lv && (seg = first_seg(seg->pool_lv))) ||
-	    (lv_is_thin_pool(lv) && (seg = first_seg(lv))) &&
+	if (((lv_is_thin_volume(lv) && (seg = first_seg(lv)) && seg->pool_lv && (seg = first_seg(seg->pool_lv))) ||
+	     (lv_is_thin_pool(lv) && (seg = first_seg(lv)))) &&
 	    seg->zero_new_blocks)
 		repstr[7] = 'z';
 	else


