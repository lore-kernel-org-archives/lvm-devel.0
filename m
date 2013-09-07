From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat,  7 Sep 2013 07:20:02 +0000 (UTC)
Subject: master - deactivate: drop readahead calc in deactivation
Message-ID: <20130907072002.44F696107C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f5832d8c49bfe96d0162d1b59125a169117c52b2
Commit:        f5832d8c49bfe96d0162d1b59125a169117c52b2
Parent:        0670bfeb5942508c3d2e2573a50980f82abe1bcf
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Sep 7 02:48:19 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Sep 7 09:13:20 2013 +0200

deactivate: drop readahead calc in deactivation

Skip readahead when device will be deactivated.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    2 --
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 342f15b..b1060af 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Drop calculation of read ahead for deactivated volume.
   Check for exactly one lv segment in validation of thin pools and volumes.
   Fix dmeventd unmonitoring of thin pools.
   Fix lvresize for stacked thin pool volumes (i.e. mirrors).
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1706ae5..e5033c6 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1947,8 +1947,6 @@ int lv_deactivate(struct cmd_context *cmd, const char *lvid_s, struct logical_vo
 	if (!lv_read_replicator_vgs(lv))
 		goto_out;
 
-	lv_calculate_readahead(lv, NULL);
-
 	if (!monitor_dev_for_events(cmd, lv, &laopts, 0))
 		stack;
 


