From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Tue,  7 Apr 2015 12:33:03 +0000 (UTC)
Subject: master - lvcreate: do not silently accept '-m #' with raid4/5/6
Message-ID: <20150407123303.CDB6F60BD5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=035276ab83bae4349e06a3158f288fa75e0bdf9c
Commit:        035276ab83bae4349e06a3158f288fa75e0bdf9c
Parent:        64353ff74b56c71b508fd040a45062facb395bae
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Tue Apr 7 14:32:25 2015 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Tue Apr 7 14:32:25 2015 +0200

lvcreate: do not silently accept '-m #' with raid4/5/6

If the user provides '-m #' (# > 0) with mappings
raid4/5/6, the command silently creates
'#mirrors * #stripes + #parity' image component pairs.

Patch rejects '-m #' altogether for those mappings
in order to avoid LV creation with unexpected layout.

- resolves bz#1209445
---
 tools/lvcreate.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index 3f7fe6f..e41f76c 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -474,6 +474,14 @@ static int _read_raid_params(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (arg_count(cmd, mirrors_ARG) && segtype_is_raid(lp->segtype) &&
+	    strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID1) &&
+	    strcmp(lp->segtype->name, SEG_TYPE_NAME_RAID10)) {
+		log_error("Mirror argument cannot be used with segment type, %s",
+			  lp->segtype->name);
+		return 0;
+	}
+
 	/* Rates are recorded in kiB/sec/disk, not sectors/sec/disk */
 	lp->min_recovery_rate = arg_uint_value(cmd, minrecoveryrate_ARG, 0) / 2;
 	lp->max_recovery_rate = arg_uint_value(cmd, maxrecoveryrate_ARG, 0) / 2;


