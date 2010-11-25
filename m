From: Petr Rockai <prockai@redhat.com>
Date: Thu, 25 Nov 2010 15:48:28 +0100
Subject: [PATCH 1/2] Update errno codes for vg_read() and lvm2app lvm_vg_open().
In-Reply-To: <1290488470-21743-2-git-send-email-wysochanski@pobox.com> (Dave
	Wysochanski's message of "Tue, 23 Nov 2010 00:01:09 -0500")
References: <1290488470-21743-1-git-send-email-wysochanski@pobox.com>
	<1290488470-21743-2-git-send-email-wysochanski@pobox.com>
Message-ID: <8762vlo3wj.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I am not checking this in yet, I would like to discuss the value choices
first a bit. Presumably, once we set them, we are sort of stuck with the
choices, so we should be careful.

Dave Wysochanski <wysochanski@pobox.com> writes:

> Update errno codes for vg_read error paths:
> - EINVAL: invalid vg_name
> - ENOLCK: lock_vol fails
EBUSY? (But really, this probably depends on *why* _lock_vol
failed... maybe we need to drill down here?)

> - ENODEV: VG 'vgname' does not exist
> - EPROTOTYPE: VG is clustered but locking not clustered
What about just EPROTO? Or ENOLCK?

> - EROFS: VG is read-only
If we want to re-use existing errnos, I would go with EACCESS or EPERM
here. EROFS *sounds* similar, but is IMHO a semantical misfit.

> - EUCLEAN: VG is inconsistent
This one is tricky. I would almost not assign an errno here at least for
now.

Yours,
   Petr.


