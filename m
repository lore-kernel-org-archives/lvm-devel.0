From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 15 Oct 2012 12:10:04 +0000 (UTC)
Subject: master - thin: allow to create read-only thin-volumes
Message-ID: <20121015121004.ED637A0C45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2fc1fc3a93783fa715a0c833e12962194674b8b1
Commit:        2fc1fc3a93783fa715a0c833e12962194674b8b1
Parent:        c93659e0e0fac317f4fe35dc19ba86e5977721d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 8 11:23:52 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 14:07:03 2012 +0200

thin: allow to create read-only thin-volumes

Useful for i.e. read-only thin snapshots.
---
 WHATS_NEW        |    1 +
 tools/lvcreate.c |    5 -----
 2 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 2780834..53f3fe9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Support creation of read-only thin volumes (lvcreate -p r).
   Using autoextend percent 0 for thin pool fails 'lvextend --use-policies'.
   Introduce blkdeactivate script.
   Implement devices/global_filter (affects lvmetad).
diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 53c4940..55b6a2c 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -619,11 +619,6 @@ static int _read_activation_params(struct lvcreate_params *lp, struct cmd_contex
 	lp->permission = arg_uint_value(cmd, permission_ARG,
 					LVM_READ | LVM_WRITE);
 
-	if (lp->thin && !(lp->permission & LVM_WRITE)) {
-		log_error("Read-only thin volumes are not currently supported.");
-		return 0;
-	}
-
 	/* Must not zero read only volume */
 	if (!(lp->permission & LVM_WRITE))
 		lp->zero = 0;


