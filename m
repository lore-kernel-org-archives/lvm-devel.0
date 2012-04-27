From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 27 Apr 2012 18:37:42 -0000
Subject: LVM2/doc example.conf.in
Message-ID: <20120427183742.5948.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2012-04-27 18:37:42

Modified files:
	doc            : example.conf.in 

Log message:
	Make a note that "raid1" is not cluster-aware in the example lvm.conf.
	
	In the description of the segment types for the 'mirror_segtype_default'
	field, we mention that "raid1" is not cluster-aware.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.47&r2=1.48

--- LVM2/doc/example.conf.in	2012/03/14 17:13:45	1.47
+++ LVM2/doc/example.conf.in	2012/04/27 18:37:42	1.48
@@ -441,6 +441,8 @@
     #		 on the same device as the image - no separate devices are
     #		 required.)  This mirror implementation does not require I/O
     #		 to be blocked in the kernel in the event of a failure.
+    #		 This mirror implementation is not cluster-aware and cannot be
+    #		 used in a shared (active/active) fashion in a cluster.
     #
     # Specify the '--type <mirror|raid1>' option to override this default
     # setting.


