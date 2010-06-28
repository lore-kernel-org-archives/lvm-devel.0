From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 28 Jun 2010 20:40:16 -0000
Subject: LVM2/doc example.conf.in
Message-ID: <20100628204016.21201.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-06-28 20:40:16

Modified files:
	doc            : example.conf.in 

Log message:
	Update example.conf.in to describe vgmetadatacopies.
	
	Update example.conf to describe vgmetadatacopies.  Provide an
	explanation for the '0' ("unmanaged") value.
	
	Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/doc/example.conf.in	2010/05/20 13:47:21	1.2
+++ LVM2/doc/example.conf.in	2010/06/28 20:40:15	1.3
@@ -456,6 +456,17 @@
 
     # pvmetadatacopies = 1
 
+    # Default number of copies of metadata to hold on each VG.
+    # If set to a non-zero value, LVM automatically manages the PV
+    # 'metadataignore' flags (see pvchange) to achieve the requested
+    # copies of metadata.  You may set a value larger than the
+    # the sum of all metadata areas on all physical volumes.  This value
+    # can be overridden on the command line of various commands. The
+    # default value of 0 indicates that LVM should not automatically
+    # manage the 'metadataignore' flags.
+
+    # vgmetadatacopies = 0
+
     # Approximate default size of on-disk metadata areas in sectors.
     # You should increase this if you have large volume groups or
     # you want to retain a large on-disk history of your metadata changes.


