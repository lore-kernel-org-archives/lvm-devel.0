From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Oct 2013 14:22:33 +0000 (UTC)
Subject: master - tests: workaround udevd compromising tests
Message-ID: <20131017142233.B0A1A6096F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=66f4698a93c6cc7d0fb027c5e4209b1de6a880ef
Commit:        66f4698a93c6cc7d0fb027c5e4209b1de6a880ef
Parent:        93a07a1b841628bb4c8caaa7f0470fc77f656ff2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 17 16:19:06 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 16:19:06 2013 +0200

tests: workaround udevd compromising tests

Patch helps a bit when lvm2 is build with disabled udev_sync support,
but udevd runs in the system - so it randomly influences unrelated tests
even - so before every test wait at least till udevd is settled.
---
 test/lib/utils.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index 0f58b25..8311c4c 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -214,3 +214,5 @@ case "$PATH" in
 esac
 
 test -z "$PREFIX" || prepare_test_vars
+
+test -e /sbin/udevsettle && pidof udevd >/dev/null && /sbin/udevsettle


