From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 25 Jun 2023 11:04:03 +0000 (GMT)
Subject: main - tests: require raid target
Message-ID: <20230625110403.625393858D35@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b8db2c0a4a4bbfc39338141cd7eee67c05b2b31d
Commit:        b8db2c0a4a4bbfc39338141cd7eee67c05b2b31d
Parent:        04860b63240c19065f79453bdffbb7637f2f01eb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Jun 24 22:37:12 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Jun 25 13:02:36 2023 +0200

tests: require raid target

---
 test/shell/snapshot-raid.sh | 1 +
 1 file changed, 1 insertion(+)

diff --git a/test/shell/snapshot-raid.sh b/test/shell/snapshot-raid.sh
index 7b045d79e..98314ddb0 100644
--- a/test/shell/snapshot-raid.sh
+++ b/test/shell/snapshot-raid.sh
@@ -16,6 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux have_raid 1 3 0 || skip
 which mkfs.ext4 || skip
 
 mount_dir="mnt"

