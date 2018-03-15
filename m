From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 15 Mar 2018 06:04:52 -0400
Subject: master - tests: use DM_DEBUG_WITH_LINE_NUMBERS
Message-ID: <201803151004.w2FA4qb1023738@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bed869a8a0e66bc4a760b6f56b0d199fc226a179
Commit:        bed869a8a0e66bc4a760b6f56b0d199fc226a179
Parent:        750fc2e876f49d48e8f883e4e342338b8c4676cd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 15 10:41:08 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 15 11:01:04 2018 +0100

tests: use DM_DEBUG_WITH_LINE_NUMBERS

Use src:line also for debugging of tools like dmsetup.
---
 test/lib/inittest.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 78bd987..8e4e064 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -106,6 +106,7 @@ DM_DEV_DIR="$TESTDIR/dev"
 LVM_SYSTEM_DIR="$TESTDIR/etc"
 # abort on the internal dm errors in the tests (allowing test user override)
 DM_ABORT_ON_INTERNAL_ERRORS=${DM_ABORT_ON_INTERNAL_ERRORS:-1}
+DM_DEBUG_WITH_LINE_NUMBERS=${DM_DEBUG_WITH_LINE_NUMBERS:-1}
 
 export DM_DEFAULT_NAME_MANGLING_MODE DM_DEV_DIR LVM_SYSTEM_DIR DM_ABORT_ON_INTERNAL_ERRORS
 


