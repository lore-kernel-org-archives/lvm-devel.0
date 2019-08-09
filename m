From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Aug 2019 06:58:25 -0400
Subject: master - make: support comments in exported symbols
Message-ID: <201908091058.x79AwPci031539@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f2489d9dda78a9976b9655cd82efaa7ef6615e91
Commit:        f2489d9dda78a9976b9655cd82efaa7ef6615e91
Parent:        3fcb4697f652e8f439b865f3b544b83576c156ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 30 15:31:01 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 9 12:57:07 2019 +0200

make: support comments in exported symbols

Now the lines starting with '#' in exported symbols files are treated as
comments (ignored).
---
 libdm/make.tmpl.in |    6 +++---
 make.tmpl.in       |    6 +++---
 2 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 26e3dba..9041da5 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -512,17 +512,17 @@ EXPORTED_SYMBOLS := $(wildcard $(srcdir)/.exported_symbols.Base $(srcdir)/.expor
 .export.sym: .exported_symbols_generated $(EXPORTED_SYMBOLS)
 ifeq (,$(firstword $(EXPORTED_SYMBOLS)))
 	$(Q) set -e; (echo "Base {"; echo "	global:";\
-		 $(SED) "s/^/		/;s/$$/;/" $<;\
+		 $(SED) "/^#/d;s/^/		/;s/$$/;/" $<;\
 		 echo "};";\
 		 echo "Local {"; echo "	local:"; echo "		*;"; echo "};";\
 		 ) > $@
 else
 	$(Q) set -e;\
-	R=$$($(SORT) $^ | uniq -u);\
+	R=$$($(SORT) $^ | $(GREP) -v "^#" | uniq -u);\
 	test -z "$$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $$R"; false; } ;\
 	( for i in $$(echo $(EXPORTED_SYMBOLS) | tr ' ' '\n' | $(SORT) -rnt_ -k5 ); do\
 		echo "$${i##*.} {"; echo "	global:";\
-		$(SED) "s/^/		/;s/$$/;/" $$i;\
+		$(SED) "/^#/d;s/^/		/;s/$$/;/" $$i;\
 		echo "};";\
 	  done;\
 	  echo "Local {"; echo "	local:"; echo "		*;"; echo "};";\
diff --git a/make.tmpl.in b/make.tmpl.in
index f3332e9..8a20818 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -551,17 +551,17 @@ EXPORTED_SYMBOLS := $(wildcard $(srcdir)/.exported_symbols.Base $(srcdir)/.expor
 .export.sym: .exported_symbols_generated $(EXPORTED_SYMBOLS)
 ifeq (,$(firstword $(EXPORTED_SYMBOLS)))
 	$(Q) set -e; (echo "Base {"; echo "	global:";\
-		 $(SED) "s/^/		/;s/$$/;/" $<;\
+		 $(SED) "/^#/d;s/^/		/;s/$$/;/" $<;\
 		 echo "};";\
 		 echo "Local {"; echo "	local:"; echo "		*;"; echo "};";\
 		 ) > $@
 else
 	$(Q) set -e;\
-	R=$$($(SORT) $^ | uniq -u);\
+	R=$$($(SORT) $^ | $(GREP) -v "^#" | uniq -u);\
 	test -z "$$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $$R"; false; } ;\
 	( for i in $$(echo $(EXPORTED_SYMBOLS) | tr ' ' '\n' | $(SORT) -rnt_ -k5 ); do\
 		echo "$${i##*.} {"; echo "	global:";\
-		$(SED) "s/^/		/;s/$$/;/" $$i;\
+		$(SED) "/^#/d;s/^/		/;s/$$/;/" $$i;\
 		echo "};";\
 	  done;\
 	  echo "Local {"; echo "	local:"; echo "		*;"; echo "};";\


