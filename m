From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  8 May 2015 22:14:35 +0000 (UTC)
Subject: master - lvmcache: set device in label when switching devs V2
Message-ID: <20150508221435.DCC166108C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=be23fae488b7df19147259d3e8505fc8301076cd
Commit:        be23fae488b7df19147259d3e8505fc8301076cd
Parent:        ca67cf84df6015c990618de3dc45c0b87eee75ce
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 8 17:10:53 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 8 17:10:53 2015 -0500

lvmcache: set device in label when switching devs V2

This is an alternative/equivalent to commit
ca67cf84df6015c990618de3dc45c0b87eee75ce

The problem (wrong label->dev after a new preferred
duplicate device is chosen) was isolated to the lvmetad
case (non-lvmetad worked fine), and this fixes the problem
by setting the new label->dev in the lvmetad-specific
code rather than in the general lvmcache code.
---
 lib/cache/lvmcache.c |    1 -
 lib/cache/lvmetad.c  |    1 +
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index ad58115..d44f9d4 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1880,7 +1880,6 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 			info->label->info = info;
 		}
 		label = info->label;
-		label->dev = dev;
 	}
 
 	info->fmt = labeller->fmt;
diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 0a79c50..a66f915 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -372,6 +372,7 @@ static int _pv_populate_lvmcache(struct cmd_context *cmd,
 							   vgname, (const char *)&vgid, 0))) {
 				dev_alternate_cache = dev_alternate;
 				info = info_alternate;
+				lvmcache_get_label(info)->dev = dev_alternate;
 			}
 		} else {
 			log_warn("Duplicate of PV %s dev %s exists on unknown device %"PRId64 ":%" PRId64,


