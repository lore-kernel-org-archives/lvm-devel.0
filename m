From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:48:51 +0000 (GMT)
Subject: dev-next - tests: test needs to have playable locking dir
Message-ID: <20210331214851.86BE23857C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=acac3cb52457b536cf8e984ce947a0ac2e837a5d
Commit:        acac3cb52457b536cf8e984ce947a0ac2e837a5d
Parent:        b19e036918cf1c2ac2995e07809a28c06bd1f34a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 23 09:48:47 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 23 09:48:47 2021 +0100

tests: test needs to have playable locking dir

---
 test/shell/vgchange-sysinit.sh | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/shell/vgchange-sysinit.sh b/test/shell/vgchange-sysinit.sh
index cea72f4d0..5740addf5 100644
--- a/test/shell/vgchange-sysinit.sh
+++ b/test/shell/vgchange-sysinit.sh
@@ -22,6 +22,8 @@ aux prepare_pvs 2 8
 var_lock="$DM_DEV_DIR/$vg1/$lv1"
 # keep in sync with aux configured lockingdir
 mount_dir="var/lock/lvm"
+mkdir -p $mount_dir
+aux lvmconf "global/locking_dir = \"$TESTDIR/$mount_dir\""
 
 cleanup_mounted_and_teardown()
 {


