From: Takahiro Yasui <tyasui@redhat.com>
Date: Mon, 15 Mar 2010 22:37:05 -0400
Subject: [PATCH 0 of 10] LVM: mirrored log patches
In-Reply-To: <1267833465.10315.3.camel@hydrogen.msp.redhat.com>
References: <1267833465.10315.3.camel@hydrogen.msp.redhat.com>
Message-ID: <4B9EEED1.5060606@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow wrote:
> There will likely be at least one more round of these patches - mostly
> to clean-up the last patch I've been working on.
> 
> This round includes changes to the _lvconvert_mirrors function to allow
> it to handle the repair conversions necessary for 'lvconvert' to accept
> only top-level LVs.  It also includes suggested changes from Taka
> (thanks for those!).

I checked your patch set. It seems that one of my suggestion has not
been implemented yet, and some of my tests failed.

https://www.redhat.com/archives/lvm-devel/2010-February/msg00214.html

In this patch set, _lvconvert_mirrors_aux() repairs in the order
of mirror images and mirror log. As I explained in the above url,
mirror log should be repaired before mirror images are repaired
because the repair procedure of the mirror image calls suspend_lv()
and that causes deadlock. The deadlock happens because suspending
LV with failed log device doesn't finish.

What do you think calling _lv_update_log_type() before and after
repairing mirror legs in _lvconvert_mirrors_aux()?

Other tests worked well so far. Thank you for fixing issues.

Thanks,
Taka


