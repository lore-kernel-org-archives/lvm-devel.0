From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed,  4 Jul 2012 00:14:41 +0000 (UTC)
Subject: master - TEST (lvconvert-raid): Turn on RAID conversion testing under snapshots
Message-ID: <20120704001441.4BAEF1778@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bf81d5607a47eb0bf3963be54f4b765b2d24b895
Commit:        bf81d5607a47eb0bf3963be54f4b765b2d24b895
Parent:        7168880caa5f09da254e930313c2d59547643bb2
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Tue Jun 26 06:45:45 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Tue Jun 26 06:45:45 2012 -0500

TEST (lvconvert-raid):  Turn on RAID conversion testing under snapshots

---
 test/shell/lvconvert-raid.sh |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 6c289a8..a4ebac9 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -81,11 +81,7 @@ vgcreate -c n -s 256k $vg $(cat DEVICES)
 ###########################################
 # RAID1 convert tests
 ###########################################
-#
-# FIXME: Snapshots of RAID is available, but there are kernel bugs that
-#        still prevent its use.
-#for under_snap in false true; do
-for under_snap in false; do
+for under_snap in false true; do
 for i in 1 2 3 4; do
 	for j in 1 2 3 4; do
 		if [ $i -eq 1 ]; then


