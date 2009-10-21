From: Alasdair G Kergon <agk@redhat.com>
Date: Wed, 21 Oct 2009 13:51:47 +0100
Subject: [PATCH] Document --all option in man pages, cleanup lvdisplay/pvdisplay man page.
In-Reply-To: <1256097493-7756-1-git-send-email-dwysocha@redhat.com>
References: <4AD83740.5070704@redhat.com>
	<1256097493-7756-1-git-send-email-dwysocha@redhat.com>
Message-ID: <20091021125147.GA10165@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Oct 20, 2009 at 11:58:13PM -0400, Dave Wysochanski wrote:
>  lvdisplay \- display attributes of a logical volume

> +.B lvdisplay \-\-columns | \-C

Still doesn't match the --help text, which shows which arguments
go with which form of the command.

>  \fBlvs\fP (8) is an alternative that provides the same information 
>  in the style of \fBps\fP (1).  \fBlvs\fP is recommended over
> -\fBlvdisplay\fP.
> +\fBlvdisplay\fP.  \fBlvdisplay --columns\fP is the equivalent
> +of calling \fBlvs\fP.

Mention that under -C in the OPTIONS section.
"Calling X is the equivalent of calling Y" ('Running' or 'Executing'?)
or better, just "X is equivalent to Y".
  
>  .B lvs
> +[\-a|\-\-all]

> +Process all logical volumes, even hidden/internal ones.

Replace 'process' with a more descriptive verb based on what
'lvs' does.

Replace 'hidden/internal' with a better description of what
is meant.  I can spot no existing references to 'internal'
in this context in the man pages, and only one to 'implemented by
creating a hidden virtual device'.

Alasdair


