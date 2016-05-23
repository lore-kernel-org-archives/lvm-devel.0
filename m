From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 23 May 2016 17:05:17 +0000 (UTC)
Subject: master - test: lvmetad-disabled
Message-ID: <20160523170517.4DC4D60D7B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=757f7d55082844a17372e4e83c6a95884c2550a8
Commit:        757f7d55082844a17372e4e83c6a95884c2550a8
Parent:        3d3efd7ab80f200148f8c133521320642aa9d221
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu May 5 15:44:27 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon May 23 12:01:11 2016 -0500

test: lvmetad-disabled

---
 test/shell/lvmetad-disabled.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvmetad-disabled.sh b/test/shell/lvmetad-disabled.sh
index e905ba7..41f1126 100644
--- a/test/shell/lvmetad-disabled.sh
+++ b/test/shell/lvmetad-disabled.sh
@@ -42,7 +42,7 @@ while ! test -e "$TESTDIR/lvmetad.socket"; do echo -n .; sleep .1; done # wait f
 test -e "$LVM_LVMETAD_PIDFILE"
 cp "$LVM_LVMETAD_PIDFILE" LOCAL_LVMETAD
 
-not pvscan --cache 2>&1 | tee out
+pvscan --cache 2>&1 | tee out
 grep "WARNING: Disabling lvmetad cache" out
 
 pvs  2>&1 | tee out


