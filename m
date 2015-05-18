From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 18 May 2015 10:52:27 +0000 (UTC)
Subject: master - makefiles: use single target
Message-ID: <20150518105227.0E50360EEA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf2b1986c20ca8fccaac0d328d3530dacf5e40f0
Commit:        bf2b1986c20ca8fccaac0d328d3530dacf5e40f0
Parent:        fe00b163d67a6ec9c113fdc9c5ed06ad1d72c6d5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 18 10:18:19 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 18 12:45:42 2015 +0200

makefiles: use single target

Possibly  easier to follow - to have just a single dependency line
and use  if() within rule.

Also replace $(words) with $(firstword) which is more commonly used.
---
 make.tmpl.in |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 2206cc2..4ad7f58 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -475,32 +475,30 @@ distclean: cleandir $(SUBDIRS.distclean)
 .exported_symbols_generated: $(EXPORTED_HEADER) .exported_symbols $(DEPS)
 	set -e; \
 	( cat $(srcdir)/.exported_symbols; \
-	  if test x$(EXPORTED_HEADER) != x; then \
+	  if test -n "$(EXPORTED_HEADER)"; then \
 		$(CC) -E -P $(INCLUDES) $(DEFS) $(EXPORTED_HEADER) | \
 		$(SED) -ne "/^typedef|}/!s/.*[ *]\($(EXPORTED_FN_PREFIX)_[a-z0-9_]*\)(.*/\1/p"; \
 	  fi \
 	) > $@
 
 EXPORTED_UC := $(shell echo $(EXPORTED_FN_PREFIX) | tr '[a-z]' '[A-Z]')
-EXPORTED_FILES := $(wildcard $(srcdir)/.exported_symbols.Base $(srcdir)/.exported_symbols.$(EXPORTED_UC)_[0-9_]*[0-9])
+EXPORTED_SYMBOLS := $(wildcard $(srcdir)/.exported_symbols.Base $(srcdir)/.exported_symbols.$(EXPORTED_UC)_[0-9_]*[0-9])
 
-ifeq (0,$(words $(EXPORTED_FILES)))
-.export.sym: .exported_symbols_generated
-	set -e; (echo "Base {"; echo "	global:"; \
-		 $(SED) "s/^/		/;s/$$/;/" < $<; \
+.export.sym: .exported_symbols_generated $(EXPORTED_SYMBOLS)
+ifeq (,$(firstword $(EXPORTED_SYMBOLS)))
+	set -e; (echo "Base {"; echo "	global:";\
+		 $(SED) "s/^/		/;s/$$/;/" $<;\
 		 echo "	local:"; echo "		*;"; echo "};") > $@
-
 else
-.export.sym: .exported_symbols_generated $(EXPORTED_FILES)
-	set -e; \
+	set -e;\
 	R=$(shell sort $^ | uniq -u);\
 	test -z "$$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $$R"; false; } ;\
-	(for i in $(EXPORTED_FILES) ; do\
+	for i in $(EXPORTED_SYMBOLS); do\
 		echo "$${i##*.} {"; echo "	global:";\
-		$(SED) "s/^/		/;s/$$/;/" < $$i;\
+		$(SED) "s/^/		/;s/$$/;/" $$i;\
 		test "$$i" = Base && { echo "	local:"; echo "		*;"; };\
 		echo "};";\
-	done ) > $@
+	done > $@
 endif
 
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \


