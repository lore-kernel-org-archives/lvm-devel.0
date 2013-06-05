From: Petr Rockai <mornfall@fedoraproject.org>
Date: Wed,  5 Jun 2013 12:04:19 +0000 (UTC)
Subject: dev-mornfall-lvmcache - WHATS_NEW: return success on dmeventd -V
Message-ID: <20130605120419.00DBB60F7E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=798ed9ea1c72b24a02d38106ecaea9379a673c6f
Commit:        798ed9ea1c72b24a02d38106ecaea9379a673c6f
Parent:        6ad17fd7129dc7f50c0623181681157faea806a1
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 29 13:24:16 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed May 29 13:24:16 2013 +0200

WHATS_NEW: return success on dmeventd -V

---
 WHATS_NEW_DM |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 6dcf9f8..4a2947a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.78 - 
 ===================================
+  Always return success on dmeventd -V command call.
   Fix parsing of 64bit snapshot status in dmeventd snapshot plugin.
   Add dm_get_status_snapshot() for parsing snapshot status.
   Detecte mounted fs also via reading /proc/self/mountinfo.


