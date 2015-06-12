From: Lidong Zhong <lzhong@suse.com>
Date: Fri, 12 Jun 2015 15:33:25 +0800
Subject: [PATCH] makefile: fail to compile if there are more than one exported symbols.
Message-ID: <1434094405-8391-1-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 make.tmpl.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/make.tmpl.in b/make.tmpl.in
index 731dab7..60ddd01 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -499,7 +499,7 @@ ifeq (,$(firstword $(EXPORTED_SYMBOLS)))
 		 echo "	local:"; echo "		*;"; echo "};") > $@
 else
 	set -e;\
-	R=$$(sort $^ | uniq -u);\
+	R="$$(sort $^ | uniq -u)";\
 	test -z "$$R" || { echo "Mismatch between symbols in shared library and lists in .exported_symbols.* files: $$R"; false; } ;\
 	for i in $(EXPORTED_SYMBOLS); do\
 		echo "$${i##*.} {"; echo "	global:";\
-- 
1.8.1.4


