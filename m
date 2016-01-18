From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 18 Jan 2016 15:35:41 +0000 (UTC)
Subject: master - lvmlockd: fix lvb validation for conversion
Message-ID: <20160118153541.2FC4F60C9B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=95ead96004c303f4285acfc223bba58e82e3ee87
Commit:        95ead96004c303f4285acfc223bba58e82e3ee87
Parent:        54b41dcd53d99059b691f72eb6e7556d4341634d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jan 15 15:31:13 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jan 18 09:35:20 2016 -0600

lvmlockd: fix lvb validation for conversion

Make the lvb validation rules for convert match
those for unlock (even though it would be very
unlikely or impossible for convert to deal with
zero lvb.)
---
 daemons/lvmlockd/lvmlockd-core.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index 093021d..53fc0d5 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -1379,12 +1379,16 @@ static int res_convert(struct lockspace *ls, struct resource *r,
 		r->version++;
 		lk->version = r->version;
 		r_version = r->version;
+		r->version_zero_valid = 0;
+
 		log_debug("S %s R %s res_convert r_version inc %u",
 			  ls->name, r->name, r_version);
 
 	} else if ((r->type == LD_RT_VG) && (r->mode == LD_LK_EX) && (lk->version > r->version)) {
 		r->version = lk->version;
 		r_version = r->version;
+		r->version_zero_valid = 0;
+
 		log_debug("S %s R %s res_convert r_version new %u", ls->name, r->name, r_version);
 	} else {
 		r_version = 0;


