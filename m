From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 28 Jul 2010 11:15:58 +0200
Subject: [PATCH 12/14] log_debug event_nr
In-Reply-To: <cover.1280307502.git.zkabelac@redhat.com>
References: <cover.1280307502.git.zkabelac@redhat.com>
Message-ID: <8f084351b0002931cef7c2a46704897c6a4c9232.1280307502.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/ioctl/libdm-iface.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index bbe1de4..3f8ffe9 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1870,7 +1870,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 	}
 
 	log_debug("dm %s %s %s%s%s %s%.0d%s%.0d%s"
-		  "%s%c%c%s%s %.0" PRIu64 " %s [%u]",
+		  "%s%c%c%s%s %.0" PRIu64 " %s [%u] en=0x%x",
 		  _cmd_data_v4[dmt->type].name,
 		  dmi->name, dmi->uuid, dmt->newname ? " " : "",
 		  dmt->newname ? dmt->newname : "",
@@ -1885,7 +1885,8 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 		  dmt->skip_lockfs ? "S " : "",
 		  dmt->query_inactive_table ? "I " : "",
 		  dmt->sector, _sanitise_message(dmt->message),
-		  dmi->data_size);
+		  dmi->data_size,
+		  dmi->event_nr);
 #ifdef DM_IOCTLS
 	if (ioctl(_control_fd, command, dmi) < 0) {
 		if (errno == ENXIO && ((dmt->type == DM_DEVICE_INFO) ||
-- 
1.7.2


