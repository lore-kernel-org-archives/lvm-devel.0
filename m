From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 27 Aug 2019 06:23:31 -0400
Subject: stable-2.02 - cov: Fix a leak
Message-ID: <201908271023.x7RANV84013914@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=36523a398d50381f8355e719b98c3ce584b81a23
Commit:        36523a398d50381f8355e719b98c3ce584b81a23
Parent:        e4f72e6655ff756c886ad78abcc696d3267e6c5f
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Aug 27 12:21:41 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Aug 27 12:23:13 2019 +0200

cov: Fix a leak

---
 lib/device/bcache.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/device/bcache.c b/lib/device/bcache.c
index a250bfd..d487ca2 100644
--- a/lib/device/bcache.c
+++ b/lib/device/bcache.c
@@ -516,6 +516,7 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 					  (unsigned long long)limit_nbytes,
 					  (unsigned long long)extra_nbytes,
 					  (unsigned long long)_last_byte_sector_size);
+                                free(io);
 				return false;
 			}
 		}
@@ -547,8 +548,8 @@ static bool _sync_issue(struct io_engine *ioe, enum dir d, int fd,
 				log_debug("Device write error %d offset %llu len %llu", errno,
 					  (unsigned long long)(where + pos),
 					  (unsigned long long)(len - pos));
-                	free(io);
-                	return false;
+			free(io);
+			return false;
 		}
 		pos += rv;
 	}


