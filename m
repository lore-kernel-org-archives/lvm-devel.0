From: Dave Wysochanski <dwysocha@redhat.com>
Date: Wed, 22 Jul 2009 16:16:21 -0400
Subject: [PATCH] Update vg_create to use lvm_errno and return NULL upon error.
In-Reply-To: <1248292346-14208-1-git-send-email-dwysocha@redhat.com>
References: <1248292346-14208-1-git-send-email-dwysocha@redhat.com>
Message-ID: <1248293781.2441.83.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, 2009-07-22 at 15:52 -0400, Dave Wysochanski wrote:
> We must update vgsplit and vgcreate at the same time or we break the
> nightly tests.
> 
> Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
> ---
> index 35c425a..158a532 100644
> --- a/tools/vgsplit.c
> +++ b/tools/vgsplit.c
> @@ -264,7 +264,7 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
>  	log_verbose("Checking for new volume group \"%s\"", vg_name_to);
>  	/*
>  	 * First try to create a new VG.  If we cannot create it,
> -	 * and we get FAILED_EXIST (we will not be holding a lock),
> +	 * and we get EEXIST (we will not be holding a lock),
>  	 * a VG must already exist with this name.  We then try to
>  	 * read the existing VG - the vgsplit will be into an existing VG.
>  	 *
> @@ -273,15 +273,12 @@ int vgsplit(struct cmd_context *cmd, int argc, char **argv)
>  	 * system.  Thus, the split will be into a new VG.
>  	 */
>  	vg_to = vg_create(cmd, vg_name_to);
> -	if (vg_read_error(vg_to) == FAILED_LOCKING) {
> -		log_error("Can't get lock for %s", vg_name_to);
> -		vg_release(vg_to);
> +	if (!vg_to && stored_errno() != EXIST) {

This is a silly typo - should be EEXIST.  I corrected this error in my
local repo and verified testsuite passes.




