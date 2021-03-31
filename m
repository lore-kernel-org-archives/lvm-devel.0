From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Mar 2021 21:49:12 +0000 (GMT)
Subject: dev-next - tests: handle case of missing /dev/disk
Message-ID: <20210331214912.2357C3858C27@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0783c661b9eb407b0b436559b6950deefc906b4f
Commit:        0783c661b9eb407b0b436559b6950deefc906b4f
Parent:        2151b71819ffd45e71f2565aa2c0d2cb9685e2c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 24 15:52:14 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 24 16:38:12 2021 +0100

tests: handle case of missing /dev/disk

In case there is no symlink - udev can optimize /dev/disk away,
thus find would fail in teardown.
---
 test/lib/aux.sh | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f81d03e88..6c43790b7 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -581,7 +581,9 @@ teardown() {
 	}
 
 	# Remove any dangling symlink in /dev/disk (our tests can confuse udev)
-	find /dev/disk -type l ! -exec test -e {} \; -print | xargs rm -f
+	test -d /dev/disk && {
+		find /dev/disk -type l ! -exec test -e {} \; -print | xargs rm -f || true
+	}
 
 	# Remove any metadata archives and backups from this test on system
 	rm -f /etc/lvm/archive/${PREFIX}* /etc/lvm/backup/${PREFIX}*


