From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Sep 2013 19:00:15 +0000 (UTC)
Subject: master - pvmove: clean exit on failed pvmove restart
Message-ID: <20130923190015.A4EBA60E21@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b2535d0c971afc665a268cbe55b6d23262e21e2b
Commit:        b2535d0c971afc665a268cbe55b6d23262e21e2b
Parent:        229e0752f1651463c21e65d8f9641ff9d1c26dfd
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Sep 23 19:53:18 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Sep 23 19:53:18 2013 +0100

pvmove: clean exit on failed pvmove restart

At present, before the pvmove command can be used to restart pvmove
polling, the LVs concerned need to be activated e.g. with lvchange
-ay.
---
 WHATS_NEW          |    1 +
 tools/polldaemon.c |    7 ++++++-
 2 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ff0303a..8c1a343 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.103 - 
 ======================================
+  Exit cleanly with message when pvmove cannot restart because LV is inactive.
 
 Version 2.02.102 - 23rd September 2013
 ======================================
diff --git a/tools/polldaemon.c b/tools/polldaemon.c
index 0b00e93..7eeea2c 100644
--- a/tools/polldaemon.c
+++ b/tools/polldaemon.c
@@ -201,7 +201,12 @@ static int _poll_vg(struct cmd_context *cmd, const char *vgname,
 			continue;
 
 		/* FIXME Need to do the activation from _set_up_pvmove here
-		 *       if it's not running and we're not aborting */
+		 *       if it's not running and we're not aborting. */
+		if (!lv_is_active(lv)) {
+			log_print_unless_silent("%s: Skipping inactive LV. Try lvchange or vgchange.", name);
+			continue;
+		}
+
 		if (_check_lv_status(cmd, vg, lv, name, parms, &finished) &&
 		    !finished)
 			parms->outstanding_count++;


