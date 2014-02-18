From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 18 Feb 2014 09:38:34 +0000 (UTC)
Subject: master - pvcreate: do not print stack when pv not found while doing pvcreate_check
Message-ID: <20140218093834.8F74160C4B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b1e8284f339cb412b83f730783ee8a06feac9341
Commit:        b1e8284f339cb412b83f730783ee8a06feac9341
Parent:        6a00a7e33dc9919610e953456081b057c8b981f6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Feb 18 09:59:21 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 18 10:01:11 2014 +0100

pvcreate: do not print stack when pv not found while doing pvcreate_check

Not finding an existing PV on a disk where we're just
creating the PV is not an error or any bad condition.
Remove misleading "stack" call.
---
 lib/metadata/metadata.c |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 88447a3..74f23b0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1322,8 +1322,7 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
 	/* FIXME Check partition type is LVM unless --force is given */
 
 	/* Is there a pv here already? */
-	if (!(pv = find_pv_by_name(cmd, name, 1, 1)))
-		stack;
+	pv = find_pv_by_name(cmd, name, 1, 1);
 
 	/* Allow partial & exported VGs to be destroyed. */
 	/* We must have -ff to overwrite a non orphan */


