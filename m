From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed,  7 Oct 2009 21:44:28 -0400
Subject: [PATCH] Minor fixes to t-unknown-segment.sh.
In-Reply-To: <87k4z79b9p.fsf_-_@twilight.int.mornfall.net>
References: <87k4z79b9p.fsf_-_@twilight.int.mornfall.net>
Message-ID: <1254966268-21710-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Need to grep out "Generated" line or the test failed for me.
Qualify vgcfgbackup to only backup the vg we've created.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/t-unknown-segment.sh |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/test/t-unknown-segment.sh b/test/t-unknown-segment.sh
index 30d6f6d..542257f 100644
--- a/test/t-unknown-segment.sh
+++ b/test/t-unknown-segment.sh
@@ -16,16 +16,16 @@ aux prepare_vg 4
 lvcreate -l 1 -n $lv1 $vg
 lvcreate -l 2 -m 1 -n $lv2 $vg
 
-vgcfgbackup -f bak0
+vgcfgbackup -f bak0 $vg
 sed -e 's,striped,unstriped,;s,mirror,unmirror,' -i.orig bak0
 vgcfgrestore -f bak0 $vg
 
-vgcfgbackup -f bak1
+vgcfgbackup -f bak1 $vg
 cat bak1
 sed -e 's,unstriped,striped,;s,unmirror,mirror,' -i.orig bak1
 vgcfgrestore -f bak1 $vg
-vgcfgbackup -f bak2
+vgcfgbackup -f bak2 $vg
 
-egrep -v 'description|seqno|creation_time' < bak0.orig > a
-egrep -v 'description|seqno|creation_time' < bak2 > b
+egrep -v 'description|seqno|creation_time|Generated' < bak0.orig > a
+egrep -v 'description|seqno|creation_time|Generated' < bak2 > b
 diff -u a b
-- 
1.6.0.6


