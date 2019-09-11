From: David Teigland <teigland@sourceware.org>
Date: Wed, 11 Sep 2019 15:02:20 -0400
Subject: master - tests: open-file-limit skip without prlimit
Message-ID: <201909111902.x8BJ2KDq022012@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=31b6a04e4c1e851dc9d51c42a6cb54a82afeb4b4
Commit:        31b6a04e4c1e851dc9d51c42a6cb54a82afeb4b4
Parent:        69b7c00a77e09d23d57eef9d35afb1dc4663478c
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 11 13:55:47 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 11 14:01:55 2019 -0500

tests: open-file-limit skip without prlimit

---
 test/shell/open-file-limit.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/open-file-limit.sh b/test/shell/open-file-limit.sh
index 87b0f7e..6bd632d 100644
--- a/test/shell/open-file-limit.sh
+++ b/test/shell/open-file-limit.sh
@@ -16,6 +16,8 @@ SKIP_WITH_LVMLOCKD=1
 
 . lib/inittest
 
+prlimit -h || skip
+
 aux lvmconf 'devices/pv_min_size = 1024'
 
 aux prepare_devs 200 1


