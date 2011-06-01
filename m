From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Jun 2011 15:30:37 -0000
Subject: LVM2 ./WHATS_NEW lib/label/label.c
Message-ID: <20110601153037.16927.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-06-01 15:30:36

Modified files:
	.              : WHATS_NEW 
	lib/label      : label.c 

Log message:
	Report sector containing label in verbose message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2001&r2=1.2002
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/label/label.c.diff?cvsroot=lvm2&r1=1.53&r2=1.54

--- LVM2/WHATS_NEW	2011/06/01 12:24:15	1.2001
+++ LVM2/WHATS_NEW	2011/06/01 15:30:36	1.2002
@@ -1,5 +1,6 @@
 Version 2.02.86 -  
 =================================
+  Report sector containing label in verbose message.
   Clarify error message when unable to convert an LV into a snapshot of an LV.
   Add and use dev_open_readonly and variations.
   Do not log a superfluous stack message when the lv is properly processed.
--- LVM2/lib/label/label.c	2011/05/28 09:48:16	1.53
+++ LVM2/lib/label/label.c	2011/06/01 15:30:36	1.54
@@ -156,8 +156,10 @@
 		dm_list_iterate_items(li, &_labellers) {
 			if (li->l->ops->can_handle(li->l, (char *) lh,
 						   sector + scan_sector)) {
-				log_very_verbose("%s: %s label detected",
-						 dev_name(dev), li->name);
+				log_very_verbose("%s: %s label detected at "
+					         "sector %" PRIu64, 
+						 dev_name(dev), li->name,
+						 sector + scan_sector);
 				if (found) {
 					log_error("Ignoring additional label "
 						  "on %s at sector %" PRIu64,


