From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Sep 2011 19:40:29 -0000
Subject: LVM2/libdm libdm-config.c
Message-ID: <20110925194029.17546.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-25 19:40:29

Modified files:
	libdm          : libdm-config.c 

Log message:
	Simplier attribute format
	
	No need to repeat whole declaration for static function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/libdm/libdm-config.c	2011/09/25 19:39:38	1.8
+++ LVM2/libdm/libdm-config.c	2011/09/25 19:40:29	1.9
@@ -316,8 +316,7 @@
 	return 1;
 }
 
-static int _line_append(struct output_line *outline, const char *fmt, ...)
-  __attribute__ ((format(printf, 2, 3)));
+__attribute__ ((format(printf, 2, 3)))
 static int _line_append(struct output_line *outline, const char *fmt, ...)
 {
 	char buf[4096];


