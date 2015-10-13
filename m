From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 13 Oct 2015 14:04:39 +0000 (UTC)
Subject: master - tests: better regex check
Message-ID: <20151013140439.1B2AD6017F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8cc21354c2b4cb58223950b7e089eb28e602f0e8
Commit:        8cc21354c2b4cb58223950b7e089eb28e602f0e8
Parent:        2cb1f6eafeb72dcd49a7ed941d9c5400540284fa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 9 21:30:37 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 13 16:02:20 2015 +0200

tests: better regex check

Enhance check for matching prefix.
---
 test/lib/inittest.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index 4ed8d20..28bc4e8 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -30,7 +30,7 @@ COMMON_PREFIX="LVMTEST"
 PREFIX="${COMMON_PREFIX}$$"
 
 # Check we are not conflickting with some exiting setup
-dmsetup table | not grep "$PREFIX" || die "DM table already has devices with prefix $PREFIX!"
+dmsetup table | not grep "${PREFIX}[^0-9]" || die "DM table already has devices with prefix $PREFIX!"
 
 if test -z "$LVM_TEST_DIR"; then LVM_TEST_DIR=$TMPDIR; fi
 TESTDIR=$(mkdtemp "${LVM_TEST_DIR:-/tmp}" "$PREFIX.XXXXXXXXXX") || \


