From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 13 Jul 2009 21:01:03 +0100
Subject: [PATCH 3/5] Add lvm_vg_* APIs to create and modify VGs.
In-Reply-To: <1247458358-24590-4-git-send-email-dwysocha@redhat.com>
References: <1247458358-24590-1-git-send-email-dwysocha@redhat.com>
	<1247458358-24590-2-git-send-email-dwysocha@redhat.com>
	<1247458358-24590-3-git-send-email-dwysocha@redhat.com>
	<1247458358-24590-4-git-send-email-dwysocha@redhat.com>
Message-ID: <20090713200103.GA31951@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Jul 13, 2009 at 12:12:36AM -0400, Dave Wysochanski wrote:
>  liblvm/vg.c        |   84 ++++++++++++++++++++++++++++++++++++++++++++++++++++

Add something else to the name 'vg' to make it more distinctive.

> +/**
> + * Create a VG with default parameters.

Extend all the comments to give more information on how the API
should be used.  E.g. Explain here that you must close it with
vg_close(), but must you also do that if you get an error?

> + * Write a VG to disk.
Does it commit it?

> +/**
> + * Close a VG opened with lvm_vg_create
> + *
> + * \param   vg
> + *          VG handle obtained from lvm_vg_create.
> + *
> + * \return  Status code of 1 (success) or 0 (failure).

What are the failure modes?  E.g. Can it fail if passed a
valid handle, and if so what should you do?

Alasdair


