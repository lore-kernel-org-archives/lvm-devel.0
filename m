From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  1 Mar 2016 13:03:12 +0000 (UTC)
Subject: master - coverity: missing error path
Message-ID: <20160301130312.5864A60DA1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8173c2ff9af805a1f8eb79fb4bd223622f79ad0d
Commit:        8173c2ff9af805a1f8eb79fb4bd223622f79ad0d
Parent:        b2d819eafac630cc683c5fdf02730a636dd9bff6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 1 11:40:53 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 1 14:02:43 2016 +0100

coverity: missing error path

---
 WHATS_NEW       |    1 +
 tools/toollib.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 507e028..3494455 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.145 - 
 =====================================
+  Fix error path when pvcreate allocation fails (2.02.144).
   Display [unknown] instead of blank for unknown VG names in pvs output.
 
 Version 2.02.144 - 26th February 2016
diff --git a/tools/toollib.c b/tools/toollib.c
index dd5ece3..dbb6d40 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -4406,6 +4406,7 @@ do_command:
 		if (!(pvl = dm_pool_alloc(cmd->mem, sizeof(*pvl)))) {
 			log_error("alloc pvl failed");
 			dm_list_move(&pp->arg_fail, &pd->list);
+			continue;
 		}
 
 		pv_name = pd->name;


