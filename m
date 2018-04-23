From: David Teigland <teigland@sourceware.org>
Date: Mon, 23 Apr 2018 09:52:00 -0400
Subject: master - clvm: fix bcache scan handling
Message-ID: <201804231352.w3NDq0eN032721@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ddb5de7a98af5e354013a07c61e46636b9ec01e6
Commit:        ddb5de7a98af5e354013a07c61e46636b9ec01e6
Parent:        196579af1f7ebe25c0266043c7d966b344699d5d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Mar 1 12:43:29 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 20 11:22:48 2018 -0500

clvm: fix bcache scan handling

We can't let clvmd keep all scanned devs open,
which prevents them from being removed.  So
drop the bcache data (and close fds) affter
doing a label scan.

Also set up bcache before the clvm-specific
vg_read (which needs to rescan the vg's devs
using bcache) and destroy the bcache after.
---
 daemons/clvmd/lvm-functions.c |    1 +
 lib/metadata/metadata.c       |    5 +++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index c845e6d..64bdab3 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -665,6 +665,7 @@ int do_refresh_cache(void)
 	init_ignore_suspended_devices(1);
 	lvmcache_force_next_label_scan();
 	lvmcache_label_scan(cmd);
+	label_scan_destroy(cmd); /* destroys bcache (to close devs), keeps lvmcache */
 	dm_pool_empty(cmd->mem);
 
 	pthread_mutex_unlock(&lvm_lock);
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b442451..462c391 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4530,11 +4530,16 @@ static struct volume_group *_vg_read_by_vgid(struct cmd_context *cmd,
 
 	consistent = 0;
 
+	label_scan_setup_bcache();
+
 	if ((vg = _vg_read(cmd, vgname, vgid, warn_flags, &consistent, precommitted))) {
 		/* Does it matter if consistent is 0 or 1? */
+		label_scan_destroy(cmd);
 		return vg;
 	}
 
+	label_scan_destroy(cmd);
+
 	log_debug_metadata("Reading VG by vgid %.8s not found.", vgid);
 	return NULL;
 }


