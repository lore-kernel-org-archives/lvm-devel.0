From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  9 Nov 2015 09:28:43 +0000 (UTC)
Subject: master - toollib: add missing check for lvmcache_init()
Message-ID: <20151109092843.69DBE60661@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=67b4761bc3c53ee67a1fbe33f41757a6563db5cb
Commit:        67b4761bc3c53ee67a1fbe33f41757a6563db5cb
Parent:        164d7e72bfd6fa0564e195d0c0fdf64893566ad6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 9 09:47:21 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 9 10:19:20 2015 +0100

toollib: add missing check for lvmcache_init()

Coverity notices lvmcache_init() may fail so check and
error out in case of failure.
---
 tools/toollib.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 42ac71a..a52252e 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3181,7 +3181,11 @@ int process_each_pv(struct cmd_context *cmd,
 		log_verbose("Some PVs were not found in first search, retrying.");
 
 		lvmcache_destroy(cmd, 0, 0);
-		lvmcache_init();
+		if (!lvmcache_init()) {
+			log_error("Failed to initalize lvm cache.");
+			ret_max = ECMD_FAILED;
+			goto out;
+		}
 		lvmcache_seed_infos_from_lvmetad(cmd);
 
 		ret = _process_pvs_in_vgs(cmd, read_flags, &all_vgnameids, &all_devices,


