From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:08:54 +0000 (UTC)
Subject: master - pv_write: check for lvmcache_add_mda failure
Message-ID: <20131122200854.AACB960EE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d3b8bfd1c7cc22383580b2723415ddcf9fbe7d7
Commit:        3d3b8bfd1c7cc22383580b2723415ddcf9fbe7d7
Parent:        a50a297f6e75d650abe9fe084b499a7968cc59ee
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 13:25:27 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 20:55:09 2013 +0100

pv_write: check for lvmcache_add_mda failure

Add missing test of failing lvmcache_add_mda() call.
---
 WHATS_NEW                     |    1 +
 lib/format_text/format-text.c |    6 ++++--
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 99f9067..41251b8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Check for failure of lvmcache_add_mda() when writing pv.
   Check for failure of dev_get_size() when reporting device size.
   Drop extra unneeded '/' when scanning sysfs directory.
   Fix undef value if skipped clustered VG ignored for toollib PV seg. (2.02.103)
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index e67d24d..275d16f 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1328,8 +1328,10 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 				   mdac->area.size >> SECTOR_SHIFT);
 
 		// if fmt is not the same as info->fmt we are in trouble
-		lvmcache_add_mda(info, mdac->area.dev,
-				 mdac->area.start, mdac->area.size, mda_is_ignored(mda));
+		if (!lvmcache_add_mda(info, mdac->area.dev,
+				      mdac->area.start, mdac->area.size,
+				      mda_is_ignored(mda)))
+			return_0;
 	}
 
 	if (!lvmcache_update_bas(info, pv))


