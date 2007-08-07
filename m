From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Tue, 07 Aug 2007 17:15:53 -0400
Subject: Re: LVM2/lib/metadata lv_manip.c
In-Reply-To: <20070807125220.GO2064@agk.fab.redhat.com>
References: <20070806203548.25477.qmail@sourceware.org>
	<20070807125220.GO2064@agk.fab.redhat.com>
Message-ID: <46B8E109.80905@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave,
thanks a lot for rapidly applying fixes for Alasdair's comments.

Alasdair,
as for the comments about extra checks in _rename_sub_lv(),
they were to allow future enhancements like stacked LV, having
LVs with independent names as sub LVs, not only the internal ones.
But, for now, the checks are not necessary unless metadata is broken.
Also we can seek for other solutions like marking independently
named LV as you mentioned.

So, I'm ok with this:
> One simple way out perhaps?
>   Check if it begins with lv_name_old: if so, replace that part of the
>   string with lv_name_new;  if not, log_error and make the entire rename
>   fail.  (Add complete name validation to vg_validate, if you wish.)

A patch is attached.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: lvm2-lvrename-simplify-sublv-name-check.patch
Type: text/x-patch
Size: 1675 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070807/07c00a58/attachment.bin>
