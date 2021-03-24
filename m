From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 24 Mar 2021 11:41:51 +0000 (GMT)
Subject: main - tests: remove more file in teardonw
Message-ID: <20210324114151.1D5C53857026@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a126dde069ada9380ba2f7ab7e520ba4ce3e2a90
Commit:        a126dde069ada9380ba2f7ab7e520ba4ce3e2a90
Parent:        18f2475fa18bfe8b08af830bb8335d41928206fe
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Mar 24 00:39:01 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 24 12:23:07 2021 +0100

tests: remove more file in teardonw

Our tests may result in producation of huge set of
invalid links in /dev/disk directory depeding on version
of udev and various kinds of failures.

Also we happen to invoke some on-system pvscans generating
local /etc/lvm/archive & backups - remove them when
test is finished.
---
 test/lib/aux.sh | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 08eeac55b..f81d03e88 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -580,6 +580,12 @@ teardown() {
 		rm -rf "${TESTDIR:?}" || echo BLA
 	}
 
+	# Remove any dangling symlink in /dev/disk (our tests can confuse udev)
+	find /dev/disk -type l ! -exec test -e {} \; -print | xargs rm -f
+
+	# Remove any metadata archives and backups from this test on system
+	rm -f /etc/lvm/archive/${PREFIX}* /etc/lvm/backup/${PREFIX}*
+
 	echo "ok"
 }
 


