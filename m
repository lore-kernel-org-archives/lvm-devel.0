From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Feb 2012 22:36:57 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20120223223657.22749.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-23 22:36:57

Modified files:
	tools          : lvconvert.c 

Log message:
	Keep same sign for 's' counter

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.185&r2=1.186

--- LVM2/tools/lvconvert.c	2012/02/22 17:18:49	1.185
+++ LVM2/tools/lvconvert.c	2012/02/23 22:36:56	1.186
@@ -596,7 +596,8 @@
 
 static int _failed_logs_count(struct logical_volume *lv)
 {
-	int ret = 0, s;
+	int ret = 0;
+	unsigned s;
 	struct logical_volume *log_lv = first_seg(lv)->log_lv;
 	if (log_lv && (log_lv->status & PARTIAL_LV)) {
 		if (log_lv->status & MIRRORED)


