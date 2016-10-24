From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 24 Oct 2016 16:21:51 +0000 (UTC)
Subject: master - dmsetup: remove stray '\n' in delete log message
Message-ID: <20161024162151.24D67609D3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=021715e897016212beb4123b25239338ab49707e
Commit:        021715e897016212beb4123b25239338ab49707e
Parent:        5eda3934885b23ce06f862a56b524ceaab3cb565
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Oct 24 17:21:35 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Oct 24 17:21:35 2016 +0100

dmsetup: remove stray '\n' in delete log message

---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index ec64d24..42f0b05 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -5323,7 +5323,7 @@ static int _stats_delete(CMD_ARGS)
 			log_error("Could not delete statistics region");
 			goto out;
 		}
-		log_info("Deleted statistics region " FMTu64 ".\n", region_id);
+		log_info("Deleted statistics region " FMTu64 ".", region_id);
 	}
 
 	r = 1;


