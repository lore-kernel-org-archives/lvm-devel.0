From: ben <benscott@nwlink.com>
Date: Wed, 4 Jul 2012 13:41:29 -0700
Subject: liblvm2app stripe_size reported wrong
In-Reply-To: <20120704202606.GK22022@agk-dp.fab.redhat.com>
References: <201207041320.24826.benscott@nwlink.com>
	<20120704202606.GK22022@agk-dp.fab.redhat.com>
Message-ID: <201207041341.29807.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wednesday, July 04, 2012 1:26:06 PM Alasdair G Kergon wrote:
> On Wed, Jul 04, 2012 at 01:20:24PM -0700, ben wrote:
> > Using Debian liblvm2app2.2:amd64   version 2.02.95-4 the size of stripes
> > on segments is reported incorrectly from the library function. The
> > number of bytes is divided by 512, which I assume is sectors.
> 
> Please be specific.
> Which function?
> What value does it give you?
> What should it give you?
> What does the output of 'lvs' show?
> 
> Alasdair
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel

I am using:

    value = lvm_lvseg_get_property(lvm_lvseg, "stripesize");
    if (value.is_valid)
          segment->stripe_size = value.value.integer; 
   /* now  value.value.integer == 128 */

lvs -o+stripesize
  LV    VG   Attr     LSize Pool Origin Data%  Move Log Copy%  Convert Stripe
  lvol0 vg1  -wi-a--- 1.00g                                            64.00k

Thank you.


