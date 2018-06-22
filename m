From: Marian Csontos <mcsontos@sourceware.org>
Date: Fri, 22 Jun 2018 09:14:12 -0400
Subject: 2018-06-01-stable - filter: make pointers distinguishable
Message-ID: <201806221314.w5MDEC40019874@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=24aee732a58a8d45acf90cbdf1d0cf30fe603a09
Commit:        24aee732a58a8d45acf90cbdf1d0cf30fe603a09
Parent:        ba6ed5c90c5a191f63c14ee9795f298eba689932
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Fri Jun 22 15:07:07 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Fri Jun 22 15:13:24 2018 +0200

filter: make pointers distinguishable

This ammends commit: 4afb5971b93a with suggestions to improve debugging
from Nir Soffer.
---
 lib/filters/filter-persistent.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index bbfd858..1d24af8 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -50,8 +50,8 @@ struct pfilter {
  * by default.  The old code for it should be removed.
  */
 
-static int _good_device;
-static int _bad_device;
+static char* _good_device = "good";
+static char* _bad_device = "bad";
 
 /*
  * The hash table holds one of these two states


