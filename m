From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Tue, 28 Mar 2017 11:50:50 -0400
Subject: master - man: regexp readability / use
Message-ID: <201703281550.v2SFooNj024293@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0bc1af3fd1d53b378840f50e42824c811d06ad10
Commit:        0bc1af3fd1d53b378840f50e42824c811d06ad10
Parent:        0c2f7ed49a611c31ad8d304b6f5cb9cd851c5e3c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Mar 28 17:50:22 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Mar 28 17:50:22 2017 +0200

man: regexp readability / use

---
 man/Makefile.in |   41 +++++++++++++++++++++++++++--------------
 1 files changed, 27 insertions(+), 14 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index e0f0eee..6b7e35c 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -170,7 +170,20 @@ SEE_ALSO=$(srcdir)/see_also.end
 	) > $@
 
 define SUBSTVARS
-echo "Generating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+/data/lvmtest/usr/sbin/clvmd+;s+#LVM_PATH#+/data/lvmtest/sbin/lvm+;s+#DEFAULT_RUN_DIR#+/var/run/lvm+;s+#DEFAULT_PID_DIR#+/var/run+;s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+;s+#DEFAULT_MANGLING#+$(DEFAULT_MANGLING)+;" $< > $@
+echo "Generating $@"
+$(SED)	-e "s+#VERSION#+$(LVM_VERSION)+" \
+	-e "s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+" \
+	-e "s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+" \
+	-e "s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+" \
+	-e "s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+" \
+	-e "s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+" \
+	-e "s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+" \
+	-e "s+#CLVMD_PATH#+/data/lvmtest/usr/sbin/clvmd+" \
+	-e "s+#LVM_PATH#+/data/lvmtest/sbin/lvm+" \
+	-e "s+#DEFAULT_RUN_DIR#+/var/run/lvm+" \
+	-e "s+#DEFAULT_PID_DIR#+/var/run+" \
+	-e "s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+" \
+	-e "s+#DEFAULT_MANGLING#+$(DEFAULT_MANGLING)+" $< > $@
 endef
 
 # Escape any '-':
@@ -181,19 +194,19 @@ endef
 # - in numerical ranges
 # - in single one in '\\f.-'
 define ESCAPEHYPHENS
-sed -i 	-e "s+\([^\\]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
-	-e "s+\([^\\]\)-\{6\}+\1\\\-\\\-\\\-\\\-\\\-\\\-+g" \
-	-e "s+\([^\\]\)-\{5\}+\1\\\-\\\-\\\-\\\-\\\-+g" \
-	-e "s+\([^\\]\)-\{4\}+\1\\\-\\\-\\\-\\\-+g" \
-	-e "s+\([^\\]\)-\{3\}+\1\\\-\\\-\\\-+g" \
-	-e "s+\([^\\]\)-\{2\}+\1\\\-\\\-+g" \
-	-e "s+^-\{2\}+\\\-\\\-+g" \
-	-e "s+ -+ \\\-+g" \
-	-e "s+\(cache\)-\([[:alpha:]]\{1,\}\)+\1\\\-\2+g" \
-	-e "s+\(thin\)-\([[:alpha:]]\{1,\}\)+\1\\\-\2+g" \
-	-e "s+\([0-9]\)-\([0-9]\)+\1\\\-\2+g" \
-	-e "s+\(\\\f.\)-\([^-]\)+\1\\\-\2+g" \
-	-e "s+\([[:digit:]]\{4\}\)\\\-\([[:digit:]]\{2\}\)\\\-\([[:digit:]]\{2\}\)+\1-\2-\3+g" $@
+$(SED) -i -e "s+\([^\\]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
+	  -e "s+\([^\\]\)-\{6\}+\1\\\-\\\-\\\-\\\-\\\-\\\-+g" \
+	  -e "s+\([^\\]\)-\{5\}+\1\\\-\\\-\\\-\\\-\\\-+g" \
+	  -e "s+\([^\\]\)-\{4\}+\1\\\-\\\-\\\-\\\-+g" \
+	  -e "s+\([^\\]\)-\{3\}+\1\\\-\\\-\\\-+g" \
+	  -e "s+\([^\\]\)-\{2\}+\1\\\-\\\-+g" \
+	  -e "s+^-\{2\}+\\\-\\\-+g" \
+	  -e "s+ -+ \\\-+g" \
+	  -e "s+\(cache\)-\([[:alpha:]]\{1,\}\)+\1\\\-\2+g" \
+	  -e "s+\(thin\)-\([[:alpha:]]\{1,\}\)+\1\\\-\2+g" \
+	  -e "s+\([0-9]\)-\([0-9]\)+\1\\\-\2+g" \
+	  -e "s+\(\\\f.\)-\([^-]\)+\1\\\-\2+g" \
+	  -e "s+\([[:digit:]]\{4\}\)\\\-\([[:digit:]]\{2\}\)\\\-\([[:digit:]]\{2\}\)+\1-\2-\3+g" $@
 endef
 
 %.5: $(srcdir)/%.5_main


