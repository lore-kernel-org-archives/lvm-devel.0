From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 1 Aug 2007 14:21:07 -0500
Subject: Re: [LVM2 PATCH 1/2] lvrename: add mirrored LV support
In-Reply-To: <46AA1024.5010606@ce.jp.nec.com>
References: <46AA1024.5010606@ce.jp.nec.com>
Message-ID: <24987A0D-5C3A-4339-BCB8-F387BBC6A1A1@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


On Jul 27, 2007, at 10:32 AM, Jun'ichi Nomura wrote:

> -	if ((lv->status & MIRRORED) ||
> -	    (lv->status & MIRROR_LOG) ||
> -	    (lv->status & MIRROR_IMAGE)) {
> -		log_error("Mirrored LV, \"%s\" cannot be renamed: %s",
> -			  lv->name, strerror(ENOSYS));
> -		return 0;
> -	}
> -

I don't think you want to remove this wholesale.  Testing reveals  
that you are allowed to change a sub-lv name by itself, which is not  
something we want, I don't think.  Instead, leave the checks in for  
MIRROR_LOG and MIRROR_IMAGE.

  brassow



