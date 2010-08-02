From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 2 Aug 2010 20:42:17 +0100
Subject: [PATCH] Add check for semaphore kernel support
In-Reply-To: <4C571B89.2030309@redhat.com>
References: <4C571B89.2030309@redhat.com>
Message-ID: <20100802194217.GC18149@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Aug 02, 2010 at 09:24:57PM +0200, Peter Rajnoha wrote:
> We also need to check for kernel semaphore support (part of System V IPC,

Ack.

> +static int _check_semaphore_is_supported()

> +	arg.array = (unsigned short int *) (void *) &seminfo;

Double cast?
The way I read the man page that could be arg.__buf = &seminfo.

Alasdair


