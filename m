From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 25 Aug 2015 18:06:17 +0000 (UTC)
Subject: master - makefiles: remove stray ')'
Message-ID: <20150825180617.761DA6031C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8c09f12943a8136079360a05bc0afc120cfc7674
Commit:        8c09f12943a8136079360a05bc0afc120cfc7674
Parent:        19ef3e0f31f375be72da875a5e6beb5d10af44df
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Tue Aug 25 19:05:45 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Aug 25 19:05:45 2015 +0100

makefiles: remove stray ')'

---
 make.tmpl.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 3e39a3a..dbc839a 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -502,7 +502,7 @@ else
 	set -e;\
 	R=$$(sort $^ | uniq -u);\
 	test -z "$$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $$R"; false; } ;\
-	for i in $$(echo $(EXPORTED_SYMBOLS) | tr ' ' '\n' | sort -rnt_ -k5 )); do\
+	for i in $$(echo $(EXPORTED_SYMBOLS) | tr ' ' '\n' | sort -rnt_ -k5 ); do\
 		echo "$${i##*.} {"; echo "	global:";\
 		$(SED) "s/^/		/;s/$$/;/" $$i;\
 		test "$$i" = Base && { echo "	local:"; echo "		*;"; };\


