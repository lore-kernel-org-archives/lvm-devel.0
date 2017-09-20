From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Sep 2017 09:14:59 -0400
Subject: master - tests: check for free space in test dir
Message-ID: <201709201314.v8KDExPs009489@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2fd2b197ab5962bc0a1e7eb25bba120d7501032f
Commit:        2fd2b197ab5962bc0a1e7eb25bba120d7501032f
Parent:        a02db1c45ab571d0c614d269a713b56cd47c2e1e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 11 14:33:07 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 20 15:14:16 2017 +0200

tests: check for free space in test dir

Avoid starting test, when test dir has less then 50M of free space.
Better to crash early before letting die machine on weird crash
in OOM cases...

Also show free disk space when test starts
---
 test/lib/inittest.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index d5ca6fd..7b0bc13 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -124,11 +124,17 @@ fi
 
 echo "$TESTNAME" >TESTNAME
 
+# Require 50M of free space in testdir
+test $(df -k . | awk '/\// {print $4}') -gt 51200  ||
+	die "Testing requires more then 50M of free space in directory $TESTDIR!\n$(df -H)"
+
 echo "Kernel is $(uname -a)"
 # Report SELinux mode
 echo "Selinux mode is $(getenforce 2>/dev/null || echo not installed)."
 free -m || true
 
+df -h || true
+
 # Set vars from utils now that we have TESTDIR/PREFIX/...
 prepare_test_vars
 


