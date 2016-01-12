From: okozina <okozina@fedoraproject.org>
Date: Tue, 12 Jan 2016 12:34:10 +0000 (UTC)
Subject: master - test: conditional skip of auto-activation bg polling test
Message-ID: <20160112123410.B447260527@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a3ee6402ecf761554040a551f6c7f52b92f73ca
Commit:        1a3ee6402ecf761554040a551f6c7f52b92f73ca
Parent:        d1e30ff0baa3cf4ae0c582c29dc017d63ca99483
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Tue Jan 12 13:24:12 2016 +0100
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue Jan 12 13:32:23 2016 +0100

test: conditional skip of auto-activation bg polling test

if dm-snapshot-merge target not present skip whole test
---
 .../shell/lvmetad-pvscan-autoactivation-polling.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvmetad-pvscan-autoactivation-polling.sh b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
index f7ea912..08e00e0 100644
--- a/test/shell/lvmetad-pvscan-autoactivation-polling.sh
+++ b/test/shell/lvmetad-pvscan-autoactivation-polling.sh
@@ -13,6 +13,9 @@ SKIP_WITHOUT_LVMETAD=1
 
 . lib/inittest
 
+# test if snapshot-merge target is available
+aux target_at_least dm-snapshot-merge 1 0 0 || skip
+
 which mkfs.ext3 || skip
 
 lvdev_() {


