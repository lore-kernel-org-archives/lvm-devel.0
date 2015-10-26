From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 Oct 2015 06:39:12 +0000 (UTC)
Subject: master - libdm: enable no_flush for driver version > 11
Message-ID: <20151026063912.5586460EE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=428ca9b1207eba53ffc721bd9e528a1a148128c2
Commit:        428ca9b1207eba53ffc721bd9e528a1a148128c2
Parent:        f898cf7539149a54a121b0aae59076c2d647bb37
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 26 07:37:59 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 26 07:37:59 2015 +0100

libdm: enable no_flush for driver version > 11

It appears the driver version 11 has troubles with usage of no_flush
So require at least version 12.
---
 libdm/ioctl/libdm-iface.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 58a8dfe..2a36b77 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1202,8 +1202,13 @@ static struct dm_ioctl *_flatten(struct dm_task *dmt, unsigned repeat_count)
 
 	if (dmt->type == DM_DEVICE_SUSPEND)
 		dmi->flags |= DM_SUSPEND_FLAG;
-	if (dmt->no_flush)
-		dmi->flags |= DM_NOFLUSH_FLAG;
+	if (dmt->no_flush) {
+		if (_dm_version_minor < 12)
+			log_verbose("No flush flag unsupported by kernel. "
+				    "Buffers will be flushed.");
+		else
+			dmi->flags |= DM_NOFLUSH_FLAG;
+	}
 	if (dmt->read_only)
 		dmi->flags |= DM_READONLY_FLAG;
 	if (dmt->skip_lockfs)


