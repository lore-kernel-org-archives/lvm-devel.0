From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 23 Apr 2015 18:27:30 +0000 (UTC)
Subject: master - libdm: Add uuid/devno to ioctl failure log message.
Message-ID: <20150423182730.7C7FF60F63@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=88534625282e8d533ae439ed308a285da10e3ef0
Commit:        88534625282e8d533ae439ed308a285da10e3ef0
Parent:        19066191877029a1fe376a7d4a657e0dba1dd13d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 23 19:26:52 2015 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 23 19:26:52 2015 +0100

libdm: Add uuid/devno to ioctl failure log message.

---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |   20 +++++++++++++++++---
 2 files changed, 18 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index c6a1619..cead126 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.96 - 
 =================================
+  Include uuid or device number in log message after ioctl failure.
   Add DM_INTERNAL_SUSPEND_FLAG to dm-ioctl.h.
   Install blkdeactivate script and its man page with make install_device-mapper.
 
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index f971519..1f301f9 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1802,15 +1802,29 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 			dmi->flags &= ~DM_EXISTS_FLAG;	/* FIXME */
 		else {
 			if (_log_suppress || errno == EINTR)
-				log_verbose("device-mapper: %s ioctl "
+				log_verbose("device-mapper: %s ioctl on %s%s%s%.0d%s%.0d%s%s "
 					    "failed: %s",
 				    	    _cmd_data_v4[dmt->type].name,
+					    dmi->name, dmi->uuid, 
+					    dmt->major > 0 ? "(" : "",
+					    dmt->major > 0 ? dmt->major : 0,
+					    dmt->major > 0 ? ":" : "",
+					    dmt->minor > 0 ? dmt->minor : 0,
+					    dmt->major > 0 && dmt->minor == 0 ? "0" : "",
+					    dmt->major > 0 ? ")" : "",
 					    strerror(errno));
 			else
-				log_error("device-mapper: %s ioctl on %s "
+				log_error("device-mapper: %s ioctl on %s%s%s%.0d%s%.0d%s%s "
 					  "failed: %s",
 					  _cmd_data_v4[dmt->type].name,
-					  dmi->name, strerror(errno));
+					  dmi->name, dmi->uuid, 
+					  dmt->major > 0 ? "(" : "",
+					  dmt->major > 0 ? dmt->major : 0,
+					  dmt->major > 0 ? ":" : "",
+					  dmt->minor > 0 ? dmt->minor : 0,
+					  dmt->major > 0 && dmt->minor == 0 ? "0" : "",
+					  dmt->major > 0 ? ")" : "",
+					  strerror(errno));
 
 			/*
 			 * It's sometimes worth retrying after EBUSY in case


