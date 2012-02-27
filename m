From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 09:54:26 -0000
Subject: LVM2/lib/format_text format-text.c
Message-ID: <20120227095426.3540.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 09:54:25

Modified files:
	lib/format_text: format-text.c 

Log message:
	Remove test for pvid
	
	Since pvid is char buffer[] and not pointer,
	there is no point to check it for NULL.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.195&r2=1.196

--- LVM2/lib/format_text/format-text.c	2012/02/23 17:59:33	1.195
+++ LVM2/lib/format_text/format-text.c	2012/02/27 09:54:25	1.196
@@ -1676,7 +1676,6 @@
 	 */
 	else {
 		if (!pv->dev ||
-		    !pv->dev->pvid ||
 		    !(info = lvmcache_info_from_pvid(pv->dev->pvid, 0))) {
 			log_error("PV %s missing from cache", pv_dev_name(pv));
 			return 0;


