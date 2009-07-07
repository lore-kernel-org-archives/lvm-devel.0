From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 7 Jul 2009 22:39:12 +0100
Subject: [PATCH 6/7] Add vg_set_alloc() liblvm function and move vgchange logic inside.
In-Reply-To: <1246953008-27609-7-git-send-email-dwysocha@redhat.com>
References: <1246953008-27609-1-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-2-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-3-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-4-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-5-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-6-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-7-git-send-email-dwysocha@redhat.com>
Message-ID: <20090707213911.GI11082@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jul 07, 2009 at 03:50:07AM -0400, Dave Wysochanski wrote:
> Add vg_set_alloc() liblvm function and move vgchange logic inside.

For the interface, we should probably say 'set_alloc_policy' rather
than just 'set_alloc'.

> +	if (alloc == vg->alloc) {
> +		log_error("Volume group allocation policy is already %s",
> +			  get_alloc_string(vg->alloc));
> +		return 1;
> +	}

It's back to 'change' vs. 'set' again:-)
If this input is acceptable now, either go for WARNING like we do in other
places where we proceed, or alternatively just reduce the message to
log_verbose if you don't consider it important.

Alasdair


