From: Steven Dake <sdake@redhat.com>
Date: Sat, 18 Apr 2009 06:25:04 -0000
Subject: Re: [Pacemaker] recent stabilization changes to corosync and openais API/ABIs
In-Reply-To: <18921.27984.477185.552163@tutpro.com>
References: <1240034017.5808.135.camel@sdake-laptop>
	<18921.27984.477185.552163@tutpro.com>
Message-ID: <1240035888.5808.139.camel@sdake-laptop>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

NOn Sat, 2009-04-18 at 09:04 +0300, Juha Heinanen wrote:
> Steven Dake writes:
> 
>  > Some people on these lists may be interested to know what is happening
>  > with Corosync and OpenAIS ABIs as well as our schedules for 1.0.
> 
> what is corosync and how is it related to openais?  the figure on page
> 
> http://www.clusterlabs.org/wiki/Main_Page
> 
> does not contain a corosync box and the text has no reference to it.
> 
> -- juha

Many portions of openais were merged into Corosync including the parts
that Pacemaker depends on.  In the future, think of Pacemaker as running
against the Corosync engine instead.

Regards
-steve


