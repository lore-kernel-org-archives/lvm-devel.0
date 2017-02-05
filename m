From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  5 Feb 2017 16:56:45 +0000 (UTC)
Subject: master - debug: add space before uuid
Message-ID: <20170205165645.5BA0E60C86@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9fe8c2da36a42a9cf08ef44ede172e1341033a24
Commit:        9fe8c2da36a42a9cf08ef44ede172e1341033a24
Parent:        12bbfbe89de5201f89ebad372ddd5f393142b13a
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Feb 5 17:30:23 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Feb 5 17:55:37 2017 +0100

debug: add space before uuid

With commit 88534625282e8d533ae439ed308a285da10e3ef0 we added
uuid right after device name. Add space between them.
(Also fix some indenting)
---
 libdm/ioctl/libdm-iface.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 390daa1..cb3e8dc 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1851,10 +1851,10 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 			dmi->flags &= ~DM_EXISTS_FLAG;	/* FIXME */
 		else {
 			if (_log_suppress || dmt->ioctl_errno == EINTR)
-				log_verbose("device-mapper: %s ioctl on %s%s%s%.0d%s%.0d%s%s "
+				log_verbose("device-mapper: %s ioctl on %s %s%s%.0d%s%.0d%s%s "
 					    "failed: %s",
-				    	    _cmd_data_v4[dmt->type].name,
-					    dmi->name, dmi->uuid, 
+					    _cmd_data_v4[dmt->type].name,
+					    dmi->name, dmi->uuid,
 					    dmt->major > 0 ? "(" : "",
 					    dmt->major > 0 ? dmt->major : 0,
 					    dmt->major > 0 ? ":" : "",
@@ -1863,10 +1863,10 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 					    dmt->major > 0 ? ")" : "",
 					    strerror(dmt->ioctl_errno));
 			else
-				log_error("device-mapper: %s ioctl on %s%s%s%.0d%s%.0d%s%s "
+				log_error("device-mapper: %s ioctl on %s %s%s%.0d%s%.0d%s%s "
 					  "failed: %s",
 					  _cmd_data_v4[dmt->type].name,
-					  dmi->name, dmi->uuid, 
+					  dmi->name, dmi->uuid,
 					  dmt->major > 0 ? "(" : "",
 					  dmt->major > 0 ? dmt->major : 0,
 					  dmt->major > 0 ? ":" : "",


