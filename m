From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Jun 2018 10:20:06 -0400
Subject: 2018-06-01-stable - Revert "man: fix lvreduce example"
Message-ID: <201806271420.w5REK6EA007492@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=814dd84e0769da568232a19f798baf24b8a26127
Commit:        814dd84e0769da568232a19f798baf24b8a26127
Parent:        d5bcc56eefde8349ffee93d0411c6f9fd71ceb84
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 27 09:19:01 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 27 09:19:01 2018 -0500

Revert "man: fix lvreduce example"

 -l -3 is correct, meaning reduce by 3.

This reverts commit d5bcc56eefde8349ffee93d0411c6f9fd71ceb84.
---
 man/lvreduce.8_end |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/man/lvreduce.8_end b/man/lvreduce.8_end
index a9cb035..53f1ac7 100644
--- a/man/lvreduce.8_end
+++ b/man/lvreduce.8_end
@@ -2,4 +2,4 @@
 
 Reduce the size of an LV by 3 logical extents:
 .br
-.B lvreduce -l 3 vg00/lvol1
+.B lvreduce -l -3 vg00/lvol1


