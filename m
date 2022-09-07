From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  7 Sep 2022 13:05:00 +0000 (GMT)
Subject: main - tests: add thin requirement
Message-ID: <20220907130500.C60F03858428@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0ed3f7a1bf7d9a7a144526048e44dd19c29fcfed
Commit:        0ed3f7a1bf7d9a7a144526048e44dd19c29fcfed
Parent:        1a3e773f37483b30f1bd1c1406ffc2f0b1e00631
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Sep 6 17:59:25 2022 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Sep 7 15:00:15 2022 +0200

tests: add thin requirement

---
 test/shell/report-format.sh | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/test/shell/report-format.sh b/test/shell/report-format.sh
index 07fa02778..399ed0337 100644
--- a/test/shell/report-format.sh
+++ b/test/shell/report-format.sh
@@ -15,6 +15,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+aux have_thin 1 0 0 || skip
+
 aux prepare_vg 1
 
 OUT_LOG_FILE="out"

