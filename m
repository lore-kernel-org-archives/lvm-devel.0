From: Petr Rockai <prockai@redhat.com>
Date: Tue, 13 Apr 2010 16:17:43 +0200
Subject: [PATCH] Allow incomplete (partial) mirror repairs in lvconvert --repair.
Message-ID: <877hob4et4.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is a third rebase (actually, this is a rewrite, due to intervening
changes to lvconvert) of the RHBZ 560105+560111 fix. Please review...

Petr Rockai <prockai@redhat.com> writes:
> the attached patch should address RHBZ 560105 and 560111. This changes
> lvconvert --repair as follows:
>
> - downconvert (like before)
> - try to replace everything (like before)
> - if the second step fails, try to reduce number of mirror images (one
>   at a time) until only 2 remain
> - if this still fails and we used to have a disk log, try 2-way + corelog
>
> This should basically give you an LV that is closest to the original
> mirror, in the space constraints of free PV areas.
>
> Failures to replace (part of) the failed devices are now reported as
> warnings.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvconvert-repair-partial.diff
Type: text/x-diff
Size: 9122 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100413/dc3ca215/attachment.bin>
