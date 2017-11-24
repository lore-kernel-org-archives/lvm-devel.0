From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 24 Nov 2017 10:11:38 -0500
Subject: master - tests: more places where missing should not appear
Message-ID: <201711241511.vAOFBc50000803@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ce83162d7c7eae008935989a26dbf23dfb08d0f9
Commit:        ce83162d7c7eae008935989a26dbf23dfb08d0f9
Parent:        7eae2647c0ad4458b90b7bcc85e42668b9f49607
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 21 17:34:41 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 24 16:09:59 2017 +0100

tests: more places where missing should not appear

---
 test/shell/lvconvert-repair-cache.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index b7925e2..4b9d8b8 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -50,6 +50,8 @@ aux disable_dev "$dev1"
 not lvconvert --uncache $vg/$lv1
 # --yes to drop when Check its prompting
 lvconvert --yes --uncache $vg/$lv1
+should not dmsetup remove ${vg}-cpool_cmeta-missing_0_0
+should not dmsetup remove ${vg}-cpool_cdata-missing_0_0
 
 "$FSCK" -n "$DM_DEV_DIR/$vg/$lv1"
 


