From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 20 Sep 2017 09:35:24 -0400
Subject: master - tests: use portable df output
Message-ID: <201709201335.v8KDZOE9013371@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d9f9ce126856245541a66492f35422ab060a837e
Commit:        d9f9ce126856245541a66492f35422ab060a837e
Parent:        a15b7961468682496f9b51d9a07223e3dd6eba3f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Sep 20 15:34:02 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 20 15:34:02 2017 +0200

tests: use portable df output

For awk parsing more 'predictable' format of output line is needed.
---
 test/lib/inittest.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 7b0bc13..a33748d 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -125,7 +125,7 @@ fi
 echo "$TESTNAME" >TESTNAME
 
 # Require 50M of free space in testdir
-test $(df -k . | awk '/\// {print $4}') -gt 51200  ||
+test $(df -k -P . | awk '/\// {print $4}') -gt 51200  ||
 	die "Testing requires more then 50M of free space in directory $TESTDIR!\n$(df -H)"
 
 echo "Kernel is $(uname -a)"


