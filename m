From: Petr Rockai <mornfall@fedoraproject.org>
Date: Thu, 27 Nov 2014 19:32:12 +0000 (UTC)
Subject: master - toollib: Fix uninitialised config value type in get_cachepolicy_params.
Message-ID: <20141127193212.543C760BBB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=92908541638b41215d48e51d6fa4aa63b82d8c1a
Commit:        92908541638b41215d48e51d6fa4aa63b82d8c1a
Parent:        4bfdb01f789a50267cbb50288a3bd5bc60edd685
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Thu Nov 27 20:19:28 2014 +0100
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Thu Nov 27 20:19:28 2014 +0100

toollib: Fix uninitialised config value type in get_cachepolicy_params.

---
 tools/toollib.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 6d409a9..41e6f88 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -1166,6 +1166,7 @@ struct dm_config_tree *get_cachepolicy_params(struct cmd_context *cmd)
 		if (!(cn->v = dm_config_create_value(result)))
 			goto_out;
 
+		cn->v->type = DM_CFG_STRING;
 		cn->v->v.str = arg_str_value(cmd, cachepolicy_ARG, NULL);
 	}
 


