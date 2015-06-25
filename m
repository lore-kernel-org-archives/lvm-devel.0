From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 25 Jun 2015 11:55:04 +0000 (UTC)
Subject: master - config: also clone associated id when cloning node using dm_config_clone_node{_with_mem}
Message-ID: <20150625115504.EFA4860FDE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f6de196c21a193db5400220f3636fad0875f6d5a
Commit:        f6de196c21a193db5400220f3636fad0875f6d5a
Parent:        110a0745cd162680002c8f7d30220dd627300a95
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 25 10:21:07 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jun 25 10:21:07 2015 +0200

config: also clone associated id when cloning node using dm_config_clone_node{_with_mem}

---
 libdm/libdm-config.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/libdm/libdm-config.c b/libdm/libdm-config.c
index 7b28972..f163677 100644
--- a/libdm/libdm-config.c
+++ b/libdm/libdm-config.c
@@ -1308,6 +1308,8 @@ struct dm_config_node *dm_config_clone_node_with_mem(struct dm_pool *mem, const
 		return NULL;
 	}
 
+	new_cn->id = cn->id;
+
 	if ((cn->v && !(new_cn->v = _clone_config_value(mem, cn->v))) ||
 	    (cn->child && !(new_cn->child = dm_config_clone_node_with_mem(mem, cn->child, 1))) ||
 	    (siblings && cn->sib && !(new_cn->sib = dm_config_clone_node_with_mem(mem, cn->sib, siblings))))


