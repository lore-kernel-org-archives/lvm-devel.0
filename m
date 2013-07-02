From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue,  2 Jul 2013 13:33:06 +0000 (UTC)
Subject: master - profile: strictly require profiles to be valid
Message-ID: <20130702133306.C00CE60DA8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9c12a23a997418700b4dac1a44d193e6a837f3a3
Commit:        9c12a23a997418700b4dac1a44d193e6a837f3a3
Parent:        24a84549a88a6c937091b894d1f0babe10aed17d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jun 27 14:01:22 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jul 2 15:22:11 2013 +0200

profile: strictly require profiles to be valid

We must ensure that the profile is valid and contains
only items that are profilable - the check is forced
for profiles.
---
 lib/config/config.c |   16 +++++++++++++++-
 1 files changed, 15 insertions(+), 1 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index 59f9bb0..2994111 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1500,7 +1500,21 @@ int load_profile(struct cmd_context *cmd, struct profile *profile) {
 
 	dm_list_move(&cmd->profile_params->profiles, &profile->list);
 
-	(void) _check_profile(cmd, profile);
+	/*
+	 * *Profile must be valid* otherwise we'd end up with incorrect config!
+	 * If there were config items present that are not supposed to be
+	 * customized by a profile, we could end up with non-deterministic
+	 * behaviour. Therefore, this check is *strictly forced* even if
+	 * config/checks=0. The config/checks=0 will only cause the warning
+	 * messages to be suppressed, but the check itself is always done
+	 * for profiles!
+	 */
+	if (!_check_profile(cmd, profile)) {
+		log_error("Ignoring invalid configuration profile %s.", profile->name);
+		/* if invalid, cut the whole tree and leave it empty */
+		dm_pool_free(profile->cft->mem, profile->cft->root);
+		profile->cft->root = NULL;
+	}
 
 	return 1;
 }


