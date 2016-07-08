From: Bryn Reeves <bmr@fedoraproject.org>
Date: Fri,  8 Jul 2016 18:27:05 +0000 (UTC)
Subject: master - WHATS_NEW_DM: add --segments grouping and resource leak fix
Message-ID: <20160708182705.E76A2610EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=008c57714ae81986fbac0a2c5574b9891a481906
Commit:        008c57714ae81986fbac0a2c5574b9891a481906
Parent:        6cb0c7bb5c41c4fa2bdc1604e86154efa946c600
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Thu Jul 7 14:37:49 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Fri Jul 8 17:27:52 2016 +0100

WHATS_NEW_DM: add --segments grouping and resource leak fix

---
 WHATS_NEW_DM |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 86d000b..40452a1 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,7 @@
 Version 1.02.131 -
 ================================
+  Automatically group regions with 'create --segments' unless --nogroup.
+  Fix resource leak when deleting the first member of a group.
   Allow --bounds with 'create --filemap' for dmstats.
   Enable creation of filemap regions with histograms.
   Enable histogram aggregation for regions with more than one area.


