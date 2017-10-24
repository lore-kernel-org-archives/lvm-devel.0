From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Tue, 24 Oct 2017 15:07:52 -0400
Subject: master - clean-up: Correct the comment to match the particular test case
Message-ID: <201710241907.v9OJ7qcK005417@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=38f7fbac64ee8291776c168b32fbd39ce2706bfe
Commit:        38f7fbac64ee8291776c168b32fbd39ce2706bfe
Parent:        10c76ce35a294b3d5fc84bc8af3ff118168282d7
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Oct 24 14:06:44 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Oct 24 14:06:44 2017 -0500

clean-up:  Correct the comment to match the particular test case

---
 test/shell/lvconvert-raid-status-validation.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-raid-status-validation.sh b/test/shell/lvconvert-raid-status-validation.sh
index 51c7048..b4140a9 100644
--- a/test/shell/lvconvert-raid-status-validation.sh
+++ b/test/shell/lvconvert-raid-status-validation.sh
@@ -101,9 +101,9 @@ while true; do
 		[ "${a[7]}" = "recover" ]
 	else
 		# Tough to tell the INVALID case,
-		#   Before starting sync thread: "Aa X/X recover"
+		#   Before starting sync thread: "AAa X/X recover"
 		# from the valid case,
-		#   Just finished sync thread: "Aa X/X recover"
+		#   Just finished sync thread: "AAa X/X recover"
 		[ "${a[5]}" = "AAA" ]
 		[ "${a[7]}" = "idle" ]
 		break


