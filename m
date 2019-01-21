From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 21 Jan 2019 06:55:09 -0500
Subject: master - man: document dD attrs for VDO lvs
Message-ID: <201901211155.x0LBt9HY024429@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9a0535e354d3027ec085d802ac6d016fec17ec75
Commit:        9a0535e354d3027ec085d802ac6d016fec17ec75
Parent:        21742c3f3d00e8df274e4d56995e6346b849acf8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jan 18 17:33:41 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 21 12:39:23 2019 +0100

man: document dD attrs for VDO lvs

New attrs v(d)o pool and v(D) pool data.
---
 man/lvs.8_end    |    5 +++--
 man/lvs.8_pregen |    5 +++--
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/man/lvs.8_end b/man/lvs.8_end
index 4f83516..6efc9cb 100644
--- a/man/lvs.8_end
+++ b/man/lvs.8_end
@@ -6,8 +6,9 @@ Volume type: (C)ache, (m)irrored, (M)irrored without initial sync, (o)rigin,
 (O)rigin with merging snapshot, (r)aid, (R)aid without initial sync,
 (s)napshot, merging (S)napshot, (p)vmove, (v)irtual,
 mirror or raid (i)mage, mirror or raid (I)mage out-of-sync, mirror (l)og device,
-under (c)onversion, thin (V)olume, (t)hin pool, (T)hin pool data, raid or
-pool m(e)tadata or pool metadata spare.
+under (c)onversion, thin (V)olume, (t)hin pool, (T)hin pool data,
+v(d)o pool, v(D)o pool data,
+raid or pool m(e)tadata or pool metadata spare.
 .IP 2 3
 Permissions: (w)riteable, (r)ead-only, (R)ead-only activation of non-read-only
 volume
diff --git a/man/lvs.8_pregen b/man/lvs.8_pregen
index 9659b70..c92ba14 100644
--- a/man/lvs.8_pregen
+++ b/man/lvs.8_pregen
@@ -519,8 +519,9 @@ Volume type: (C)ache, (m)irrored, (M)irrored without initial sync, (o)rigin,
 (O)rigin with merging snapshot, (r)aid, (R)aid without initial sync,
 (s)napshot, merging (S)napshot, (p)vmove, (v)irtual,
 mirror or raid (i)mage, mirror or raid (I)mage out-of-sync, mirror (l)og device,
-under (c)onversion, thin (V)olume, (t)hin pool, (T)hin pool data, raid or
-pool m(e)tadata or pool metadata spare.
+under (c)onversion, thin (V)olume, (t)hin pool, (T)hin pool data,
+v(d)o pool, v(D)o pool data,
+raid or pool m(e)tadata or pool metadata spare.
 .IP 2 3
 Permissions: (w)riteable, (r)ead-only, (R)ead-only activation of non-read-only
 volume


