From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 23 Nov 2016 16:55:59 +0000 (UTC)
Subject: master - cleanup: add doc for raid status states
Message-ID: <20161123165559.19B8C60F9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=74923c213fe3c876d3532ef4251e15f946e90fb5
Commit:        74923c213fe3c876d3532ef4251e15f946e90fb5
Parent:        e38678be3fd3ceb610ec649f5036e77a64ee24b4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Nov 16 15:29:09 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 23 17:55:03 2016 +0100

cleanup: add doc for raid status states

Show possible values for raid fields user may get ATM.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |    2 ++
 2 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 72a62cc..a8dd4f5 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.137 - 
 ====================================
+  Document raid status values.
 
 Version 1.02.136 - 5th November 2016
 ====================================
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 97c3e51..09e3fcc 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -327,7 +327,9 @@ struct dm_status_raid {
 	uint64_t mismatch_count;
 	uint32_t dev_count;
 	char *raid_type;
+	/* A - alive,  a - alive not in-sync,  D - dead/failed */
 	char *dev_health;
+	/* idle, frozen, resync, recover, check, repair */
 	char *sync_action;
 };
 


