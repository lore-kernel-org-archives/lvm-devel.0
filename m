From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 27 Nov 2013 07:33:39 +0000 (UTC)
Subject: master - WHATS_NEW: commit 729b104
Message-ID: <20131127073339.7D6BA602D6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d6e67b850365864bba91619a40503ff0b0392e2c
Commit:        d6e67b850365864bba91619a40503ff0b0392e2c
Parent:        729b104413e11412866a549ef8a6702f56c4acd1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Nov 27 08:33:02 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Nov 27 08:33:02 2013 +0100

WHATS_NEW: commit 729b104

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4148754..7718b6f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Do not fail the whole autoactivation if the VG refresh done before fails.
   Do not connect to lvmetad on vg/lvchange --sysinit -aay and socket absent.
   Use lv_check_not_in_use() when testing device in use before merging.
   Move test for target present from init_snapshot_merge() to lvconvert.


