From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue,  6 Apr 2021 20:07:18 +0000 (GMT)
Subject: main - makefiles: slight change in .export.sym
Message-ID: <20210406200718.3C8453858012@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=40b277ae1799fc7a2e3f38b0abebd81a8e3d1995
Commit:        40b277ae1799fc7a2e3f38b0abebd81a8e3d1995
Parent:        1398e66a556fd3ed79353819ca8bef4ccb351990
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 4 13:06:09 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 6 21:26:57 2021 +0200

makefiles: slight change in .export.sym

Avoid emitting Local symbol and sort symbols from
start and add dependency on previous version
Should not change anything, just better followup
linkage guidlines.
---
 libdm/make.tmpl.in | 13 +++++++------
 make.tmpl.in       | 13 +++++++------
 2 files changed, 14 insertions(+), 12 deletions(-)

diff --git a/libdm/make.tmpl.in b/libdm/make.tmpl.in
index 70edcf91d..219eeca9d 100644
--- a/libdm/make.tmpl.in
+++ b/libdm/make.tmpl.in
@@ -509,20 +509,21 @@ EXPORTED_SYMBOLS := $(wildcard $(srcdir)/.exported_symbols.Base $(srcdir)/.expor
 ifeq (,$(firstword $(EXPORTED_SYMBOLS)))
 	$(Q) set -e; (echo "Base {"; echo "	global:";\
 		 $(SED) "/^#/d;s/^/		/;s/$$/;/" $<;\
+		 echo "	local:"; echo "		*;";\
 		 echo "};";\
-		 echo "Local {"; echo "	local:"; echo "		*;"; echo "};";\
 		 ) > $@
 else
 	$(Q) set -e;\
 	R=$$($(SORT) $^ | $(GREP) -v "^#" | uniq -u);\
 	test -z "$$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $$R"; false; } ;\
-	( for i in $$(echo $(EXPORTED_SYMBOLS) | tr ' ' '\n' | $(SORT) -rnt_ -k5 ); do\
+	LAST=;\
+	for i in $$(echo $(EXPORTED_SYMBOLS) | tr ' ' '\n' | $(SORT) -nt_ -k5 ); do\
 		echo "$${i##*.} {"; echo "	global:";\
 		$(SED) "/^#/d;s/^/		/;s/$$/;/" $$i;\
-		echo "};";\
-	  done;\
-	  echo "Local {"; echo "	local:"; echo "		*;"; echo "};";\
-	) > $@
+		if test -z "$$LAST"; then echo "	local:"; echo "		*;";fi;\
+		echo "}$$LAST;";\
+		LAST=" $${i##*.}";\
+	done > $@
 endif
 
 ifeq ("@USE_TRACKING@","yes")
diff --git a/make.tmpl.in b/make.tmpl.in
index 99998f9fd..b28ef6f8f 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -551,20 +551,21 @@ EXPORTED_SYMBOLS := $(wildcard $(srcdir)/.exported_symbols.Base $(srcdir)/.expor
 ifeq (,$(firstword $(EXPORTED_SYMBOLS)))
 	$(Q) set -e; (echo "Base {"; echo "	global:";\
 		 $(SED) "/^#/d;s/^/		/;s/$$/;/" $<;\
+		 echo "	local:"; echo "		*;";\
 		 echo "};";\
-		 echo "Local {"; echo "	local:"; echo "		*;"; echo "};";\
 		 ) > $@
 else
 	$(Q) set -e;\
 	R=$$($(SORT) $^ | $(GREP) -v "^#" | uniq -u);\
 	test -z "$$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $$R"; false; } ;\
-	( for i in $$(echo $(EXPORTED_SYMBOLS) | tr ' ' '\n' | $(SORT) -rnt_ -k5 ); do\
+	LAST=;\
+	for i in $$(echo $(EXPORTED_SYMBOLS) | tr ' ' '\n' | $(SORT) -nt_ -k5 ); do\
 		echo "$${i##*.} {"; echo "	global:";\
 		$(SED) "/^#/d;s/^/		/;s/$$/;/" $$i;\
-		echo "};";\
-	  done;\
-	  echo "Local {"; echo "	local:"; echo "		*;"; echo "};";\
-	) > $@
+		if test -z "$$LAST"; then echo "	local:"; echo "		*;";fi;\
+		echo "}$$LAST;";\
+		LAST=" $${i##*.}";\
+	done > $@
 endif
 
 ifeq ("$(USE_TRACKING)","yes")


