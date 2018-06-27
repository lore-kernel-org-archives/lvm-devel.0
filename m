From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Jun 2018 09:58:58 -0400
Subject: 2018-06-01-stable - man: fix lvreduce example
Message-ID: <201806271358.w5RDww0w004693@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d5bcc56eefde8349ffee93d0411c6f9fd71ceb84
Commit:        d5bcc56eefde8349ffee93d0411c6f9fd71ceb84
Parent:        f7ffba204e06ae432ae2c7943cb41eec5b8e8bb1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 27 08:58:22 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 27 08:58:22 2018 -0500

man: fix lvreduce example

---
 man/lvreduce.8_end |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvreduce.8_end b/man/lvreduce.8_end
index 53f1ac7..a9cb035 100644
--- a/man/lvreduce.8_end
+++ b/man/lvreduce.8_end
@@ -2,4 +2,4 @@
 
 Reduce the size of an LV by 3 logical extents:
 .br
-.B lvreduce -l -3 vg00/lvol1
+.B lvreduce -l 3 vg00/lvol1


