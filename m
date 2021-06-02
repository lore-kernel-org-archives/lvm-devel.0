From: David Teigland <teigland@sourceware.org>
Date: Wed,  2 Jun 2021 16:40:44 +0000 (GMT)
Subject: dev-next - lvmdbusd: Use ID_FS_TYPE UDev property in udevwatch
Message-ID: <20210602164044.3F717385DC22@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2801b7a9b2faf08183685a79ec1dcee42d333541
Commit:        2801b7a9b2faf08183685a79ec1dcee42d333541
Parent:        c53bb2b5ea5e5a985e32235515ad21fff62e3b5b
Author:        Vojtech Trefny <vtrefny@redhat.com>
AuthorDate:    Wed Jun 2 17:17:40 2021 +0200
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 2 11:40:01 2021 -0500

lvmdbusd: Use ID_FS_TYPE UDev property in udevwatch

'.ID_FS_TYPE_NEW' is a custom property added by an LVM UDev rule
which is now being removed and 'ID_FS_TYPE' has the same value.

Signed-off-by: Vojtech Trefny <vtrefny@redhat.com>
---
 daemons/lvmdbusd/udevwatch.py | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/udevwatch.py b/daemons/lvmdbusd/udevwatch.py
index b53b18003..f9b3e4ad1 100644
--- a/daemons/lvmdbusd/udevwatch.py
+++ b/daemons/lvmdbusd/udevwatch.py
@@ -52,8 +52,8 @@ def filter_event(action, device):
 	# when appropriate.
 	refresh = False
 
-	if '.ID_FS_TYPE_NEW' in device:
-		fs_type_new = device['.ID_FS_TYPE_NEW']
+	if 'ID_FS_TYPE' in device:
+		fs_type_new = device['ID_FS_TYPE']
 
 		if 'LVM' in fs_type_new:
 			refresh = True


