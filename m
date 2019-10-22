From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 22 Oct 2019 10:08:14 -0400
Subject: master - cache: _cpool is protected suffix now
Message-ID: <201910221408.x9ME8EGv004588@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=80ae7206a80277f3e01ba92725c209ea82a0bde6
Commit:        80ae7206a80277f3e01ba92725c209ea82a0bde6
Parent:        b4e87e638ea2fc1c0f8ebca01496f4c34dbd80d0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 22 16:07:21 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Oct 22 16:07:21 2019 +0200

cache: _cpool is protected suffix now

---
 lib/misc/lvm-string.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index d96d431..0ee3403 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -157,6 +157,7 @@ static const char *_lvname_has_reserved_component_string(const char *lvname)
 		"_cdata",
 		"_cmeta",
 		"_corig",
+		"_cpool",
 		"_cvol",
 		"_wcorig",
 		"_mimage",


