From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 29 Mar 2017 18:44:55 -0400
Subject: master - man: use variable in Makefile / regexp
Message-ID: <201703292244.v2TMit52016517@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e9921ffd333692e8262ec511328dc97a5fc42ba6
Commit:        e9921ffd333692e8262ec511328dc97a5fc42ba6
Parent:        2f1fd1584efc46e69453a38788ad22470f73698a
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 30 00:41:24 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 30 00:44:35 2017 +0200

man: use variable in Makefile / regexp

---
 man/Makefile.in |   37 +++++++++++++++++++++----------------
 1 files changed, 21 insertions(+), 16 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index dd170ac..a391e90 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -198,23 +198,28 @@ endef
 # - in symbolic use (e.g. '->')
 # - in single one in '\\f.-'
 define ESCAPEHYPHENS
-$(SED) -i -e "s+\([^\\]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
-	  -e "s+\([^\\]\)-\{6\}+\1\\\-\\\-\\\-\\\-\\\-\\\-+g" \
-	  -e "s+\([^\\]\)-\{5\}+\1\\\-\\\-\\\-\\\-\\\-+g" \
-	  -e "s+\([^\\]\)-\{4\}+\1\\\-\\\-\\\-\\\-+g" \
-	  -e "s+\([^\\]\)-\{3\}+\1\\\-\\\-\\\-+g" \
-	  -e "s+\([^\\]\)-\{2\}+\1\\\-\\\-+g" \
-	  -e "s+^-\{2\}+\\\-\\\-+g" \
-	  -e "s+ -\([[:alnum:]]\)+ \\\-\1+g" \
-	  -e "s+\(cache\)-\([[:alpha:]]\{1,\}\)+\1\\\-\2+g" \
-	  -e "s+\(thin\)-\([[:alpha:]]\{1,\}\)+\1\\\-\2+g" \
-	  -e "s+\([ :\[][[:alnum:]]\{1,\}\)-\([[:alnum:]]\{1,\}[[ ]\)+\1\\\-\2+g" \
-	  -e "s+\([[:alnum:]]\{2,\}\)-\([[:alnum:]]\{2,\}\)-\([[:alnum:]]\{2,\}\)+\1\\\-\2\\\-\3+g" \
-	  -e "s+\([[:alnum:]]\{2,\}\)-\([[:alnum:]]\{2,\}\)+\1\\\-\2+g" \
+$(SED) -i -e "s+\([ [:alpha:]]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
+	  -e "s+\([ [:alpha:]]\)-\{6\}+\1\\\-\\\-\\\-\\\-\\\-\\\-+g" \
+	  -e "s+\([ [:alpha:]]\)-\{5\}+\1\\\-\\\-\\\-\\\-\\\-+g" \
+	  -e "s+\([ [:alpha:]]\)-\{4\}+\1\\\-\\\-\\\-\\\-+g" \
+	  -e "s+\([ [:alpha:]]\)-\{3\}+\1\\\-\\\-\\\-+g" \
+	  -e "s+\([ [:alpha:]]\)-\{2\}+\1\\\-\\\-+g" \
+	  -e "s+\([^\]\)-\([[:alnum:]\?]\)+\1\\\-\2+g" \
+	  -e "s+ --+\\\-\\\-+g" \
+	  -e "s+|-|+|\\\-|+g" \
+	  -e "s+ -\"+ \\\-\"+g" \
+	  -e "s+'--'+'\\\-\\\-'+g" \
+	  -e "s+^--+\\\-\\\-+g" \
+	  -e "s+\([[:alnum:]]\) - \([[:alnum:]]\)+\1 \\\- \2+g" \
 	  -e "s+\(<\)-+\1\\\-+g" \
 	  -e "s+[^\\]-\(>\)+\\\-\1+g" \
-	  -e "s+\(\\\f.\)-\([^-]\)+\1\\\-\2+g" \
-	  -e "s+\([[:digit:]]\{4\}\).*-\([[:digit:]]\{2\}\).*-\([[:digit:]]\{2\}\)+\1-\2-\3+g" $@
+	  -e "s+\([[:alnum:]]\{2,\}\)\\\-\([[:alnum:]]\{2,\}\)+\1-\2+g" \
+	  -e "s+\(\\\-\\\-[[:alnum:]]\{2,\}\)-+\1\\\-+g" \
+	  -e "s+\(lvm2\-activation\)+lvm2\\\-activation+" \
+	  -e "s+\([[:digit:]]\)-\([[:digit:]]\)+\1\\\-\2+g" \
+	  -e "s+\\\-git+\-git+g" \
+	  -e "s+\(vg.*\)\-lv+\1\\\-lv+g" \
+	  -e "s+\([[:digit:]]\{4\}\)\\\-\([[:digit:]]\{2\}\)\\\-\([[:digit:]]\{2\}\)+\1-\2-\3+g" $@
 endef
 
 %.5: $(srcdir)/%.5_main
@@ -233,7 +238,7 @@ endef
 	$(SUBSTVARS)
 	$(ESCAPEHYPHENS)
 
-lvm-config.8 lvm-dumpconfig.8: lvmconfig.8
+$(MAN8SO): lvmconfig.8
 	echo ".so $<" > $@
 
 install_man5: $(MAN5)


