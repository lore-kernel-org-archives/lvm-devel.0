From: David Teigland <teigland@fedoraproject.org>
Date: Tue,  1 Mar 2016 17:16:57 +0000 (UTC)
Subject: master - WHATS_NEW: [unknown] replaces 'unknown device'
Message-ID: <20160301171657.41A716079C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3d610fabbdb5f63e6e46661f7080f74852b118b0
Commit:        3d610fabbdb5f63e6e46661f7080f74852b118b0
Parent:        57cd94b9e3b74c65f34eb2c40096cbbac024e986
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 1 11:16:35 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 1 11:16:35 2016 -0600

WHATS_NEW: [unknown] replaces 'unknown device'

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3494455..7602fa4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.145 - 
 =====================================
+  Display [unknown] instead of 'unknown device' in pvs output.
   Fix error path when pvcreate allocation fails (2.02.144).
   Display [unknown] instead of blank for unknown VG names in pvs output.
 


