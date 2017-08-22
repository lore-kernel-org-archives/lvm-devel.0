From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Aug 2017 04:34:16 -0400
Subject: master - debug: add stack trace point
Message-ID: <201708220834.v7M8YGZJ031161@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=539a48a328a7ddd1030dd5809a2f9f0df6c1fe70
Commit:        539a48a328a7ddd1030dd5809a2f9f0df6c1fe70
Parent:        c1e3f96c9764b242898914c282fb273803ba89ae
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 22 10:19:52 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 22 10:23:31 2017 +0200

debug: add stack trace point

---
 lib/cache/lvmetad.c       |    2 +-
 libdm/ioctl/libdm-iface.c |    4 ++--
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 2e0ee51..1ba844f 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1281,7 +1281,7 @@ int lvmetad_vg_update_finish(struct volume_group *vg)
 		if (pvl->pv->dev && !lvmetad_pv_found(vg->cmd, &pvl->pv->id, pvl->pv->dev,
 						      vgu->fid ? vgu->fid->fmt : pvl->pv->fmt,
 						      pvl->pv->label_sector, NULL, NULL, NULL))
-			return 0;
+			return_0;
 	}
 
 	vg->lvmetad_update_pending = 0;
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 63d305b..100d0cc 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -273,7 +273,7 @@ static int _create_control(const char *control, uint32_t major, uint32_t minor)
 	 */
 	ret = _control_exists(control, major, minor);
 	if (ret == -1)
-		return 0;	/* Failed to unlink existing incorrect node */
+		return_0;	/* Failed to unlink existing incorrect node */
 	if (ret)
 		return 1;	/* Already exists and correct */
 
@@ -284,7 +284,7 @@ static int _create_control(const char *control, uint32_t major, uint32_t minor)
 	(void) dm_prepare_selinux_context(NULL, 0);
 
 	if (!ret)
-		return 0;
+		return_0;
 
 	log_verbose("Creating device %s (%u, %u)", control, major, minor);
 


