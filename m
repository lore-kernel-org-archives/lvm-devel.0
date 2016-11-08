From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Nov 2016 15:01:58 +0000 (UTC)
Subject: master - tests: for repair we need neewer version
Message-ID: <20161108150158.A547C60DCC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c1862ea84cdcbb72f4c30a81a7643f39f851e96d
Commit:        c1862ea84cdcbb72f4c30a81a7643f39f851e96d
Parent:        2ec3e7dca8822770b3eb832488b9897b7d372e01
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 8 11:15:25 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 8 16:01:35 2016 +0100

tests: for repair we need neewer version

Older cache targets were not able to report write failures.
---
 test/shell/lvconvert-repair-cache.sh |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index f907289..565ebf4 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -25,7 +25,8 @@ which "$FSCK" || skip
 #
 # Main
 #
-aux have_cache 1 5 0 || skip
+# older versions of cache target reported unreliably write failures
+aux have_cache 1 7 0 || skip
 
 aux prepare_vg 4
 


