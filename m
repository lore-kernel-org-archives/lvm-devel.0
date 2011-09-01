From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Sep 2011 10:19:01 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/mm/pool.c
Message-ID: <20110901101901.11955.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-01 10:19:01

Modified files:
	.              : WHATS_NEW_DM 
	libdm/mm       : pool.c 

Log message:
	Mark unreleased memory pools as internal error

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.495&r2=1.496
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/mm/pool.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/WHATS_NEW_DM	2011/08/19 19:42:39	1.495
+++ LVM2/WHATS_NEW_DM	2011/09/01 10:19:01	1.496
@@ -1,5 +1,6 @@
 Version 1.02.68 -
 ==================================
+  Mark unreleased memory pools as internal error.
 
 Version 1.02.67 - 19th August 2011
 ==================================
--- LVM2/libdm/mm/pool.c	2011/08/11 17:29:05	1.8
+++ LVM2/libdm/mm/pool.c	2011/09/01 10:19:01	1.9
@@ -94,6 +94,7 @@
 		log_error(" [%p] %s", p, p->name);
 #endif
 	}
+	log_error(INTERNAL_ERROR "Unreleased memory pool(s) found.");
 }
 
 /**


