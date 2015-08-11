From: David Teigland <teigland@fedoraproject.org>
Date: Tue, 11 Aug 2015 17:18:40 +0000 (UTC)
Subject: master - lvconvert: fix lockd LV locking
Message-ID: <20150811171840.6303160A96@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=819dc1845edcf48e0f3eb282a6d8b9ace8cb1a1b
Commit:        819dc1845edcf48e0f3eb282a6d8b9ace8cb1a1b
Parent:        53c08f0bba9f18df80403eab67acb032f3049902
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Aug 11 12:12:22 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Aug 11 12:17:24 2015 -0500

lvconvert: fix lockd LV locking

Request a transient LV lock from lvmlockd when
converting an LV.  If the LV is inactive when
lvconvert is run, the LV lock will be acquired
and then released when the command is done.
If the LV is active, a persistent lock exists
already and the transient lock request does nothing.

This fixes the issue that had been mentioned in the
comment previously.
---
 tools/lvconvert.c |   12 +++++-------
 1 files changed, 5 insertions(+), 7 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6a0e0ca..3a7f9ae 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3427,14 +3427,12 @@ static int lvconvert_single(struct cmd_context *cmd, struct lvconvert_params *lp
 	}
 
 	/*
-	 * If the lv is inactive before and after the command, the
-	 * use of PERSISTENT here means the lv will remain locked as
-	 * an effect of running the lvconvert.
-	 * To unlock it, it would need to be activated+deactivated.
-	 * Or, we could identify the commands for which the lv remains
-	 * inactive, and not use PERSISTENT here for those cases.
+	 * Request a transient lock.  If the LV is active, it has a persistent
+	 * lock already, and this request does nothing.  If the LV is not
+	 * active, this acquires a transient lock that will be released when
+	 * the command exits.
 	 */
-	if (!lockd_lv(cmd, lv, "ex", LDLV_PERSISTENT))
+	if (!lockd_lv(cmd, lv, "ex", 0))
 		goto_bad;
 
 	/*


