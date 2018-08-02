From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 Aug 2018 12:39:52 -0400
Subject: 2018-06-01-stable - mirrors: fix read_only_volume_list
Message-ID: <201808021639.w72Gdqx1005966@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5f648406b0f2e322851fce36b062a298cb3d6736
Commit:        5f648406b0f2e322851fce36b062a298cb3d6736
Parent:        3ebc745f53a12848012c3345571a67bc9cd59cf7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 2 11:26:59 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 2 11:39:08 2018 -0500

mirrors: fix read_only_volume_list

If a mirror LV is listed in read_only_volume_list, it would
still be activated rw.  The activation would initially be
readonly, but the monitoring function would immediately
change it to rw.  This was a regression from commit

fade45b1d14c mirror: improve table update

The monitoring function needs to copy the read_only setting
into the new set of mirror activation options it uses.
---
 lib/activate/activate.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 56ec732..70cce30 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1851,6 +1851,8 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 
 	if (!laopts)
 		laopts = &zlaopts;
+	else
+		mirr_laopts.read_only = laopts->read_only;
 
 	/* skip dmeventd code altogether */
 	if (dmeventd_monitor_mode() == DMEVENTD_MONITOR_IGNORE)


