From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 Oct 2011 09:13:40 -0000
Subject: LVM2 doc/example.conf.in lib/config/defaults.h
Message-ID: <20111011091340.4881.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-10-11 09:13:39

Modified files:
	doc            : example.conf.in 
	lib/config     : defaults.h 

Log message:
	Reduce preallocated stack size
	
	Go with just 64KiB for stack.
	
	Closer inspection should be made, whether we actually need to play with
	settings at all.
	
	Since default stack size is 8MB and gets mapped via page locking thus,
	it seems there is no big help with preallocation of stack to some value.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.in.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.84&r2=1.85

--- LVM2/doc/example.conf.in	2011/10/04 20:49:24	1.33
+++ LVM2/doc/example.conf.in	2011/10/11 09:13:39	1.34
@@ -481,7 +481,8 @@
     missing_stripe_filler = "error"
 
     # How much stack (in KB) to reserve for use while devices suspended
-    reserved_stack = 256
+    # Prior to version 2.02.89 this used to be set to 256KB
+    reserved_stack = 64
 
     # How much memory (in KB) to reserve for use while devices suspended
     reserved_memory = 8192
--- LVM2/lib/config/defaults.h	2011/09/22 17:39:57	1.84
+++ LVM2/lib/config/defaults.h	2011/10/11 09:13:39	1.85
@@ -116,7 +116,7 @@
 #ifdef DEVMAPPER_SUPPORT
 #  define DEFAULT_ACTIVATION 1
 #  define DEFAULT_RESERVED_MEMORY 8192
-#  define DEFAULT_RESERVED_STACK 256
+#  define DEFAULT_RESERVED_STACK 64 /* KB */
 #  define DEFAULT_PROCESS_PRIORITY -18
 #else
 #  define DEFAULT_ACTIVATION 0


