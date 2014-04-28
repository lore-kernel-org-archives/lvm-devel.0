From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 28 Apr 2014 10:43:43 +0000 (UTC)
Subject: master - thin: display info when -tpool is running
Message-ID: <20140428104343.6A11360D59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=71314a9905eb5f515aa15af5de2a1f73d82b5ae3
Commit:        71314a9905eb5f515aa15af5de2a1f73d82b5ae3
Parent:        91a8e4a3d8198990ddffcfa9916ba22dcb0c033d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 28 11:50:38 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 28 12:40:17 2014 +0200

thin: display info when -tpool is running

For percentage display we need -tpool - so check for layered
device presence here instead of plain pool device.
Also update 'info' - so when pool is 'available' we
display open count for -tpool device instead of mostly
irrelevant pool.
TODO: Maybe we should actually display this open info always?
(even when just -tpool is available, but pool is not)
---
 WHATS_NEW             |    1 +
 lib/display/display.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index de9ef23..4d4640f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Display thin pool usage even when just thin volume is available.
   Display monitoring status for monitorable segments in 'lvdisplay --maps'.
   Display virtual extents for virtual LVs in 'lvdisplay --maps'.
   Make vgsplit fail cleanly when not all PVs are specified for RAID 4/5/6.
diff --git a/lib/display/display.c b/lib/display/display.c
index d824150..83fb901 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -525,7 +525,7 @@ int lvdisplay_full(struct cmd_context *cmd,
 			log_print("LV merged with         %s",
 				  find_snapshot(lv)->lv->name);
 	} else if (lv_is_thin_pool(lv)) {
-		if (inkernel) {
+		if (lv_info(cmd, lv, 1, &info, 1, 1) && info.exists) {
 			thin_data_active = lv_thin_pool_percent(lv, 0, &thin_data_percent);
 			thin_metadata_active = lv_thin_pool_percent(lv, 1, &thin_metadata_percent);
 		}


