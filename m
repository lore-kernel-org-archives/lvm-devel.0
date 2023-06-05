From: David Teigland <teigland@sourceware.org>
Date: Mon,  5 Jun 2023 15:44:17 +0000 (GMT)
Subject: main - man: lvmraid update limitations
Message-ID: <20230605154417.2ED61388202D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8e53b3bc14a03c243d10fc6bd9a7a8dc43d0a4d4
Commit:        8e53b3bc14a03c243d10fc6bd9a7a8dc43d0a4d4
Parent:        e2ecc6c763557462a4bc3d88bbc883917eb0f010
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jun 5 10:43:51 2023 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jun 5 10:43:51 2023 -0500

man: lvmraid update limitations

---
 man/lvmraid.7_main | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/lvmraid.7_main b/man/lvmraid.7_main
index 26938da83..086f53491 100644
--- a/man/lvmraid.7_main
+++ b/man/lvmraid.7_main
@@ -839,7 +839,7 @@ to do this.)
 RAID LVs with integrity cannot yet be used as sub LVs with other LV types.
 .P
 The following are not yet permitted on RAID LVs with integrity: lvreduce,
-pvmove, snapshots, splitmirror, raid syncaction commands, raid rebuild.
+pvmove, lvconvert --splitmirrors, lvchange --syncaction, lvchange --rebuild.
 .
 .SH RAID1 TUNING
 .

