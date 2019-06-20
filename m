From: David Teigland <teigland@sourceware.org>
Date: Thu, 20 Jun 2019 17:06:23 -0400
Subject: master - vgchange: don't fail monitor command if vg is exported
Message-ID: <201906202106.x5KL6Nkb025070@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=82b137ef2f7f1b6fc1bbf83918750037835a9568
Commit:        82b137ef2f7f1b6fc1bbf83918750037835a9568
Parent:        556dcd2c6b82ead3a5aa50211f08f9d69be13fe1
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jun 20 15:59:36 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jun 20 15:59:36 2019 -0500

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
index d6d4f91..a17f456 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -631,6 +631,8 @@ static int _vgchange_single(struct cmd_context *cmd, const char *vg_name,
 	};
 
 	if (vg_is_exported(vg)) {
+		if (cmd->command->command_enum == vgchange_monitor_CMD)
+			return ECMD_PROCESSED;
 		log_error("Volume group \"%s\" is exported", vg_name);
 		return ECMD_FAILED;
 	}


