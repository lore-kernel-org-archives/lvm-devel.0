From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  2 Mar 2021 21:58:14 +0000 (GMT)
Subject: main - makefiles: fix man-generate rule
Message-ID: <20210302215814.4D9863851C35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8d93d8b7b7f9ae90e56f171e694da0304ab3c6fe
Commit:        8d93d8b7b7f9ae90e56f171e694da0304ab3c6fe
Parent:        824230e1e27c285eff98cec7497ef9474ceb4ddd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 28 01:17:31 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 2 22:54:40 2021 +0100

makefiles: fix man-generate rule

Symlink and compiled man-generate binary has to go to builddir.
---
 tools/Makefile.in | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/Makefile.in b/tools/Makefile.in
index dce85726b..c89c75fa5 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -128,13 +128,13 @@ lvm: $(OBJECTS) lvm.o $(LVMINTERNAL_LIBS)
 
 DEFS_man-generator.o += -DMAN_PAGE_GENERATOR
 
-man-generator.c: command.c
+man-generator.c: $(srcdir)/command.c
 	@echo "    [LN] $@"
-	$(Q) $(LN_S) -f $< $@
+	$(Q) $(LN_S) -f $< $(@F)
 
 man-generator: man-generator.o
 	@echo "    [CC] $@"
-	$(Q) $(CC) $(CFLAGS) -o $@ $<
+	$(Q) $(CC) $(CFLAGS) -o $@ $(<F)
 
 lvm.static: $(OBJECTS) lvm-static.o $(LVMINTERNAL_LIBS)
 	@echo "    [CC] $@"


