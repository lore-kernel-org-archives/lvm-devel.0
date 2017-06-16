From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 16 Jun 2017 11:13:20 -0400
Subject: master - libdm: workarounds reported raid status info
Message-ID: <201706161513.v5GFDKdT011159@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=529dcaf6a3c4fea4a15baf13cf057d2333860c05
Commit:        529dcaf6a3c4fea4a15baf13cf057d2333860c05
Parent:        40e0dcf70d5a719671916aa88adf9a8f18e096c6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 16 13:20:47 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 16 17:04:00 2017 +0200

libdm: workarounds reported raid status info

Current existing kernels reports status sometimes in weird form.

Instead of showing what is the exact progress, we need to estimate
this in-sync state from several surrounding states.

Main reason here is to never report 100% sync state for a raid device
which will be undergoing i.e. recovery.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdm-targets.c |   18 ++++++++++++++++++
 2 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 5718ab7..581cd42 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.141 - 
 ===============================
+  dm_get_status_raid() handle better some incosistent md statuses.
   Accept truncated files in calls to dm_stats_update_regions_from_fd().
   Restore Warning by 5% increment when thin-pool is over 80% (1.02.138).
 
diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index 1709c2b..6577f07 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -99,6 +99,7 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 	unsigned num_fields;
 	const char *p, *pp, *msg_fields = "";
 	struct dm_status_raid *s = NULL;
+	unsigned a = 0;
 
 	if ((num_fields = _count_fields(params)) < 4)
 		goto_bad;
@@ -168,6 +169,23 @@ int dm_get_status_raid(struct dm_pool *mem, const char *params,
 out:
 	*status = s;
 
+	if (s->insync_regions == s->total_regions) {
+		/* FIXME: kernel gives misleading info here
+		 * Trying to recognize a true state */
+		while (i-- > 0)
+			if (s->dev_health[i] == 'a')
+				a++; /* Count number of 'a' */
+
+		if (a && a < s->dev_count) {
+			/* SOME legs are in 'a' */
+			if (!strcasecmp(s->sync_action, "recover")
+			    || !strcasecmp(s->sync_action, "idle"))
+				/* Kernel may possibly start some action
+				 * in near-by future, do not report 100% */
+				s->insync_regions--;
+		}
+	}
+
 	return 1;
 
 bad:


