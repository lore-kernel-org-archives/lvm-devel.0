From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 17 Feb 2016 11:08:22 +0100
Subject: [PATCH] dmsetup: treat no devices found as error
In-Reply-To: <1455695471-5710-1-git-send-email-hare@suse.de>
References: <1455695471-5710-1-git-send-email-hare@suse.de>
Message-ID: <56C44696.8020806@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 17.2.2016 v 08:51 Hannes Reinecke napsal(a):
> When calling 'dmsetup ls' and no devices are found the program will
> print out 'No devices found' and exit normally.
> This makes it really hard for the calling application to determine
> if the output 'No devices found' is a valid device or not.
> This patch moves the 'No devices found' string to stderr and
> sets the return code to non-0 to allow calling applications to
> better differentiate here.
>
> Signed-off-by: Hannes Reinecke <hare@suse.com>
> ---
>   tools/dmsetup.c | 3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/tools/dmsetup.c b/tools/dmsetup.c
> index 4db6004..3629931 100644
> --- a/tools/dmsetup.c
> +++ b/tools/dmsetup.c
> @@ -1835,7 +1835,8 @@ static int _process_all(const struct command *cmd, const char *subcommand, int a
>
>   	if (!names->dev) {
>   		if (!silent)
> -			printf("No devices found\n");
> +			fprintf(stderr, "No devices found\n");
> +		r = 0;
>   		goto out;
>   	}
>

Hi

NACKing this patch.

dmsetup cannot change behavior this way - it'd cause major regression for 
existing script using dmsetup (rule #1 - no regressions).


'No devices found'  when you list empty table  is correct & expected state.

So return code is  'success' in this case
(and as success output goes to stdout).


I'm actually not even sure why would you want to base ANY script on error code 
as empty dm table is not an error (btw with this logic   'dmsetup table'  for 
empty table would also need to return error and so on...)


You may get mapping pairs   major:minor with 'dmsetup ls -o devno' :

"vg-lvol0	(253:0)"
...


or with 'dmsetup ls -o blkdevname' pairs like this:

"vg-lvol0	(dm-0)"
...


and when no device exists:
"No devices found"


and all you need to do is just check for string on output line (stdout).
(i.e. line does not have '(', ':', ')'  --> so it's empty table --> no device...)

Technically I don't see much difference in checking string or error code 
(which is just not an error).


On the other hand - when 'dmsetup' has a real error - you should take correct 
steps to work around some real error (e.g. out-of-mem system).
But usually 'error' code behavior is 'exception' state - and as exception
it's typically more 'expensive' in code handling...


Regards

Zdenek


