From: Peter Rajnoha <prajnoha@redhat.com>
Date: Tue, 17 Apr 2018 11:46:43 +0200
Subject: [PATCH RESEND 1/2] lvm2: 69-dm-lvm-metad.rules: explicit pvscan rule
In-Reply-To: <20180416185341.8588-2-mwilck@suse.com>
References: <20180416185341.8588-1-mwilck@suse.com>
	<20180416185341.8588-2-mwilck@suse.com>
Message-ID: <8adb2a0c-3aa2-2233-0ba7-40e95cc602a5@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 04/16/2018 08:53 PM, Martin Wilck wrote:
> Make the distinction between the cases with and without systemd
> background jobs explicit in 69-dm-lvm-metad.rules rather than
> substituting the rule from the Makefile. At this stage,
> this improves only readibility, at the cost of one GOTO statement.
> 
> The next patch will add more differences between the two cases (mostly
> comments), which are practically impossible to generate with the current
> string subsitution approach.
> 
> This patch introduces no functional change to the udev rules.
> 
> Signed-off-by: Martin Wilck <mwilck@suse.com>
> ---
>  udev/69-dm-lvm-metad.rules.in | 19 ++++++++++++++++++-
>  udev/Makefile.in              |  7 ++++---
>  2 files changed, 22 insertions(+), 4 deletions(-)
> 

OK, I agree, this makes it a bit more readable, applied:

https://sourceware.org/git/?p=lvm2.git;a=commit;h=99bfbbf229acf4548f1ffc06625f464dc0ae4ca4

Thanks

-- 
Peter


