From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  6 Sep 2016 19:55:00 +0000 (UTC)
Subject: master - man lvmraid: remove rebuild example
Message-ID: <20160906195500.5EA0760F13@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ff3f5fa1796f4c55b102ae01e93567030ca8d533
Commit:        ff3f5fa1796f4c55b102ae01e93567030ca8d533
Parent:        a1fb7b51b799f8169a4dc03c7e414c9c88934f2d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Sep 6 14:54:45 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Sep 6 14:54:45 2016 -0500

man lvmraid: remove rebuild example

---
 man/lvmraid.7.in |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/man/lvmraid.7.in b/man/lvmraid.7.in
index 9725cbf..5c49def 100644
--- a/man/lvmraid.7.in
+++ b/man/lvmraid.7.in
@@ -730,11 +730,6 @@ those PVs can be reconstructed with:
 The rebuild option can be repeated with different PVs to replace the data
 on multiple PVs.
 
-For example, in a raid1 LV, the master mirror image on PV1 may have
-corrupt data to due a transient disk error.  In this case, \-\-rebuild PV1
-reconstructs data on the master image rather than rebuilding all other
-images from the master image.
-
 
 .SH Monitoring
 


