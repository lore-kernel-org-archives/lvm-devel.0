From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 4 May 2018 04:50:11 -0400
Subject: master - Revert "build: Calculate dependencies at same time as compiling."
Message-ID: <201805040850.w448oBQV030439@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ed837e6971ee84aa5b112e021df19901ae400216
Commit:        ed837e6971ee84aa5b112e021df19901ae400216
Parent:        49db9b5e0b35f6b0a47ad10276fb252c09f438ef
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri May 4 09:48:40 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri May 4 09:48:40 2018 +0100

Revert "build: Calculate dependencies at same time as compiling."

This reverts commit 0931067dc5549c443e144d599683b53220021f44.

The dep files should be in the build dir, which is not necc. the src dir.

Easy to fix, but reverting for now until I have time to revisit.
---
 make.tmpl.in |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index d3a80ef..9d5d367 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -442,14 +442,12 @@ endif
 
 .LIBPATTERNS = lib%.so lib%.a
 
-DEPFLAGS=-MT $@ -MMD -MP -MF $*.d
-
 # still needed in 2018 for 32bit builds
 DEFS+=-D_FILE_OFFSET_BITS=64
 
 %.o: %.c
 	@echo "    [CC] $<"
-	$(Q) $(CC) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
+	$(Q) $(CC) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.o: %.cpp
 	@echo "    [CXX] $<"
@@ -509,9 +507,18 @@ $(LIB_STATIC): $(OBJECTS)
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(OBJECTS) > /dev/null
 
-%.d: $(INC_LNS)
-.PRECIOUS: %.d
-	
+%.d: %.c $(INC_LNS)
+	@echo "    [DEP] $<"
+	$(Q) $(MKDIR_P) $(dir $@); \
+	set -e; \
+	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \
+	DEPS=`echo $(DEPS) | sed -e 's/\\//\\\\\\//g'`; \
+	$(CC) -MM $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) -o $@ $<; \
+	sed -i "s/\(.*\)\.o[ :]*/$$FILE.o $$FILE.d $$FILE.pot: $$DEPS /g" $@; \
+	DEPLIST=`sed 's/ \\\\//;s/.*://;' < $@`; \
+	echo $$DEPLIST | fmt -1 | sed 's/ //g;s/\(.*\)/\1:/' >> $@; \
+	[ -s $@ ] || $(RM) $@
+
 %.mo: %.po
 	@echo "    [MSGFMT] $<"
 	$(Q) $(MSGFMT) -o $@ $<


