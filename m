From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri,  2 Oct 2020 20:28:00 +0000 (GMT)
Subject: master - debug: show actually reason for taking this code path
Message-ID: <20201002202800.2FD1C398E4BE@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1b8c6f09bcba1996892a231bc6c25be6ac40d808
Commit:        1b8c6f09bcba1996892a231bc6c25be6ac40d808
Parent:        e1af80c81c2c196ccc2e2a3f45e56cd1abc0dd45
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 11:12:49 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 2 21:04:16 2020 +0200

debug: show actually reason for taking this code path

Instead of not so useful backtrace, report what was the reason.
---
 lib/format_text/format-text.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 0de881b67..e1142c07e 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2216,8 +2216,10 @@ static int _create_vg_text_instance(struct format_instance *fid,
 		}
 
 		if (type & FMT_INSTANCE_MDAS) {
-			if (!(vginfo = lvmcache_vginfo_from_vgname(vg_name, vg_id)))
-				goto_out;
+			if (!(vginfo = lvmcache_vginfo_from_vgname(vg_name, vg_id))) {
+				log_debug("No cached vginfo for VG %s and ID %s.", vg_name, vg_id);
+				goto out;
+			}
 			if (!lvmcache_fid_add_mdas_vg(vginfo, fid))
 				goto_out;
 		}


