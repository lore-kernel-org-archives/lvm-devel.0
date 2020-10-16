From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Oct 2020 19:12:08 +0000 (GMT)
Subject: stable-2.02 - debug: show actually reason for taking this code path
Message-ID: <20201016191208.1FEAC396EC9B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b97440290c952c33e32f86f7d4b0e47ed6e30d4d
Commit:        b97440290c952c33e32f86f7d4b0e47ed6e30d4d
Parent:        03bddd7d41bc644dfe6498c3b2d0d412190f2e5e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 2 11:12:49 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 16 18:09:55 2020 +0200

debug: show actually reason for taking this code path

Instead of not so useful backtrace, report what was the reason.
---
 lib/format_text/format-text.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 225d6424c..20eeb0854 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -2075,8 +2075,10 @@ static int _create_vg_text_instance(struct format_instance *fid,
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


