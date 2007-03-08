From: agk@sourceware.org <agk@sourceware.org>
Date: 8 Mar 2007 21:37:49 -0000
Subject: LVM2 VERSION WHATS_NEW
Message-ID: <20070308213749.2985.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-03-08 21:37:48

Modified files:
	.              : VERSION WHATS_NEW 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.147&r2=1.148
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.581&r2=1.582

--- LVM2/VERSION	2007/03/08 21:28:13	1.147
+++ LVM2/VERSION	2007/03/08 21:37:48	1.148
@@ -1 +1 @@
-2.02.23-cvs (2007-03-08)
+2.02.24-cvs (2007-03-08)
--- LVM2/WHATS_NEW	2007/03/08 21:28:13	1.581
+++ LVM2/WHATS_NEW	2007/03/08 21:37:48	1.582
@@ -1,5 +1,8 @@
-Version 2.02.23 - 8th March 2008
+Version 2.02.24 -
 ====================================
+
+Version 2.02.23 - 8th March 2007
+================================
   Fix vgrename active LV check to ignore differing vgids.
   Remove no-longer-used uuid_out parameter from activation info functions.
   Fix two more segfaults if an empty config file section encountered.


