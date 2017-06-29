From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:28:56 -0400
Subject: master - tests: inittest.sh double quote and mixing string
Message-ID: <201706292028.v5TKSuSv026883@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=32be18959d7899822d80c715fd271410f05462f1
Commit:        32be18959d7899822d80c715fd271410f05462f1
Parent:        b45ca523ecbba006d2982ae085140c69edbe084e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 10:38:06 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:17 2017 +0200

tests: inittest.sh  double quote and mixing string

---
 test/lib/inittest.sh |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index b75eddc..f959b71 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -1,5 +1,5 @@
 #!/usr/bin/env bash
-# Copyright (C) 2011-2015 Red Hat, Inc. All rights reserved.
+# Copyright (C) 2011-2017 Red Hat, Inc. All rights reserved.
 #
 # This copyrighted material is made available to anyone wishing to use,
 # modify, copy, or redistribute it subject to the terms and conditions
@@ -10,7 +10,7 @@
 # Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
 
 initskip() {
-	test "$#" -eq 0 || echo "TEST SKIPPED: $@"
+	test "$#" -eq 0 || echo "TEST SKIPPED: " "$@"
 	exit 200
 }
 
@@ -26,7 +26,7 @@ PS4='#${BASH_SOURCE[0]##*/}:${LINENO}+ '
 export TESTNAME PS4
 
 if test -n "$LVM_TEST_FLAVOUR"; then
-	. lib/flavour-$LVM_TEST_FLAVOUR
+	. "lib/flavour-$LVM_TEST_FLAVOUR"
 fi
 
 test -n "$SKIP_WITHOUT_CLVMD" && test "$LVM_TEST_LOCKING" -ne 3 && initskip


