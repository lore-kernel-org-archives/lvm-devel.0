From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  9 Oct 2013 12:47:28 +0000 (UTC)
Subject: master - test: Correctly trigger inconsistent metadata repair in lvmcache-exercise.
Message-ID: <20131009124728.3EBF460D86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=17f3b8280b8ade397a6a4a8fd82ba7dd7d0e1d1b
Commit:        17f3b8280b8ade397a6a4a8fd82ba7dd7d0e1d1b
Parent:        0decd7553ac9dcf4a7d81f5b10b1f4ca053ae9a5
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Oct 9 14:44:15 2013 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Oct 9 14:44:15 2013 +0200

test: Correctly trigger inconsistent metadata repair in lvmcache-exercise.

Since lvconvert --repair sets handles_missing_pvs, it will not repair
inconsistent metadata automatically. Calling lvs instead should do the trick.
---
 test/shell/lvmcache-exercise.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmcache-exercise.sh b/test/shell/lvmcache-exercise.sh
index 5ea6381..6e8efda 100644
--- a/test/shell/lvmcache-exercise.sh
+++ b/test/shell/lvmcache-exercise.sh
@@ -30,7 +30,7 @@ lvconvert --yes --repair $vg2/$lv1
 aux enable_dev "$dev3"
 
 # here it should fix any reappeared devices
-lvconvert --yes --repair $vg2/$lv1
+lvs
 
 lvs -a $vg2 -o+devices 2>&1 | tee out
 not grep reappeared out


