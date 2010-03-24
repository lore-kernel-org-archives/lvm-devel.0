From: Mike Snitzer <snitzer@redhat.com>
Date: Wed, 24 Mar 2010 09:07:37 -0400
Subject: [PATCH v2] improve activation monitoring option processing
In-Reply-To: <4BA9D905.9090107@redhat.com>
References: <1269372233-4199-1-git-send-email-snitzer@redhat.com>
	<4BA9D905.9090107@redhat.com>
Message-ID: <20100324130736.GA19258@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Wed, Mar 24 2010 at  5:19am -0400,
Milan Broz <mbroz@redhat.com> wrote:

> 
> 
> On 03/23/2010 08:23 PM, Mike Snitzer wrote:
> > Add "monitoring" option to "activation" section of lvm.conf
> >
> > Have clvmd consult the lvm.conf "activation/monitoring" too.
> please do it something like this... (untested)

OK, I already committed that other patch (got ack to do so).

Your patch looks good.  I had some doubts about checking lvm.conf like I
did in do_lock_query (but didn't explicitly share as much).

Mike


