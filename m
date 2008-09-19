From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Sep 2008 07:12:46 -0000
Subject: LVM2/lib/activate activate.c
Message-ID: <20080919071246.27172.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-19 07:12:45

Modified files:
	lib/activate   : activate.c 

Log message:
	rename var

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.138&r2=1.139

--- LVM2/lib/activate/activate.c	2008/09/19 06:41:57	1.138
+++ LVM2/lib/activate/activate.c	2008/09/19 07:12:45	1.139
@@ -1027,7 +1027,7 @@
 		return 0;
 	}
 
-	if ((!lv->vg->cmd->partial_activate) && (lv->status & PARTIAL_LV)) {
+	if ((!lv->vg->cmd->partial_activation) && (lv->status & PARTIAL_LV)) {
 		log_error("Refusing activation of partial LV %s. Use --partial to override.",
 			  lv->name);
 		return_0;


