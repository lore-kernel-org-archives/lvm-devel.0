From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 18 Sep 2013 00:26:29 +0000 (UTC)
Subject: master - libdm: avoid leak if dm_task_set_* fn called again
Message-ID: <20130918002629.F289D6119B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a0ca2c11ee69b51a99644955cb4daa8ca50c8034
Commit:        a0ca2c11ee69b51a99644955cb4daa8ca50c8034
Parent:        a3a5f58c21edba308dd8ced15860e52b5b902890
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Sep 18 01:13:06 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Sep 18 01:13:06 2013 +0100

libdm: avoid leak if dm_task_set_* fn called again

(Mikulas)
---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |    3 +++
 libdm/libdm-common.c      |    1 +
 3 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index f5d7dc2..252f105 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.80 - 
 ==================================
+  Free any previously-set string if a dm_task_set_* function is called again.
   Do not allow passing empty new name for dmsetup rename.
   Display any output returned by 'dmsetup message'.
   Add dm_task_get_message_response to libdevmapper.
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index b0a2228..c530bb7 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -785,6 +785,7 @@ int dm_task_set_newuuid(struct dm_task *dmt, const char *newuuid)
 		newuuid = mangled_uuid;
 	}
 
+	dm_free(dmt->newname);
 	if (!(dmt->newname = dm_strdup(newuuid))) {
 		log_error("dm_task_set_newuuid: strdup(%s) failed", newuuid);
 		return 0;
@@ -796,6 +797,7 @@ int dm_task_set_newuuid(struct dm_task *dmt, const char *newuuid)
 
 int dm_task_set_message(struct dm_task *dmt, const char *message)
 {
+	dm_free(dmt->message);
 	if (!(dmt->message = dm_strdup(message))) {
 		log_error("dm_task_set_message: strdup failed");
 		return 0;
@@ -814,6 +816,7 @@ int dm_task_set_sector(struct dm_task *dmt, uint64_t sector)
 int dm_task_set_geometry(struct dm_task *dmt, const char *cylinders, const char *heads,
 			 const char *sectors, const char *start)
 {
+	dm_free(dmt->geometry);
 	if (dm_asprintf(&(dmt->geometry), "%s %s %s %s",
 			cylinders, heads, sectors, start) < 0) {
 		log_error("dm_task_set_geometry: sprintf failed");
diff --git a/libdm/libdm-common.c b/libdm/libdm-common.c
index c0669cb..b66911c 100644
--- a/libdm/libdm-common.c
+++ b/libdm/libdm-common.c
@@ -720,6 +720,7 @@ int dm_task_set_newname(struct dm_task *dmt, const char *newname)
 		newname = mangled_name;
 	}
 
+	dm_free(dmt->newname);
 	if (!(dmt->newname = dm_strdup(newname))) {
 		log_error("dm_task_set_newname: strdup(%s) failed", newname);
 		return 0;


