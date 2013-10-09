From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed,  9 Oct 2013 19:11:01 +0000 (UTC)
Subject: master - filters: Add NVM Express (nvme).
Message-ID: <20131009191101.CA92961291@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7bed6d1263c5a65dbdf8e6d6ead021009aa9a59a
Commit:        7bed6d1263c5a65dbdf8e6d6ead021009aa9a59a
Parent:        1b91847beb38c3bd522a6ecb62e0a275825c0b5d
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Oct 9 20:08:07 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Oct 9 20:08:07 2013 +0100

filters: Add NVM Express (nvme).

---
 WHATS_NEW                 |    1 +
 lib/device/device-types.h |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index dd274da..a87a906 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.104
 ===================================
+  Recognise NVM Express devices in filter.
   Fix failing metadata repair when lvmetad is used.
   Fix incorrect memory handling when reading messages from lvmetad.
   Fix locking in lvmetad when handling the PV which is gone.
diff --git a/lib/device/device-types.h b/lib/device/device-types.h
index d25c2f0..d716878 100644
--- a/lib/device/device-types.h
+++ b/lib/device/device-types.h
@@ -61,5 +61,6 @@ static const dev_known_type_t _dev_known_types[] = {
 	{"skd", 16, "STEC"},
 	{"scm", 8, "Storage Class Memory (IBM S/390)"},
 	{"bcache", 1, "bcache block device cache"},
+	{"nvme", 64, "NVM Express"},
 	{"", 0, ""}
 };


