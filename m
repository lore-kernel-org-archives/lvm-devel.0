From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 28 Apr 2014 10:43:41 +0000 (UTC)
Subject: master - display: show monitoring status
Message-ID: <20140428104341.41BBD60D59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=91a8e4a3d8198990ddffcfa9916ba22dcb0c033d
Commit:        91a8e4a3d8198990ddffcfa9916ba22dcb0c033d
Parent:        e6168b8d70935004e38bc2f1ac9d57cc0bf6df10
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 28 11:53:56 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 28 12:39:03 2014 +0200

display: show monitoring status

When displaying segments  (lvdisplay --maps)
show monitoring status when supported by segment.
---
 WHATS_NEW             |    1 +
 lib/display/display.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index cd649da..de9ef23 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Display monitoring status for monitorable segments in 'lvdisplay --maps'.
   Display virtual extents for virtual LVs in 'lvdisplay --maps'.
   Make vgsplit fail cleanly when not all PVs are specified for RAID 4/5/6.
   Make vgsplit work on mirrors with logs that share PVs with images.
diff --git a/lib/display/display.c b/lib/display/display.c
index a34d947..d824150 100644
--- a/lib/display/display.c
+++ b/lib/display/display.c
@@ -667,6 +667,10 @@ int lvdisplay_segments(const struct logical_volume *lv)
 
 		log_print("  Type\t\t%s", seg->segtype->ops->name(seg));
 
+		if (seg->segtype->ops->target_monitored)
+			log_print("  Monitoring\t\t%s",
+				  lvseg_monitor_dup(lv->vg->cmd->mem, seg));
+
 		if (seg->segtype->ops->display)
 			seg->segtype->ops->display(seg);
 	}


