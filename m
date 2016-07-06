From: Bryn Reeves <bmr@fedoraproject.org>
Date: Wed,  6 Jul 2016 07:59:59 +0000 (UTC)
Subject: master - libdm: fix mask leak in dm_bitset_parse_list
Message-ID: <20160706075959.04A206032E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=69c721dd68a6ac517d7962f927f3f59f9e05d9c4
Commit:        69c721dd68a6ac517d7962f927f3f59f9e05d9c4
Parent:        fb0a67141928dc62279ba1c8ab137c527f82a393
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Wed Jul 6 08:59:09 2016 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Wed Jul 6 08:59:09 2016 +0100

libdm: fix mask leak in dm_bitset_parse_list

If an unexpected '-' is found jump to the error branch so that the
mask is properly freed before returning.
---
 libdm/datastruct/bitset.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/datastruct/bitset.c b/libdm/datastruct/bitset.c
index 2f84ea4..3fd6a9c 100644
--- a/libdm/datastruct/bitset.c
+++ b/libdm/datastruct/bitset.c
@@ -153,7 +153,7 @@ scan:
 
 			if (c == '-') {
 				if (at_start || in_range)
-					return_0;
+					goto_bad;
 				b = 0;
 				in_range = 1;
 				at_start = 1;


