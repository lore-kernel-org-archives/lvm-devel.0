From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Feb 2010 18:35:06 -0000
Subject: LVM2/lib/report report.c
Message-ID: <20100215183506.3597.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-02-15 18:35:06

Modified files:
	lib/report     : report.c 

Log message:
	Cleanup float arithmetic gcc warning.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/report/report.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114

--- LVM2/lib/report/report.c	2010/02/15 18:34:00	1.113
+++ LVM2/lib/report/report.c	2010/02/15 18:35:06	1.114
@@ -1049,7 +1049,7 @@
 		return 0;
 	}
 
-	*sortval = snap_percent * UINT64_C(1000);
+	*sortval = (uint64_t)(snap_percent * 1000.f);
 	dm_report_field_set_value(field, repstr, sortval);
 
 	return 1;
@@ -1091,7 +1091,7 @@
 		return 0;
 	}
 
-	*sortval = percent * UINT64_C(1000);
+	*sortval = (uint64_t)(percent * 1000.f);
 	dm_report_field_set_value(field, repstr, sortval);
 
 	return 1;


