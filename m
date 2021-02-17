From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Feb 2021 12:01:21 +0000 (GMT)
Subject: stable-2.02 - tests: check for raid target support
Message-ID: <20210217120121.F139A389850A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8bc7bb2dbf7126d9e6ba92d4bc8ccbd6dc026965
Commit:        8bc7bb2dbf7126d9e6ba92d4bc8ccbd6dc026965
Parent:        a157c9e1a145819276586b39565b8c41019932df
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 1 15:01:04 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 17 12:09:16 2021 +0100

tests: check for raid target support

---
 test/shell/lvdisplay-raid.sh | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/shell/lvdisplay-raid.sh b/test/shell/lvdisplay-raid.sh
index 18ea9ae1e..95205ba81 100644
--- a/test/shell/lvdisplay-raid.sh
+++ b/test/shell/lvdisplay-raid.sh
@@ -18,6 +18,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux have_raid 1 7 0 || skip
+
 aux prepare_vg 6
 get_devs
 


