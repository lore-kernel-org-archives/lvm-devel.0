From: agk@sourceware.org <agk@sourceware.org>
Date: 10 Apr 2008 18:50:37 -0000
Subject: LVM2/doc example.conf
Message-ID: <20080410185037.18181.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-10 18:50:37

Modified files:
	doc            : example.conf 

Log message:
	.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/doc/example.conf	2008/02/11 16:57:40	1.35
+++ LVM2/doc/example.conf	2008/04/10 18:50:37	1.36
@@ -25,9 +25,8 @@
     # list of regular expressions in turn and the first match is used.
     preferred_names = [ ]
 
-    # If device-mapper multipath is used, more descriptive names might
-    # be preferred over the dm-N names:
-    # preferred_names = [ "^/dev/mapper/mpath" ]
+    # Try to avoid using undescriptive /dev/dm-N names, if present.
+    # preferred_names = [ "^/dev/mpath/", "^/dev/mapper/mpath", "^/dev/[hs]d" ]
 
     # A filter that tells LVM2 to only use a restricted set of devices.
     # The filter consists of an array of regular expressions.  These


