From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 10 Jun 2009 11:21:11 -0000
Subject: LVM2/tools vgsplit.c
Message-ID: <20090610112111.14693.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-10 11:21:10

Modified files:
	tools          : vgsplit.c 

Log message:
	Fix compiler warning.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgsplit.c.diff?cvsroot=lvm2&r1=1.75&r2=1.76

--- LVM2/tools/vgsplit.c	2009/06/09 14:31:20	1.75
+++ LVM2/tools/vgsplit.c	2009/06/10 11:21:10	1.76
@@ -281,7 +281,7 @@
 	char *vg_name_from, *vg_name_to;
 	struct volume_group *vg_to = NULL, *vg_from = NULL;
 	int opt;
-	int existing_vg;
+	int existing_vg = 0;
 	int consistent;
 	int r = ECMD_FAILED;
 	const char *lv_name;


