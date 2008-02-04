From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 4 Feb 2008 20:26:14 -0000
Subject: LVM2 doc/example.conf man/lvm.conf.5
Message-ID: <20080204202614.17301.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-02-04 20:26:14

Modified files:
	doc            : example.conf 
	man            : lvm.conf.5 

Log message:
	Fix default preferred_names filter to use /dev/mapper/mpath devices.
	If these devices exist, we should be using them for multipath rather than any
	underlying device names.
	Reference: http://kbase.redhat.com/faq/FAQ_96_11196.shtma
	bz195685

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/man/lvm.conf.5.diff?cvsroot=lvm2&r1=1.20&r2=1.21

--- LVM2/doc/example.conf	2008/01/09 15:32:19	1.33
+++ LVM2/doc/example.conf	2008/02/04 20:26:14	1.34
@@ -23,9 +23,11 @@
     # same block device and the tools need to display a name for device,
     # all the pathnames are matched against each item in the following
     # list of regular expressions in turn and the first match is used.
-    preferred_names = [ ]
+    # If device-mapper multipath is used, we should always use the mpath
+    # devices rather than the underlying paths.
+    preferred_names = [ "^/dev/mapper/mpath" ]
 
-    # preferred_names = [ "^/dev/mpath/", "^/dev/[hs]d" ]
+    # preferred_names = [ "^/dev/mapper/mpath", "^/dev/[hs]d" ]
 
     # A filter that tells LVM2 to only use a restricted set of devices.
     # The filter consists of an array of regular expressions.  These
--- LVM2/man/lvm.conf.5	2007/11/09 16:51:54	1.20
+++ LVM2/man/lvm.conf.5	2008/02/04 20:26:14	1.21
@@ -84,7 +84,10 @@
 \fBpreferred_names\fP \(em List of patterns compared in turn against
 all the pathnames referencing the same device in in the scanned directories.
 The pathname that matches the earliest pattern in the list is the
-one used in any output.
+one used in any output.  As an example, if device mapper multipathing
+is used, the following will select multipath device names:
+.br
+\fBdevices { preferred_names = [ "^/dev/mapper/mpath" ] }\fP
 .IP
 \fBfilter\fP \(em List of patterns to apply to devices found by a scan.
 Patterns are regular expressions delimited by any character and preceded
@@ -98,6 +101,7 @@
 device is accepted; otherwise if any name matches any \fBr\fP
 pattern it is rejected; otherwise it is accepted.
 As an example, to ignore /dev/cdrom you could use:
+.br
 \fBdevices { filter=["r|cdrom|"] }\fP 
 .IP
 \fBcache_dir\fP \(em Persistent filter cache file directory.


