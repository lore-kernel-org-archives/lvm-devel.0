From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 16 Nov 2015 21:14:19 +0000 (UTC)
Subject: master - lvmetad: fix some error logging
Message-ID: <20151116211419.5883760DE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d1c9e1d5a11e7e06c52036c380dd51a2c761f66
Commit:        7d1c9e1d5a11e7e06c52036c380dd51a2c761f66
Parent:        68c386cce71f5bf876cc9ed754d901f1ca9daeed
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 16 15:08:52 2015 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 16 15:13:26 2015 -0600

lvmetad: fix some error logging

For some errors old_meta may not be set, so
check before logging it.
---
 daemons/lvmetad/lvmetad-core.c |    6 ++++--
 1 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmetad/lvmetad-core.c b/daemons/lvmetad/lvmetad-core.c
index 623e1df..2ceaa02 100644
--- a/daemons/lvmetad/lvmetad-core.c
+++ b/daemons/lvmetad/lvmetad-core.c
@@ -1603,7 +1603,8 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	if (pvid && needs_repair) {
 		ERROR(s, "update_metadata ignore inconsistent metadata on PV %s seqno %d for %s %s seqno %d",
 		      pvid, new_seq, arg_vgid, arg_name, old_seq);
-		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
+		if (old_meta)
+			DEBUGLOG_cft(s, "OLD: ", old_meta->root);
 		DEBUGLOG_cft(s, "NEW: ", new_metadata);
 		retval = 0;
 		goto out;
@@ -1615,7 +1616,8 @@ static int _update_metadata(lvmetad_state *s, const char *arg_name, const char *
 	if (!pvid && needs_repair) {
 		ERROR(s, "update_metadata inconsistent with cache for vgid %s and name %s",
 		      arg_vgid, arg_name);
-		DEBUGLOG_cft(s, "OLD: ", old_meta->root);
+		if (old_meta)
+			DEBUGLOG_cft(s, "OLD: ", old_meta->root);
 		DEBUGLOG_cft(s, "NEW: ", new_metadata);
 		abort_daemon = 1;
 		retval = 0;


