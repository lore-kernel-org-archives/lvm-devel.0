From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 20 Jan 2017 23:04:14 +0000 (UTC)
Subject: master - dmeventd_thin: init command
Message-ID: <20170120230414.0D89560B39@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=bc7a1d70d4936fd892223686388fd6fe5c8c3934
Commit:        bc7a1d70d4936fd892223686388fd6fe5c8c3934
Parent:        14746a6c0025fad0d918bff7f1ee105e0eee10c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 20 21:50:23 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jan 20 23:55:50 2017 +0100

dmeventd_thin: init command

When dmeventd configured command does not start with 'lvm ' prefix,
it's going to be an 'external' command.
In this case we split command by spaces to argv strings.
---
 daemons/dmeventd/plugins/thin/dmeventd_thin.c |   16 ++++++++++++++++
 1 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/daemons/dmeventd/plugins/thin/dmeventd_thin.c b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
index 74b010a..86a2115 100644
--- a/daemons/dmeventd/plugins/thin/dmeventd_thin.c
+++ b/daemons/dmeventd/plugins/thin/dmeventd_thin.c
@@ -549,6 +549,8 @@ int register_device(const char *device,
 		    void **user)
 {
 	struct dso_state *state;
+	int maxcmd;
+	char *str;
 
 	if (!dmeventd_lvm2_init_with_pool("thin_pool_state", state))
 		goto_bad;
@@ -561,6 +563,20 @@ int register_device(const char *device,
 		goto_bad;
 	}
 
+	if (strncmp(state->cmd_str, "lvm ", 4)) {
+		maxcmd = 2; /* space for last NULL element */
+		for (str = state->cmd_str; *str; str++)
+			if (*str == ' ')
+				maxcmd++;
+		if (!(str = dm_pool_strdup(state->mem, state->cmd_str)) ||
+		    !(state->argv = dm_pool_zalloc(state->mem, maxcmd * sizeof(char *)))) {
+			log_error("Failed to allocate memory for command.");
+			goto bad;
+		}
+
+		dm_split_words(str, maxcmd - 1, 0, state->argv);
+	}
+
 	state->metadata_percent_check = CHECK_MINIMUM;
 	state->data_percent_check = CHECK_MINIMUM;
 	state->pid = -1;


