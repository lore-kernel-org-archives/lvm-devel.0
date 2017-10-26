From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 26 Oct 2017 11:25:37 -0400
Subject: master - lvcreate: error message with dot.
Message-ID: <201710261525.v9QFPbpF007287@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=adb80816fbd95215ffc18fdfe5901abed25787c2
Commit:        adb80816fbd95215ffc18fdfe5901abed25787c2
Parent:        4a3884245d02bcdad41e4dd99f9201721c60158f
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Oct 26 17:25:22 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Oct 26 17:25:22 2017 +0200

lvcreate: error message with dot.

---
 tools/lvcreate.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index ff57baf..09bbe10 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -643,7 +643,7 @@ static int _read_mirror_and_raid_params(struct cmd_context *cmd,
 	}
 
 	if ((lp->nosync = arg_is_set(cmd, nosync_ARG)) && seg_is_any_raid6(lp)) {
-		log_error("nosync option prohibited on RAID6");
+		log_error("nosync option prohibited on RAID6.");
 		return 0;
 	}
 


