From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Oct 2010 10:04:35 -0000
Subject: LVM2/lib/misc util.h
Message-ID: <20101026100435.20019.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-26 10:04:35

Modified files:
	lib/misc       : util.h 

Log message:
	Macro uninitialized_var gives warnings in static analysis
	
	Deactivate uninitialized_var() macro for clang static analysis.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/util.h.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/lib/misc/util.h	2010/05/24 23:11:35	1.6
+++ LVM2/lib/misc/util.h	2010/10/26 10:04:34	1.7
@@ -25,7 +25,11 @@
 		     (void) (&_a == &_b); \
 		     _a > _b ? _a : _b; })
 
+#ifdef __clang__
+#define uninitialized_var(x) x
+#else
 #define uninitialized_var(x) x = x
+#endif
 
 #define KERNEL_VERSION(major, minor, release) (((major) << 16) + ((minor) << 8) + (release))
 


