From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 14 Dec 2018 09:31:14 -0500
Subject: master - lvmdbusd: Update table lookup for health lv_attr
Message-ID: <201812141431.wBEEVEfR011981@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a6cba2d0a08e77a7e5178a2fac605863848a8e2e
Commit:        a6cba2d0a08e77a7e5178a2fac605863848a8e2e
Parent:        51f08efaa700550740254093bacea270325f2ccf
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Dec 11 11:23:56 2018 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Dec 14 08:28:02 2018 -0600

lvmdbusd: Update table lookup for health lv_attr

---
 daemons/lvmdbusd/lv.py |   14 +++++++++++---
 1 files changed, 11 insertions(+), 3 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index a80675f..1b66af5 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -369,9 +369,17 @@ class LvCommon(AutomatedProperties):
 
 	@property
 	def Health(self):
-		type_map = {'p': 'partial', 'r': 'refresh',
-					'm': 'mismatches', 'w': 'writemostly',
-					'X': 'X unknown', '-': 'Unspecified'}
+		type_map = {'p': 'partial',
+					'r': 'refresh needed',
+					'm': 'mismatches',
+					'w': 'writemostly',
+					'X': 'unknown',
+					'-': 'unspecified',
+					's': 'reshaping',
+					'F': 'failed',
+					'D': 'Data space',
+					'R': 'Remove',
+					'M': 'Metadata'}
 		return self.attr_struct(8, type_map)
 
 	@property


