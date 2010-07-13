From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Jul 2010 22:04:37 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20100713220437.6239.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-07-13 22:04:36

Modified files:
	tools          : lvconvert.c 

Log message:
	Fix reversal of LV list before performing a split mirror.
	
	When splitting off mirror images from a mirror, we always take
	LVs from the end of a list.  For example, if the mirror sub-devices
	are lv_mimage_[012], we should select lv_mimage_2 if splitting off
	one image.  However, lv_mimage_0 was being selected instead.
	
	The problem came from calling '_move_removable_mimages_to_end'
	when it was unnecessary to do so.  When the user /does/ specify
	specific devices to be removed, this function properly moved the
	appropriate LVs to the end of the list for extraction.  However,
	if the user /doesn't/ give any specific PVs, the function should
	do nothing.  '_move_removable_mimages_to_end' was keying off of
	whether 'removable_pvs' was NULL or not and this value was
	improperly being populated with the set of all available PVs.
	This was causing '_move_removable_mimages_to_end' to completely
	reverse the list, which in turn caused us to extract the
	hithertofore front-of-the-list LVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140

--- LVM2/tools/lvconvert.c	2010/07/13 21:53:07	1.139
+++ LVM2/tools/lvconvert.c	2010/07/13 22:04:36	1.140
@@ -1002,7 +1002,7 @@
 						  lv->le_count,
 						  lp->region_size);
 
-	if (!operable_pvs)
+	if (!operable_pvs && !lp->keep_mimages)
 		operable_pvs = lp->pvh;
 
 	seg = first_seg(lv);


