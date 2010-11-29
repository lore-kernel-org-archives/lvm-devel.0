From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 29 Nov 2010 20:16:02 +0000
Subject: [PATCH 10/29] Add some backtrace - Attention please
In-Reply-To: <4b104b57c2aff346b77434aa52d0126801e25af9.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<4b104b57c2aff346b77434aa52d0126801e25af9.1290682013.git.zkabelac@redhat.com>
Message-ID: <20101129201601.GV29380@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Nov 25, 2010 at 11:55:14AM +0100, Zdenek Kabelac wrote:
> -		dm_task_set_name(dmt, dirent->d_name);
> -		dm_task_run(dmt);
> +		if (!dm_task_set_name(dmt, dirent->d_name)) {
> +			stack;
> +			continue; /* try next name */
> +		}
> +		if (!dm_task_run(dmt))
> +                        stack;  /* keep going */

Yes, best endeavours makes sense in this (repair) function.
but add some 'r = 0' to return 0 not 1 if any of them failed.

Ack.

Alasdair


