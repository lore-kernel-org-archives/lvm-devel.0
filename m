From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 26 Sep 2016 10:38:51 +0000 (UTC)
Subject: master - man: fix dmsetup stats
Message-ID: <20160926103851.895486029A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f93cddeafd3d30a2645b0f47c3910a0f1c555b63
Commit:        f93cddeafd3d30a2645b0f47c3910a0f1c555b63
Parent:        70be57c8dab4a011b0f6014636d3948d10ddd8c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 26 12:36:04 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 26 12:38:32 2016 +0200

man: fix dmsetup stats

Fix typo  STATS -> STATUS.
---
 WHATS_NEW_DM     |    1 +
 man/dmsetup.8.in |    4 ++--
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 7d32dff..3ab03b2 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.135 - 
 =====================================
+  Fix man entry for dmsetup status.
   Introduce new dm_config_parse_without_dup_node_check().
 
 Version 1.02.134 - 7th September 2016
diff --git a/man/dmsetup.8.in b/man/dmsetup.8.in
index f92dbe5..8aa0ff7 100644
--- a/man/dmsetup.8.in
+++ b/man/dmsetup.8.in
@@ -787,14 +787,14 @@ The precise encoding might change without notice in any future
 release, so we recommend you always decode using the current version of
 this command.
 .HP
-.BR stats " " \fIcommand " [" \fIoptions ]
+.CMD_STATS
 .br
 Manages IO statistics regions for devices.
 See
 .BR dmstats (8)
 for more details.
 .HP
-.CMD_STATS
+.CMD_STATUS
 .br
 Outputs status information for each of the device's targets.
 With \fB\-\-target\fP, only information relating to the specified target type


