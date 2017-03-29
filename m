From: Bryn Reeves <bmr@sourceware.org>
Date: Wed, 29 Mar 2017 16:41:36 -0400
Subject: master - libdm: use log_sys_error if dmfilemapd exec fails
Message-ID: <201703292041.v2TKfamc003574@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b3d71212fb07c945acebb074820a63e970504e5
Commit:        4b3d71212fb07c945acebb074820a63e970504e5
Parent:        5994ed9df218d4201415855b9bd6defa6f371c74
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Mar 29 21:27:11 2017 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Mar 29 21:38:15 2017 +0100

libdm: use log_sys_error if dmfilemapd exec fails

Use log_sys_error rather than log_error if execvp() fails:

  /mnt/redhat/xdoio.13752.XIORQ: Created new group with 2 region(s) as group ID 0.
  # execvp() failed.

vs:

  /var/lib/libvirt/images/rhel7-vm1.qcow2: Created new group with 884 region(s) as group ID 0.
  dmfilemapd: execvp failed: No such file or directory
---
 libdm/libdm-stats.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index 3e2983d..290097f 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -5032,7 +5032,7 @@ int dm_stats_start_filemapd(int fd, uint64_t group_id, const char *path,
 	}
 
 	execvp(args[0], args);
-	log_error("execvp() failed.");
+	log_sys_error("execvp", args[0]);
 	if (!foreground)
 		_exit(127);
 	return 0;


