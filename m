From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 07 Jul 2009 16:32:44 -0400
Subject: [PATCH 0/2] error messages bound to command
In-Reply-To: <1246998001-17258-1-git-send-email-twoerner@redhat.com>
References: <1246998001-17258-1-git-send-email-twoerner@redhat.com>
Message-ID: <1246998764.10007.1.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, 2009-07-07 at 22:19 +0200, Thomas Woerner wrote:

> twoerner (2):
>   Add cmd logging for liblvm error reporting: All logging functions
>     have an additional argument: The error code This makes the
>     functions incompatible with the old ones.
>   Add error code for all log_err and log_error calls. Replace log_err
>     with log_error.
> 

Note: This second patch was 550k so I guess the mailing list choked on
that.  Not that interesting anyway - just script output really.


