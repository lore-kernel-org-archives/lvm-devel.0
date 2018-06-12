From: David Teigland <teigland@sourceware.org>
Date: Tue, 12 Jun 2018 12:42:22 -0400
Subject: master - tests: lvconvert-repair remove cluster test
Message-ID: <201806121642.w5CGgM4M007254@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7824bb710d376804a7b821730aaa8ff1a65cae21
Commit:        7824bb710d376804a7b821730aaa8ff1a65cae21
Parent:        be3af7f93ef0ca7d65b07863c876a7cbb1e7a239
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Jun 12 11:35:45 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Jun 12 11:35:45 2018 -0500

tests: lvconvert-repair remove cluster test

---
 test/shell/lvconvert-repair.sh |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/test/shell/lvconvert-repair.sh b/test/shell/lvconvert-repair.sh
index 9ee7980..5f7b851 100644
--- a/test/shell/lvconvert-repair.sh
+++ b/test/shell/lvconvert-repair.sh
@@ -68,11 +68,7 @@ vgreduce --removemissing $vg
 aux enable_dev "$dev4"
 
 # 3-way, mirrored log => 3-way, core log
-if test -n "$LVM_TEST_LVMLOCKD"; then
 recreate_vg_
-else
-recreate_vg_ -c n
-fi
 lvcreate -aey --type mirror -m 2 --mirrorlog mirrored --ignoremonitoring -L 1 -n 3way $vg \
     "$dev1" "$dev2" "$dev3" "$dev4":0 "$dev5":0
 aux disable_dev "$dev4" "$dev5"


