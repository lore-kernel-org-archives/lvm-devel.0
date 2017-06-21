From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 21 Jun 2017 08:04:22 -0400
Subject: master - tests: lvresize needs --yes
Message-ID: <201706211204.v5LC4MUY005884@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=93fbfa2ed397d7b87d4088e19303748c242f24d1
Commit:        93fbfa2ed397d7b87d4088e19303748c242f24d1
Parent:        e3f63693a4ea76975fb01f8456f1f263b029b07f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jun 21 13:58:55 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jun 21 14:03:29 2017 +0200

tests: lvresize needs --yes

---
 test/shell/fsadm.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/fsadm.sh b/test/shell/fsadm.sh
index ac43900..6eff24a 100644
--- a/test/shell/fsadm.sh
+++ b/test/shell/fsadm.sh
@@ -131,6 +131,7 @@ if check_missing ext3; then
 	not fsadm -y --lvresize resize $vg_lv 4M
 	echo n | not lvresize -L4M -r -n $vg_lv
 	lvresize -L+20M -r -n $vg_lv
+	lvresize -L-10M -r -y $vg_lv
 	umount "$mount_dir"
 	umount "$mount_space_dir"
 	fscheck_ext3


