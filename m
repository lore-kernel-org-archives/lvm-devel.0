From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Dec 2010 14:20:53 -0000
Subject: LVM2/lib/format_pool disk_rep.c
Message-ID: <20101220142053.29593.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-20 14:20:52

Modified files:
	lib/format_pool: disk_rep.c 

Log message:
	Add internal error if pointer is uninitialized
	
	Add simple check for existance of 'pl' and printer internal error message
	if device is missing instead of plain crash.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/disk_rep.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18

--- LVM2/lib/format_pool/disk_rep.c	2010/07/09 15:34:44	1.17
+++ LVM2/lib/format_pool/disk_rep.c	2010/12/20 14:20:52	1.18
@@ -263,6 +263,11 @@
 		 */
 		if (!sp_count) {
 			/* FIXME pl left uninitialised if !info->dev */
+			if (!pl) {
+				log_error(INTERNAL_ERROR "device is missing");
+				dm_pool_destroy(tmpmem);
+				return 0;
+			}
 			sp_count = pl->pd.pl_subpools;
 			if (!(sp_devs =
 			      dm_pool_zalloc(tmpmem,


