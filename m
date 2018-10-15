From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:55:45 -0400
Subject: master - cov: check dm_strncpy result
Message-ID: <201810151555.w9FFtjOT020664@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=668c9d0762fc6736a1e9372785544eda6a939806
Commit:        668c9d0762fc6736a1e9372785544eda6a939806
Parent:        b1ff52ca146f58938c07f6c6855bc860453059e6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 16:16:14 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: check dm_strncpy result

---
 device_mapper/vdo/status.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/device_mapper/vdo/status.c b/device_mapper/vdo/status.c
index c86c911..6ae7b84 100644
--- a/device_mapper/vdo/status.c
+++ b/device_mapper/vdo/status.c
@@ -207,7 +207,11 @@ bool dm_vdo_status_parse(struct dm_pool *mem, const char *input,
 		_set_error(result, "out of memory");
 		goto bad;
 	}
-	dm_strncpy(s->device, b, te - b + 1);
+
+	if (!dm_strncpy(s->device, b, te - b + 1)) {
+		_set_error(result, "copy device");
+		goto bad;
+	}
 
 	b = _eat_space(te, e);
 


