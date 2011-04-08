From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Apr 2011 14:21:35 -0000
Subject: LVM2/lib/format_text export.c
Message-ID: <20110408142135.14536.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-04-08 14:21:35

Modified files:
	lib/format_text: export.c 

Log message:
	Add missing printf attributes
	
	These attributes were missing in previous patch, that was adding
	instrumentation for printf formating string parameter.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.80&r2=1.81

--- LVM2/lib/format_text/export.c	2010/11/29 12:19:58	1.80
+++ LVM2/lib/format_text/export.c	2011/04/08 14:21:34	1.81
@@ -27,6 +27,7 @@
 #include <sys/utsname.h>
 
 struct formatter;
+__attribute__((format(printf, 3, 0)))
 typedef int (*out_with_comment_fn) (struct formatter * f, const char *comment,
 				    const char *fmt, va_list ap);
 typedef int (*nl_fn) (struct formatter * f);
@@ -147,6 +148,7 @@
 }
 
 #define COMMENT_TAB 6
+__attribute__((format(printf, 3, 0)))
 static int _out_with_comment_file(struct formatter *f, const char *comment,
 				  const char *fmt, va_list ap)
 {
@@ -182,6 +184,7 @@
 	return 1;
 }
 
+__attribute__((format(printf, 3, 0)))
 static int _out_with_comment_raw(struct formatter *f,
 				 const char *comment __attribute__((unused)),
 				 const char *fmt, va_list ap)


