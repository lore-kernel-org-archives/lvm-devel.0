From: ben <benscott@nwlink.com>
Date: Sat, 21 May 2011 16:12:22 -0700
Subject: lvm2app lv properties stripe size issue
In-Reply-To: <201105092042.22143.benscott@nwlink.com>
References: <201105092042.22143.benscott@nwlink.com>
Message-ID: <201105211612.22830.benscott@nwlink.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Monday, May 09, 2011 08:42:21 PM ben wrote:
> When using:
> 
>    value = lvm_lvseg_get_property(lvm_lvseg, "stripesize");
> 
> The value returned seems to be double what I expect. Is this function
> returning disk sectors (512 bytes) and not 1024 byte units?
> 
> Thank you.
> 
> 
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel

shouldn't this function return bytes? Anyone?

Thank you


