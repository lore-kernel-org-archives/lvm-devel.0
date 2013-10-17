From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 17 Oct 2013 20:58:11 +0000 (UTC)
Subject: master - tests: drop settle for old systems
Message-ID: <20131017205811.A3C5960FF0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f406ce252c40a29c06dba4bebe92b570207df93
Commit:        9f406ce252c40a29c06dba4bebe92b570207df93
Parent:        7f4452a41e55a60678cadda99ae1a383a367a9e5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 17 22:54:12 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 17 22:54:12 2013 +0200

tests: drop settle for old systems

Reverts previously added udevsettle call.

Seems to be unrelated, while udev on old system may take over 10
minutes, to finish it's very slow and CPU intensive work, it doesn't
interact directly with created device, only access /dev/mapper/control
node via dmsetup, so the device is ocasionaly blocked by something else.
---
 test/lib/utils.sh |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/test/lib/utils.sh b/test/lib/utils.sh
index c3bd533..0f58b25 100644
--- a/test/lib/utils.sh
+++ b/test/lib/utils.sh
@@ -214,5 +214,3 @@ case "$PATH" in
 esac
 
 test -z "$PREFIX" || prepare_test_vars
-
-test ! -e /sbin/udevsettle || if pidof udevd >/dev/null; then /sbin/udevsettle ; fi


