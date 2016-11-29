From: tasleson <tasleson@fedoraproject.org>
Date: Tue, 29 Nov 2016 22:51:31 +0000 (UTC)
Subject: master - lvmdbusd: WS fix
Message-ID: <20161129225131.3312F612EC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=617a819abc553aaf79058f4016697328a9b1d98a
Commit:        617a819abc553aaf79058f4016697328a9b1d98a
Parent:        d882edb32d8695ffb1498759649af93f407f39db
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Nov 29 15:01:41 2016 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Tue Nov 29 16:50:30 2016 -0600

lvmdbusd: WS fix

---
 daemons/lvmdbusd/cmdhandler.py |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 1d5ff4a..f221f93 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -353,7 +353,8 @@ def vg_lv_create_raid(vg_name, create_options, name, raid_type, size_bytes,
 								size_bytes, num_stripes, stripe_size_kb)
 
 
-def vg_lv_create_mirror(vg_name, create_options, name, size_bytes, num_copies):
+def vg_lv_create_mirror(
+		vg_name, create_options, name, size_bytes, num_copies):
 	cmd = ['lvcreate']
 	cmd.extend(options_to_cli_args(create_options))
 


