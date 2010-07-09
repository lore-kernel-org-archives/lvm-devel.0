From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Jul 2010 15:26:41 -0000
Subject: LVM2 WHATS_NEW make.tmpl.in
Message-ID: <20100709152641.11156.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-07-09 15:26:41

Modified files:
	.              : WHATS_NEW make.tmpl.in 

Log message:
	Fix redundant declarations and always compile with -Wredundant-decls.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1660&r2=1.1661
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.104&r2=1.105

--- LVM2/WHATS_NEW	2010/07/09 15:08:12	1.1660
+++ LVM2/WHATS_NEW	2010/07/09 15:26:41	1.1661
@@ -1,5 +1,6 @@
 Version 2.02.71 -
 ===============================
+  Fix redundant declarations and always compile with -Wredundant-decls.
   Fix possible hang when all mirror images of a mirrored log fail.
   Do not log backtrace in valid _lv_resume() code path.
   Cleanup help strings in configure.in.
--- LVM2/make.tmpl.in	2010/06/25 18:17:38	1.104
+++ LVM2/make.tmpl.in	2010/07/09 15:26:41	1.105
@@ -107,9 +107,9 @@
 
 .SUFFIXES: .c .d .o .so .a .po .pot .mo .dylib
 
-CFLAGS += -fPIC -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn -Wformat-security
+CFLAGS += -fPIC -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn -Wformat-security -Wredundant-decls
 
-#CFLAGS += -W -Wconversion -Wpointer-arith -Wredundant-decls -Wbad-function-cast -Wcast-qual
+#CFLAGS += -W -Wconversion -Wpointer-arith -Wbad-function-cast -Wcast-qual
 #CFLAGS += -pedantic -std=gnu99
 
 CFLAGS += @COPTIMISE_FLAG@


