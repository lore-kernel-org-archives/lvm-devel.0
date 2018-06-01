From: Joe Thornber <thornber@sourceware.org>
Date: Fri, 1 Jun 2018 10:31:10 -0400
Subject: master - Revert "Revert "build: Calculate dependencies at same time as compiling.""
Message-ID: <201806011431.w51EVAav024645@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=02b99be57eab4f55bd0db045a3873bdf5e500b92
Commit:        02b99be57eab4f55bd0db045a3873bdf5e500b92
Parent:        413488edc6dd077e79517e44a8d3b9a51c5138e5
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Fri May 11 14:40:05 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Fri May 11 14:40:05 2018 +0100

Revert "Revert "build: Calculate dependencies at same time as compiling.""

This reverts commit ed837e6971ee84aa5b112e021df19901ae400216.
---
 make.tmpl.in |   19 ++++++-------------
 1 files changed, 6 insertions(+), 13 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 9d5d367..d3a80ef 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -442,12 +442,14 @@ endif
 
 .LIBPATTERNS = lib%.so lib%.a
 
+DEPFLAGS=-MT $@ -MMD -MP -MF $*.d
+
 # still needed in 2018 for 32bit builds
 DEFS+=-D_FILE_OFFSET_BITS=64
 
 %.o: %.c
 	@echo "    [CC] $<"
-	$(Q) $(CC) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
+	$(Q) $(CC) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.o: %.cpp
 	@echo "    [CXX] $<"
@@ -507,18 +509,9 @@ $(LIB_STATIC): $(OBJECTS)
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(OBJECTS) > /dev/null
 
-%.d: %.c $(INC_LNS)
-	@echo "    [DEP] $<"
-	$(Q) $(MKDIR_P) $(dir $@); \
-	set -e; \
-	FILE=`echo $@ | sed 's/\\//\\\\\\//g;s/\\.d//g'`; \
-	DEPS=`echo $(DEPS) | sed -e 's/\\//\\\\\\//g'`; \
-	$(CC) -MM $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) -o $@ $<; \
-	sed -i "s/\(.*\)\.o[ :]*/$$FILE.o $$FILE.d $$FILE.pot: $$DEPS /g" $@; \
-	DEPLIST=`sed 's/ \\\\//;s/.*://;' < $@`; \
-	echo $$DEPLIST | fmt -1 | sed 's/ //g;s/\(.*\)/\1:/' >> $@; \
-	[ -s $@ ] || $(RM) $@
-
+%.d: $(INC_LNS)
+.PRECIOUS: %.d
+	
 %.mo: %.po
 	@echo "    [MSGFMT] $<"
 	$(Q) $(MSGFMT) -o $@ $<


