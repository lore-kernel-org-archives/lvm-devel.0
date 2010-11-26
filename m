From: Dave Wysochanski <wysochanski@pobox.com>
Date: Fri, 26 Nov 2010 11:31:10 -0500
Subject: [PATCH 1/2] Update WHATS_NEW for lvm2app updates.
In-Reply-To: <1290789071-8458-1-git-send-email-wysochanski@pobox.com>
References: <1290789071-8458-1-git-send-email-wysochanski@pobox.com>
Message-ID: <1290789071-8458-2-git-send-email-wysochanski@pobox.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Dave Wysochanski <wysochanski@pobox.com>
---
 WHATS_NEW |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2f6e445..98d11b8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,7 @@
 Version 2.02.78 - 
 ====================================
+  Add lvm2app helper functions to lookup an lv or pv handle by uuid or name.
+  Fix seg_size lvm2app property to return bytes.
   Certain lvconvert invocations are now required to be done in two steps.
   Fix missing context desctruction in err path of lvm1 fallback in lvm2_main().
   Fix memory leak in error path of parse_loop_device_name() from dmsetup.
-- 
1.7.2.2


