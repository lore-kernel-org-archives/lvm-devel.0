From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 23 Feb 2023 15:48:47 +0000 (GMT)
Subject: main - tests: add fixme
Message-ID: <20230223154847.C91D23858C5E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6943afe9d5dc6e82444bdadf9abc54198cadfd16
Commit:        6943afe9d5dc6e82444bdadf9abc54198cadfd16
Parent:        d5c0b68dde47f7a6feb9f84764a8055b033c21c4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Feb 23 15:24:23 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 23 16:01:50 2023 +0100

tests: add fixme

---
 test/shell/lvmlockd_failure.sh | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/test/shell/lvmlockd_failure.sh b/test/shell/lvmlockd_failure.sh
index e0fccfb83..2825462b9 100644
--- a/test/shell/lvmlockd_failure.sh
+++ b/test/shell/lvmlockd_failure.sh
@@ -14,13 +14,14 @@ SKIP_WITH_LVMPOLLD=1
 
 . lib/inittest
 
-[ -z "$LVM_TEST_FAILURE" ] && skip;
+[ -z "$LVM_TEST_FAILURE" ] && skip
 
 aux prepare_vg 3
 
 # Create new logic volume
 lvcreate -a ey --zero n -l 1 -n $lv1 $vg
 
+# FIXME - test shall NOT kill random processes in the system!
 # Emulate lvmlockd abnormally exiting
 killall -9 lvmlockd
 

