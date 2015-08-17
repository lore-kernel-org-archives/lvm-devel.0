From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 17 Aug 2015 19:54:26 +0000 (UTC)
Subject: master - config: recognize a blank comment line
Message-ID: <20150817195426.52E9160B28@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca70770cfd281a353143057d3164e3f9bc661081
Commit:        ca70770cfd281a353143057d3164e3f9bc661081
Parent:        5243a81c29a4b60fe8ef8e12b9a1486a3f2b85a6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Aug 12 15:45:27 2015 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Aug 17 13:52:34 2015 -0500

config: recognize a blank comment line

Consider the comment line "#\n" to be a blank line, and
print a blank line at that position when --withspaces is set.
---
 lib/config/config.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index bfcf87c..0c3cf92 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1695,6 +1695,11 @@ static int _out_prefix_fn(const struct dm_config_node *cn, const char *line, voi
 		if (cfg_def->comment) {
 			int pos = 0;
 			while (_copy_one_line(cfg_def->comment, commentline, &pos, strlen(cfg_def->comment))) {
+				if ((commentline[0] == '#') && (strlen(commentline) == 1)) {
+					if (!out->tree_spec->withspaces)
+						continue;
+					commentline[0] = '\0';
+				}
 				fprintf(out->fp, "%s# %s\n", line, commentline);
 				/* withsummary prints only the first comment line. */
 				if (!out->tree_spec->withcomments)


