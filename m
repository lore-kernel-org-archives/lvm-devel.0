From: David Teigland <teigland@sourceware.org>
Date: Tue, 23 Apr 2019 10:44:45 -0400
Subject: stable-2.02 - devices: drop open error message
Message-ID: <201904231444.x3NEij6u018823@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=559cf0cd1e226baf63a98c39572264fbf5c3f6b4
Commit:        559cf0cd1e226baf63a98c39572264fbf5c3f6b4
Parent:        228e331e270451e16126659655905a583a03a0d3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 23 09:39:42 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 23 09:42:25 2019 -0500

devices: drop open error message

This open error is being printed in more common,
non-error circumstances than expected.  After a
number of complaints make it only a debug message.
---
 lib/device/dev-io.c |    5 +----
 1 files changed, 1 insertions(+), 4 deletions(-)

diff --git a/lib/device/dev-io.c b/lib/device/dev-io.c
index 2a83a96..6996a44 100644
--- a/lib/device/dev-io.c
+++ b/lib/device/dev-io.c
@@ -572,10 +572,7 @@ int dev_open_flags(struct device *dev, int flags, int direct, int quiet)
 			}
 		}
 #endif
-		if (quiet)
-			log_sys_debug("open", name);
-		else
-			log_sys_error("open", name);
+		log_sys_debug("open", name);
 
 		dev->flags |= DEV_OPEN_FAILURE;
 		return 0;


