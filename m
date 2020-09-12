From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sat, 12 Sep 2020 11:24:53 +0000 (GMT)
Subject: master - tests: avoid using string
Message-ID: <20200912112453.9110B38708A2@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe77d1a71043ca449dbe3a2a635ba0096e4ef9b9
Commit:        fe77d1a71043ca449dbe3a2a635ba0096e4ef9b9
Parent:        3008e1be08c92fc9ee409397c174805d4193e63b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 12 12:25:58 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 12 13:24:03 2020 +0200

tests: avoid using string

String 'TEST WARNING' may not be present in the test script itself.
Add '\ ' to avoid 'grep' matching test as the test with warning.
---
 test/shell/integrity-blocksize-2.sh | 2 +-
 test/shell/integrity-blocksize-3.sh | 2 +-
 test/shell/integrity-dmeventd.sh    | 2 +-
 test/shell/integrity-large.sh       | 2 +-
 test/shell/integrity-misc.sh        | 2 +-
 test/shell/integrity.sh             | 2 +-
 6 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/test/shell/integrity-blocksize-2.sh b/test/shell/integrity-blocksize-2.sh
index 5e0fd9ad1..3f6eb9242 100644
--- a/test/shell/integrity-blocksize-2.sh
+++ b/test/shell/integrity-blocksize-2.sh
@@ -42,7 +42,7 @@ _wait_recalc() {
         # enabled never gets in sync. I saw this in BB, but not when executing
         # the commands manually
         if test -z "$sync"; then
-                echo "TEST WARNING: Resync of dm-integrity device '$checklv' failed"
+                echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
                 dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
                 exit
         fi
diff --git a/test/shell/integrity-blocksize-3.sh b/test/shell/integrity-blocksize-3.sh
index 4aea97253..7034bc362 100644
--- a/test/shell/integrity-blocksize-3.sh
+++ b/test/shell/integrity-blocksize-3.sh
@@ -42,7 +42,7 @@ _wait_recalc() {
         # enabled never gets in sync. I saw this in BB, but not when executing
         # the commands manually
         if test -z "$sync"; then
-                echo "TEST WARNING: Resync of dm-integrity device '$checklv' failed"
+                echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
                 dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
                 exit
         fi
diff --git a/test/shell/integrity-dmeventd.sh b/test/shell/integrity-dmeventd.sh
index 296f55680..0a081599f 100644
--- a/test/shell/integrity-dmeventd.sh
+++ b/test/shell/integrity-dmeventd.sh
@@ -113,7 +113,7 @@ _wait_recalc() {
 	# enabled never gets in sync. I saw this in BB, but not when executing
 	# the commands manually
 	if test -z "$sync"; then
-		echo "TEST WARNING: Resync of dm-integrity device '$checklv' failed"
+		echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
                 dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
 		exit
 	fi
diff --git a/test/shell/integrity-large.sh b/test/shell/integrity-large.sh
index 06b0e03db..7d252590e 100644
--- a/test/shell/integrity-large.sh
+++ b/test/shell/integrity-large.sh
@@ -99,7 +99,7 @@ _wait_recalc() {
 	# enabled never gets in sync. I saw this in BB, but not when executing
 	# the commands manually
 	if test -z "$sync"; then
-		echo "TEST WARNING: Resync of dm-integrity device '$checklv' failed"
+		echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
                 dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
 		exit
 	fi
diff --git a/test/shell/integrity-misc.sh b/test/shell/integrity-misc.sh
index c8ec3bf49..e025c93d2 100644
--- a/test/shell/integrity-misc.sh
+++ b/test/shell/integrity-misc.sh
@@ -113,7 +113,7 @@ _wait_sync() {
 	# enabled never gets in sync. I saw this in BB, but not when executing
 	# the commands manually
 	if test -z "$sync"; then
-		echo "TEST WARNING: Resync of dm-integrity device '$checklv' failed"
+		echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
                 dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
 		exit
 	fi
diff --git a/test/shell/integrity.sh b/test/shell/integrity.sh
index f8740bc4f..95c8557cc 100644
--- a/test/shell/integrity.sh
+++ b/test/shell/integrity.sh
@@ -212,7 +212,7 @@ _wait_recalc() {
 	# enabled never gets in sync. I saw this in BB, but not when executing
 	# the commands manually
 	if test -z "$sync"; then
-		echo "TEST WARNING: Resync of dm-integrity device '$checklv' failed"
+		echo "TEST\ WARNING: Resync of dm-integrity device '$checklv' failed"
                 dmsetup status "$DM_DEV_DIR/mapper/${checklv/\//-}"
 		exit
 	fi


