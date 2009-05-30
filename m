From: agk@sourceware.org <agk@sourceware.org>
Date: 30 May 2009 01:54:30 -0000
Subject: LVM2 lib/metadata/metadata.c ./WHATS_NEW
Message-ID: <20090530015430.27065.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-05-30 01:54:29

Modified files:
	lib/metadata   : metadata.c 
	.              : WHATS_NEW 

Log message:
	Remove verbose 'visited' messages.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.222&r2=1.223
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1134&r2=1.1135

--- LVM2/lib/metadata/metadata.c	2009/05/27 13:19:34	1.222
+++ LVM2/lib/metadata/metadata.c	2009/05/30 01:54:29	1.223
@@ -1330,10 +1330,9 @@
 	baton.fn = fn;
 	baton.data = data;
 	r = _lv_each_dependency(lv, _lv_postorder_level, &baton);
-	if (r) {
+	if (r)
 		r = fn(lv, data);
-		log_verbose("visited %s", lv->name);
-	}
+
 	return r;
 }
 
--- LVM2/WHATS_NEW	2009/05/30 00:09:27	1.1134
+++ LVM2/WHATS_NEW	2009/05/30 01:54:29	1.1135
@@ -1,5 +1,6 @@
 Version 2.02.48 - 
 ===============================
+  Remove verbose 'visited' messages.
   Handle multi-extent mirror log allocation when smallest PV has only 1 extent.
   Add LSB standard headers and functions (incl. reload) to clvmd initscript.
   When creating new LV, double-check that name is not already in use.


