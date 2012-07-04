From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 4 Jul 2012 21:53:01 +0100
Subject: liblvm2app stripe_size reported wrong
In-Reply-To: <201207041341.29807.benscott@nwlink.com>
References: <201207041320.24826.benscott@nwlink.com>
	<20120704202606.GK22022@agk-dp.fab.redhat.com>
	<201207041341.29807.benscott@nwlink.com>
Message-ID: <20120704205301.GM22022@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Jul 04, 2012 at 01:41:29PM -0700, ben wrote:
> I am using:
>     value = lvm_lvseg_get_property(lvm_lvseg, "stripesize");
>     if (value.is_valid)
>           segment->stripe_size = value.value.integer; 
>    /* now  value.value.integer == 128 */
> lvs -o+stripesize
>   LV    VG   Attr     LSize Pool Origin Data%  Move Log Copy%  Convert Stripe
>   lvol0 vg1  -wi-a--- 1.00g                                            64.00k
 
Well this field is stored in sectors internally, so it's probably just
returning that value directly.

Whether it should be converting or not, I don't know.
This doesn't seem to be documented and so we'll need to look at how other
fields are handled to see if there's a consistent 'rule' here or not.

Alasdair


