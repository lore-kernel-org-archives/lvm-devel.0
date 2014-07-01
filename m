From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  1 Jul 2014 23:54:27 +0000 (UTC)
Subject: master - make: Fix pofile and .d file generation.
Message-ID: <20140701235427.EEE8B61061@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c77197c688fad937b0701d749b9a449160bb40dc
Commit:        c77197c688fad937b0701d749b9a449160bb40dc
Parent:        70551eec5921e3b8bce7318880e54836f467b5fa
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jul 2 00:48:50 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jul 2 00:48:50 2014 +0100

make: Fix pofile and .d file generation.

Use builddir not srcdir with make pofile.

Append 'incfile:' lines to %.d files to handle newly-missing dependencies
without 'make clean' after a file is moved or deleted.
---
 WHATS_NEW      |    2 ++
 make.tmpl.in   |    4 +++-
 po/Makefile.in |    6 +++---
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4fa881c..2259976 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.108 -
 =================================
+  Change makefile %.d generation to handle filename changes without make clean.
+  Fix use of buildir in make pofile.
   Enhance private volumes UUIDs with suffixed for easier detection.
   Do not use reserved _[tc]meta volumes for temporary LVs.
   Leave backup pool metadata with _meta%d suffix instead of reserved _tmeta%d.
diff --git a/make.tmpl.in b/make.tmpl.in
index 5a3694a..5d4c144 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -362,7 +362,7 @@ $(TARGETS): $(OBJECTS)
 	$(CC) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.pot: %.c Makefile
-	$(CC) -E $(INCLUDES) -include $(top_srcdir)/include/pogen.h \
+	$(CC) -E $(INCLUDES) -include $(top_builddir)/include/pogen.h \
 		$(DEFS) $(WFLAGS) $(CFLAGS) $< > $@
 
 %.so: %.o
@@ -413,6 +413,8 @@ $(LIB_STATIC): $(OBJECTS)
 	DEPS=`echo $(DEPS) | sed -e 's/\\//\\\\\\//g'`; \
 	$(CC) -MM $(INCLUDES) $(DEFS) -o $@ $<; \
 	sed -i "s/\(.*\)\.o[ :]*/$$FILE.o $$FILE.d $$FILE.pot: $$DEPS /g" $@; \
+	DEPLIST=`sed 's/ \\\\//;s/.*://;' < $@`; \
+	echo $$DEPLIST | fmt -1 | sed 's/ //g;s/\(.*\)/\1:/' >> $@; \
 	[ -s $@ ] || $(RM) $@
 
 %.mo: %.po
diff --git a/po/Makefile.in b/po/Makefile.in
index a4f57a6..ff5db17 100644
--- a/po/Makefile.in
+++ b/po/Makefile.in
@@ -19,10 +19,10 @@ LANGS=de
 
 TARGETS=$(LANGS:%=lvm2_%.mo) $(LANGS:%=dm_%.mo)
 
-DM_POSOURCES = $(top_srcdir)/dmsetup/*.pot $(top_srcdir)/libdm/*.pot \
-	       $(top_srcdir)/libdm/*/*.pot
+DM_POSOURCES = $(top_builddir)/tools/dmsetup.pot $(top_builddir)/libdm/*.pot \
+	       $(top_builddir)/libdm/*/*.pot
 
-LVM_POSOURCES = $(top_srcdir)/tools/*.pot $(top_srcdir)/lib/*/*.pot
+LVM_POSOURCES = $(top_builddir)/tools/*.pot $(top_builddir)/lib/*/*.pot
 
 include $(top_builddir)/make.tmpl
 


