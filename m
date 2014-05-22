From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 22 May 2014 10:02:29 +0000 (UTC)
Subject: master - tests: swap tests
Message-ID: <20140522100229.85C97611E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=65b0948c1e9baf65e7f1bffe0f01c355d094cf9c
Commit:        65b0948c1e9baf65e7f1bffe0f01c355d094cf9c
Parent:        1208e92b3476d4350b0734897ed9adb30697dcfd
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 22 12:00:46 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 22 12:01:44 2014 +0200

tests: swap tests

---
 test/shell/lvconvert-repair-raid.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-raid.sh b/test/shell/lvconvert-repair-raid.sh
index 7d4ea7e..df64f3b 100644
--- a/test/shell/lvconvert-repair-raid.sh
+++ b/test/shell/lvconvert-repair-raid.sh
@@ -11,8 +11,8 @@
 
 . lib/test
 
-aux raid456_replace_works || skip
 aux have_raid 1 1 0 || skip
+aux raid456_replace_works || skip
 
 aux lvmconf 'allocation/maximise_cling = 0'
 aux lvmconf 'allocation/mirror_logs_require_separate_pvs = 1'


