From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 5 Mar 2019 08:53:12 -0500
Subject: stable-2.02 - cov: ensure vars are set
Message-ID: <201903051353.x25DrC9A006668@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d1ae1455b48fb09c4530b3b823bf02df50450b18
Commit:        d1ae1455b48fb09c4530b3b823bf02df50450b18
Parent:        c115d92287e86d153f2f09d7f8aea8065098f91c
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 15:27:45 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Mar 5 12:14:43 2019 +0100

cov: ensure vars are set

Make sure, tmp_begin and tmp_end are always set, even for blind
coverity.

(cherry picked from commit 251366146727aac97af5de2eef855860d14910ca)

Conflicts:
	device_mapper/libdm-report.c
---
 libdm/libdm-report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 6d140af..0401f9c 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -2380,7 +2380,7 @@ static const char *_get_reserved(struct dm_report *rh, unsigned type,
 {
 	const struct dm_report_reserved_value *iter = implicit ? NULL : rh->reserved_values;
 	const struct dm_report_field_reserved_value *frv;
-	const char *tmp_begin, *tmp_end, *tmp_s = s;
+	const char *tmp_begin = NULL, *tmp_end = NULL, *tmp_s = s;
 	const char *name = NULL;
 	char c;
 


