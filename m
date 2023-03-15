From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 15 Mar 2023 14:10:09 +0000 (GMT)
Subject: main - lvmdbusd: Add a new 'Shared' property to the Vg interface
Message-ID: <20230315141009.C3F763858D39@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ddfe839dd1aa42e3d2a15a19eaf86c4b6fc65d19
Commit:        ddfe839dd1aa42e3d2a15a19eaf86c4b6fc65d19
Parent:        0c73d3545b2c964cea7e74cc022d2bc599ce7739
Author:        Vojtech Trefny <vtrefny@redhat.com>
AuthorDate:    Wed Mar 15 12:31:14 2023 +0100
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Mar 15 09:09:38 2023 -0500

lvmdbusd: Add a new 'Shared' property to the Vg interface

Signed-off-by: Vojtech Trefny <vtrefny@redhat.com>
---
 daemons/lvmdbusd/vg.py | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/daemons/lvmdbusd/vg.py b/daemons/lvmdbusd/vg.py
index 6e7d6ec9b..c65d9db2b 100644
--- a/daemons/lvmdbusd/vg.py
+++ b/daemons/lvmdbusd/vg.py
@@ -151,6 +151,7 @@ class Vg(AutomatedProperties):
 	_AllocNormal_meta = ('b', VG_INTERFACE)
 	_AllocAnywhere_meta = ('b', VG_INTERFACE)
 	_Clustered_meta = ('b', VG_INTERFACE)
+	_Shared_meta = ('b', VG_INTERFACE)
 	_Name_meta = ('s', VG_INTERFACE)
 
 	# noinspection PyUnusedLocal,PyPep8Naming
@@ -785,6 +786,10 @@ class Vg(AutomatedProperties):
 	def Clustered(self):
 		return self._attribute(5, 'c')
 
+	@property
+	def Shared(self):
+		return self._attribute(5, 's')
+
 
 class VgVdo(Vg):
 

