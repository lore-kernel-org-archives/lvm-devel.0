From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 22 Jan 2014 14:48:57 +0000 (UTC)
Subject: master - WHATS_NEW: be more specific about cryptsetup version that sets the udev flags
Message-ID: <20140122144857.CAEEB60817@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=34e6d59bba1507141a72c644d7d96e173b09fa19
Commit:        34e6d59bba1507141a72c644d7d96e173b09fa19
Parent:        36a09cf463b68cc56330db43d44e02932c12251b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 22 15:48:40 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 22 15:48:40 2014 +0100

WHATS_NEW: be more specific about cryptsetup version that sets the udev flags

---
 WHATS_NEW_DM |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 40c371b..5aa3892 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,6 +1,6 @@
 Version 1.02.85 - 
 ===================================
-  Drop cryptsetup specific rules from 10-dm.rules - cryptsetup sets them.
+  Drop cryptsetup rules from 10-dm.rules - cryptsetup >= 1.1.3 sets them.
 
 Version 1.02.84 - 20th January 2014
 ===================================


