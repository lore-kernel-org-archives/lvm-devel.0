From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  3 Sep 2013 18:06:35 +0000 (UTC)
Subject: master - test: Fix a spurious failure in skip_if_mirror_recovery_broken.
Message-ID: <20130903180635.8B52361053@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7918217c754555fc685851e7d80f86a8f6c8abcb
Commit:        7918217c754555fc685851e7d80f86a8f6c8abcb
Parent:        848e8026d68e53dae078ed99fb5f3a47db3def2a
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Tue Sep 3 20:05:22 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Tue Sep 3 20:06:24 2013 +0200

test: Fix a spurious failure in skip_if_mirror_recovery_broken.

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index bca709a..286fb96 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -605,7 +605,7 @@ api() {
 }
 
 skip_if_mirror_recovery_broken() {
-        test `uname -r` = 3.3.4-5.fc17.i686 && skip
+        if test `uname -r` = 3.3.4-5.fc17.i686; then skip; fi
 }
 
 udev_wait() {


