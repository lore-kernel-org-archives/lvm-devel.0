From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:59 +0000 (UTC)
Subject: master - tests: use aux func to disable device
Message-ID: <20141030230059.B9E5F60AA2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b58a0f5cd31669e789d6944ced5b42ce7c6f4f74
Commit:        b58a0f5cd31669e789d6944ced5b42ce7c6f4f74
Parent:        da61e6355e35ba7961b2073812c6a5639d9d541d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Oct 26 20:41:49 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:49 2014 +0100

tests: use aux func to disable device

---
 test/shell/lvcreate-missing.sh |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/test/shell/lvcreate-missing.sh b/test/shell/lvcreate-missing.sh
index 2b74052..4553e98 100644
--- a/test/shell/lvcreate-missing.sh
+++ b/test/shell/lvcreate-missing.sh
@@ -12,10 +12,11 @@
 . lib/inittest
 
 aux prepare_vg 2
-init_udev_transaction
-dmsetup remove -f "$dev1" || true
-finish_udev_transaction
+
+aux disable_dev "$dev1"
 
 not lvcreate -n "foo" $vg -l 1
 
+aux enable_dev "$dev1"
+
 vgremove -ff $vg


