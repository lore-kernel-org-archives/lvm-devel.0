From: Tony Asleson <tasleson@sourceware.org>
Date: Fri, 14 Dec 2018 09:31:14 -0500
Subject: master - lvmdbusd: Update table lookup for state lv_attr
Message-ID: <201812141431.wBEEVEIG011983@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2e01af0f78fb63c084998f728668553d8cce2b64
Commit:        2e01af0f78fb63c084998f728668553d8cce2b64
Parent:        a6cba2d0a08e77a7e5178a2fac605863848a8e2e
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Dec 11 11:24:51 2018 -0600
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Fri Dec 14 08:28:03 2018 -0600

lvmdbusd: Update table lookup for state lv_attr

---
 daemons/lvmdbusd/lv.py |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 1b66af5..c0029b8 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -346,13 +346,19 @@ class LvCommon(AutomatedProperties):
 
 	@property
 	def State(self):
-		type_map = {'a': 'active', 's': 'suspended', 'I': 'Invalid snapshot',
+		type_map = {'a': 'active',
+					's': 'suspended',
+					'I': 'Invalid snapshot',
 					'S': 'invalid Suspended snapshot',
 					'm': 'snapshot merge failed',
 					'M': 'suspended snapshot (M)erge failed',
 					'd': 'mapped device present without  tables',
 					'i': 'mapped device present with inactive table',
-					'X': 'unknown', '-': 'Unspecified'}
+					'h': 'historical',
+					'c': 'check needed suspended thin-pool',
+					'C': 'check needed',
+					'X': 'unknown',
+					'-': 'Unspecified'}
 		return self.attr_struct(4, type_map)
 
 	@property


