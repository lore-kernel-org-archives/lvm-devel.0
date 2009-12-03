From: Milan Broz <mbroz@redhat.com>
Date: Thu,  3 Dec 2009 17:23:20 +0100
Subject: [PATCH] Fix memory lock imbalance in lv_suspend if already suspended.
In-Reply-To: <1259857073-5036-1-git-send-email-mbroz@redhat.com>
References: <1259857073-5036-1-git-send-email-mbroz@redhat.com>
Message-ID: <1259857400-5778-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

(well, this time correct version)

pvmove suspends all moved LVs + pvmoveX mirrored LV itself.

This suspends even underlying pvmoveX and following explicit
suspend call is just noop.

But in resume the pvmoveX volume is no longer underlying
device for moved LVs, so it performs full resume with memlock
decrease.

Code must call memlock_inc() if suspend is requested, volume
is already suspended and error is not requested.

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/activate/activate.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 1aaa16c..cfd2953 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -879,7 +879,11 @@ static int _lv_suspend(struct cmd_context *cmd, const char *lvid_s,
 		goto_out;
 
 	if (!info.exists || info.suspended) {
-		r = error_if_not_suspended ? 0 : 1;
+		if (!error_if_not_suspended) {
+			r = 1;
+			if (info.suspended)
+				memlock_inc();
+		}
 		goto out;
 	}
 
-- 
1.6.5.3


