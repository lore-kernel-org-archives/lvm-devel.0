From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 28 Sep 2009 09:17:59 -0400
Subject: Re: [PATCH 2/3] differentiate between S.I. and binary units in output
In-Reply-To: <20090928124906.GD5351@agk-dp.fab.redhat.com>
References: <1253979227-28051-1-git-send-email-impulze@impulze.org>
	<1253979227-28051-2-git-send-email-impulze@impulze.org>
	<20090928124906.GD5351@agk-dp.fab.redhat.com>
Message-ID: <20090928131758.GA26763@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 28 2009 at  8:49am -0400,
Alasdair G Kergon <agk@redhat.com> wrote:

> On Sat, Sep 26, 2009 at 05:33:46PM +0200, Daniel Mierswa wrote:
> > For binary based uints:
> >  Long output strings (unsed) will be Kibibyte, Mebibyte, etc.
> >  Short output strings will be KiB, MiB, etc.
> >  Unit output strings will be lower-cased: k, m, g, etc.
> >  Sectors determined by division with 512 will be suffixed with s.
> > For S.I. based units:
> >  Long output strings (unused) will be Kilobyte, Megabyte, etc.
> >  Short output strings will be kB, MB, GB, etc.
> >  Unit output strings will be upper-cased: K, M, G, etc.
> >  Sectors determined by division with 500 will be suffixed with S.
> 
> Bytes, Units and Sectors are special cases - in a separate group.
> A sector is always 512 bytes.  I don't see any need to support 500-byte
> sectors.

I agree that 500-byte sectors aren't meaningful but I added support for
them a few months ago to be consistent, see:
http://sources.redhat.com/git/?p=lvm2.git;a=commit;h=69da2ac0


