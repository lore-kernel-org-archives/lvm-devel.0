From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:33:57 -0400
Subject: master - tests: assign as string
Message-ID: <201707101233.v6ACXvTO022869@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f161c6ee9fad4d2ddefb97d4837d29360e5bc280
Commit:        f161c6ee9fad4d2ddefb97d4837d29360e5bc280
Parent:        2e47ab9b8c4526d1663da4aa3122b013237aaf9f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jul 7 12:12:24 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: assign as string

Assigning an array to a string! Assign as array, or use * instead of @ to concatenate.
---
 test/shell/vgsplit-operation.sh |    2 +-
 test/shell/vgsplit-raid.sh      |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/vgsplit-operation.sh b/test/shell/vgsplit-operation.sh
index 5dff173..2ec140b 100644
--- a/test/shell/vgsplit-operation.sh
+++ b/test/shell/vgsplit-operation.sh
@@ -21,7 +21,7 @@ export LVM_TEST_LVMETAD_DEBUG_OPTS=${LVM_TEST_LVMETAD_DEBUG_OPTS-}
 . lib/inittest
 
 COMM() {
-	LAST_TEST="$@"
+	LAST_TEST="$*"
 }
 
 create_vg_() {
diff --git a/test/shell/vgsplit-raid.sh b/test/shell/vgsplit-raid.sh
index dc2ef5a..08e2a8e 100644
--- a/test/shell/vgsplit-raid.sh
+++ b/test/shell/vgsplit-raid.sh
@@ -17,7 +17,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 COMM() {
-	LAST_TEST="$@"
+	LAST_TEST="$*"
 }
 
 create_vg_() {


