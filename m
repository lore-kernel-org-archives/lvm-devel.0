From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 20:56:58 +0000
Subject: [PATCH 18/29] Check result of vginfo_from_vgname
In-Reply-To: <5fc3db8c4744cb62207355b79f41372512484558.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<5fc3db8c4744cb62207355b79f41372512484558.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129205658.GC29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:22AM +0100, Zdenek Kabelac wrote:
> Keep static code analyzers happier. In this case there is a very small
> chance bug could appear (memory fault?). 

Our code doesn't attempt to protect against memory faults!

We are entitled to assume the orphan VGs are always there, so if they
aren't it's an internal error, yes.

>  			dm_list_iterate_items_safe(info2, info3, &primary_vginfo->infos) {
>  				orphan_vginfo = vginfo_from_vgname(primary_vginfo->fmt->orphan_vg_name, NULL);
> +				if (!orphan_vginfo) {
> +					log_error(INTERNAL_ERROR "vginfo for orphan_vg_name failed.");

Which orphan VG?  If this failed, I'd want to know what it was trying to look up!
INTERNAL_ERROR "Orphan vginfo %s lost from cache."

Ack with a more-useful error message.

Alasdair


