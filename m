From: Petr Rockai <prockai@redhat.com>
Date: Wed, 30 Jun 2010 23:22:47 +0200
Subject: [PATCH] avoid scanning suspended & otherwise inaccessible devices
Message-ID: <87aaqcjjvc.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is the second patch from the aforementioned pair debugging session
(of Milan and myself) and fixes another class of bugs (including repair
deadlocks). It turned out that the persistent device filter takes
precedence over everything else, including the
ignore_suspended_devices()-related checks. This is clearly wrong and a
reasonable solution is to just not trust the cache at all when
ignore_suspended_devices() is in effect.

I believe this may address at least RHBZ 606931 and possibly other BZs,
and a deadlock we have reproduced locally on our bar cluster (which is
not in bugzilla, as far as I know). The bug could certainly cause a lot
of grief...

Yours,
   Petr.

diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 6574d69..c9f709b 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -266,7 +266,7 @@ static int _lookup_p(struct dev_filter *f, struct device *dev)
 	void *l = dm_hash_lookup(pf->devices, dev_name(dev));
 	struct str_list *sl;
 
-	if (!l) {
+	if (!l || ignore_suspended_devices()) {
 		l = pf->real->passes_filter(pf->real, dev) ?
 		    PF_GOOD_DEVICE : PF_BAD_DEVICE;
 


