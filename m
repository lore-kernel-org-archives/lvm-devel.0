From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Feb 2015 14:42:16 +0000 (UTC)
Subject: master - tests: ensure array is synchronized
Message-ID: <20150212144216.003C26010E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4b7097b96c94e115581e77588fe1591dae1e035f
Commit:        4b7097b96c94e115581e77588fe1591dae1e035f
Parent:        739b751046c17ba8e6225821446951e6742c16eb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 12 10:40:57 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 12 15:38:51 2015 +0100

tests: ensure array is synchronized

Before continue of repair test, ensure mirror is in sync
---
 test/shell/lvconvert-repair-transient.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-repair-transient.sh b/test/shell/lvconvert-repair-transient.sh
index 99018ef..9bf6a9d 100644
--- a/test/shell/lvconvert-repair-transient.sh
+++ b/test/shell/lvconvert-repair-transient.sh
@@ -17,6 +17,7 @@ aux prepare_vg 5
 # ordinary mirrors
 
 lvcreate -aey --type mirror -m 3 --ignoremonitoring -L 1 -n 4way $vg
+aux wait_for_sync $vg 4way
 aux disable_dev --error --silent "$dev2" "$dev4"
 mkfs.ext3 "$DM_DEV_DIR/$vg/4way" &
 sleep 1


