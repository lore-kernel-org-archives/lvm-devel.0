From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 24 Sep 2019 08:08:43 -0400
Subject: stable-2.02 - tests: allow-mixed-block-sizes skip with older losetup
Message-ID: <201909241208.x8OC8h8M016032@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2327f3997bfb70d67299f3dfa45436132e0a8521
Commit:        2327f3997bfb70d67299f3dfa45436132e0a8521
Parent:        9fcda0d9752bf06b619d29aa6738b4ac52acedfc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 11 13:52:51 2019 -0500
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Sep 24 14:08:23 2019 +0200

tests: allow-mixed-block-sizes skip with older losetup

(cherry picked from commit 69b7c00a77e09d23d57eef9d35afb1dc4663478c)
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


