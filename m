From: David Teigland <teigland@redhat.com>
Date: Fri, 17 Oct 2014 10:37:57 -0500
Subject: [PATCH] pvchange: use process_each_pv
In-Reply-To: <5440C3D8.2080009@redhat.com>
References: <20141016214130.GA13251@redhat.com> <5440C3D8.2080009@redhat.com>
Message-ID: <20141017153757.GA18008@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 17, 2014 at 09:23:04AM +0200, Zdenek Kabelac wrote:
> Dne 16.10.2014 v 23:41 David Teigland napsal(a):
> >The summary output at the end has been removed.
> >A similar counter method could be added to the
> >various process_each functions if we want to
> >retain this sort of summary reporting.
> >
> >---
> >  tools/pvchange.c | 112 +++++++++++--------------------------------------------
> >  1 file changed, 22 insertions(+), 90 deletions(-)
> >
> >diff --git a/tools/pvchange.c b/tools/pvchange.c
> >index c2adc34309c5..e10da609f3c5 100644
> >--- a/tools/pvchange.c
> >+++ b/tools/pvchange.c
> >@@ -40,20 +40,20 @@ static int _pvchange_single(struct cmd_context *cmd, struct volume_group *vg,
> >  		if (tagargs && !(vg->fid->fmt->features & FMT_TAGS)) {
> >  			log_error("Volume group containing %s does not "
> >  				  "support tags", pv_name);
> >-			return 0;
> >+			return ECMD_FAILED;
> >  		}
> 
> 
> I'd prefer to not switch internal functions that are called after
> the VG is opened to anything else then 0/1 return code.
> 
> Logic is:
> 
> 
> When command starts - it validates options - any error detected
> before the VG is opened means  EINVALID_CMD_LINE == 3 return code
> (but if the error is result of i.e. failing memory alloc it should
> be ECMD_FAIL)
> 
> Once you open VG - error is always ECMD_FAIL since VG was needed to
> resolve it. We do not make any more differences on cmd return code -
> more info goes from error message.
> 
> So until we figure out reasonable good interface for error passing
> form library function for error reporting I'd keep any function to
> stay with
> 0 - error
> 1 - ok
> 
> Once we start mixing ECMD_PROCESSED == 0  with 0/1 functions
> we get into troubles  (I've already fixing these errors).

Returning 0/1 is not compatible with process_each, so I simply switched it
to the ECMD standard used by process_each.  The old 0/1 appears to be no
more than a method to count objects for the summary output.  Whether
process_each ought to change from ECMD to 0/1 is another question.


