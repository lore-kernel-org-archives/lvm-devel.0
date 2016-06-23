From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Jun 2016 23:03:26 +0000 (UTC)
Subject: master - tests: smaller number of devs created to fill metadata
Message-ID: <20160623230326.C06C2609D8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fc174f6b74ee1d0fc12cca9fe5c392621acf069f
Commit:        fc174f6b74ee1d0fc12cca9fe5c392621acf069f
Parent:        1c212371fa6e65c783d7df50eab0108acb7b0cf8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 24 00:35:42 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 24 00:39:14 2016 +0200

tests: smaller number of devs created to fill metadata

---
 test/shell/thin-flags.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/thin-flags.sh b/test/shell/thin-flags.sh
index 395b98d..7d87553 100644
--- a/test/shell/thin-flags.sh
+++ b/test/shell/thin-flags.sh
@@ -67,7 +67,7 @@ aux lvmconf 'global/thin_check_executable = ""'
 
 # Prepare some fake metadata prefilled to ~100%
 lvcreate -L2 -n $lv1 $vg # tmp for metadata
-aux prepare_thin_metadata 500 1 | tee data
+aux prepare_thin_metadata 490 1 | tee data
 "$LVM_TEST_THIN_RESTORE_CMD" -i data -o "$DM_DEV_DIR/mapper/$vg-$lv1"
 
 # Swap volume with restored fake metadata


