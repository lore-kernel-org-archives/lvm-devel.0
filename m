From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Jan 2012 09:00:57 -0000
Subject: LVM2 WHATS_NEW
Message-ID: <20120125090057.28540.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-25 09:00:57

Modified files:
	.              : WHATS_NEW 

Log message:
	Update lv_info whats_new

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2237&r2=1.2238

--- LVM2/WHATS_NEW	2012/01/25 08:48:42	1.2237
+++ LVM2/WHATS_NEW	2012/01/25 09:00:57	1.2238
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Update lv_info to use -real layer for origin_only LVs.
   Add lv_thin_pool_transaction_id to read the transaction_id value.
   Use suspend|resume_origin_only when up-converting RAID, as mirrors do.
   Fix the way RAID meta LVs are added to the dependency tree.


