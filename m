From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Fri,  3 Feb 2017 22:41:54 +0000 (UTC)
Subject: master - WHATS_NEW: New segment type raid5_n
Message-ID: <20170203224154.35EE760DF3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=96f331fe05297259274c04ac7fbd7d99eb911c77
Commit:        96f331fe05297259274c04ac7fbd7d99eb911c77
Parent:        7e92535d475da7403f2ec8eeb2c5af6209fa2ba8
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Fri Feb 3 23:41:48 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Fri Feb 3 23:41:48 2017 +0100

WHATS_NEW: New segment type raid5_n

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 94411ae..95a24ba 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Support raid5_n segment type and conversions from/to it.
   Support new internal command _dmeventd_thin_command.
   Introduce new dmeventd/thin_command configurable setting.
   Use new default units 'r' for displaying sizes.


