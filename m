From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 13 Oct 2013 22:30:55 +0000 (UTC)
Subject: master - snapshot: disable merging for virtual snaps
Message-ID: <20131013223055.E0F2360CFC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ac961087b0fe9846f95bedee7687d9ca840b217d
Commit:        ac961087b0fe9846f95bedee7687d9ca840b217d
Parent:        81504ba70caec0adaa63cb4a074b7296d109e807
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 11 22:47:45 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Oct 12 00:15:55 2013 +0200

snapshot: disable merging for virtual snaps

Merging into virtual origin is not supposed to work.
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    4 ++++
 2 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8d83f71..37fe7ad 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Disable unsupported merge for virtual snapshot.
   Move code to remove virtual snapshot from tools to lib for lvm2app.
   Fix possible race during daemon worker thread creation (lvmetad).
   Fix possible deadlock while clearing lvmetad cache for full rescan.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 1970ca3..ee6d868 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -1891,6 +1891,10 @@ static int lvconvert_merge(struct cmd_context *cmd,
 			  find_merging_snapshot(origin)->cow->name);
 		return 0;
 	}
+	if (lv_is_virtual_origin(origin)) {
+		log_error("Snapshot %s has virtual origin.", lv->name);
+		return 0;
+	}
 
 	/*
 	 * Prevent merge with open device(s) as it would likely lead


