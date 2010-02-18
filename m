From: Jonathan Brassow <jbrassow@redhat.com>
Date: Thu, 18 Feb 2010 10:48:54 -0600
Subject: [PATCH 0 of 13] LVM add 'mirrored' log type
In-Reply-To: <1266429310.29358.35.camel@hydrogen.msp.redhat.com>
References: <1266429310.29358.35.camel@hydrogen.msp.redhat.com>
Message-ID: <B66E0CF9-8028-4597-AE6E-3B2F1A7B213A@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I'm also testing the other approach; that is, allowing lvconvert to  
take non-top-level LVs (e.g. "lv_mlog").  It seems to work just fine.   
We might want to strongly consider allowing this.

There are drawbacks to this approach too, however.  For example, when  
one of the devices of the log fails, it will be treated as an 'image'  
failure, and not a 'log' failure (I can fix that though by checking  
its lv->status).  If we decide to go this route, we will have to  
decide if this is the behavior we want or not.  (Once the log is  
linear, it will behave as you would expect - either being replaced or  
removed according to the log policy.)

  brassow

On Feb 17, 2010, at 11:55 AM, Jonathan Brassow wrote:

> I've fixed the segfaults Taka reported.  I've also begun to go through
> and fix the remaining issues with handling device failures in the
> various different scenarios.  I could use some help testing all the
> different variations.  I've described below some of the different
> permutations that will now exist.  I will be going through and testing
> these as well.
>
> Device failure handling policies:
> =================================
> The following policies are available for both mirror logs and mirror
> images...
> "remove" (rm):
> Take out the failed device from the LV and do nothing else.  IOW, just
> make things consistent again.
>
> "replace" (rp):
> Remove the failed device and attempt to replace it with available  
> space
> in the VG.  IOW, try to recreate what was lost.
>
> Device failure scenarios:
> =========================
> "2devs":
> You will have to use '--alloc anywhere' to get the mirrored log to be
> placed on the same devices as the mirror images.  Failing a single
> device will result in a failure of an image in the mirrored log and  
> the
> mirror itself - simultaneously.  Obviously, a "replace" policy will
> fail, but the results should be the same as "remove".  The final  
> result
> should be a linear device.
>
> "3devs":
> '--alloc anywhere' is still necessary.  Failing a single leg can  
> affect
> the mirror, its mirrored log, or both.  The "remove" policy can  
> leave a
> lone linear LV or a mirror with a linear log.  The "replace" policy
> should be able to restore the LV.  It is also possible to test 3-way
> mirrors and fail one of the legs - presumably leaving a 2-way mirror  
> and
> a mirrored log.
>
> "5devs":
> Gives the ability to have the mirrored log on separate devices from  
> the
> mirror images and be able to "replace" the device.
>
> So, the it is necessary to test all of the fault scenarios in each  
> cell
> of the following matrix.  Any help would be most welcome.
>
>          | 2devs | 3devs | 5devs |
> ----------|-------|-------|-------|
> rm_l,rm_i |       |       |       |
> rm_l,rp_i |       |       |       |
> rp_l,rm_i |       |       |       |
> rp_l,rp_i |       |       |       |
> -----------------------------------
>
> brassow
>
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


