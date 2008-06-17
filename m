From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 17 Jun 2008 14:14:01 -0000
Subject: LVM2 ./WHATS_NEW lib/log/log.c
Message-ID: <20080617141401.17414.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2008-06-17 14:14:00

Modified files:
	.              : WHATS_NEW 
	lib/log        : log.c 

Log message:
	Fix identifier 'error_message_produced' used ambiguously.
	
	Related compiler warning:
	log/log.c:242: warning: declaration of 'error_message_produced' shadows a global declaration
	../include/log.h:98: warning: shadowed declaration is here

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.904&r2=1.905
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/log/log.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/WHATS_NEW	2008/06/13 14:37:15	1.904
+++ LVM2/WHATS_NEW	2008/06/17 14:14:00	1.905
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  Fix ambiguous use of identifier 'error_message_produced'.
   Begin syncing configure.in for merge/unification with device-mapper.
   Fix add_mirror_images not to dereference uninitialized log_lv upon failure.
   Don't call openlog for every debug line output by clvmd.
--- LVM2/lib/log/log.c	2008/06/06 19:28:33	1.46
+++ LVM2/lib/log/log.c	2008/06/17 14:14:00	1.47
@@ -239,9 +239,9 @@
 	_indent = indent;
 }
 
-void init_error_message_produced(int error_message_produced)
+void init_error_message_produced(int value)
 {
-	_error_message_produced = error_message_produced;
+	_error_message_produced = value;
 }
 
 int error_message_produced(void)


