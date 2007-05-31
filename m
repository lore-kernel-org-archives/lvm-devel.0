From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 31 May 2007 15:18:45 -0000
Subject: LVM2/lib/display display.c
Message-ID: <20070531151845.2272.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-05-31 15:18:45

Modified files:
	lib/display    : display.c 

Log message:
	Remove 'Type' from pvdisplay --maps as there is no 'Type' of a physical segment, only logical segments

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/display/display.c.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/lib/display/display.c	2007/05/31 14:19:57	1.72
+++ LVM2/lib/display/display.c	2007/05/31 15:18:44	1.73
@@ -271,8 +271,6 @@
 			  pvseg->pe, pvseg->pe + pvseg->len - 1);
 
 		if (pvseg->lvseg) {
-			log_print("  Type\t\t%s",
-				  pvseg->lvseg->segtype->ops->name(pvseg->lvseg));
 			log_print("  Logical volume\t%s%s/%s",
 				  pvseg->lvseg->lv->vg->cmd->dev_dir,
 				  pvseg->lvseg->lv->vg->name,


