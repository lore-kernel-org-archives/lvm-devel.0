From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 18:26:59 +0000 (UTC)
Subject: master - WHATS_NEW_DM: add --filemap and histogram aggregation
Message-ID: <20160708182659.88D97610EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db63587ce2473f3ceaea1c8ccc911eb3f1cacd0f
Commit:        db63587ce2473f3ceaea1c8ccc911eb3f1cacd0f
Parent:        bce1bc4ca34a72389f78e10e968417c8d60ef856
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jul 7 09:51:54 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 17:27:52 2016 +0100

WHATS_NEW_DM: add --filemap and histogram aggregation

---
 WHATS_NEW_DM |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6a4a919..86d000b 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,11 @@
 Version 1.02.131 -
 ================================
+  Allow --bounds with 'create --filemap' for dmstats.
+  Enable creation of filemap regions with histograms.
+  Enable histogram aggregation for regions with more than one area.
+  Enable histogram aggregation for groups of regions.
+  Add a --filemap option to 'dmstats create' to allow mapping of files.
+  Add dm_stats_create_regions_from_fd() to map file extents to regions.
 
 Version 1.02.130 - 6th July 2016
 ================================


