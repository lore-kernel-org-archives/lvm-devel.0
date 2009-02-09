From: Dave Wysochanski <dwysocha@redhat.com>
Date: Sun,  8 Feb 2009 23:22:06 -0500
Subject: [PATCH 18/21] Update lvmcache_update_vg to use vgid as well as vgname.
In-Reply-To: <1234153329-2829-18-git-send-email-dwysocha@redhat.com>
References: <1234153329-2829-1-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-2-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-3-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-4-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-5-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-6-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-7-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-8-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-9-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-10-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-11-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-12-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-13-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-14-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-15-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-16-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-17-git-send-email-dwysocha@redhat.com>
	<1234153329-2829-18-git-send-email-dwysocha@redhat.com>
Message-ID: <1234153329-2829-19-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

With duplicate vgnames in a system, vg metadata could get
exported to the wrong lvmcache_vginfo structure.  Use the vg_uuid as
well as the name to lookup the vginfo structure before we store the
metadata.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 lib/cache/lvmcache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d24e9a2..083aab1 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1068,7 +1068,7 @@ int lvmcache_update_vg(struct volume_group *vg, unsigned precommitted)
 
 	/* store text representation of vg to cache */
 	if (vg->cmd->current_settings.cache_vgmetadata &&
-	    (vginfo = vginfo_from_vgname(vg->name, NULL)))
+	    (vginfo = vginfo_from_vgname(vg->name, (char *)&vg->id)))
 		_store_metadata(vginfo, vg, precommitted);
 
 	return 1;
-- 
1.6.0.5


