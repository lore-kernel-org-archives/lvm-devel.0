From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 24 Feb 2014 20:16:53 +0000 (UTC)
Subject: master - libdm: drop unneded assignment
Message-ID: <20140224201653.9800760E53@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c132fc3ff6d031c136528ef00ecfbed417dae941
Commit:        c132fc3ff6d031c136528ef00ecfbed417dae941
Parent:        8346f106b448caeb9625d05eb9d196cced860288
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 24 09:44:54 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Feb 24 20:59:10 2014 +0100

libdm: drop unneded assignment

---
 libdm/libdm-deptree.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index cede734..8592cdb 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1871,8 +1871,6 @@ int dm_tree_activate_children(struct dm_tree_node *dnode,
 			dnode->props.send_messages = 0; /* messages posted */
 	}
 
-	handle = NULL;
-
 	return r;
 }
 


