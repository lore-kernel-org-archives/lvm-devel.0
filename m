From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 30 May 2017 10:19:42 -0400
Subject: master - flags: restore same logic with MISSING
Message-ID: <201705301419.v4UEJgrW026828@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d1ac6108c39ff8a3496624508a0e709c503d7d9f
Commit:        d1ac6108c39ff8a3496624508a0e709c503d7d9f
Parent:        4141409eb09e78aef030346995f1722fb40956d8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 30 16:12:45 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue May 30 16:16:29 2017 +0200

flags: restore same logic with MISSING

Since lvmetad is using 'MISSING' in status for 'another' purpose,
we need to support ATM also flag get from this place.

Until fixed better - we accept both flags - alhough lvm2 will
only print in flags.
---
 lib/format_text/flags.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index 04896f4..2b934da 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -47,6 +47,7 @@ static const struct flag _pv_flags[] = {
 	{ALLOCATABLE_PV, "ALLOCATABLE", STATUS_FLAG},
 	{EXPORTED_VG, "EXPORTED", STATUS_FLAG},
 	{MISSING_PV, "MISSING", COMPATIBLE_FLAG},
+	{MISSING_PV, "MISSING", STATUS_FLAG},
 	{UNLABELLED_PV, NULL, 0},
 	{0, NULL, 0}
 };


