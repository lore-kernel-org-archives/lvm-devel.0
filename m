From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:45:46 -0400
Subject: master - lvmdbusd: Fix model inconsistency when LV loses interface
Message-ID: <201910301545.x9UFjkRB016994@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4dcb36aba4160ffe9ae90c93642e717e813e4779
Commit:        4dcb36aba4160ffe9ae90c93642e717e813e4779
Parent:        f56b21ae2c7667d69c050653d527f9071ef83ad5
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Oct 10 16:53:10 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbusd: Fix model inconsistency when LV loses interface

When a LV loses an interface it ends up getting removed and recreated.
This happens after the VGs have been processed and updated.  Thus when
this happens we need to re-check the VGs.
---
 daemons/lvmdbusd/fetch.py |   17 ++++++++++++++++-
 1 files changed, 16 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/fetch.py b/daemons/lvmdbusd/fetch.py
index e8f3521..b7eb8c8 100644
--- a/daemons/lvmdbusd/fetch.py
+++ b/daemons/lvmdbusd/fetch.py
@@ -29,11 +29,26 @@ def _main_thread_load(refresh=True, emit_signal=True):
 		refresh=refresh,
 		emit_signal=emit_signal,
 		cache_refresh=False)[1]
-	num_total_changes += load_lvs(
+
+	lv_changes = load_lvs(
 		refresh=refresh,
 		emit_signal=emit_signal,
 		cache_refresh=False)[1]
 
+	num_total_changes += lv_changes
+
+	# When the LVs change it can cause another change in the VGs which is
+	# missed if we don't scan through the VGs again.  We could achieve this
+	# the other way and re-scan the LVs, but in general there are more LVs than
+	# VGs, thus this should be more efficient.  This happens when a LV interface
+	# changes causing the dbus object representing it to be removed and
+	# recreated.
+	if refresh and lv_changes > 0:
+		num_total_changes += load_vgs(
+			refresh=refresh,
+			emit_signal=emit_signal,
+			cache_refresh=False)[1]
+
 	return num_total_changes
 
 


