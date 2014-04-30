From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 30 Apr 2014 08:27:50 +0000 (UTC)
Subject: master - display: check for dmeventd support
Message-ID: <20140430082750.C230A60EB6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=517b0026481d29d31524e472efbdc99e945c9c12
Commit:        517b0026481d29d31524e472efbdc99e945c9c12
Parent:        b1f765d72aa56dab547a819447371b5315e78455
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 30 10:13:35 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 30 10:26:26 2014 +0200

display: check for dmeventd support

When quering for dmeventd monitoring status, check first
if lvm2 is configured to monitor to avoid unwanted start
of dmeventd process for answering monitoring status.
---
 WHATS_NEW         |    1 +
 lib/metadata/lv.c |    3 ++-
 2 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bb5b4c3..456f132 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.107 - 
 ==================================
+  Don't start dmeventd checking seg_monitor and monitoring is disabled.
   Catch CTRL-c during pvremove prompts.
   Show correct availability status for snapshot origin in lvscan.
   Move segment thin pool/volume info into segment display 'lvdisplay --maps'.
diff --git a/lib/metadata/lv.c b/lib/metadata/lv.c
index 8445d16..0225704 100644
--- a/lib/metadata/lv.c
+++ b/lib/metadata/lv.c
@@ -146,7 +146,8 @@ char *lvseg_monitor_dup(struct dm_pool *mem, const struct lv_segment *seg)
 		segm = first_seg(seg->log_lv);
 
 	// log_debug("Query LV:%s mon:%s segm:%s tgtm:%p  segmon:%d statusm:%d", seg->lv->name, segm->lv->name, segm->segtype->name, segm->segtype->ops->target_monitored, seg_monitored(segm), (int)(segm->status & PVMOVE));
-	if (!segm->segtype->ops->target_monitored)
+	if ((dmeventd_monitor_mode() != 1) ||
+	    !segm->segtype->ops->target_monitored)
 		/* Nothing to do, monitoring not supported */;
 	else if (lv_is_cow_covering_origin(seg->lv))
 		/* Nothing to do, snapshot already covers origin */;


