From: Nikhil Kshirsagar <nkshirsa@redhat.com>
Date: Tue, 30 Jul 2019 13:32:29 +0530
Subject: lvmcache in writeback mode gets stuck flushing dirty blocks
In-Reply-To: <5d3fce60.1c69fb81.f521b.46a8@mx.google.com>
References: <5d3fce60.1c69fb81.f521b.46a8@mx.google.com>
Message-ID: <CAMNNMLH8jxxRYNyZn6s=Qqhgt7kA5CereTUw8GSNeUrJ5V9iDw@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This used to happen if the chunksize increased as a result of needing to
use more than a million chunks to store the size of the cached lv. What is
the size of the pool?

Regards,
Nikhil.

On Tue, 30 Jul, 2019, 1:25 PM Lakshmi Narasimhan Sundararajan, <
lns@portworx.com> wrote:

> Hi Team,
>
> A very good day to all.
>
>
> I am using lvmcache in writeback mode. When there are dirty blocks still
> in the lv, and if needs to be destroyed or flushed, then
>
> It seems to me that there are some conditions under which the dirty data
> flush gets stuck forever.
>
>
>
>
>
> As an example:
>
> root at pdc4-sm35:~# lvremove -f pwx0/pool
>
>   367 blocks must still be flushed.
>
>   367 blocks must still be flushed.
>
>   367 blocks must still be flushed.
>
>   367 blocks must still be flushed.
>
>   367 blocks must still be flushed.
>
>   367 blocks must still be flushed.
>
> ^C
>
> root at pdc4-sm35:~#
>
>
>
> I am running these version:
>
> root at pdc4-sm35:~# lvm version
>
>   LVM version:     2.02.133(2) (2015-10-30)
>
>   Library version: 1.02.110 (2015-10-30)
>
>   Driver version:  4.34.0
>
> root at pdc4-sm35:~#
>
>
>
>
>
> This issue seems old and reported multiple places. There have been some
> acknowledgement that this issue is resolved in 2.02.133, but still I see
> it. Also, I have seen some posts report it in 2.02.170+ as well (here:
> https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=878441) (Package: lvm2
> Version: 2.02.173-1 Severity: normal)
>
>
>
> I filed one here myself, https://github.com/lvmteam/lvm2/issues/22,
> trying  to understand from you experts where we are on this?
>
>
>
> I would sincerely appreciate your help in understanding the state of this
> issue in more detail.
>
>
>
> Best regards
> LN
>
> Sent from Mail <https://go.microsoft.com/fwlink/?LinkId=550986> for
> Windows 10
>
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190730/562a564e/attachment.htm>
