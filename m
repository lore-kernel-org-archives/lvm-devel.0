From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 11 Jul 2017 19:22:48 -0400
Subject: master - tests: more vars bounded
Message-ID: <201707112322.v6BNMmSG010819@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8387f4efc96d4a32446006dcc7f3d1aa039c8bfe
Commit:        8387f4efc96d4a32446006dcc7f3d1aa039c8bfe
Parent:        2baac408fc8421b0f65d1cc9ec18470f330c36a1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 12 01:15:41 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 12 01:21:44 2017 +0200

tests: more vars bounded

---
 test/lib/inittest.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index e32b044..c0f3e6b 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -25,7 +25,11 @@ TESTNAME=${0##*/}
 PS4='#${BASH_SOURCE[0]##*/}:${LINENO}+ '
 export TESTNAME PS4
 
+LVM_TEST_DEVDIR=${LVM_TEST_DEVDIR-}
 LVM_TEST_NODEBUG=${LVM_TEST_NODEBUG-}
+LVM_TEST_LVM1=${LVM_TEST_LVM1-}
+# TODO: LVM_TEST_SHARED
+SHARED=${SHARED-}
 
 LVM_TEST_LVMETAD=${LVM_TEST_LVMETAD-}
 LVM_TEST_LVMLOCKD=${LVM_TEST_LVMLOCKD-}


