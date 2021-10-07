From: David Teigland <teigland@sourceware.org>
Date: Thu,  7 Oct 2021 17:43:29 +0000 (GMT)
Subject: main - lvmdbusd: Use ID_FS_TYPE UDev property in udevwatch
Message-ID: <20211007174329.B42403858015@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=61bd5e50232d72345b5d55ece237c05025a731ab
Commit:        61bd5e50232d72345b5d55ece237c05025a731ab
Parent:        5ac4b662df525039eda6a5fc461da60c6ea42c2a
Author:        Vojtech Trefny <vtrefny@redhat.com>
AuthorDate:    Wed Jun 2 17:17:40 2021 +0200
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Oct 7 12:42:44 2021 -0500

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


