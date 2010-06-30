From: Petr Rockai <prockai@redhat.com>
Date: Wed, 30 Jun 2010 22:43:53 +0200
Subject: [PATCH] restore the "removemissing" behaviour of lvconvert --repair --use-policies
Message-ID: <87y6dwjlo6.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

When we are doing lvconvert --repair --use-policies, which is the
combination that is used in dmeventd, at the end of the repair, we clean
up any bad (missing) PVs from the VG that have become empty. In common
cases, this leads to a clean and consistent VG after a repair, with no
missing PVs in it.

This feature has regressed with the mirroredlog patches for lvconvert.

I conjecture, that this patch should fix Corey's RHBZ 606528 (it is not
entirely clear what exactly happened there yet, but I believe this could
definitely explain the behaviour).

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair-removemissing.diff
Type: text/x-diff
Size: 2318 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100630/d633f82e/attachment.bin>
