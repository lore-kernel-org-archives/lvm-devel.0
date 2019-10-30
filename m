From: Tony Asleson <tasleson@sourceware.org>
Date: Wed, 30 Oct 2019 11:43:40 -0400
Subject: master - lvmdbusd: Add d and D to type map for VolumeType
Message-ID: <201910301543.x9UFheLh016534@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b0286fa1277a9fc7a293916a3c8a3e460d276aa2
Commit:        b0286fa1277a9fc7a293916a3c8a3e460d276aa2
Parent:        1839702cb4fa4f66c41c774f46d65b8dfa7a00f0
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Tue Oct 1 16:36:11 2019 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Wed Oct 30 10:38:40 2019 -0500

lvmdbusd: Add d and D to type map for VolumeType

These were added for vdo integration.
---
 daemons/lvmdbusd/lv.py |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmdbusd/lv.py b/daemons/lvmdbusd/lv.py
index 147e51c..9290c19 100644
--- a/daemons/lvmdbusd/lv.py
+++ b/daemons/lvmdbusd/lv.py
@@ -315,6 +315,7 @@ class LvCommon(AutomatedProperties):
 					'l': 'mirror log device', 'c': 'under conversion',
 					'V': 'thin Volume', 't': 'thin pool', 'T': 'Thin pool data',
 					'e': 'raid or pool metadata or pool metadata spare',
+					'd': 'vdo pool', 'D': 'vdo pool data',
 					'-': 'Unspecified'}
 		return self.attr_struct(0, type_map)
 


