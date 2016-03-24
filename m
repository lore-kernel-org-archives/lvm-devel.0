From: tasleson <tasleson@fedoraproject.org>
Date: Thu, 24 Mar 2016 17:28:30 +0000 (UTC)
Subject: master - lvmdbusd: Add '-' to allowable PV device path chars
Message-ID: <20160324172830.A030860B41@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d243db5466591412a3c99bb5be84e338da9ba4c9
Commit:        d243db5466591412a3c99bb5be84e338da9ba4c9
Parent:        109b7e2095a7bc5603bf79db0224b8399463af7c
Author:        Tony Asleson <tasleson@redhat.com>
AuthorDate:    Thu Mar 24 12:26:28 2016 -0500
Committer:     Tony Asleson <tasleson@redhat.com>
CommitterDate: Thu Mar 24 12:27:02 2016 -0500

lvmdbusd: Add '-' to allowable PV device path chars

---
 daemons/lvmdbusd/utils.py |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmdbusd/utils.py b/daemons/lvmdbusd/utils.py
index dacd0ef..3dcb373 100644
--- a/daemons/lvmdbusd/utils.py
+++ b/daemons/lvmdbusd/utils.py
@@ -389,7 +389,7 @@ def round_size(size_bytes):
 	return size_bytes + bs - remainder
 
 
-_ALLOWABLE_CH = string.ascii_letters + string.digits + '#+.:=@_\/%'
+_ALLOWABLE_CH = string.ascii_letters + string.digits + '#+-.:=@_\/%'
 _ALLOWABLE_CH_SET = set(_ALLOWABLE_CH)
 
 _ALLOWABLE_VG_LV_CH = string.ascii_letters + string.digits + '.-_+'


