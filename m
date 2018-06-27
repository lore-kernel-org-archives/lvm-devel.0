From: David Teigland <teigland@sourceware.org>
Date: Wed, 27 Jun 2018 10:00:14 -0400
Subject: master - man: fix lvreduce example
Message-ID: <201806271400.w5RE0EB7004762@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=163a30d7844e07a678c5eea8f38b5f5b2ea58d24
Commit:        163a30d7844e07a678c5eea8f38b5f5b2ea58d24
Parent:        a14f21bf1ddbb93b13a917cad8720fed6c94d6de
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 27 08:58:22 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 27 08:59:41 2018 -0500

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


