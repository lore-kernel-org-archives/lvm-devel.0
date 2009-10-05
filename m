From: agk@sourceware.org <agk@sourceware.org>
Date: 5 Oct 2009 12:44:21 -0000
Subject: LVM2 ./WHATS_NEW doc/example.conf lib/config/d ...
Message-ID: <20091005124421.16478.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-05 12:44:21

Modified files:
	.              : WHATS_NEW 
	doc            : example.conf 
	lib/config     : defaults.h 

Log message:
	Correct example.conf to indicate that lvm2 not lvm1 is the default format.
	Remove an unused stray LVM1_SUPPORT ifdef.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1289&r2=1.1290
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/doc/example.conf.diff?cvsroot=lvm2&r1=1.50&r2=1.51
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/config/defaults.h.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/WHATS_NEW	2009/10/05 12:11:30	1.1289
+++ LVM2/WHATS_NEW	2009/10/05 12:44:20	1.1290
@@ -1,5 +1,7 @@
 Version 2.02.54 -
 =====================================
+  Correct example.conf to indicate that lvm2 not lvm1 is the default format.
+  Remove an unused stray LVM1_SUPPORT ifdef.
   Only include selinux libs in libdevmapper.pc when selinux build enabled.
   Allow for a build directory separate from the source.
   Update distclean target for rename clogd to cmirrord. (2.02.52)
--- LVM2/doc/example.conf	2009/09/28 16:23:45	1.50
+++ LVM2/doc/example.conf	2009/10/05 12:44:21	1.51
@@ -262,8 +262,8 @@
 
     # The default metadata format that commands should use - "lvm1" or "lvm2".
     # The command line override is -M1 or -M2.
-    # Defaults to "lvm1" if compiled in, else "lvm2".
-    # format = "lvm1"
+    # Defaults to "lvm2".
+    # format = "lvm2"
 
     # Location of proc filesystem
     proc = "/proc"
--- LVM2/lib/config/defaults.h	2009/09/28 16:23:46	1.52
+++ LVM2/lib/config/defaults.h	2009/10/05 12:44:21	1.53
@@ -58,11 +58,7 @@
 #  define DEFAULT_FALLBACK_TO_LVM1 0
 #endif
 
-#ifdef LVM1_SUPPORT
-#  define DEFAULT_FORMAT "lvm1"
-#else
-#  define DEFAULT_FORMAT "lvm2"
-#endif
+#define DEFAULT_FORMAT "lvm2"
 
 #define DEFAULT_STRIPESIZE 64	/* KB */
 #define DEFAULT_PVMETADATASIZE 255


