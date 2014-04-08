From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue,  8 Apr 2014 09:02:47 +0000 (UTC)
Subject: master - lvm-string: add cdata/cmeta as reserved name
Message-ID: <20140408090247.3333A60268@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2868d897da186d0f65856936543e25bcd5057440
Commit:        2868d897da186d0f65856936543e25bcd5057440
Parent:        700b4bfc9428d7440c018c0a5e9d9dcc3cc4cea1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 7 21:36:59 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 8 11:00:14 2014 +0200

lvm-string: add cdata/cmeta as reserved name

---
 lib/misc/lvm-string.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index b96b5cc..a74fd58 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -109,6 +109,8 @@ int apply_lvname_restrictions(const char *name)
 	};
 
 	static const char * const _reserved_strings[] = {
+		"_cdata",
+		"_cmeta",
 		"_mlog",
 		"_mimage",
 		"_pmspare",


