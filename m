From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 21 Apr 2023 12:53:39 +0000 (GMT)
Subject: main - tests: add data sync
Message-ID: <20230421125339.03FEF3858C50@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8bcf46a0acfa500b4fb586cba254ca3930389d3d
Commit:        8bcf46a0acfa500b4fb586cba254ca3930389d3d
Parent:        80ebec099dbb20e46655958e1ca7fcfd466b78d8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Apr 21 14:51:47 2023 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 21 14:52:43 2023 +0200

tests: add data sync

---
 test/shell/thin-foreign-dmeventd.sh | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/shell/thin-foreign-dmeventd.sh b/test/shell/thin-foreign-dmeventd.sh
index 561cea885..76995a3d0 100644
--- a/test/shell/thin-foreign-dmeventd.sh
+++ b/test/shell/thin-foreign-dmeventd.sh
@@ -70,6 +70,8 @@ mkdir "$MOUNT_DIR"
 # This mkfs should fill 2MB pool over 95%
 # no autoresize is configured
 mkfs.ext4 "$DM_DEV_DIR/mapper/$THIN"
+# ensure all data from mkfs are written to disk
+sync
 test "$(percent_)" -gt 95
 mount "$DM_DEV_DIR/mapper/$THIN" "$MOUNT_DIR"
 

