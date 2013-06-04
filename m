From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:28:05 +0000 (UTC)
Subject: dev-mornfall-activate - tests: skip if the system already uses tested minor
Message-ID: <20130604192805.33F5D60E46@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=274eae592fc0d1787e5794c8d4f6d17c8a595659
Commit:        274eae592fc0d1787e5794c8d4f6d17c8a595659
Parent:        1c83c159631dd9be40d47da168ce1c77423798b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri May 31 12:48:37 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 31 21:42:32 2013 +0200

tests: skip if the system already uses tested minor

---
 test/shell/activate-minor.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/activate-minor.sh b/test/shell/activate-minor.sh
index 5433f01..3726faa 100644
--- a/test/shell/activate-minor.sh
+++ b/test/shell/activate-minor.sh
@@ -11,6 +11,10 @@
 
 . lib/test
 
+# Just skip this test if minor is already in use...
+dmsetup info | tee info
+egrep "^Major, minor: *[0-9]+, 123" info && skip
+
 aux prepare_vg 2
 lvcreate -a n --zero n -l 1 -n foo $vg
 lvchange $vg/foo -My --major=255 --minor=123


