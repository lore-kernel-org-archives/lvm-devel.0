From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  3 Jul 2015 07:22:58 +0000 (UTC)
Subject: master - cleanup: commit fe70b03 turned lv_time to STR, put it back to TIM
Message-ID: <20150703072258.40F8860786@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=82ecfa6f0eea0e09dadc9b6e32f6d1359152997f
Commit:        82ecfa6f0eea0e09dadc9b6e32f6d1359152997f
Parent:        e944a9c63561f6a6bb5690f9df14ba4ababb02b3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jul 3 09:22:48 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jul 3 09:22:48 2015 +0200

cleanup: commit fe70b03 turned lv_time to STR, put it back to TIM

---
 lib/report/columns.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 22141d8..fe9aad9 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -85,7 +85,7 @@ FIELD(LVS, lv, STR, "Pool", lvid, 4, poollv, pool_lv, "For thin volumes, the thi
 FIELD(LVS, lv, STR_LIST, "LV Tags", tags, 7, tags, lv_tags, "Tags, if any.", 0)
 FIELD(LVS, lv, STR, "LProfile", lvid, 8, lvprofile, lv_profile, "Configuration profile attached to this LV.", 0)
 FIELD(LVS, lv, STR, "Lock Args", lvid, 9, lvlockargs, lv_lockargs, "Lock args of the LV used by lvmlockd.", 0)
-FIELD(LVS, lv, STR, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV, if known", 0)
+FIELD(LVS, lv, TIM, "Time", lvid, 26, lvtime, lv_time, "Creation time of the LV, if known", 0)
 FIELD(LVS, lv, STR, "Host", lvid, 10, lvhost, lv_host, "Creation host of the LV, if known.", 0)
 FIELD(LVS, lv, STR_LIST, "Modules", lvid, 7, modules, lv_modules, "Kernel device-mapper modules required for this LV.", 0)
 


