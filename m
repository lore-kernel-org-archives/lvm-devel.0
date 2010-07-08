From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 8 Jul 2010 17:41:46 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100708174146.7500.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-08 17:41:46

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Init mda->list in mda_copy.
	
	This patch should be no functional change as all callers initialize
	mda->list.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.385&r2=1.386

--- LVM2/lib/metadata/metadata.c	2010/07/07 18:59:45	1.385
+++ LVM2/lib/metadata/metadata.c	2010/07/08 17:41:46	1.386
@@ -4207,7 +4207,7 @@
 		}
 	}
 
-	/* FIXME mda 'list' left invalid here */
+	dm_list_init(&mda_new->list);
 
 	return mda_new;
 }


