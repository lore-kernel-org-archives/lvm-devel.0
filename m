From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 15 Sep 2015 16:08:45 +0000 (UTC)
Subject: master - format-text: label: fix missing dev assignment for struct label in _text_pv_write
Message-ID: <20150915160845.B8B47601FC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fcfca57e2e15c5cae3ccac225669d97c65b6b9db
Commit:        fcfca57e2e15c5cae3ccac225669d97c65b6b9db
Parent:        0ac10bb23a9e356b87ead9e1304a6482f6761b9b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 15 17:38:02 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 15 18:07:32 2015 +0200

format-text: label: fix missing dev assignment for struct label in _text_pv_write

When using lvm shell, some structures which are cached in memory may be
reused. This happens for the struct label (a part of lvmcache_info
structure) when lvmetad is used in which case the PV scan is not
done that would normally overwrite these label structures in memory
and making them up-to-date.

This is all consequence of the fact that struct lvmcache_info and
struct label are not always assigned in the same part of the code.
For example, if lvmetad *is not* used, parts of the struct label are
reassigned in label_read fn while struct lvmcache_info is created
elsewhere. No part of the code reused struct label (and its "dev"
field) before calling label_read fn. That's why the real bug is
hidden when using lvm shell without lvmetad.

However, with lvmetad and lvm shell, the situation is a bit different.
The label_read fn is not called if lvmetad *is* used, hence the
struct label may have ended up not initialized properly.

There was missing assignment for the dev field in struct label
in _text_pv_write fn which caused this problem to appear in
lvm shell with lvmetad, for example:

Before this patch:

lvm> pvcreate /dev/sda
  Physical volume "/dev/sda" successfully created
lvm> pvs /dev/sda
  PV             VG     Fmt  Attr PSize   PFree
  unknown device        lvm2 ---  128.00m 128.00m

With this patch applied:

lvm> pvcreate /dev/sda
  Physical volume "/dev/sda" successfully created
lvm> pvs /dev/sda
  PV         VG   Fmt  Attr PSize   PFree
  /dev/sda        lvm2 ---  128.00m 128.00m

Also, this problem had not appeared before changes introduced
by commits e1a63905d14cc73352b905c70cb4084b7e521e33 through
3a6f91d7139119bea664050a957cbc21490398bc which, among other
things, added proper label field type reporting. Before, label
reporting was the same as using struct physical_volume which
has its own dev field assigned and so this problem was not exposed.
---
 WHATS_NEW                     |    1 +
 lib/format_text/format-text.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c50eecb..e50ffd2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.132 - 
 ======================================
+  Fix PV label processing failure after pvcreate in lvm shell with lvmetad.
 
 Version 2.02.131 - 15th September 2015
 ======================================
diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 4544f26..e0ec8ed 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -1339,6 +1339,7 @@ static int _text_pv_write(const struct format_type *fmt, struct physical_volume
 
 	label = lvmcache_get_label(info);
 	label->sector = pv->label_sector;
+	label->dev = pv->dev;
 
 	lvmcache_update_pv(info, pv, fmt);
 


