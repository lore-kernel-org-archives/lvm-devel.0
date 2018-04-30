From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 30 Apr 2018 04:34:46 -0400
Subject: master - build: Calculate dependencies at same time as compiling.
Message-ID: <201804300834.w3U8Yknx016112@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0931067dc5549c443e144d599683b53220021f44
Commit:        0931067dc5549c443e144d599683b53220021f44
Parent:        ab63923d19afe3f72d4806082fb8496c8c7900f9
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Apr 30 09:32:14 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Apr 30 09:32:14 2018 +0100

build: Calculate dependencies at same time as compiling.

Speeds up the build slightly.
---
 make.tmpl.in |   17 +++++------------
 1 files changed, 5 insertions(+), 12 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 4542392..76e076a 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -441,9 +441,11 @@ endif
 
 .LIBPATTERNS = lib%.so lib%.a
 
+DEPFLAGS=-MT $@ -MMD -MP -MF $*.d
+
 %.o: %.c
 	@echo "    [CC] $<"
-	$(Q) $(CC) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
+	$(Q) $(CC) $(DEPFLAGS) -c $(INCLUDES) $(VALGRIND_CFLAGS) $(PROGS_CFLAGS) $(DEFS) $(DEFS_$@) $(WFLAGS) $(WCFLAGS) $(CFLAGS) $(CFLAGS_$@) $< -o $@
 
 %.o: %.cpp
 	@echo "    [CXX] $<"
@@ -503,17 +505,8 @@ $(LIB_STATIC): $(OBJECTS)
 	$(Q) $(RM) $@
 	$(Q) $(AR) rsv $@ $(OBJECTS) > /dev/null
 
-%.d: %.c
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
+%.d: ;
+.PRECIOUS: %.d
 
 %.mo: %.po
 	@echo "    [MSGFMT] $<"


