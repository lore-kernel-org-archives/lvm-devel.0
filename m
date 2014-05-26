From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 26 May 2014 10:09:35 +0000 (UTC)
Subject: master - cleanup: use const for endptr in dm_units_to_factor
Message-ID: <20140526100935.79EAA60EBF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6e9105c7bb7f4a1beb34579303670e4510c7d2e6
Commit:        6e9105c7bb7f4a1beb34579303670e4510c7d2e6
Parent:        cfe18d85c148c5d3c9407fac586b28b186471615
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon May 26 12:09:01 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon May 26 12:09:01 2014 +0200

cleanup: use const for endptr in dm_units_to_factor

---
 libdm/libdevmapper.h |    2 +-
 libdm/libdm-string.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index d63b135..990692c 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1496,7 +1496,7 @@ int dm_strncpy(char *dest, const char *src, size_t n);
  * Returns the unit factor or 0 if no unit is recognized.
  */
 uint64_t dm_units_to_factor(const char *units, char *unit_type,
-			    int strict, char **endptr);
+			    int strict, const char **endptr);
 
 /**************************
  * file/stream manipulation
diff --git a/libdm/libdm-string.c b/libdm/libdm-string.c
index 7336e6b..8ad479c 100644
--- a/libdm/libdm-string.c
+++ b/libdm/libdm-string.c
@@ -444,7 +444,7 @@ static int _close_enough(double d1, double d2)
 }
 
 uint64_t dm_units_to_factor(const char *units, char *unit_type,
-			    int strict, char **endptr)
+			    int strict, const char **endptr)
 {
 	char *ptr = NULL;
 	uint64_t v;


