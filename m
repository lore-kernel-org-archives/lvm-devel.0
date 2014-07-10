From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Thu, 10 Jul 2014 23:54:01 +0000 (UTC)
Subject: master - test: Test failing due to too few PVs
Message-ID: <20140710235401.E9FA261100@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f33d75e2e586a88ddeb20d860765f091098b8ab5
Commit:        f33d75e2e586a88ddeb20d860765f091098b8ab5
Parent:        3063b48602220b0aa5e1ad7a91dc4ca60d717e36
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Thu Jul 10 18:52:55 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Thu Jul 10 18:53:46 2014 -0500

test: Test failing due to too few PVs

Commit 33d69162e4b45e7926d4c0e4a425fedb4246088e reduced the number of
PVs to a level where the test could not function.  (It is impossible
to replace 3 PVs of a 4-way RAID1 LV if there are only 5 PVs.)
---
 test/shell/lvconvert-raid.sh    |    2 +-
 test/shell/lvconvert-raid456.sh |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index 6f17303..bcf3874 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -24,7 +24,7 @@ get_image_pvs() {
 ########################################################
 aux have_raid 1 3 0 || skip
 
-aux prepare_pvs 5
+aux prepare_pvs 9
 vgcreate -s 256k $vg $(cat DEVICES)
 
 ###########################################
diff --git a/test/shell/lvconvert-raid456.sh b/test/shell/lvconvert-raid456.sh
index 1ead128..833b10e 100644
--- a/test/shell/lvconvert-raid456.sh
+++ b/test/shell/lvconvert-raid456.sh
@@ -25,7 +25,7 @@ get_image_pvs() {
 aux raid456_replace_works || skip
 aux have_raid 1 3 0 || skip
 
-aux prepare_pvs 6
+aux prepare_pvs 7  # 7 devices for 2 dev replacement of 5-dev RAID6
 vgcreate -s 256k $vg $(cat DEVICES)
 
 # RAID 4/5/6 (can replace up to 'parity' devices)


