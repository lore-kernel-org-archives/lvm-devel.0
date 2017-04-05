From: David Teigland <teigland@sourceware.org>
Date: Wed, 5 Apr 2017 11:09:36 -0400
Subject: master - lvchange: fix missing return value
Message-ID: <201704051509.v35F9axr011838@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6fdc391baec1129d0c70913f116c04f928d083fa
Commit:        6fdc391baec1129d0c70913f116c04f928d083fa
Parent:        448bf9491a10715650569d5eeceb1026941d70ae
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 5 10:08:01 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 5 10:08:01 2017 -0500

lvchange: fix missing return value

A return value from lvchange_persistent_cmd() was missed
in commit 1c41898c07ad750820fb39770355fded8e9b030a
---
 tools/lvchange.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 60a37a9..1778b52 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -1618,6 +1618,8 @@ int lvchange_persistent_cmd(struct cmd_context *cmd, int argc, char **argv)
 	} else if (arg_is_set(cmd, monitor_ARG) || arg_is_set(cmd, poll_ARG)) {
 		ret = lvchange_monitor_poll_cmd(cmd, argc, argv);
 	}
+
+	return ret;
 }
 
 int lvchange(struct cmd_context *cmd, int argc, char **argv)


