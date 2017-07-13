From: Alasdair Kergon <agk@sourceware.org>
Date: Thu, 13 Jul 2017 12:10:15 -0400
Subject: master - format_text: Extend FIXME to reduce label scans
Message-ID: <201707131610.v6DGAFKU014161@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5027c3c7eea0791a9a80b0622b43c8a493e2a8a7
Commit:        5027c3c7eea0791a9a80b0622b43c8a493e2a8a7
Parent:        c2de4b9747fcaf4c3735dc68318a28c80a939374
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jul 13 17:05:49 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jul 13 17:05:49 2017 +0100

format_text: Extend FIXME to reduce label scans

It's unnecessarily scanning all invalid labels even when nothing changed
instead of first just scanning the ones under the lock.
---
 lib/format_text/format-text.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 5d731ca..9e99c85 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2002,6 +2002,9 @@ static int _create_vg_text_instance(struct format_instance *fid,
 			 */
 			if (!critical_section())
 				/* Scan PVs in VG for any further MDAs */
+				/*
+				 * FIXME Only scan PVs believed to be in the VG.
+ 				 */
 				lvmcache_label_scan(fid->fmt->cmd);
 
 			if (!(vginfo = lvmcache_vginfo_from_vgname(vg_name, vg_id)))
@@ -2010,7 +2013,7 @@ static int _create_vg_text_instance(struct format_instance *fid,
 				goto_out;
 		}
 
-		/* FIXME Check raw metadata area count - rescan if required */
+		/* FIXME If PV list or raw metadata area count are not as expected rescan */
 	}
 
 out:


