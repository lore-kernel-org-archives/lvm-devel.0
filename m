From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 21 Dec 2012 10:17:42 +0000 (UTC)
Subject: master - pvscan: synchronize with udev if pvscan --cache is used.
Message-ID: <20121221101743.095EAAABEF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ad85b0c526b40a4e78ac83426f54c935c147c787
Commit:        ad85b0c526b40a4e78ac83426f54c935c147c787
Parent:        756bcabbfe297688ba240a880bc2b55265ad33f0
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Dec 21 10:54:31 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Dec 21 11:15:46 2012 +0100

pvscan: synchronize with udev if pvscan --cache is used.

We need to call sync_local_dev_names directly as pvscan uses
VG_GLOBAL lock and this one *does not* cause the synchronization
(sync_dev_names) to be called on unlock (VG_GLOBAL is not a real VG):

define unlock_vg(cmd, vol)
  do { \
    if (is_real_vg(vol)) \
      sync_dev_names(cmd); \
    (void) lock_vol(cmd, vol, LCK_VG_UNLOCK); \
  } while (0)

Without this fix, we end up without udev synchronization for the
pvscan --cache (mainly for -aay that causes the VGs/LVs to be
autoactivated) and also udev synchronization cookies are then left
in the system since they're not managed properly (code before sets
up udev sync cookies, but we have to call dm_udev_wait at least once
after that to do the wait and cleanup).
---
 WHATS_NEW      |    1 +
 tools/pvscan.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5ac3090..5b81d52 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Synchronize with udev in pvscan --cache and fix dangling udev_sync cookies.
   Fix autoactivation to not autoactivate VG/LV on each change of the PVs used.
   Limit RAID device replacement to repair only if LV is not in-sync.
   Disallow RAID device replacement or repair on inactive LVs.
diff --git a/tools/pvscan.c b/tools/pvscan.c
index c2e6f5c..1e844c5 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -241,6 +241,7 @@ static int _pvscan_lvmetad(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 out:
+	sync_local_dev_names(cmd);
 	unlock_vg(cmd, VG_GLOBAL);
 
 	return ret;


