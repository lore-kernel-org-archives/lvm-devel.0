From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Apr 2013 12:40:35 +0000 (UTC)
Subject: master - test: do not break test if there is no .cache
Message-ID: <20130423124035.D7F991409@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=23775c8fe8cdd82dee33cd397eeab5a84181380b
Commit:        23775c8fe8cdd82dee33cd397eeab5a84181380b
Parent:        67fc56f5ca1e05f78cedc5f729745e176447c6b2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 23 14:36:27 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 23 14:36:27 2013 +0200

test: do not break test if there is no .cache

When running test on read /dev, we obtain devices from udev,
and there is no .cache file, so do not stop test if the file
is missing.
---
 test/shell/vgimportclone.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index 0a476ec..60c833a 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -31,7 +31,7 @@ vgimportclone --basevgname $vg2 "$dev2"
 # concerned, can only live on a single device. With the last pvscan, we told it
 # that PV from $dev1 now lives on $dev2, but in fact this is not true anymore,
 # since we wrote a different PV over $dev2.
-rm $TESTDIR/etc/.cache
+rm -f $TESTDIR/etc/.cache
 aux notify_lvmetad "$dev2"
 aux notify_lvmetad "$dev1"
 


