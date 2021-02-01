From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 14:05:30 +0000 (GMT)
Subject: main - tests: check for raid target support
Message-ID: <20210201140530.4B50A386F43F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=bfafd2b4e962b8b6bce3355843dec47b4842ed12
Commit:        bfafd2b4e962b8b6bce3355843dec47b4842ed12
Parent:        026d94d882635f859814280573d1198203652d29
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 1 15:01:04 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 15:01:04 2021 +0100

tests: check for raid target support

---
 test/shell/lvdisplay-raid.sh | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/shell/lvdisplay-raid.sh b/test/shell/lvdisplay-raid.sh
index 18ea9ae1e..0c6bfba34 100644
--- a/test/shell/lvdisplay-raid.sh
+++ b/test/shell/lvdisplay-raid.sh
@@ -18,6 +18,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux have_raid 1 3 0 || skip
+
 aux prepare_vg 6
 get_devs
 


