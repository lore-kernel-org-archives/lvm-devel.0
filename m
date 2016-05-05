From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  5 May 2016 22:01:39 +0000 (UTC)
Subject: master - tests: check for thin tools
Message-ID: <20160505220139.CFB9560C97@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95f0e25601155755baf4ea1649cd241949120185
Commit:        95f0e25601155755baf4ea1649cd241949120185
Parent:        673d4f745322d6d9ca274697148267114058beec
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 5 23:14:38 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 5 23:55:20 2016 +0200

tests: check for thin tools

Test needs repair utils to be available.
---
 test/shell/lvconvert-repair-thin-raid.sh |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-repair-thin-raid.sh b/test/shell/lvconvert-repair-thin-raid.sh
index a895e08..7afceef 100644
--- a/test/shell/lvconvert-repair-thin-raid.sh
+++ b/test/shell/lvconvert-repair-thin-raid.sh
@@ -21,6 +21,15 @@ aux have_thin 1 0 0 || skip
 aux have_raid 1 4 0 || skip
 
 #
+# To continue this test - we need real tools available
+# When they are not present mark test as skipped, but still
+# let proceed initial part which should work even without tools
+#
+aux have_tool_at_least "$LVM_TEST_THIN_CHECK_CMD" 0 3 1 || skip
+aux have_tool_at_least "$LVM_TEST_THIN_DUMP_CMD" 0 3 1 || skip
+aux have_tool_at_least "$LVM_TEST_THIN_REPAIR_CMD" 0 3 1 || skip
+
+#
 # Main
 #
 


