From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Tue,  3 Sep 2013 15:55:20 +0000 (UTC)
Subject: master - TEST: pvmove-all-segtypes.sh should not be run in a cluster
Message-ID: <20130903155520.8A25560F58@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=848e8026d68e53dae078ed99fb5f3a47db3def2a
Commit:        848e8026d68e53dae078ed99fb5f3a47db3def2a
Parent:        3b51f298bb505e5184b715032872e5cd1ce2d544
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Sep 3 10:51:21 2013 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Sep 3 10:54:42 2013 -0500

TEST: pvmove-all-segtypes.sh should not be run in a cluster

---
 test/shell/pvmove-all-segtypes.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvmove-all-segtypes.sh b/test/shell/pvmove-all-segtypes.sh
index 13b8fba..8ea9d39 100644
--- a/test/shell/pvmove-all-segtypes.sh
+++ b/test/shell/pvmove-all-segtypes.sh
@@ -15,6 +15,7 @@ test_description="ensure pvmove works with all segment types"
 
 which mkfs.ext2 || skip
 which md5sum || skip
+test -e LOCAL_CLVMD && skip
 
 # ---------------------------------------------------------------------
 # Utilities


