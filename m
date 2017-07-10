From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 10 Jul 2017 08:34:01 -0400
Subject: master - tests: drop extra sourcing of utils
Message-ID: <201707101234.v6ACY1s4022879@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=494d819a6f5e5dbc978cf095cb2ff41b15d4f57a
Commit:        494d819a6f5e5dbc978cf095cb2ff41b15d4f57a
Parent:        ff2242036b9719c51a7f000dcb91f3ad5aa2580a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 9 11:20:47 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 10 14:23:53 2017 +0200

tests: drop extra sourcing of utils

This sourceing is automatic by . lib/inittest
---
 test/shell/aa-lvmlockd-dlm-prepare.sh     |    1 -
 test/shell/aa-lvmlockd-sanlock-prepare.sh |    1 -
 2 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/test/shell/aa-lvmlockd-dlm-prepare.sh b/test/shell/aa-lvmlockd-dlm-prepare.sh
index 7e3700f..24021f3 100644
--- a/test/shell/aa-lvmlockd-dlm-prepare.sh
+++ b/test/shell/aa-lvmlockd-dlm-prepare.sh
@@ -12,7 +12,6 @@
 
 test_description='Set up things to run tests with dlm'
 
-. lib/utils
 . lib/inittest
 
 [ -z "$LVM_TEST_LOCK_TYPE_DLM" ] && skip;
diff --git a/test/shell/aa-lvmlockd-sanlock-prepare.sh b/test/shell/aa-lvmlockd-sanlock-prepare.sh
index b897bbd..6060927 100644
--- a/test/shell/aa-lvmlockd-sanlock-prepare.sh
+++ b/test/shell/aa-lvmlockd-sanlock-prepare.sh
@@ -12,7 +12,6 @@
 
 test_description='Set up things to run tests with sanlock'
 
-. lib/utils
 . lib/inittest
 
 [ -z "$LVM_TEST_LOCK_TYPE_SANLOCK" ] && skip;


