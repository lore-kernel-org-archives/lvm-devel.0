From: David Teigland <teigland@sourceware.org>
Date: Thu, 2 Aug 2018 12:42:56 -0400
Subject: master - mirrors: fix read_only_volume_list
Message-ID: <201808021642.w72Ggu27006693@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9adae653e98256901897e65aa349bb83a9f9ad5c
Commit:        9adae653e98256901897e65aa349bb83a9f9ad5c
Parent:        763219611c30d6870013b7cb84d66ec67a5dd7ec
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 2 11:26:59 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Aug 2 11:42:33 2018 -0500

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
index 28d67b4..d4a20c9 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1740,6 +1740,8 @@ int monitor_dev_for_events(struct cmd_context *cmd, const struct logical_volume
 
 	if (!laopts)
 		laopts = &zlaopts;
+	else
+		mirr_laopts.read_only = laopts->read_only;
 
 	/* skip dmeventd code altogether */
 	if (dmeventd_monitor_mode() == DMEVENTD_MONITOR_IGNORE)


