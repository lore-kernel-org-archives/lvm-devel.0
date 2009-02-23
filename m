From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 23 Feb 2009 16:53:42 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20090223165342.29473.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-02-23 16:53:42

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Fix validation of dataalignment value introduced in previous commit.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.204&r2=1.205

--- LVM2/lib/metadata/metadata.c	2009/02/22 19:00:27	1.204
+++ LVM2/lib/metadata/metadata.c	2009/02/23 16:53:42	1.205
@@ -868,6 +868,12 @@
 		goto bad;
 	}
 
+	if (pv->size < data_alignment) {
+		log_error("%s: Data alignment must not exceed device size.",
+			  pv_dev_name(pv));
+		goto bad;
+	}
+
 	pv->fmt = fmt;
 	pv->vg_name = fmt->orphan_vg_name;
 


