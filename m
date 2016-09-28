From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 28 Sep 2016 18:31:38 +0000 (UTC)
Subject: master - lvmlockd: fix segfault in error path
Message-ID: <20160928183138.133FC60721@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=49a1c4d4b0f2c5fbc83a1ad4bfde59a366049b2a
Commit:        49a1c4d4b0f2c5fbc83a1ad4bfde59a366049b2a
Parent:        bd96036835e088de6a59811834b5fa0747274a62
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Sep 28 13:29:55 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Sep 28 13:29:55 2016 -0500

lvmlockd: fix segfault in error path

The log_debug statement was ignoring the NULL vg error case.
---
 lib/cache/lvmetad.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmetad.c b/lib/cache/lvmetad.c
index 727d3d3..8e9bb1f 100644
--- a/lib/cache/lvmetad.c
+++ b/lib/cache/lvmetad.c
@@ -2061,7 +2061,8 @@ scan_more:
 		dm_config_destroy(vgmeta_ret);
 	}
 out:
-	log_debug_lvmetad("Rescan VG %s done (seqno %u).", vg_ret->name, vg_ret->seqno);
+	if (vg_ret)
+		log_debug_lvmetad("Rescan VG %s done (seqno %u).", vg_ret->name, vg_ret->seqno);
 	return vg_ret;
 }
 


