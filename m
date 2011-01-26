From: Peter Rajnoha <prajnoha@redhat.com>
Date: Wed, 26 Jan 2011 12:12:17 +0100
Subject: [PATCH 04/17] Add format_instance support for pv_read.
In-Reply-To: <4D400015.5040908@redhat.com>
References: <1295867048-21558-1-git-send-email-prajnoha@redhat.com>	<1295867048-21558-5-git-send-email-prajnoha@redhat.com>
	<87lj29ru07.fsf@twilight.int.mornfall.net.>
	<4D400015.5040908@redhat.com>
Message-ID: <4D400191.3070103@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 01/26/2011 12:05 PM +0100, Peter Rajnoha wrote:
> It's because this _pv_read could be part of a vg_read (e.g. _vg_read_orphans).

..for the other "vg_read", we call the other fn, the _read_pv (_pv_read - read_pv
nice :) ). That one already handles the fid through the "fid" parameter and
then we call add_pvl_to_vgs which does the job of referencing the pv->fid to pv->vg->fid
(the format instance is already done before that where we create the VG-based
fid). So everything is tied together nicely...

Peter


