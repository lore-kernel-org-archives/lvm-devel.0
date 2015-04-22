From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 22 Apr 2015 09:20:41 +0000 (UTC)
Subject: master - tests: add missing "" around dev
Message-ID: <20150422092041.4673260093@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2fea7208810ace2b4ab08408d12ab5e728f498b0
Commit:        2fea7208810ace2b4ab08408d12ab5e728f498b0
Parent:        4b161de2e5afac32ab99c3d5bb2ffe65be5dce13
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 22 11:06:29 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 22 11:18:31 2015 +0200

tests: add missing "" around dev

---
 test/shell/select-tools-thin.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/select-tools-thin.sh b/test/shell/select-tools-thin.sh
index d70289f..f4d49eb 100644
--- a/test/shell/select-tools-thin.sh
+++ b/test/shell/select-tools-thin.sh
@@ -24,7 +24,7 @@ aux prepare_pvs 1 16
 # selecting on initial state (here, thin origin LV thin_orig is removed
 # first, but thin snap should be still selectable based on origin=thin_orig
 # condition even though thin_orig has just been removed)
-vgcreate -s 4m $vg1 $dev1
+vgcreate -s 4m $vg1 "$dev1"
 lvcreate -l100%FREE -T $vg1/pool
 lvcreate -V4m -T $vg1/pool -n thin_orig
 lvcreate -s $vg1/thin_orig -n thin_snap


