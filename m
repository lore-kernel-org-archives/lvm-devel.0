From: agk@sourceware.org <agk@sourceware.org>
Date: 27 Apr 2007 19:26:57 -0000
Subject: LVM2 ./WHATS_NEW ./make.tmpl.in lib/format_tex ...
Message-ID: <20070427192657.9251.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2007-04-27 20:26:57

Modified files:
	.              : WHATS_NEW make.tmpl.in 
	lib/format_text: export.c 

Log message:
	Add -Wformat-security and change one fprintf() to fputs().

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.609&r2=1.610
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.48&r2=1.49
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/export.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55

--- LVM2/WHATS_NEW	2007/04/27 18:52:05	1.609
+++ LVM2/WHATS_NEW	2007/04/27 19:26:56	1.610
@@ -1,5 +1,6 @@
 Version 2.02.25 -
 =================================
+  Add -Wformat-security and change one fprintf() to fputs().
   Move regex functions into libdevmapper.
   Change some #include lines to search only standard system directories.
   Add devices/preferred_names config regex list for displayed device names.
--- LVM2/make.tmpl.in	2007/04/27 17:46:15	1.48
+++ LVM2/make.tmpl.in	2007/04/27 19:26:56	1.49
@@ -56,7 +56,7 @@
 
 .SUFFIXES: .c .d .o .so .a .po .pot .mo .dylib
 
-CFLAGS += -fPIC -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn
+CFLAGS += -fPIC -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings -Wmissing-prototypes -Wmissing-declarations -Wnested-externs -Winline -Wmissing-noreturn -Wformat-security
 
 #CFLAGS += -W -Wconversion -Wpointer-arith -Wredundant-decls -Wbad-function-cast -Wcast-qual
 #CFLAGS += -pedantic -std=gnu99
--- LVM2/lib/format_text/export.c	2006/11/10 18:24:11	1.54
+++ LVM2/lib/format_text/export.c	2007/04/27 19:26:57	1.55
@@ -160,7 +160,7 @@
 	for (i = 0; i < f->indent; i++)
 		white_space[i] = '\t';
 	white_space[i] = '\0';
-	fprintf(f->data.fp, white_space);
+	fputs(white_space, f->data.fp);
 	i = vfprintf(f->data.fp, fmt, ap);
 
 	if (comment) {
@@ -176,7 +176,7 @@
 
 		while (++i < COMMENT_TAB);
 
-		fprintf(f->data.fp, comment);
+		fputs(comment, f->data.fp);
 	}
 	fputc('\n', f->data.fp);
 


