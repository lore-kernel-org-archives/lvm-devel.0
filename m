From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Nov 2011 14:56:48 -0000
Subject: LVM2/test Makefile.in api/Makefile.in lib/harn ...
Message-ID: <20111123145648.13518.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-23 14:56:47

Modified files:
	test           : Makefile.in 
	test/api       : Makefile.in 
	test/lib       : harness.c 

Log message:
	Cleanup files from testing
	
	Cleanup generated files from coverage testing.
	Do not skip standard .o compilation for lib/not and lib/harness.
	Make a bit longer string in harness to fit new shell/ in.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/Makefile.in.diff?cvsroot=lvm2&r1=1.65&r2=1.66
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/api/Makefile.in.diff?cvsroot=lvm2&r1=1.24&r2=1.25
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/lib/harness.c.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/test/Makefile.in	2011/11/23 13:03:57	1.65
+++ LVM2/test/Makefile.in	2011/11/23 14:56:47	1.66
@@ -25,6 +25,7 @@
 abs_top_srcdir = @abs_top_srcdir@
 
 SUBDIRS = api unit
+SOURCES = lib/not.c lib/harness.c
 
 include $(top_builddir)/make.tmpl
 
@@ -61,8 +62,8 @@
 lib/should: lib/not
 	ln -sf not lib/should
 
-lib/%: $(srcdir)/lib/%.c .lib-dir-stamp
-	$(CC) $(DEFS) $(CFLAGS) -o $@ $<
+lib/%: lib/%.o .lib-dir-stamp
+	$(CC) $(LDFLAGS) -o $@ $<
 
 lib/%: $(srcdir)/lib/%.sh .lib-dir-stamp
 	cp $< $@
--- LVM2/test/api/Makefile.in	2011/11/23 13:02:17	1.24
+++ LVM2/test/api/Makefile.in	2011/11/23 14:56:47	1.25
@@ -21,6 +21,7 @@
 SOURCES = test.c
 
 TARGETS += vgtest.t percent.t pe_start.t
+SOURCES2 = vgtest.c percent.c pe_start.c
 endif
 
 include $(top_builddir)/make.tmpl
--- LVM2/test/lib/harness.c	2011/11/07 17:02:56	1.9
+++ LVM2/test/lib/harness.c	2011/11/23 14:56:47	1.10
@@ -208,7 +208,7 @@
 		char buf[128];
 		snprintf(buf, 128, "%s ...", f);
 		buf[127] = 0;
-		printf("Running %-40s ", buf);
+		printf("Running %-50s ", buf);
 		fflush(stdout);
 		while ((w = waitpid(pid, &st, WNOHANG)) == 0) {
 			drain();


