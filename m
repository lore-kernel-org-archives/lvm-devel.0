From: agk@sourceware.org <agk@sourceware.org>
Date: 30 Sep 2008 20:37:53 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c
Message-ID: <20080930203753.22001.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-09-30 20:37:53

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 

Log message:
	Free text metadata buffer after a failure writing it.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.968&r2=1.969
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.95&r2=1.96

--- LVM2/WHATS_NEW	2008/09/29 09:59:10	1.968
+++ LVM2/WHATS_NEW	2008/09/30 20:37:52	1.969
@@ -1,5 +1,6 @@
 Version 2.02.41 -
 =====================================
+  Free text metadata buffer after a failure writing it.
   Fix misleading error message when there is no allocatable extents in VG.
   Fix handling of PVs which reappeared with old metadata version.
   Fix mirror DSO to call vgreduce with proper parameters.
--- LVM2/lib/format_text/format-text.c	2008/09/19 04:27:26	1.95
+++ LVM2/lib/format_text/format-text.c	2008/09/30 20:37:52	1.96
@@ -597,8 +597,15 @@
 	r = 1;
 
       out:
-	if (!r && !dev_close(mdac->area.dev))
-		stack;
+	if (!r) {
+		if (!dev_close(mdac->area.dev))
+			stack;
+
+                if (fidtc->raw_metadata_buf) {
+                        dm_free(fidtc->raw_metadata_buf);
+                        fidtc->raw_metadata_buf = NULL;
+                }
+	}
 
 	return r;
 }


