From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 12 Jul 2016 11:23:27 +0000 (UTC)
Subject: master - tests: cache error message changes too often
Message-ID: <20160712112327.0816660C94@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1891fa827215a10085bda9c9b660791de997d198
Commit:        1891fa827215a10085bda9c9b660791de997d198
Parent:        80394ae7cd9ae3a9b7523216840a3b4bfca5cd70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jul 11 21:58:14 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jul 12 13:20:56 2016 +0200

tests: cache error message changes too often

Until lvconvert stabilize, avoid testing resulting error message.
---
 test/shell/lvconvert-cache.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 58274de..3bffb32 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -144,7 +144,7 @@ lvcreate -H -L 4 -n corigin --cachepool $vg/cpool
 
 # unsupported yet
 fail lvconvert --repair $vg/cpool 2>&1 | tee out
-grep "Cannot convert internal LV" out
+#grep "Cannot convert internal LV" out
 
 lvremove -f $vg
 


