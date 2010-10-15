From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 15 Oct 2010 09:41:22 -0000
Subject: LVM2/tools Makefile.in
Message-ID: <20101015094122.24938.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-15 09:41:21

Modified files:
	tools          : Makefile.in 

Log message:
	Fix linking order for liblvm2cmd
	
	Reorder linked libraries so we better support --as-needed linker flag used
	by some distributions (i.e. Gentoo).
	
	Patch suggested by Diego Elio Petten?? <flameeyes <at> gmail.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/Makefile.in.diff?cvsroot=lvm2&r1=1.121&r2=1.122

--- LVM2/tools/Makefile.in	2010/08/03 13:00:46	1.121
+++ LVM2/tools/Makefile.in	2010/10/15 09:41:21	1.122
@@ -149,8 +149,9 @@
 
 liblvm2cmd.$(LIB_SUFFIX): liblvm2cmd.a $(LDDEPS)
 	$(CC) -shared -Wl,-soname,$@.$(LIB_VERSION) \
-	$(CFLAGS) $(CLDFLAGS) -o $@ $(LVMLIBS) $(LIBS) \
-		@CLDWHOLEARCHIVE@ liblvm2cmd.a @CLDNOWHOLEARCHIVE@
+		$(CFLAGS) $(CLDFLAGS) -o $@ \
+		@CLDWHOLEARCHIVE@ liblvm2cmd.a @CLDNOWHOLEARCHIVE@ \
+		$(LVMLIBS) $(LIBS)
 
 liblvm2cmd.$(LIB_SUFFIX).$(LIB_VERSION): liblvm2cmd.$(LIB_SUFFIX)
 	$(LN_S) -f $< $@


