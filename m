From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 11 Nov 2019 16:46:41 -0500
Subject: master - WHATS_NEW: update
Message-ID: <96981.119111116463901275@us-mta-184.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9cad26be321844868a904c7b07bebe37be4e0169
Commit:        9cad26be321844868a904c7b07bebe37be4e0169
Parent:        38617213f080492e03f324a73cd8f912ae557349
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Nov 11 17:44:14 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 11 22:44:25 2019 +0100

WHATS_NEW: update

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 816dd86..e5af036 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.07 - 
 ===================================
+  Fix resize of thin-pool with data and metadata of different segtype.
   Improve mirror type leg splitting.
   Fix activation order when removing merged snapshot.
   Experimental VDO support for lvmdbusd.



