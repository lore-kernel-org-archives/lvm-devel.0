From: David Teigland <teigland@sourceware.org>
Date: Wed, 20 Feb 2019 15:05:20 -0500
Subject: master - config: change scan_lvs default to 0
Message-ID: <201902202005.x1KK5K48011319@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7be6791e707da333e56aea3cc50c079ab6207bad
Commit:        7be6791e707da333e56aea3cc50c079ab6207bad
Parent:        0aa51a2f6129bf05d9897894a7abae627f05ce45
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 20 13:30:46 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Feb 20 13:30:46 2019 -0600

config: change scan_lvs default to 0

so that lvm does not scan LVs for PVs by default.
---
 lib/config/defaults.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 06a5ecf..cb013c6 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -310,7 +310,7 @@
 #define DEFAULT_VDO_POOL_AUTOEXTEND_THRESHOLD 100
 #define DEFAULT_VDO_POOL_AUTOEXTEND_PERCENT 20
 
-#define DEFAULT_SCAN_LVS 1
+#define DEFAULT_SCAN_LVS 0
 
 #define DEFAULT_HINTS "all"
 


