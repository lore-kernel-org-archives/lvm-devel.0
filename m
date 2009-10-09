From: agk@sourceware.org <agk@sourceware.org>
Date: 9 Oct 2009 15:55:33 -0000
Subject: LVM2 make.tmpl.in
Message-ID: <20091009155533.1886.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-10-09 15:55:32

Modified files:
	.              : make.tmpl.in 

Log message:
	linking parms missing from o->so conversion.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/make.tmpl.in.diff?cvsroot=lvm2&r1=1.72&r2=1.73

--- LVM2/make.tmpl.in	2009/10/02 19:10:32	1.72
+++ LVM2/make.tmpl.in	2009/10/09 15:55:31	1.73
@@ -204,7 +204,7 @@
 		$(DEFS) $(CFLAGS) $< > $@
 
 %.so: %.o
-	$(CC) -c $(INCLUDES) $(DEFS) $(CFLAGS) $< -o $@
+	$(CC) -c $(INCLUDES) $(DEFS) $(CFLAGS) $(CLDFLAGS) $< $(LIBS) -o $@
 
 ifeq ("@LIB_SUFFIX@","so")
 $(LIB_SHARED): $(OBJECTS) $(LDDEPS)


