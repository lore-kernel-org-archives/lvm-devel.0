From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Apr 2010 12:18:35 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20100420121835.5383.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-20 12:18:34

Modified files:
	tools          : lvconvert.c 

Log message:
	typo in comment

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.128&r2=1.129

--- LVM2/tools/lvconvert.c	2010/04/14 13:51:58	1.128
+++ LVM2/tools/lvconvert.c	2010/04/20 12:18:31	1.129
@@ -1046,7 +1046,7 @@
 		uint32_t nmc = old_mimage_count - new_mimage_count;
 		uint32_t nlc = (!new_log_count || lp->mirrors == 1) ? 1U : 0U;
 
-		/* FIXME: We did nlc used to be calculated that way? */
+		/* FIXME: Why did nlc used to be calculated that way? */
 
 		/* Reduce number of mirrors */
 		if (lp->keep_mimages) {


