From: David Teigland <teigland@sourceware.org>
Date: Mon, 22 Mar 2021 15:39:04 +0000 (GMT)
Subject: dev-next - tests: increase version of targets for progress
Message-ID: <20210322153904.C3AD53854808@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=80d0f200d00727f591569512ea04d9b50c22ae59
Commit:        80d0f200d00727f591569512ea04d9b50c22ae59
Parent:        e793ff1e185acfdbbbedb85a420d48527cd57c90
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 16 22:59:01 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 17 00:59:50 2021 +0100

tests: increase version of targets for progress

---
 test/shell/lvextend-raid.sh | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/test/shell/lvextend-raid.sh b/test/shell/lvextend-raid.sh
index e8bd7deea..9370bf295 100644
--- a/test/shell/lvextend-raid.sh
+++ b/test/shell/lvextend-raid.sh
@@ -17,7 +17,7 @@ SKIP_WITH_LVMPOLLD=1
 
 aux have_raid 1 3 0 || skip
 PROGRESS=0
-aux have_raid 1 13 0 && PROGRESS=1
+aux have_raid 1 15 0 && PROGRESS=1
 
 # Use smallest regionsize to save VG space
 regionsize=$(getconf PAGESIZE) # in bytes


