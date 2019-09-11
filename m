From: David Teigland <teigland@sourceware.org>
Date: Wed, 11 Sep 2019 15:02:17 -0400
Subject: master - tests: allow-mixed-block-sizes skip with older losetup
Message-ID: <201909111902.x8BJ2HBZ021998@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=69b7c00a77e09d23d57eef9d35afb1dc4663478c
Commit:        69b7c00a77e09d23d57eef9d35afb1dc4663478c
Parent:        715d2c778fb8f7b705a5c222e02638cdf845ea5b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 11 13:52:51 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 11 14:01:55 2019 -0500

tests: allow-mixed-block-sizes skip with older losetup

---
 test/shell/allow-mixed-block-sizes.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/allow-mixed-block-sizes.sh b/test/shell/allow-mixed-block-sizes.sh
index 1803256..2f0b3a0 100644
--- a/test/shell/allow-mixed-block-sizes.sh
+++ b/test/shell/allow-mixed-block-sizes.sh
@@ -14,6 +14,8 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
+losetup -h | grep sector-size || skip
+
 dd if=/dev/zero of=loopa bs=$((1024*1024)) count=2 2> /dev/null
 dd if=/dev/zero of=loopb bs=$((1024*1024)) count=2 2> /dev/null
 LOOP1=$(losetup -f loopa --sector-size 4096 --show)


