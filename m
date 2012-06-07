From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu,  7 Jun 2012 14:14:47 +0000 (UTC)
Subject: master - Edit WHATS_NEW.
Message-ID: <20120607141447.68B9D23EC@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=LVM2.git;a=commitdiff;h=d459f6b32abb5c9a2d18dd25efe5f84d036e869c
Commit:        d459f6b32abb5c9a2d18dd25efe5f84d036e869c
Parent:        bb2a2bb3ff92c27083354b9c02d6f869938aab2b
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jun 7 15:14:19 2012 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jun 7 15:14:19 2012 +0100

Edit WHATS_NEW.

---
 WHATS_NEW |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b3f742d..7692b2f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -39,7 +39,7 @@ Version 2.02.96 -
   Fix exclusive lvchange running from other node. (2.02.89)
   Add 'vgscan --cache' functionality for consistency with 'pvscan --cache'.
   Keep exclusive activation in pvmove if LV is already active.
-  Disallow pvmove for exclusive LV if some affected LVs are not exclusively activated.
+  Disallow exclusive pvmove if some affected LVs are not exclusively activated.
   Remove unused and wrongly set cluster VG flag from clvmd lock query command.
   Fix pvmove for exclusively activated LV pvmove in clustered VG. (2.02.86)
   Always free hash table on update_pvid_to_vgid() in lvmetad.


