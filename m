From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 2 Jun 2017 13:51:13 -0400
Subject: master - lvmdbusd: cmdhandler.py vg_reduce, remove extranous '--all'
Message-ID: <201706021751.v52HpDNw024383@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=192d142e1cd38c1593ec76502d8424997ec01ec8
Commit:        192d142e1cd38c1593ec76502d8424997ec01ec8
Parent:        3217e0cfeaed313332a0b69437ee87ca1f4b9e5e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Fri Jun 2 12:22:24 2017 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Jun 2 12:32:43 2017 -0500

lvmdbusd: cmdhandler.py vg_reduce, remove extranous '--all'

vgreduce previously allowed --all and --removemissing together even though
it only actual did the remove missing.  The lvm dbus daemon was passing
--all anytime there was no entries in pv_object_paths.  This change supplies
--all if and only if we are not removing missing and the pv_object_paths
is empty.

Vgreduce has and continues to enforce the invalid combination of supplying a
device list when you specify --all or --removemissing so we do not need
to check for that invalid combination explicitly in the lvm dbus service as
it's already covered.

Ref: https://bugzilla.redhat.com/show_bug.cgi?id=1455471
---
 daemons/lvmdbusd/cmdhandler.py |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 8ed38cb..a883f1e 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -618,10 +618,10 @@ def vg_reduce(vg_name, missing, pv_devices, reduce_options):
 	cmd = ['vgreduce']
 	cmd.extend(options_to_cli_args(reduce_options))
 
-	if len(pv_devices) == 0:
-		cmd.append('--all')
 	if missing:
 		cmd.append('--removemissing')
+	elif len(pv_devices) == 0:
+		cmd.append('--all')
 
 	cmd.append(vg_name)
 	cmd.extend(pv_devices)


