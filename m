From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  4 Dec 2013 12:30:21 +0000 (UTC)
Subject: master - make: support per-object defines
Message-ID: <20131204123021.B03796030C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc37d4fb0dfc47c49b8acdc773a4ad67d59b51b8
Commit:        fc37d4fb0dfc47c49b8acdc773a4ad67d59b51b8
Parent:        6c6bcc00e401262db3b906259674a3231a119603
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 4 12:35:02 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Dec 4 13:30:08 2013 +0100

make: support per-object defines

In the case we have a dir with multiple objects and for
an individual object file we need special define -
allow to define it without adding extra rules.

To ensure dmeventd.o compilation will use EXTRA_FLAGS:
CFLAGS_dmeventd.o += $(EXTRA_FLAGS)

Then it's better to use:
dmeventd.o: CFLAGS += $(EXTRA_FLAGS)
---
 WHATS_NEW    |    1 +
 make.tmpl.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 9155ddf..d512ab5 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Support per-object compilation cflags via CFLAGS_object.o.
   Automatically detect support for compiler/linker options to use RELRO and PIE.
   Add --splitsnapshot to lvconvert to separate out cow LV.
   Reinstate origin reload to complete lvconvert -s with active LVs. (2.02.98)
diff --git a/make.tmpl.in b/make.tmpl.in
index 35a47be..944be9b 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -345,7 +345,7 @@ endif
 $(TARGETS): $(OBJECTS)
 
 %.o: %.c
-	$(CC) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(CFLAGS) $< -o $@
+	$(CC) -c $(INCLUDES) $(DEFS) $(WFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.pot: %.c Makefile
 	$(CC) -E $(INCLUDES) -include $(top_srcdir)/include/pogen.h \


