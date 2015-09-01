From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  1 Sep 2015 15:28:51 +0000 (UTC)
Subject: master - libdm: Reinstate dm_task_get_info@Base.
Message-ID: <20150901152851.25F6960C83@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cb57f4f89b908ad3d7149ce18204b71448c9d259
Commit:        cb57f4f89b908ad3d7149ce18204b71448c9d259
Parent:        8b6226997eecb35560fd32fcb571478971024bd1
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Sep 1 16:26:02 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Sep 1 16:26:02 2015 +0100

libdm: Reinstate dm_task_get_info at Base.

Move the version script local:* wildcard into a node of its own
to avoid conflicting with in-source export macro definitions.
---
 WHATS_NEW_DM |    1 +
 make.tmpl.in |    7 ++++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 176759a..ba89a9d 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.107 - 
 ===================================
+  Reinstate dm_task_get_info at Base to libdevmapper exports. (1.02.106)
 
 Version 1.02.106 - 26th August 2015
 ===================================
diff --git a/make.tmpl.in b/make.tmpl.in
index 96889b4..6fc1195 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -502,12 +502,13 @@ else
 	set -e;\
 	R=$$(sort $^ | uniq -u);\
 	test -z "$$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $$R"; false; } ;\
-	for i in $$(echo $(EXPORTED_SYMBOLS) | tr ' ' '\n' | sort -rnt_ -k5 ); do\
+	( for i in $$(echo $(EXPORTED_SYMBOLS) | tr ' ' '\n' | sort -rnt_ -k5 ); do\
 		echo "$${i##*.} {"; echo "	global:";\
 		$(SED) "s/^/		/;s/$$/;/" $$i;\
-		test "$${i##*.}" = Base && { echo "	local:"; echo "		*;"; };\
 		echo "};";\
-	done > $@
+	  done;\
+	  echo "Local {"; echo "	local:"; echo "		*;"; echo "};";\
+	) > $@
 endif
 
 ifeq (,$(findstring $(MAKECMDGOALS),cscope.out cflow clean distclean lcov \


