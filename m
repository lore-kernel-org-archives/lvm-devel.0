From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed, 19 Feb 2014 16:43:43 +0000 (UTC)
Subject: master - format-text: Avoid a label_scan while in a critical_section().
Message-ID: <20140219164343.9BB4760DAC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b391ae88e5ed3720a8b5a87312e0cd907a94fcc2
Commit:        b391ae88e5ed3720a8b5a87312e0cd907a94fcc2
Parent:        00ce01e52d7fe3a8512d2c5fbe155186638172fd
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Tue Feb 18 17:52:05 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Wed Feb 19 17:43:30 2014 +0100

format-text: Avoid a label_scan while in a critical_section().

---
 lib/format_text/format-text.c |   15 +++++++++++++--
 1 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 6e309a3..6cedc99 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1912,8 +1912,19 @@ static int _create_vg_text_instance(struct format_instance *fid,
 		}
 
 		if (type & FMT_INSTANCE_MDAS) {
-			/* Scan PVs in VG for any further MDAs */
-			lvmcache_label_scan(fid->fmt->cmd, 0);
+			/*
+			 * TODO in theory, this function should be never reached
+			 * while in critical_section(), because lvmcache's
+			 * cached_vg should be valid. However, this assumption
+			 * sometimes fails (possibly due to inconsistent
+			 * (precommit) metadata and/or missing devices), and
+			 * calling lvmcache_label_scan inside the critical
+			 * section may be fatal (i.e. deadlock).
+			 */
+			if (!critical_section())
+				/* Scan PVs in VG for any further MDAs */
+				lvmcache_label_scan(fid->fmt->cmd, 0);
+
 			if (!(vginfo = lvmcache_vginfo_from_vgname(vg_name, vg_id)))
 				goto_out;
 			if (!lvmcache_fid_add_mdas_vg(vginfo, fid))


