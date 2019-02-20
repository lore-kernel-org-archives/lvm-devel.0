From: David Teigland <teigland@sourceware.org>
Date: Wed, 20 Feb 2019 17:47:00 -0500
Subject: stable-2.02 - config: change scan_lvs default to 0
Message-ID: <201902202247.x1KMl0dJ005055@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=427e8ba3e3186e291ff26f014003d149da6ec2a8
Commit:        427e8ba3e3186e291ff26f014003d149da6ec2a8
Parent:        6a5575e9597c50a7ebc89895de154db3fa13d753
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 20 14:31:03 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 20 14:31:03 2019 -0600

config: change scan_lvs default to 0

so that lvm does not scan LVs for PVs by default.
---
 lib/config/defaults.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 12d8e1d..7a5d365 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -267,6 +267,6 @@
 #define DEFAULT_THIN_POOL_AUTOEXTEND_THRESHOLD 100
 #define DEFAULT_THIN_POOL_AUTOEXTEND_PERCENT 20
 
-#define DEFAULT_SCAN_LVS 1
+#define DEFAULT_SCAN_LVS 0
 
 #endif				/* _LVM_DEFAULTS_H */


