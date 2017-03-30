From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 30 Mar 2017 11:55:04 -0400
Subject: master - man: add minor regexp
Message-ID: <201703301555.v2UFt4wb009301@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=99dc49c7dda2244000eaa3b91b129923c8ed26e8
Commit:        99dc49c7dda2244000eaa3b91b129923c8ed26e8
Parent:        2b46fe5843401abff4004a1629152ed1de68fbd9
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Mar 30 17:54:02 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Mar 30 17:54:02 2017 +0200

man: add minor regexp

---
 man/Makefile.in |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index a391e90..defa9b3 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -191,11 +191,10 @@ endef
 #
 # - multiple (>= 2)
 # - in ' -'
-# - in (cache|thin)-*
 # - in ranges
-# - in "$vg-$lv"
-# - in middle of options (e.g. '--use-policies')
+# - in middle of options (e.g. '--use-policies') and their arguments
 # - in symbolic use (e.g. '->')
+# - in "$vg-$lv"
 # - in single one in '\\f.-'
 define ESCAPEHYPHENS
 $(SED) -i -e "s+\([ [:alpha:]]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
@@ -207,6 +206,7 @@ $(SED) -i -e "s+\([ [:alpha:]]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
 	  -e "s+\([^\]\)-\([[:alnum:]\?]\)+\1\\\-\2+g" \
 	  -e "s+ --+\\\-\\\-+g" \
 	  -e "s+|-|+|\\\-|+g" \
+	  -e "s+|-\\\-+\\\-\\\-+g" \
 	  -e "s+ -\"+ \\\-\"+g" \
 	  -e "s+'--'+'\\\-\\\-'+g" \
 	  -e "s+^--+\\\-\\\-+g" \


