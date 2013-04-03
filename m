From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  3 Apr 2013 20:20:41 +0000 (UTC)
Subject: master - test: Invalidate .cache after vgimportclone.
Message-ID: <20130403202041.3398A954@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=72921d79225bb822f156212177253ac2a0cb8082
Commit:        72921d79225bb822f156212177253ac2a0cb8082
Parent:        95372a852bbcacc9f194324832b94fcf1493f7c5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Apr 3 22:08:46 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Apr 3 22:08:46 2013 +0200

test: Invalidate .cache after vgimportclone.

---
 test/shell/vgimportclone.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/shell/vgimportclone.sh b/test/shell/vgimportclone.sh
index 9b1c121..0a476ec 100644
--- a/test/shell/vgimportclone.sh
+++ b/test/shell/vgimportclone.sh
@@ -31,6 +31,7 @@ vgimportclone --basevgname $vg2 "$dev2"
 # concerned, can only live on a single device. With the last pvscan, we told it
 # that PV from $dev1 now lives on $dev2, but in fact this is not true anymore,
 # since we wrote a different PV over $dev2.
+rm $TESTDIR/etc/.cache
 aux notify_lvmetad "$dev2"
 aux notify_lvmetad "$dev1"
 


