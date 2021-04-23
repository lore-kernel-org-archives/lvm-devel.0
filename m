From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:06:00 +0000 (GMT)
Subject: main - clang: always initialized values
Message-ID: <20210423210600.CB8DA393BC13@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=21bdd0a3597eaa138906bc467f6749e70bc60e78
Commit:        21bdd0a3597eaa138906bc467f6749e70bc60e78
Parent:        8f85834a330c1b803c130d9f7a33633267fb8d5b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 21:49:30 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

clang: always initialized values

---
 device_mapper/libdm-report.c | 2 +-
 libdm/libdm-report.c         | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/device_mapper/libdm-report.c b/device_mapper/libdm-report.c
index f14aa8bc7..c6e7a2a03 100644
--- a/device_mapper/libdm-report.c
+++ b/device_mapper/libdm-report.c
@@ -3774,7 +3774,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 	struct field_selection *fs;
 	struct selection_node *sn;
 	const char *ws, *we; /* field name */
-	const char *vs, *ve; /* value */
+	const char *vs = NULL, *ve = NULL; /* value */
 	const char *last;
 	uint32_t flags, field_num;
 	int implicit;
diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 5433e74ae..2efcc07c9 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -3773,7 +3773,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 	struct field_selection *fs;
 	struct selection_node *sn;
 	const char *ws, *we; /* field name */
-	const char *vs, *ve; /* value */
+	const char *vs = NULL, *ve = NULL; /* value */
 	const char *last;
 	uint32_t flags, field_num;
 	int implicit;


