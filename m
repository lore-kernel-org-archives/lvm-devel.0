From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 2 May 2017 02:49:16 -0400
Subject: master - dbus: Add --yes when --setphysicalvolumesize is used
Message-ID: <201705020649.v426nGef031552@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7da13bbf7baf161d275cc14fe1e5c97c50229e60
Commit:        7da13bbf7baf161d275cc14fe1e5c97c50229e60
Parent:        15eaf703fcfc548ff687a07002f35b06f9fd8c7d
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Apr 28 16:47:58 2017 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue May 2 08:42:21 2017 +0200

dbus: Add --yes when --setphysicalvolumesize is used

---
 daemons/lvmdbusd/cmdhandler.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/cmdhandler.py b/daemons/lvmdbusd/cmdhandler.py
index 94c3f59..8ed38cb 100644
--- a/daemons/lvmdbusd/cmdhandler.py
+++ b/daemons/lvmdbusd/cmdhandler.py
@@ -553,7 +553,7 @@ def pv_resize(device, size_bytes, create_options):
 	cmd.extend(options_to_cli_args(create_options))
 
 	if size_bytes != 0:
-		cmd.extend(['--setphysicalvolumesize', str(size_bytes) + 'B'])
+		cmd.extend(['--yes', '--setphysicalvolumesize', str(size_bytes) + 'B'])
 
 	cmd.extend([device])
 	return call(cmd)


