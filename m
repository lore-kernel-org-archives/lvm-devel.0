From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed,  7 Jan 2015 12:47:32 +0000 (UTC)
Subject: master - WHATS_NEW: previous commit
Message-ID: <20150107124732.8E97360C21@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9dbeacf303f34d4a9f4ccad666e44ca55b83fada
Commit:        9dbeacf303f34d4a9f4ccad666e44ca55b83fada
Parent:        aaecbb181838102e1ce58ea19df14eb69db79dd9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jan 7 13:47:16 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jan 7 13:47:16 2015 +0100

WHATS_NEW: previous commit

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 37611da..419f9c9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Fix incorrect rimage names when converting from mirror to raid1 LV (2.02.112).
   Avoid excessive re-reading of metadata and related error messages in pvremove.
   Check for cmirror availability during cluster mirror creation and activation.
   Add cache_policy and cache_settings reporting fields.


