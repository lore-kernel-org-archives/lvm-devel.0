From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Feb 2014 08:44:52 +0000 (UTC)
Subject: master - tests: cache needs 1.3
Message-ID: <20140225084452.765BB61268@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e49753e6cf9886472c3e7cd11da456f1bd856d1
Commit:        3e49753e6cf9886472c3e7cd11da456f1bd856d1
Parent:        502213e06ca8d30eaa957c284802c0bff4cb8940
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Feb 25 09:36:07 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 25 09:36:07 2014 +0100

tests: cache needs 1.3

---
 test/shell/lvcreate-cache.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index c4c0794..ccfb4ad 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -11,7 +11,7 @@
 
 . lib/test
 
-aux target_at_least dm-cache 1 2 0 || skip
+aux target_at_least dm-cache 1 3 0 || skip
 
 # Skip in cluster for now, but should test EX mode...
 test -e LOCAL_CLVMD && skip


