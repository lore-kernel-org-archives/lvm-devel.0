From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 14 Apr 2016 21:56:01 +0000 (UTC)
Subject: master - WHATS_NEW for lvmetad scanning changes
Message-ID: <20160414215601.80DBF61C4D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7ae5f6fc5c300413e740d4fa537090f0a4be5d2c
Commit:        7ae5f6fc5c300413e740d4fa537090f0a4be5d2c
Parent:        ff09bda7d585bbf743048965142e5b0ec881b896
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Apr 14 16:55:34 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Apr 14 16:55:34 2016 -0500

WHATS_NEW for lvmetad scanning changes

---
 WHATS_NEW |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 69ced16..8c58c8d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,8 @@
 Version 2.02.151 -
 =================================
+  Improve retrying lvmetad requests while lvmetad is being updated.
+  Read devices instead of using the lvmetad cache if rescan fails.
+  Move lvmetad token/filter check and device rescan to the start of commands.
   Don't try deactivating fictional internal LV before snapshot merge. (2.02.105)
   When not obtaining devs from udev, check they exist before caching them.
   Detect device mismatch also when compiling without udev support.


