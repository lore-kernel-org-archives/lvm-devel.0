From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Jul 2016 15:40:01 +0000 (UTC)
Subject: master - tests: enforce flush of cache target
Message-ID: <20160719154001.815D7602C7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d19c1075f0265aed7a1d1dab216e65cae6d460a
Commit:        9d19c1075f0265aed7a1d1dab216e65cae6d460a
Parent:        6dc4d035088c74693e3920961ec7814e4ecf0793
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 19 17:21:56 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 19 17:39:46 2016 +0200

tests: enforce flush of cache target

Since now  lvm command no longer is flushing cache target with status
query - enforce it with extra status.
---
 test/shell/lvconvert-repair-cache.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index 756fd12..568d66b 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -101,6 +101,9 @@ sync
 # Seriously damage cache metadata
 aux error_dev "$dev1" 2054:2
 
+# flushing status
+dmsetup status $vg-$lv1
+
 # On fixed kernel we get instant Fail here
 get lv_field  $vg/$lv1 lv_attr | tee out
 grep "Cwi-a-C-F-" out || {


