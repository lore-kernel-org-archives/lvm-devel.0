From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  1 Oct 2015 14:47:44 +0000 (UTC)
Subject: master - tests: use proper target name for check
Message-ID: <20151001144744.E792C6112C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=05e7fdd5ce3eb5db827aa8b8ab9e07571d9a857a
Commit:        05e7fdd5ce3eb5db827aa8b8ab9e07571d9a857a
Parent:        796e3fb7e4dc9d996316b0fcc4ed09a2cc800ade
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 1 16:05:51 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 1 16:05:51 2015 +0200

tests: use proper target name for check

---
 test/shell/snapshot-merge.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index ff4f8d1..f2ad2cb 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -12,7 +12,7 @@
 . lib/inittest
 
 # test if snapshot-merge target is available
-aux target_at_least snapshot-merge 1 0 0 || skip
+aux target_at_least dm-snapshot-merge 1 0 0 || skip
 
 which mkfs.ext3 || skip
 


