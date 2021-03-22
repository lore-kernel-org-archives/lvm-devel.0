From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:40 +0000 (GMT)
Subject: dev-next - tests: require newer raid version
Message-ID: <20210322153940.6DDB73854808@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fe3ef6867fc585a26bf9950f66b4f190993f457c
Commit:        fe3ef6867fc585a26bf9950f66b4f190993f457c
Parent:        3d26bde1c02b5b3cdfe6bbf87dcad8ce552b0bba
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 19 00:09:19 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Mar 20 00:05:01 2021 +0100

tests: require newer raid version

Tests needs reshape support - so require newer target version
as quick fix.

TODO: inspect indiviual supportable conversion with older versions.
---
 test/shell/lvconvert-raid-takeover.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvconvert-raid-takeover.sh b/test/shell/lvconvert-raid-takeover.sh
index 6a4d554e8..0265d4871 100644
--- a/test/shell/lvconvert-raid-takeover.sh
+++ b/test/shell/lvconvert-raid-takeover.sh
@@ -16,7 +16,7 @@ SKIP_WITH_LVMPOLLD=1
 . lib/inittest
 
 which mkfs.ext4 || skip
-aux have_raid 1 9 0 || skip
+aux have_raid 1 12 0 || skip
 
 correct_raid4_layout=0
 aux have_raid 1 9 1 && correct_raid4_layout=1


