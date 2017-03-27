From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Mon, 27 Mar 2017 18:27:28 -0400
Subject: master - man: enhance man postprocessing regexp
Message-ID: <201703272227.v2RMRS1A032086@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7f312618447b0dc34901e77c45f468a738808d9b
Commit:        7f312618447b0dc34901e77c45f468a738808d9b
Parent:        88e408b8eddc77854be5785c86726b67f814f080
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Mar 28 00:17:43 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Mar 28 00:17:43 2017 +0200

man: enhance man postprocessing regexp

---
 man/Makefile.in |   21 ++++++++++++++++++++-
 1 files changed, 20 insertions(+), 1 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 4fcce7d..e0f0eee 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -173,8 +173,27 @@ define SUBSTVARS
 echo "Generating $@" ; $(SED) -e "s+#VERSION#+$(LVM_VERSION)+;s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+;s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+;s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+;s+#DEFAULT_PROFILE_DIR#+$(DEFAULT_PROFILE_DIR)+;s+#DEFAULT_CACHE_DIR#+$(DEFAULT_CACHE_DIR)+;s+#DEFAULT_LOCK_DIR#+$(DEFAULT_LOCK_DIR)+;s+#CLVMD_PATH#+/data/lvmtest/usr/sbin/clvmd+;s+#LVM_PATH#+/data/lvmtest/sbin/lvm+;s+#DEFAULT_RUN_DIR#+/var/run/lvm+;s+#DEFAULT_PID_DIR#+/var/run+;s+#SYSTEMD_GENERATOR_DIR#+$(SYSTEMD_GENERATOR_DIR)+;s+#DEFAULT_MANGLING#+$(DEFAULT_MANGLING)+;" $< > $@
 endef
 
+# Escape any '-':
+#
+# - multiple (>= 2)
+# - in ' -'
+# - in (cache|thin)-*
+# - in numerical ranges
+# - in single one in '\\f.-'
 define ESCAPEHYPHENS
-	sed -i "s+\([^\\]\)--+\1\\\-\\\-+g;s+\([^\\]\)-+\1\\\-+g" $@
+sed -i 	-e "s+\([^\\]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
+	-e "s+\([^\\]\)-\{6\}+\1\\\-\\\-\\\-\\\-\\\-\\\-+g" \
+	-e "s+\([^\\]\)-\{5\}+\1\\\-\\\-\\\-\\\-\\\-+g" \
+	-e "s+\([^\\]\)-\{4\}+\1\\\-\\\-\\\-\\\-+g" \
+	-e "s+\([^\\]\)-\{3\}+\1\\\-\\\-\\\-+g" \
+	-e "s+\([^\\]\)-\{2\}+\1\\\-\\\-+g" \
+	-e "s+^-\{2\}+\\\-\\\-+g" \
+	-e "s+ -+ \\\-+g" \
+	-e "s+\(cache\)-\([[:alpha:]]\{1,\}\)+\1\\\-\2+g" \
+	-e "s+\(thin\)-\([[:alpha:]]\{1,\}\)+\1\\\-\2+g" \
+	-e "s+\([0-9]\)-\([0-9]\)+\1\\\-\2+g" \
+	-e "s+\(\\\f.\)-\([^-]\)+\1\\\-\2+g" \
+	-e "s+\([[:digit:]]\{4\}\)\\\-\([[:digit:]]\{2\}\)\\\-\([[:digit:]]\{2\}\)+\1-\2-\3+g" $@
 endef
 
 %.5: $(srcdir)/%.5_main


