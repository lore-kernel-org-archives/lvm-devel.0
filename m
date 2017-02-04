From: Heinz Mauelshagen <mauelsha@fedoraproject.org>
Date: Sat,  4 Feb 2017 13:10:01 +0000 (UTC)
Subject: master - WHATS_NEW: New segment type raid6_n_6
Message-ID: <20170204131001.3A97360D9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d8568552e460afe477f1baa7c46da81039f85b15
Commit:        d8568552e460afe477f1baa7c46da81039f85b15
Parent:        3673ce48e0d6147fe7a24fcce97130fab8914e51
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Sat Feb 4 14:09:26 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Sat Feb 4 14:09:26 2017 +0100

WHATS_NEW: New segment type raid6_n_6

---
 WHATS_NEW |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 95a24ba..cfa1179 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Support raid6_n_6 segment type and conversions from/to it.
   Support raid5_n segment type and conversions from/to it.
   Support new internal command _dmeventd_thin_command.
   Introduce new dmeventd/thin_command configurable setting.


