From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 7 Aug 2019 09:29:24 -0400
Subject: stable-2.02 - make: support comments in exported symbols
Message-ID: <201908071329.x77DTO9k018627@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f39141ebc1aa7f4eda302530ccf866e6954dd077
Commit:        f39141ebc1aa7f4eda302530ccf866e6954dd077
Parent:        5ddd1ead2dcaf9594a025a15986b8bac573c81b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 30 15:31:01 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 7 15:27:25 2019 +0200

make: support comments in exported symbols

Now the lines starting with '#' in exported symbols files are treated as
comments (ignored).
---
 make.tmpl.in |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 9d5d367..c8e4f14 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -557,17 +557,17 @@ EXPORTED_SYMBOLS := $(wildcard $(srcdir)/.exported_symbols.Base $(srcdir)/.expor
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


