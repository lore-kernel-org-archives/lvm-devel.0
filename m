From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri,  6 Sep 2013 14:50:52 +0000 (UTC)
Subject: master - test: Add the 64b fc17 kernel to the mirror recovery blacklist.
Message-ID: <20130906145052.9C34760188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fe6b19a6a3deb707243a5728842fff17e52258e0
Commit:        fe6b19a6a3deb707243a5728842fff17e52258e0
Parent:        10a5838a600bbadfe9e20f686f86ffcd9d0c473e
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Fri Sep 6 16:35:49 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Fri Sep 6 16:50:05 2013 +0200

test: Add the 64b fc17 kernel to the mirror recovery blacklist.

---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 286fb96..5ff0b0c 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -606,6 +606,7 @@ api() {
 
 skip_if_mirror_recovery_broken() {
         if test `uname -r` = 3.3.4-5.fc17.i686; then skip; fi
+        if test `uname -r` = 3.3.4-5.fc17.x86_64; then skip; fi
 }
 
 udev_wait() {


