From: Lidong Zhong <lzhong@suse.com>
Date: Thu,  6 Aug 2015 14:22:02 +0800
Subject: [PATCH] man: typo fix about lvmthin
Message-ID: <1438842122-8831-1-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 man/lvmthin.7.in | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/man/lvmthin.7.in b/man/lvmthin.7.in
index eb791f0..76597a9 100644
--- a/man/lvmthin.7.in
+++ b/man/lvmthin.7.in
@@ -1047,7 +1047,7 @@ Command to display the current discard mode of a thin pool LV:
 
 Command to set the discard mode when creating a thin pool LV:
 .br
-.B lvconvert \-\-discards {ignore|nopassdown|passdown}
+.B lvcreate \-\-discards {ignore|nopassdown|passdown}
 .br
 .RS
 .B \-\-type thin\-pool \-\-poolmetadata VG/ThinMetaLV VG/ThinDataLV
-- 
1.8.1.4


