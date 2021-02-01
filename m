From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon,  1 Feb 2021 20:34:53 +0000 (GMT)
Subject: main - tests: increase required target version
Message-ID: <20210201203453.5AA0239450E8@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=48dfc388f7bde964d8e4d6816f27de858c984fb3
Commit:        48dfc388f7bde964d8e4d6816f27de858c984fb3
Parent:        6e8a32e4fd424ef599549ac1036ce795a8ae3837
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 1 20:10:07 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 1 20:10:07 2021 +0100

tests: increase required target version

Require 1.7.0 for raid0.
---
 test/shell/lvdisplay-raid.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvdisplay-raid.sh b/test/shell/lvdisplay-raid.sh
index 0c6bfba34..95205ba81 100644
--- a/test/shell/lvdisplay-raid.sh
+++ b/test/shell/lvdisplay-raid.sh
@@ -18,7 +18,7 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-aux have_raid 1 3 0 || skip
+aux have_raid 1 7 0 || skip
 
 aux prepare_vg 6
 get_devs


