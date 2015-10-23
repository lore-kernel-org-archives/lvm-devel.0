From: David Teigland <teigland@fedoraproject.org>
Date: Fri, 23 Oct 2015 17:23:05 +0000 (UTC)
Subject: master - vg_read: remove unused inconsistent check
Message-ID: <20151023172305.233456103B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8f269697d21035035ffb4954f31bd702a6dd7ca8
Commit:        8f269697d21035035ffb4954f31bd702a6dd7ca8
Parent:        98d81a43ea31ec963a36b8610f3b5a9be28b4cc1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Oct 23 12:19:11 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Oct 23 12:19:11 2015 -0500

vg_read: remove unused inconsistent check

Commit 1a74171ca5682a684d0e05c6090c3d33cab8795b added
a check to ignore a VG that was FAILED_INCONSISTENT
if the command doesn't care if the VG is not found.
Remove that check because that case is never reached
by the current code.
---
 tools/toollib.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 39bf0ac..fba075a 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -195,12 +195,6 @@ static int _ignore_vg(struct volume_group *vg, const char *vg_name,
 		return 0;
 	}
 
-	if ((read_error & FAILED_INCONSISTENT) && (read_flags & READ_OK_NOTFOUND)) {
-		read_error &= ~FAILED_INCONSISTENT;
-		*skip = 1;
-		return 0;
-	}
-
 	if ((read_error & FAILED_INCONSISTENT) && (read_flags & READ_ALLOW_INCONSISTENT))
 		read_error &= ~FAILED_INCONSISTENT; /* Check for other errors */
 


