From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 21 Feb 2013 12:34:27 +0000 (UTC)
Subject: master - fix: 'Couldn't read extent size' --> '... extent start'
Message-ID: <20130221123427.66483A32BE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a7d6a612b800ac53ded216842d0386f41e504c4e
Commit:        a7d6a612b800ac53ded216842d0386f41e504c4e
Parent:        722ca363f03f805cb583156eb42886c72f9c93b8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 21 13:33:27 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 21 13:33:27 2013 +0100

fix: 'Couldn't read extent size' --> '... extent start'

---
 lib/format_text/import_vsn1.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index e73c475..33ad37d 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -235,7 +235,8 @@ static int _read_pv(struct format_instance *fid,
 	}
 
 	if (!_read_uint64(pvn, "pe_start", &pv->pe_start)) {
-		log_error("Couldn't read extent size for physical volume.");
+		log_error("Couldn't read extent start value (pe_start) "
+			  "for physical volume.");
 		return 0;
 	}
 


