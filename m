From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:30 -0400
Subject: master - cov: fix typo
Message-ID: <201810151555.w9FFtUiH020623@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a7298810d1fd0f64be3fd903e9f9fcce9af7b84c
Commit:        a7298810d1fd0f64be3fd903e9f9fcce9af7b84c
Parent:        eb566e034fecd27ced0dc1133e19ced2636b3714
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 15:11:34 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: fix typo

Avoid double assing same value.
---
 device_mapper/vdo/status.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/device_mapper/vdo/status.c b/device_mapper/vdo/status.c
index 6831195..c86c911 100644
--- a/device_mapper/vdo/status.c
+++ b/device_mapper/vdo/status.c
@@ -184,7 +184,7 @@ static bool _parse_field(const char **b, const char *e,
 bool dm_vdo_status_parse(struct dm_pool *mem, const char *input,
 			 struct dm_vdo_status_parse_result *result)
 {
-	const char *b = b = input;
+	const char *b = input;
 	const char *e = input + strlen(input);
 	const char *te;
 	struct dm_vdo_status *s;


