From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Fri, 16 Jun 2017 10:01:23 -0400
Subject: master - raid: adjust reshape feature flag check
Message-ID: <201706161401.v5GE1NWW000509@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=40e0dcf70d5a719671916aa88adf9a8f18e096c6
Commit:        40e0dcf70d5a719671916aa88adf9a8f18e096c6
Parent:        ddf2a1d6564800f6d7f87e91cb8a7dfaa0edac1f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Jun 16 15:58:47 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Jun 16 15:58:47 2017 +0200

raid: adjust reshape feature flag check

Relative to last comit ddf2a1d6564800f6d7f87e91cb8a7dfaa0edac1f:

adjust the dm-raid target version to 1.12.0 which shows
mandatory kernel MD deadlock fixes related to reshaping
are presant in the kernel.

Related: rhbz1443999
---
 lib/raid/raid.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 8a53d7e..969007c 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -475,7 +475,7 @@ static int _raid_target_present(struct cmd_context *cmd,
 		{ 1, 7, 0, RAID_FEATURE_RAID0, SEG_TYPE_NAME_RAID0 },
 		{ 1, 9, 0, RAID_FEATURE_SHRINK, "shrinking" },
 		{ 1, 9, 0, RAID_FEATURE_NEW_DEVICES_ACCEPT_REBUILD, "rebuild+emptymeta" },
-		{ 1, 10, 1, RAID_FEATURE_RESHAPE, "reshaping" },
+		{ 1, 12, 0, RAID_FEATURE_RESHAPE, "reshaping" },
 	};
 
 	static int _raid_checked = 0;


