From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 30 Sep 2019 07:38:35 -0400
Subject: master - vdo: deactivate forgotten vdo pool
Message-ID: <201909301138.x8UBcZet002500@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c813db8fc2ec15a8370bb291f662e15ba26682e8
Commit:        c813db8fc2ec15a8370bb291f662e15ba26682e8
Parent:        fd5b8b72da79e2f0a10785d055a27643d9eaaf19
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 30 13:22:42 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 30 13:34:34 2019 +0200

vdo: deactivate forgotten vdo pool

If the linear mapping is lost (for whatever reason, i.e.
test suite forcible  'dmsetup remove' linear LV,
lvm2 had hard times figuring out how to deactivate such DM table.

So add function which is in case inactive VDO pool LV checks if
the pool is actually still active (-vpool device present) and
it has open count == 0.  In this case deactivation is allowed
to continue and cleanup DM table.
---
 lib/activate/activate.c |   11 +++++++++++
 1 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 29cd2d3..2588816 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -2434,6 +2434,17 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, const struct logi
 			}
 		}
 
+		if (lv_is_vdo_pool(lv)) {
+			/* If someone has remove 'linear' mapping over VDO device
+			 * we may still be able to deactivate the rest of the tree
+			 * i.e. in test-suite we simulate this via 'dmsetup remove' */
+			if (!lv_info(cmd, lv, 1, &info, 1, 0))
+				goto_out;
+
+			if (info.exists && !info.open_count)
+				r = 0; /* Unused VDO device left in table? */
+		}
+
 		if (r)
 			goto out;
 	}


