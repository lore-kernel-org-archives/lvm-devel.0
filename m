From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 4 Nov 2009 14:56:36 -0000
Subject: LVM2/lib/activate dev_manager.c
Message-ID: <20091104145636.2319.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-11-04 14:56:36

Modified files:
	lib/activate   : dev_manager.c 

Log message:
	Fix compilation warning:
	activate/dev_manager.c:362: warning: combined_percent_range may be used uninitialized in this function

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/dev_manager.c.diff?cvsroot=lvm2&r1=1.162&r2=1.163

--- LVM2/lib/activate/dev_manager.c	2009/10/26 14:29:33	1.162
+++ LVM2/lib/activate/dev_manager.c	2009/11/04 14:56:35	1.163
@@ -359,7 +359,7 @@
 	struct dm_list *segh = &lv->segments;
 	struct lv_segment *seg = NULL;
 	struct segment_type *segtype;
-	percent_range_t percent_range, combined_percent_range;
+	percent_range_t percent_range = 0, combined_percent_range = 0;
 	int first_time = 1;
 
 	uint64_t total_numerator = 0, total_denominator = 0;


