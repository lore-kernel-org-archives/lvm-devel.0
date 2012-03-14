From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 14 Mar 2012 17:13:45 -0000
Subject: LVM2/doc example.conf.in
Message-ID: <20120314171345.9873.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-14 17:13:45

Modified files:
	doc            : example.conf.in 

Log message:
	Cleanup for conf file

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/doc/example.conf.in	2012/03/14 17:12:05	1.46
+++ LVM2/doc/example.conf.in	2012/03/14 17:13:45	1.47
@@ -661,8 +661,8 @@
     thin_check_executable = "@THIN_CHECK_CMD@"
 
     # String with options passed with thin_check command. By default,
-    # option '-q' is for quite output.
-    thin_check_options = [ "-q", 121e321 ]
+    # option '-q' is for quiet output.
+    thin_check_options = [ "-q" ]
 
     # While activating devices, I/O to devices being (re)configured is
     # suspended, and as a precaution against deadlocks, LVM2 needs to pin


