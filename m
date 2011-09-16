From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 16 Sep 2011 11:53:14 -0000
Subject: LVM2/lib/metadata merge.c
Message-ID: <20110916115314.20320.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-16 11:53:14

Modified files:
	lib/metadata   : merge.c 

Log message:
	Trim spaces on EOL

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/lib/metadata/merge.c	2011/09/08 16:41:18	1.48
+++ LVM2/lib/metadata/merge.c	2011/09/16 11:53:14	1.49
@@ -202,7 +202,7 @@
 					inc_error_count;
 				}
 			} else {
-				if (seg->pool_metadata_lv) {	
+				if (seg->pool_metadata_lv) {
 					log_error("LV %s: segment %u must not have thin pool metadata LV set",
 						  lv->name, seg_count);
 					inc_error_count;
@@ -222,7 +222,7 @@
 					inc_error_count;
 				}
 
-				if (!seg->pool_lv) {	
+				if (!seg->pool_lv) {
 					log_error("LV %s: segment %u is missing thin pool LV",
 						  lv->name, seg_count);
 					inc_error_count;
@@ -232,7 +232,7 @@
 					inc_error_count;
 				}
 			} else {
-				if (seg->pool_lv) {	
+				if (seg->pool_lv) {
 					log_error("LV %s: segment %u must not have thin pool LV set",
 						  lv->name, seg_count);
 					inc_error_count;


