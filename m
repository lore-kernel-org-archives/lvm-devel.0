From: agk@sourceware.org <agk@sourceware.org>
Date: 24 Jan 2007 22:06:13 -0000
Subject: LVM2/lib/activate activate.c
Message-ID: <20070124220613.21129.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-01-24 22:06:12

Modified files:
	lib/activate   : activate.c 

Log message:
	fix earlier checkin

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.118&r2=1.119

--- LVM2/lib/activate/activate.c	2007/01/24 16:51:23	1.118
+++ LVM2/lib/activate/activate.c	2007/01/24 22:06:11	1.119
@@ -651,7 +651,7 @@
 	int r = 1;
 	struct list *tmp;
 	struct lv_segment *seg;
-	int (*monitor_fn) (struct cmd_context *c, struct lv_segment *s, int e);
+	int (*monitor_fn) (struct lv_segment *s, int e);
 
 	/*
 	 * Nothing to do if dmeventd configured not to be used.


