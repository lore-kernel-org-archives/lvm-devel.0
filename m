From: yuan yuan <yuanyuan0526@gmail.com>
Date: Fri, 12 Dec 2008 22:33:33 +0800
Subject: Re: [linux-lvm] A question about the metadata circular buffer
In-Reply-To: <20081212124917.GA24785@agk.fab.redhat.com>
References: <b2a58a4c0812120435jca6a842m13a389a5aa6d27e3@mail.gmail.com>
	<20081212124917.GA24785@agk.fab.redhat.com>
Message-ID: <b2a58a4c0812120633q556fc21bod0634cff3747230a@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Dec 12, 2008 at 8:49 PM, Alasdair G Kergon <agk@redhat.com> wrote:

> On Fri, Dec 12, 2008 at 08:35:46PM +0800, yuan yuan wrote:
> >     if ((new_wrap && old_wrap) ||
> >             (rlocn && (new_wrap || old_wrap) && (new_end >
> rlocn->offset))
> > ||
> >             (mdac->rlocn.size >= mdah->size)) {
> >                 log_error("VG %s metadata too large for circular buffer",
> >                           vg->name);
>
> > My question is , for a circular buffer, why should we check so many
> > conditions instead of just checking (mdac->rlocn.size >= mdah->size)?
>
> The buffer has to hold *two* versions of the metadata during a change,
> the old and the new version, and those two could be different sizes.
>

Does this mean that if the buffer size is 2K, the size of the metadata can't
be larger than 1K?
What will happen if we just hold one version?


>
> Alasdair
> --
> agk at redhat.com
>
> _______________________________________________
> linux-lvm mailing list
> linux-lvm at redhat.com
> https://www.redhat.com/mailman/listinfo/linux-lvm
> read the LVM HOW-TO at http://tldp.org/HOWTO/LVM-HOWTO/
>
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20081212/2745c85f/attachment.htm>
