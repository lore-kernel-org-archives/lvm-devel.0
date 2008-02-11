From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 11 Feb 2008 16:57:40 -0000
Subject: LVM2/doc example.conf
Message-ID: <20080211165740.29389.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-02-11 16:57:40

Modified files:
	doc            : example.conf 

Log message:
	Reflect actual default setting of preferred_names in example.conf and
	update comments.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/doc/example.conf	2008/02/04 20:26:14	1.34
+++ LVM2/doc/example.conf	2008/02/11 16:57:40	1.35
@@ -23,11 +23,11 @@
     # same block device and the tools need to display a name for device,
     # all the pathnames are matched against each item in the following
     # list of regular expressions in turn and the first match is used.
-    # If device-mapper multipath is used, we should always use the mpath
-    # devices rather than the underlying paths.
-    preferred_names = [ "^/dev/mapper/mpath" ]
+    preferred_names = [ ]
 
-    # preferred_names = [ "^/dev/mapper/mpath", "^/dev/[hs]d" ]
+    # If device-mapper multipath is used, more descriptive names might
+    # be preferred over the dm-N names:
+    # preferred_names = [ "^/dev/mapper/mpath" ]
 
     # A filter that tells LVM2 to only use a restricted set of devices.
     # The filter consists of an array of regular expressions.  These


