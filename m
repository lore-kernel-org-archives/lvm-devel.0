From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 29 Oct 2015 11:39:50 +0000 (UTC)
Subject: master - cleanup: error is not a WARNING
Message-ID: <20151029113950.0494F60E62@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f58c63410327c2bc49b671df4538dee9e90e577d
Commit:        f58c63410327c2bc49b671df4538dee9e90e577d
Parent:        175119fdcd1a8eb23011e4c25d0df5899dfc42ea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Oct 29 12:18:40 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 29 12:38:59 2015 +0100

cleanup: error is not a WARNING

Drop 'WARNING' from error message.
It's plain error message leading to command failure.
---
 lib/cache/lvmetad.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index c7f6ecb..683c87c 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -1331,7 +1331,7 @@ int lvmetad_pvscan_single(struct cmd_context *cmd, struct device *dev,
 			log_warn("WARNING: Ignoring obsolete format of metadata (%s) on device %s when using lvmetad",
 				  baton.fid->fmt->name, dev_name(dev));
 		else
-			log_error("WARNING: Ignoring obsolete format of metadata (%s) on device %s when using lvmetad",
+			log_error("Ignoring obsolete format of metadata (%s) on device %s when using lvmetad.",
 				  baton.fid->fmt->name, dev_name(dev));
 		lvmcache_fmt(info)->ops->destroy_instance(baton.fid);
 


