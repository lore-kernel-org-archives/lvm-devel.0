From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 Jan 2015 10:59:02 +0000 (UTC)
Subject: master - WHATS_NEW: line for previous commit
Message-ID: <20150109105902.B281060F7C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08ac12d5e7dd8375fda49dc44c4ee924dcf05b1b
Commit:        08ac12d5e7dd8375fda49dc44c4ee924dcf05b1b
Parent:        c0e17bca90326104020ba31b00fb9f66abf278b6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 9 11:57:25 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 9 11:57:25 2015 +0100

WHATS_NEW: line for previous commit

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 419f9c9..893c382 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Do not filter out snapshot origin LVs as unusable devices for an LVM stack.
   Fix incorrect rimage names when converting from mirror to raid1 LV (2.02.112).
   Avoid excessive re-reading of metadata and related error messages in pvremove.
   Check for cmirror availability during cluster mirror creation and activation.


