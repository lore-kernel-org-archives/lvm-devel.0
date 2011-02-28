From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 28 Feb 2011 20:50:02 -0000
Subject: LVM2/lib/format_text archiver.c
Message-ID: <20110228205002.17491.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-02-28 20:50:01

Modified files:
	lib/format_text: archiver.c 

Log message:
	Rephrase backup message.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/archiver.c.diff?cvsroot=lvm2&r1=1.43&r2=1.44

--- LVM2/lib/format_text/archiver.c	2011/02/25 14:12:14	1.43
+++ LVM2/lib/format_text/archiver.c	2011/02/28 20:50:01	1.44
@@ -217,7 +217,7 @@
 	}
 
 	if (test_mode()) {
-		log_verbose("Test mode: Skipping volume group backup.");
+		log_verbose("Test mode: Skipping backup of volume group.");
 		return 1;
 	}
 


