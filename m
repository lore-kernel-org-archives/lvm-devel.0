From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 12 Oct 2012 09:59:46 +0000 (UTC)
Subject: master - libdm: remove dm dev without error even with malformed UUID
Message-ID: <20121012095946.E0579A0D9C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=abb07a1b5ee2bbe4def9218c6fdf05b0a5718e12
Commit:        abb07a1b5ee2bbe4def9218c6fdf05b0a5718e12
Parent:        5a958655ddd63a7e9feeda444788313f9380aef1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Oct 12 11:53:04 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Oct 12 11:53:04 2012 +0200

libdm: remove dm dev without error even with malformed UUID

On each ioctl return, the device UUID is decoded from \xNN format.
If the UUID of the device being *removed* is malformed (e.g. it
hasn't been corrected before), just remove it without any error
as the UUID is not needed anymore - the device is gone anyway.

Otherwise a misleading error message would be issued just after
the removal:
  # dmsetup remove test
  The UUID "a b" should be mangled but it contains blacklisted characters.
  Command failed
---
 libdm/ioctl/libdm-iface.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index 3b6731d..9e78e1c 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -1762,7 +1762,8 @@ static struct dm_ioctl *_do_dm_ioctl(struct dm_task *dmt, unsigned command,
 	if (!_dm_ioctl_unmangle_names(dmt->type, dmi))
 		goto error;
 
-	if (!_dm_ioctl_unmangle_uuids(dmt->type, dmi))
+	if (dmt->type != DM_DEVICE_REMOVE &&
+	    !_dm_ioctl_unmangle_uuids(dmt->type, dmi))
 		goto error;
 
 #else /* Userspace alternative for testing */


