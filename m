From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 28 Mar 2017 20:27:30 -0400
Subject: master - man: ranges/LV names/symbolic use regexp
Message-ID: <201703290027.v2T0RUnU021757@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5012be326dbadad811620b1584e46144b3c47722
Commit:        5012be326dbadad811620b1584e46144b3c47722
Parent:        4af09a94bd44693e5a40a4f895599601d8233d69
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Mar 29 02:27:10 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Mar 29 02:27:10 2017 +0200

man: ranges/LV names/symbolic use regexp

---
 man/Makefile.in |   15 +++++++++++----
 1 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index e357d86..2421116 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -192,7 +192,10 @@ endef
 # - multiple (>= 2)
 # - in ' -'
 # - in (cache|thin)-*
-# - in numerical ranges
+# - in ranges
+# - in "$vg-$lv"
+# - in middle of options (e.g. '--use-policies')
+# - in symbolic use (e.g. '->')
 # - in single one in '\\f.-'
 define ESCAPEHYPHENS
 $(SED) -i -e "s+\([^\\]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
@@ -202,12 +205,16 @@ $(SED) -i -e "s+\([^\\]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
 	  -e "s+\([^\\]\)-\{3\}+\1\\\-\\\-\\\-+g" \
 	  -e "s+\([^\\]\)-\{2\}+\1\\\-\\\-+g" \
 	  -e "s+^-\{2\}+\\\-\\\-+g" \
-	  -e "s+ -+ \\\-+g" \
+	  -e "s+ -\([[:alnum:]]\)+ \\\-\1+g" \
 	  -e "s+\(cache\)-\([[:alpha:]]\{1,\}\)+\1\\\-\2+g" \
 	  -e "s+\(thin\)-\([[:alpha:]]\{1,\}\)+\1\\\-\2+g" \
-	  -e "s+\([0-9]\)-\([0-9]\)+\1\\\-\2+g" \
+	  -e "s+\([ :\[][[:alnum:]]\{1,\}\)-\([[:alnum:]]\{1,\}[[ ]\)+\1\\\-\2+g" \
+	  -e "s+\([[:alnum:]]\{2,\}\)-\([[:alnum:]]\{2,\}\)-\([[:alnum:]]\{2,\}\)+\1\\\-\2\\\-\3+g" \
+	  -e "s+\([[:alnum:]]\{2,\}\)-\([[:alnum:]]\{2,\}\)+\1\\\-\2+g" \
+	  -e "s+\(<\)-+\1\\\-+g" \
+	  -e "s+[^\\]-\(>\)+\\\-\1+g" \
 	  -e "s+\(\\\f.\)-\([^-]\)+\1\\\-\2+g" \
-	  -e "s+\([[:digit:]]\{4\}\)\\\-\([[:digit:]]\{2\}\)\\\-\([[:digit:]]\{2\}\)+\1-\2-\3+g" $@
+	  -e "s+\([[:digit:]]\{4\}\).*-\([[:digit:]]\{2\}\).*-\([[:digit:]]\{2\}\)+\1-\2-\3+g" $@
 endef
 
 %.5: $(srcdir)/%.5_main


