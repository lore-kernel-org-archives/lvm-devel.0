From: Lakshmi Narasimhan Sundararajan <lsundararajan@purestorage.com>
Date: Mon, 6 Mar 2023 20:32:46 +0530
Subject: lvmetad status
In-Reply-To: <655bd398-9bc0-7b1c-0891-598ca4c8d36d@redhat.com>
References: <CAFe+wq235CR3DavwD+z200MAe4-CnWQveF2CX2S5vm0qSmTfLA@mail.gmail.com>
 <655bd398-9bc0-7b1c-0891-598ca4c8d36d@redhat.com>
Message-ID: <CAFe+wq1_AqQRREpvW9AkztbC54+mbWWb7nOQD=pCzERrg25JZQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Thanks Zdenek, How about in memory caching of device properties? That was
also supposedly a function of lvmetad isnt it?
Do we have a suitable replacement for the same?

Also, why is lvmetad deprecation not called out more noticeable. I still
see man pages and many distro continue to use lvmetad.

Thanks


On Mon, Mar 6, 2023 at 4:15?PM Zdenek Kabelac <zkabelac@redhat.com> wrote:

> Dne 03. 03. 23 v 13:19 Lakshmi Narasimhan Sundararajan napsal(a):
> > Hi Team!
> > A very good day to you all.
> > Can anyone please confirm the current status of lvmetad?
> > Is this deprecated? On the lvm2 dev branch I see as early as 2018 that
> it
> > has been removed, but I do not see any other information anywhere on its
> status.
> >
> > Is there some place where the reason is called out?
> > I still see distros default flag to use_lvmetad = true and man pages
> calling
> > out usage of lvmetad.
>
>
> Hi
>
>
> lvmetad has been removed and replaced with better udev rule logic and
> files
> stored in /run/lvm directory.
>
> So autoactivation works without this daemon.
>
>
> Regards
>
>
> Zdenek
>
>
>
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20230306/6d7e10a8/attachment.htm>
