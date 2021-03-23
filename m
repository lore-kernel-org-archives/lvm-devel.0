From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 23 Mar 2021 10:37:17 +0000 (GMT)
Subject: main - tests: set default basic flavour
Message-ID: <20210323103717.746883854805@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a5fc6a0fe7f7384db9a88a399d288d16d782f516
Commit:        a5fc6a0fe7f7384db9a88a399d288d16d782f516
Parent:        0b2a037c800c3b8d20ea4d233cd2642611a2d136
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 23 11:33:30 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 23 11:33:30 2021 +0100

tests: set default basic flavour

---
 test/lib/inittest.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 0014a8cfd..0fd651710 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -25,7 +25,7 @@ TESTNAME=${0##*/}
 PS4='#${BASH_SOURCE[0]##*/}:${LINENO}+ '
 export TESTNAME PS4
 
-LVM_TEST_FLAVOUR=${LVM_TEST_FLAVOUR-}
+LVM_TEST_FLAVOUR=${LVM_TEST_FLAVOUR-ndev-vanilla}
 
 LVM_TEST_BACKING_DEVICE=${LVM_TEST_BACKING_DEVICE-}
 LVM_TEST_DEVDIR=${LVM_TEST_DEVDIR-}


