From: Alasdair G Kergon <agk@redhat.com>
Date: Sat, 6 Dec 2008 02:26:53 +0000
Subject: [PATCH] Make _init_rand() thread safe - use rand_r() instead of rand().
In-Reply-To: <1228517565-28873-1-git-send-email-dwysocha@redhat.com>
References: <1228517565-28873-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20081206022653.GF26097@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Dec 05, 2008 at 05:52:45PM -0500, Dave Wysochanski wrote:
> This random code is for temp files.  Other code which uses
> /dev/urandom is used for uuids.  Should we be using /dev/urandom
> everywhere?
 
Well look what we are using it for - we are not relying on the randomness
- if the filename is already in use, we just try another one - so it's
nothing to worry about.

> +	if (!create_temp_name(temp_dir, temp_file, sizeof(temp_file), &fd,
> +			      &vg->cmd->rand_seed)) {

Just pass 'cmd'? (as first arg)

Does this patch do enough to ensure each thread will get a different value of
'seed'?

Alasdair
-- 
agk at redhat.com


