From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Apr 2011 14:11:41 -0000
Subject: LVM2/lib/misc util.h
Message-ID: <20110408141141.8674.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-04-08 14:11:40

Modified files:
	lib/misc       : util.h 

Log message:
	Newer gcc doesn't need this trick
	
	In fact it now generates an opposite warning about using undefined variable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/misc/util.h.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/lib/misc/util.h	2010/10/26 10:04:34	1.7
+++ LVM2/lib/misc/util.h	2011/04/08 14:11:40	1.8
@@ -25,7 +25,7 @@
 		     (void) (&_a == &_b); \
 		     _a > _b ? _a : _b; })
 
-#ifdef __clang__
+#if defined(__clang__) || (defined(__GNUC__) && __GNUC__ >= 4 && __GNUC_MINOR__ >= 6)
 #define uninitialized_var(x) x
 #else
 #define uninitialized_var(x) x = x


