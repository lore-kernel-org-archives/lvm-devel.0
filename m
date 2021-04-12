From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 12 Apr 2021 07:55:41 +0000 (GMT)
Subject: main - makefiles: no need for double Q
Message-ID: <20210412075541.D8FE839FCC7A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f5efe1beb53dde57bd83c4b50e001b3feceaa983
Commit:        f5efe1beb53dde57bd83c4b50e001b3feceaa983
Parent:        2e84dd47d44a3a65a984e3af724684d4982785a3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Apr 11 22:29:04 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 12 09:54:16 2021 +0200

makefiles: no need for double Q

We already use $(Q) while calling macros
---
 man/Makefile.in | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/man/Makefile.in b/man/Makefile.in
index 786671e3a..01097c886 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -133,7 +133,7 @@ SEE_ALSO=$(srcdir)/see_also.end
 	) > $@
 
 define SUBSTVARS
-$(Q)$(SED) -e "s+#VERSION#+$(LVM_VERSION)+" \
+$(SED) -e "s+#VERSION#+$(LVM_VERSION)+" \
 	-e "s+#DEFAULT_SYS_DIR#+$(DEFAULT_SYS_DIR)+" \
 	-e "s+#DEFAULT_ARCHIVE_DIR#+$(DEFAULT_ARCHIVE_DIR)+" \
 	-e "s+#DEFAULT_BACKUP_DIR#+$(DEFAULT_BACKUP_DIR)+" \
@@ -157,7 +157,7 @@ endef
 # - in "$vg-$lv"
 # - in single one in '\\f.-'
 define ESCAPEHYPHENS
-$(Q)$(SED) -i -e "s+\([ [:alpha:]]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
+$(SED) -i -e "s+\([ [:alpha:]]\)-\{7\}+\1\\\-\\\-\\\-\\\-\\\-\\\-\\\-+g" \
 	  -e "s+\([ [:alpha:]]\)-\{6\}+\1\\\-\\\-\\\-\\\-\\\-\\\-+g" \
 	  -e "s+\([ [:alpha:]]\)-\{5\}+\1\\\-\\\-\\\-\\\-\\\-+g" \
 	  -e "s+\([ [:alpha:]]\)-\{4\}+\1\\\-\\\-\\\-\\\-+g" \


