From: Eric Ren <renzhengeek@gmail.com>
Date: Thu, 11 Apr 2019 19:26:22 +0800
Subject: Aborting. LV mythinpool_tmeta is now incomplete
In-Reply-To: <47346a29-e6c7-6e22-4360-2d07e2ec7be3@redhat.com>
References: <CAKM4AewbcVR1x0cK8hWLCRxb1BzDd-F+WeK6ObUmB35N1HTqOA@mail.gmail.com>
	<47346a29-e6c7-6e22-4360-2d07e2ec7be3@redhat.com>
Message-ID: <CAKM4Aexm31mYW8WDeiZ4shCoysCcGjic8zV0XiVqEVZvKz-ecQ@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Zdenek,

Thanks for your reply. The use case is for containerd snapshooter, yes, all
lvm setup is on host machine, creating thin LV for VM-based/KATA container
as rootfs.

For example:
https://github.com/containerd/containerd/pull/3136

and

https://github.com/containerd/containerd/pull/3022

So, we're evaluating such solution now~

Thanks,
Eric



On Thu, 11 Apr 2019 at 19:04, Zdenek Kabelac <zkabelac@redhat.com> wrote:

> Dne 11. 04. 19 v 2:27 Eric Ren napsal(a):
> > Hello list,
> >
> > Recently, we're exercising our container environment which uses lvm to
> manage
> > thin LVs, meanwhile we found a very strange error to activate the thin
> LV:
> >
>
>
> Hi
>
>
> The reason is very simple here - lvm2 does not work from containers.
> It's unsupported and if it partially works - it's a pure lucky case.
>
> ATM it's simply clear statement that lvm2 cannot be used from container
> simply
> because block layer is not namespaced.
>
> I'd give here long list of reason why it currently cannot work, but for
> now  -
> you should focus on making all 'device-block' operation on you host - and
> pass
> results to container.
>
> Regards
>
> Zdenek
>


-- 
- Eric Ren
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20190411/15e556b9/attachment.htm>
