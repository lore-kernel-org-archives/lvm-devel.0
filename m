From: Takahiro Yasui <tyasui@redhat.com>
Date: Mon, 22 Feb 2010 04:18:35 -0500
Subject: [PATCH 0 of 13] LVM add 'mirrored' log type
In-Reply-To: <B66E0CF9-8028-4597-AE6E-3B2F1A7B213A@redhat.com>
References: <1266429310.29358.35.camel@hydrogen.msp.redhat.com>
	<B66E0CF9-8028-4597-AE6E-3B2F1A7B213A@redhat.com>
Message-ID: <4B824BEB.60708@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Jonathan Brassow wrote:
> I'm also testing the other approach; that is, allowing lvconvert to take
> non-top-level LVs (e.g. "lv_mlog").  It seems to work just fine.  We
> might want to strongly consider allowing this.
> 
> There are drawbacks to this approach too, however.  For example, when
> one of the devices of the log fails, it will be treated as an 'image'
> failure, and not a 'log' failure (I can fix that though by checking its
> lv->status).  If we decide to go this route, we will have to decide if
> this is the behavior we want or not.  (Once the log is linear, it will
> behave as you would expect - either being replaced or removed according
> to the log policy.)

This approach requires two threads in dmeventd; it is for a top-level LV,
and another is for a mirrored log. If a leg and mirrored log failed at
the same time, a mirrored log needs to be recovered before a top-level LV.
I think this approach is also good if we can handle this situation.

Thanks,
Taka




