From: Petr Rockai <prockai@redhat.com>
Date: Sun,  3 May 2009 13:38:52 +0200
Subject: [PATCH] Use (new) vg_read(_for_update) in client code.
Message-ID: <1241350741-31349-1-git-send-email-prockai@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this patchset is rebased and updated version of the previous rebase of the
vg_read series. Most of the patches had lots of conflicts, mostly with Milan's
per-VG pool work. Some review wrt. pool behaviour is needed, since we may have
introduced some leaks again. The tests are passing though, and I have tried to
make sure that I am not breaking anything.

Anyway, I'd welcome a timely review, as the rebases are quite tedious (also not
made easier by the fact that part of the earlier patches changed semantics
between review and corresponding CVS checkin).

There are still further patches blocking on this, but I'll only rebase them
when this batch (which is relatively independent of the rest) is checked in.

Yours,
   Petr.

PS: I have upgraded git-core and git-email since the last batch, and it is
printing lots of perl errors in the terminal now... hopefully, it won't mangle
the e-mails too badly.


