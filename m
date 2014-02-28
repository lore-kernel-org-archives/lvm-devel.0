From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:35 +0000 (UTC)
Subject: master - test: Fix notify_lvmetad for symlinked devices.
Message-ID: <20140228102635.6033C60FF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8e814eb8997d6aa5e3169d909a3ce1d8d2536897
Commit:        8e814eb8997d6aa5e3169d909a3ce1d8d2536897
Parent:        bf29eabdba4be1c706da7b80c803de5a98619baf
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Fri Feb 28 11:07:56 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:53 2014 +0100

test: Fix notify_lvmetad for symlinked devices.

---
 test/lib/aux.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 66ed910..de14253 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -381,8 +381,8 @@ disable_dev() {
 	udev_wait
 	init_udev_transaction
 	for dev in "$@"; do
-		maj=$(($(stat --printf=0x%t "$dev")))
-		min=$(($(stat --printf=0x%T "$dev")))
+		maj=$(($(stat -L --printf=0x%t "$dev")))
+		min=$(($(stat -L --printf=0x%T "$dev")))
 		echo "Disabling device $dev ($maj:$min)"
 		dmsetup remove -f "$dev" 2>/dev/null || true
 		notify_lvmetad --major "$maj" --minor "$min"


