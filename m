From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 11 Dec 2013 15:52:46 +0000 (UTC)
Subject: master - WHATS_NEW: commit 4c267c7286145165dfe078f77d18d194a21a2e1c
Message-ID: <20131211155246.EC0FD60E59@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=877418b1a2edfba6903314797ab3676ec7f2385a
Commit:        877418b1a2edfba6903314797ab3676ec7f2385a
Parent:        4c267c7286145165dfe078f77d18d194a21a2e1c
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Dec 11 16:50:52 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Dec 11 16:50:52 2013 +0100

WHATS_NEW: commit 4c267c7286145165dfe078f77d18d194a21a2e1c

See also https://bugzilla.redhat.com/show_bug.cgi?id=1026860
for more info, comment 76 for summary.
---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7068289..e985922 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Fix SYSTEMD_READY assignment for foreign devices in lvmetad udev rules.
   Disable online thin pool metadata resize for 1.9 kernel thin target.
   Shortened code for initialization of raid segment types.
   Cache global library dir in command context.


