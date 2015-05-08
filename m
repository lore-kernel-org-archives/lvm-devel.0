From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  8 May 2015 19:41:15 +0000 (UTC)
Subject: master - lvmcache: set device in label when switching devs
Message-ID: <20150508194115.D228360E5E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca67cf84df6015c990618de3dc45c0b87eee75ce
Commit:        ca67cf84df6015c990618de3dc45c0b87eee75ce
Parent:        53aff9322e6be8f805688445fb7d7d8825d53692
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri May 8 14:38:26 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 8 14:41:05 2015 -0500

lvmcache: set device in label when switching devs

When using lvmetad, the reporter code was not reporting
the new preferred device because the new preferred dev
was not being set in the label struct.
---
 lib/cache/lvmcache.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index d44f9d4..ad58115 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -1880,6 +1880,7 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller, const char *pvid,
 			info->label->info = info;
 		}
 		label = info->label;
+		label->dev = dev;
 	}
 
 	info->fmt = labeller->fmt;


