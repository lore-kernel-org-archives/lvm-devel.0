From: David Teigland <teigland@redhat.com>
Date: Fri, 30 Sep 2022 10:32:51 -0500
Subject: [RFC PATCH] lvmlockd: purge the lock resources left in previous lockspace
In-Reply-To: <ff6e311a-5e87-2fe8-7c11-46aa7aaa048e@suse.com>
References: <ff6e311a-5e87-2fe8-7c11-46aa7aaa048e@suse.com>
Message-ID: <20220930153251.GA1502@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Sep 30, 2022 at 09:57:08PM +0800, Lidong Zhong wrote:
> ???? /* FIXME: purge any remaining orphan locks in each rejoined ls? */

You're fixing it, so we can drop the comment.

> +??? ??? ??? ??? file = fopen(ls_comms_path, "r");
> +??? ??? ??? ??? if (!file)
> +??? ??? ??? ??? ??? continue;
> +??? ??? ??? ??? if (fgets(line, LOCK_LINE_MAX, file)) {
> +??? ??? ??? ??? ??? rv = sscanf(line, "%d", &val);
> +??? ??? ??? ??? ??? if (rv == 1)
> +??? ??? ??? ??? ??? ??? return val;

Is this missing an fclose?

Please confirm that this works for your test case and I'll include it.

Thanks,
Dave
