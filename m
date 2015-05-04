From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  4 May 2015 08:21:26 +0000 (UTC)
Subject: master - tests: validate passed LVM_TEST_DEVDIR
Message-ID: <20150504082126.C593760F2F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3f05e662bbb0a02315e3ef806543fd3e092f40f0
Commit:        3f05e662bbb0a02315e3ef806543fd3e092f40f0
Parent:        b09ac72624031a7d6d0b6416a067aa60584e0d6c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon May 4 10:15:56 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon May 4 10:15:56 2015 +0200

tests: validate passed LVM_TEST_DEVDIR

Quit test early if passed LVM_TEST_DEVDIR dir does not exists.
---
 test/lib/inittest.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/inittest.sh b/test/lib/inittest.sh
index b577389..cd6471c 100644
--- a/test/lib/inittest.sh
+++ b/test/lib/inittest.sh
@@ -60,6 +60,7 @@ DM_DEV_DIR="$TESTDIR/dev"
 LVM_SYSTEM_DIR="$TESTDIR/etc"
 mkdir "$LVM_SYSTEM_DIR" "$DM_DEV_DIR"
 if test -n "$LVM_TEST_DEVDIR" ; then
+	test -d "$LVM_TEST_DEVDIR" || die "Test device directory LVM_TEST_DEVDIR=\"$LVM_TEST_DEVDIR\" is not valid."
 	DM_DEV_DIR=$LVM_TEST_DEVDIR
 else
 	mknod "$DM_DEV_DIR/testnull" c 1 3 || die "mknod failed"


