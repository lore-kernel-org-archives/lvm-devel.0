From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  6 Feb 2014 17:19:31 +0000 (UTC)
Subject: master - WHATS_NEW: latest commits
Message-ID: <20140206171931.1426C60E33@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=290e58b0b6f001b2f3563304fd17d606eff51ba2
Commit:        290e58b0b6f001b2f3563304fd17d606eff51ba2
Parent:        73f30ed6a4b85c3b70aa39efa14ce78be5bf8a3a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 6 18:19:24 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 6 18:19:24 2014 +0100

WHATS_NEW: latest commits

---
 WHATS_NEW_DM |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 5aa3892..827e994 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,8 @@
 Version 1.02.85 - 
 ===================================
+  Exit dmeventd with pidfile cleanup instead of raising SIGKILL on DIE request.
+  Add new DM_EVENT_GET_PARAMETERS request to dmeventd protocol.
+  Do not use systemd's reload for dmeventd restart, use dmeventd -R instead.
   Drop cryptsetup rules from 10-dm.rules - cryptsetup >= 1.1.3 sets them.
 
 Version 1.02.84 - 20th January 2014


