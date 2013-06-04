From: Petr Rockai <mornfall@fedoraproject.org>
Date: Tue,  4 Jun 2013 19:27:42 +0000 (UTC)
Subject: dev-mornfall-activate - libdm: compensate suspend counter for live table
Message-ID: <20130604192742.368E261095@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e4dfa785d14643e1efd298af1040f461704b0a67
Commit:        e4dfa785d14643e1efd298af1040f461704b0a67
Parent:        b08c3464898f1c1e45fcac95258a495286e4dd47
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu May 30 11:19:28 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu May 30 17:35:23 2013 +0200

libdm: compensate suspend counter for live table

This patch may not be fully correct. It tries to solve
the imbalanced suspend counter.

The problem starts when some LV is created and fails in resume path.
(i.e. resuming to large PV (enforced) over small loop devices)

This fails in _resume_node() after dm_task_run(). And while
existing device with empty table is left in inactive table,
further calls are reporting this device is in suspend state.

When later the lvm2 tries to rollback created device and deactivate it,
it will end with internal error, when we try to decrement
never incremented suspend counter.

As an 'easy fix' for now update suspend counter only for live nodes.

TODO: explore better fix.
---
 libdm/libdm-deptree.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index 2201b30..4482296 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -1598,7 +1598,7 @@ static int _dm_tree_deactivate_children(struct dm_tree_node *dnode,
 				  info.minor);
 			r = 0;
 			continue;
-		} else if (info.suspended)
+		} else if (info.suspended && info.live_table)
 			dec_suspended();
 
 		if (child->callback &&


