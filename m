From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 21 Jan 2015 12:54:33 +0000 (UTC)
Subject: master - dmeventd: Reduce waitevent EINTR message severity.
Message-ID: <20150121125433.6302360CD7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=25d906dbde45bc64c5a0978e40c810b3b070cb0d
Commit:        25d906dbde45bc64c5a0978e40c810b3b070cb0d
Parent:        7cfc9a4f640296679f2b860842cc8b25b82fd30f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Jan 21 12:54:00 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Jan 21 12:54:00 2015 +0000

dmeventd: Reduce waitevent EINTR message severity.

---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 0a59875..8cbb6b6 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.93 -
 ====================================
+  Reduce severity of ioctl error message when dmeventd waitevent is interrupted.
   Report 'unknown version' when incompatible version numbers were not obtained.
   Report more info from thin pool status (out of data, metadata-ro, fail).
   Support error_if_no_space for thin pool target.
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index f8b4ed9..f971519 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1801,7 +1801,7 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 				       (dmt->type == DM_DEVICE_STATUS)))
 			dmi->flags &= ~DM_EXISTS_FLAG;	/* FIXME */
 		else {
-			if (_log_suppress)
+			if (_log_suppress || errno == EINTR)
 				log_verbose("device-mapper: %s ioctl "
 					    "failed: %s",
 				    	    _cmd_data_v4[dmt->type].name,


