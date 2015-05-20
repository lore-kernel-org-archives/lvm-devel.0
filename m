From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 May 2015 07:36:14 +0000 (UTC)
Subject: master - makefiles: use bash subshell
Message-ID: <20150520073614.7225160EFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f3c7bd4004a64b6ce2c9e0f0069eedb050420c62
Commit:        f3c7bd4004a64b6ce2c9e0f0069eedb050420c62
Parent:        682e0c898e7fd96ff936b7113738f773335e0fff
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 20 09:25:50 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 20 09:33:51 2015 +0200

makefiles: use bash subshell

Avoid using  make's $(shell invocation since the eval order is
then somewhat different and use $$(  subshell.

This also fixes a problem when more then one symbol is found,
since target shell has been given separate word list
so the 'R' assignment would need "" around it.
---
 make.tmpl.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 806bde4..731dab7 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -499,7 +499,7 @@ ifeq (,$(firstword $(EXPORTED_SYMBOLS)))
 		 echo "	local:"; echo "		*;"; echo "};") > $@
 else
 	set -e;\
-	R=$(shell sort $^ | uniq -u);\
+	R=$$(sort $^ | uniq -u);\
 	test -z "$$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $$R"; false; } ;\
 	for i in $(EXPORTED_SYMBOLS); do\
 		echo "$${i##*.} {"; echo "	global:";\


