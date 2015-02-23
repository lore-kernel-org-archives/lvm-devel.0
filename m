From: Alasdair Kergon <agk@fedoraproject.org>
Date: Mon, 23 Feb 2015 19:22:05 +0000 (UTC)
Subject: master - format_text: Fix creation_host_system_id.
Message-ID: <20150223192205.DFF7A60F50@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a5df78e0f045e374f44be2fad3c09d44d39314f7
Commit:        a5df78e0f045e374f44be2fad3c09d44d39314f7
Parent:        cc5e3dbf24f69df8f7410919df3a9f11988cee54
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Mon Feb 23 19:19:48 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Mon Feb 23 19:19:48 2015 +0000

format_text: Fix creation_host_system_id.

Don't escape quotes - forbidden characters.
---
 lib/format_text/export.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/export.c b/lib/format_text/export.c
index d853bb5..d6a92c4 100644
--- a/lib/format_text/export.c
+++ b/lib/format_text/export.c
@@ -352,7 +352,7 @@ static int _print_header(struct cmd_context *cmd, struct formatter *f,
 	     _utsname.sysname, _utsname.nodename, _utsname.release,
 	     _utsname.version, _utsname.machine);
 	if (cmd->system_id && *cmd->system_id)
-		outf(f, "creation_host_system_id = \"%s\"", dm_escape_double_quotes(buf, cmd->system_id));
+		outf(f, "creation_host_system_id = \"%s\"", cmd->system_id);
 	outf(f, "creation_time = %lu\t# %s", t, ctime(&t));
 
 	return 1;


