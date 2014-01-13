From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon, 13 Jan 2014 10:57:07 +0000 (UTC)
Subject: master - toollib: Fix a pool leak in _process_all_devs.
Message-ID: <20140113105707.0CC2F60D93@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5f7286f15d34d89b6710af3946985b4479e2a472
Commit:        5f7286f15d34d89b6710af3946985b4479e2a472
Parent:        e892ac73980db349deeb3ff6863bd8e3b5727654
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Jan 13 11:26:43 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Jan 13 11:26:43 2014 +0100

toollib: Fix a pool leak in _process_all_devs.

---
 tools/toollib.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index bf226b9..61c14f1 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -777,6 +777,8 @@ static int _process_all_devs(struct cmd_context *cmd, void *handle,
 	}
 
 	dev_iter_destroy(iter);
+	dm_list_iterate_items(pvl, pvslist)
+		free_pv_fid(pvl->pv);
 
 	return ret_max;
 }


