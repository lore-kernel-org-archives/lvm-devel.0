From: David Teigland <teigland@sourceware.org>
Date: Wed, 31 Jul 2019 14:26:32 -0400
Subject: stable-2.02 - vgchange: don't fail monitor command if vg is exported
Message-ID: <201907311826.x6VIQWfE009659@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=5ddd1ead2dcaf9594a025a15986b8bac573c81b2
Commit:        5ddd1ead2dcaf9594a025a15986b8bac573c81b2
Parent:        b387d026bd065b99f894a5c7b67d1f0441b583f3
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 20 15:59:36 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jul 31 13:18:58 2019 -0500

vgchange: don't fail monitor command if vg is exported

When monitoring, skip exported VGs without causing a command
failure.

The lvm2-monitor service runs 'vgchange --monitor y', so
any exported VG on the system would cause the service to
fail.
---
 tools/vgchange.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index 24c2253..e15fca7 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -712,6 +712,8 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	};
 
 	if (vg_is_exported(vg)) {
+		if (cmd->command->command_enum == vgchange_monitor_CMD)
+			return ECMD_PROCESSED;
 		log_error("Volume group \"%s\" is exported", vg_name);
 		return ECMD_FAILED;
 	}


