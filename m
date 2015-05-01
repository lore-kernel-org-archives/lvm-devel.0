From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  1 May 2015 13:08:29 +0000 (UTC)
Subject: master - tests: wait between remount
Message-ID: <20150501130829.8B2F060366@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0480b4743a77c166390f50561e8bcdb68214d4ba
Commit:        0480b4743a77c166390f50561e8bcdb68214d4ba
Parent:        4daede06e50bc87e7d5e0b9645e239a9fb03adc0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 30 13:43:31 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 1 15:07:58 2015 +0200

tests: wait between remount

Let's see if this help with some races...
---
 test/shell/topology-support.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/topology-support.sh b/test/shell/topology-support.sh
index c186814..f465ab7 100644
--- a/test/shell/topology-support.sh
+++ b/test/shell/topology-support.sh
@@ -24,9 +24,11 @@ test_snapshot_mount() {
     mount "$(lvdev_ $vg $lv1)" test_mnt
     lvcreate -L4M -n $lv2 -s $vg/$lv1
     umount test_mnt
+    aux udev_wait
     # mount the origin
     mount "$(lvdev_ $vg $lv1)" test_mnt
     umount test_mnt
+    aux udev_wait
     # mount the snapshot
     mount "$(lvdev_ $vg $lv2)" test_mnt
     umount test_mnt


