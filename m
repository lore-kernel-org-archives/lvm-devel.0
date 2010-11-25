From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 26 Nov 2010 00:02:33 +0100
Subject: [PATCH 29/29] Check for NULL pointer
In-Reply-To: <5aaa9a83ca612d4594736d7b7c34dcd5adc0a611.1290682013.git.zkabelac@redhat.com>
References: <cover.1290682013.git.zkabelac@redhat.com>
	<5aaa9a83ca612d4594736d7b7c34dcd5adc0a611.1290682013.git.zkabelac@redhat.com>
Message-ID: <4CEEEB09.5050508@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 25.11.2010 11:55, Zdenek Kabelac napsal(a):
> clangs is happier and check for non NULL options value.
> Report internal error in this case.
> 
> Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
> ---
>  tools/reporter.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/tools/reporter.c b/tools/reporter.c
> index 40d3c9a..16c19e2 100644
> --- a/tools/reporter.c
> +++ b/tools/reporter.c
> @@ -328,6 +328,10 @@ static int _report(struct cmd_context *cmd, int argc, char **argv,
>  			return EINVALID_CMD_LINE;
>  		}
>  		if (*opts == '+') {
> +			if (!options) {
> +				log_error(INTERNAL_ERROR "Missing options.");
> +				return EINVALID_CMD_LINE;
> +			}
>  			if (!(str = dm_pool_alloc(cmd->mem,
>  					 strlen(options) + strlen(opts) + 1))) {
>  				log_error("options string allocation failed");

Ok - here is 'smarter' way how to avoid NULL 'options' path:

It's more or less assert - but since we are not using asserts.

As with current code 'default:' could never be reached - so it doesn't put any
extra check into the original code path.

diff --git a/tools/reporter.c b/tools/reporter.c
index 40d3c9a..358c404 100644
--- a/tools/reporter.c
+++ b/tools/reporter.c
@@ -318,6 +318,9 @@ static int _report(struct cmd_context *cmd, int argc, char
**argv,
 						  "report/pvsegs_cols_verbose",
 						  DEFAULT_PVSEGS_COLS_VERB);
 		break;
+	default:
+		log_error(INTERNAL_ERROR "Unknown report type.");
+		return ECMD_FAILED;
 	}

 	/* If -o supplied use it, else use default for report_type */


